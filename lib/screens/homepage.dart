import 'package:corousel_fe/widgets/curved_carousel.dart';
import 'package:corousel_fe/widgets/dod_card_back.dart';
import 'package:corousel_fe/widgets/dod_card_front.dart';
import 'package:corousel_fe/widgets/flying_item.dart';
import 'package:corousel_fe/widgets/item.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final List<CarouselItem> _items = List.generate(5, (index) {
    return CarouselItem(
      id: '${index + 1}',
      title: 'Item ${index + 1}',
      image: '',
      color: Colors.primaries[index % Colors.primaries.length],
    );
  });

  bool _isCartHandleMove = false;

  late PageController _pageController;
  late AnimationController _gapController;
  int _removedIndex = -1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.7,
    ); // Adjusted for taller aspect ratio
    _gapController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 600),
        )..addListener(() {
          setState(() {}); // Ensure smooth rebuilds during animation
        });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _gapController.dispose();
    super.dispose();
  }

  List<Widget> _flyingItems = [];
  final List<GlobalKey<FlyingItemState>> _flyingItemKeys = [];
  final GlobalKey<DodCardFrontState> _cartKey = GlobalKey<DodCardFrontState>();
  final GlobalKey<DodCardBackState> _cartBackKey = GlobalKey<DodCardBackState>();
  final Set<String> _hiddenItemIds = {};

  void _handlePullDown(CarouselItem item, double dragOffset) {
    final size = MediaQuery.of(context).size;
    final cardWidth =
        size.width *
        0.7; // Matches flying item width
    // Carousel height is 400. Card has vertical margin 20. So card height is 400 - 40 = 360.
    final cardHeight = 360.0;
    final startLeft = (size.width - cardWidth) / 2;
    // Top margin 20 + SizedBox 50 = 70.
    final startTop = 50.0 + 20.0 + dragOffset;

    // Target: Center bottom, peeking out 10%
    final endLeft = (size.width - cardWidth) / 2;
    // Card height 360. 10% is 36.
    // Cart top is size.height - 100.
    // Card top should be size.height - 100 - 36 = size.height - 136.
    final endTop = size.height - 185 + 10 * _flyingItems.length;
    // If I want 5% peeking out, it means 95% is hidden.
    // If the cart covers the bottom 100px.
    // And the card is 360px high.
    // If I put the card at `size.height - 100`, the top of the card aligns with cart top.
    // If I want 5% (18px) peeking out, I should put it at `size.height - 100 + 18`?
    // No, that pushes it down.
    // `size.height - 100 - 18` pushes it up (more visible).
    // Let's try aligning the top of the card with the cart top for now, maybe slightly up.

    // Wait, if the card is 360px tall, and I put it at `size.height - 100`,
    // the bottom 260px of the card are off screen?
    // The cart is 100px tall.
    // If I want it to look like it's IN the cart.
    // I should scale it down? "card becomes square... remove this".
    // User implies they don't want it to shrink to a tiny square.
    // I will keep the scale 1.0 or slightly smaller (0.8).

    // Get current page before removal
    final currentPage = _pageController.page?.round() ?? 0;

    setState(() {
      // Calculate rotation based on position in stack
      // 0th item: 0 degrees
      // 1st item: 2 degrees
      // 2nd item: -2 degrees
      // Pattern continues...
      double rotation;
      final index = _flyingItems.length;
      if (index == 0) {
        rotation = 0.0;
      } else if (index % 2 == 1) {
        rotation = 2 * 3.14159 / 180; // 2 degrees in radians
      } else {
        rotation = -2 * 3.14159 / 180; // -2 degrees in radians
      }

      // Create a GlobalKey for this flying item
      final flyingKey = GlobalKey<FlyingItemState>();
      _flyingItemKeys.add(flyingKey);

      // Start flying animation
      final flyingWidget = FlyingItem(
        key: flyingKey,
        item: item,
        startPosition: Offset(endLeft, endTop),
        // Cart height 100. Card height 360. 5% of 360 is 18.
        // We want top 18px visible above cart.
        // Cart top is size.height - 100.
        // Card top should be size.height - 100 - 18 = size.height - 118.
        endPosition: Offset(endLeft, endTop),
        targetRotation: rotation,
        onAnimationComplete: () {
          // Trigger bounce on all flying items and cart when this one completes
          for (final key in _flyingItemKeys) {
            key.currentState?.triggerBounce();
          }
          _cartKey.currentState?.triggerBounce();
          _cartBackKey.currentState?.triggerBounce();
        },
      );
      _flyingItems.add(flyingWidget);
      setState(() {
        _isCartHandleMove = true;
      });

      // Remove item from carousel immediately
      int indexToRemove = _items.indexOf(item);
      _removedIndex = indexToRemove;
      _items.remove(item);
      _hiddenItemIds.remove(item.id);

      // Start gap closing animation
      _gapController.forward(from: 0.0);
    });

    // Calculate target page immediately
    int targetPage = currentPage;
    if (_removedIndex < currentPage) {
      targetPage = currentPage - 1;
    }
    targetPage = targetPage.clamp(0, _items.length - 1);

    // Immediately jump to target page (updates _currentPage for verticalOffset)
    // This happens instantly, gap animation handles the visual transition
    if (_items.isNotEmpty && _pageController.hasClients) {
      _pageController.jumpToPage(targetPage);
    }

    // After gap animation completes, do a smooth micro-adjustment if needed
    Future.delayed(const Duration(milliseconds: 600), () {
      if (_items.isNotEmpty && _pageController.hasClients) {
        _pageController.animateToPage(
          targetPage,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _removeFlyingItem(String itemId) {
    _flyingItems.removeWhere((widget) {
      return (widget as FlyingItem).item.id == itemId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF001F3F), // Dark Blue
              Colors.black,
            ],
            stops: [0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            DodCardBack(
              key: _cartBackKey,
              cartItems: [],
              // onCartHandleMove: (value) {
              //   // setState(() => _isCartHandleMove = value);
              // },
              isCartHandleMove: _isCartHandleMove,
            ),
            ..._flyingItems,
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  SizedBox(
                    height: 400, // Reverted height
                    child: CurvedCarousel(
                      items: _items,
                      hiddenItems: _hiddenItemIds,
                      pageController: _pageController,
                      onPullDown: _handlePullDown,
                      gapAnimation: _gapController,
                      removedIndex: _removedIndex,
                      totalCountBeforeRemoval: _removedIndex != -1
                          ? _items.length + 1
                          : 0,
                    ),
                  ),
                  const Spacer(),
                  // Placeholder for spacing, actual cart is in Stack
                  const SizedBox(height: 100),
                ],
              ),
            ),
            
             DodCardFront(
              key: _cartKey,
              onCartHandleMove: (value) {
                setState(() => _isCartHandleMove = value);
              },
              isCartHandleMove: _isCartHandleMove,
            ),
            // Cart Overlay
            // Positioned(
            //   bottom: 0,
            //   left: 0,
            //   right: 0,
            //   child: Container(
            //     height: 100,
            //     color: Colors.black54,
            //     child: const Center(
            //       child: Text(
            //         'Cart Area',
            //         style: TextStyle(color: Colors.white),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

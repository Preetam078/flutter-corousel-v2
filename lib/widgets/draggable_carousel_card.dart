import 'package:corousel_fe/widgets/item.dart';
import 'package:flutter/material.dart';
import 'carousel_card.dart';

class DraggableCarouselCard extends StatefulWidget {
  final CarouselItem item;
  final Function(double) onPulledDown;
  final bool isCurrent; // Only allow dragging if it's the current item

  const DraggableCarouselCard({
    super.key,
    required this.item,
    required this.onPulledDown,
    this.isCurrent = false,
  });

  @override
  State<DraggableCarouselCard> createState() => _DraggableCarouselCardState();
}

class _DraggableCarouselCardState extends State<DraggableCarouselCard>
    with SingleTickerProviderStateMixin {
  double _dragOffset = 0.0;
  late AnimationController _resetController;
  late Animation<double> _resetAnimation;

  @override
  void initState() {
    super.initState();
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _resetController.dispose();
    super.dispose();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!widget.isCurrent) return;
    
    // Only allow dragging down
    if (details.delta.dy > 0 || _dragOffset > 0) {
      setState(() {
        _dragOffset += details.delta.dy;
      });
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!widget.isCurrent) return;

    if (_dragOffset > 150) {
      // Trigger pull down action
      widget.onPulledDown(_dragOffset);
      // We might want to keep it down or reset it depending on what happens next.
      // For now, let's reset it visually but the parent should handle the removal.
      // But if we reset immediately it looks glitchy. 
      // The parent will likely remove this card from the tree.
    } else {
      // Snap back
      _resetAnimation = Tween<double>(begin: _dragOffset, end: 0.0).animate(
        CurvedAnimation(parent: _resetController, curve: Curves.easeOut),
      );
      _resetController.forward(from: 0.0);
      _resetController.addListener(() {
        setState(() {
          _dragOffset = _resetAnimation.value;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: _handleDragUpdate,
      onVerticalDragEnd: _handleDragEnd,
      child: Transform.translate(
        offset: Offset(0, _dragOffset),
        child: CarouselCard(item: widget.item),
      ),
    );
  }
}

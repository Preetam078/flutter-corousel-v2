import 'package:corousel_fe/models/onboard_card.dart';
import 'package:corousel_fe/widgets/onboard_card.dart';
import 'package:flutter/material.dart';

class DraggableOnboardCard extends StatefulWidget {
  final OnboardCardData data;
  final Function(double) onPulledDown;
  final bool isCurrent; // Only allow dragging if it's the current item

  const DraggableOnboardCard({
    super.key,
    required this.data,
    required this.onPulledDown,
    this.isCurrent = true, // Default to true for onboard cards
  });

  @override
  State<DraggableOnboardCard> createState() => _DraggableOnboardCardState();
}

class _DraggableOnboardCardState extends State<DraggableOnboardCard>
    with SingleTickerProviderStateMixin {
  double _dragOffset = 0.0;
  late AnimationController _resetController;
  late Animation<double> _resetAnimation;
  bool _isAutoAnimating = false;

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
    if (!widget.isCurrent || _isAutoAnimating) return;
    
    // Check if delta exceeds threshold for auto-drag
    if (details.delta.dy > 100) {
      _triggerAutoDrag();
      return;
    }
    
    // Only allow dragging down
    if (details.delta.dy > 0 || _dragOffset > 0) {
      setState(() {
        _dragOffset += details.delta.dy;
      });
    }
  }

  void _triggerAutoDrag() {
    final size = MediaQuery.of(context).size;
    final targetOffset = size.height - 186;
    
    _isAutoAnimating = true;
    
    _resetAnimation = Tween<double>(begin: _dragOffset, end: targetOffset).animate(
      CurvedAnimation(parent: _resetController, curve: Curves.easeOut),
    );
    
    _resetController.forward(from: 0.0).then((_) {
      widget.onPulledDown(targetOffset);
      _isAutoAnimating = false;
    });
    
    _resetController.addListener(() {
      setState(() {
        _dragOffset = _resetAnimation.value;
      });
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!widget.isCurrent || _isAutoAnimating) return;
    
    final size = MediaQuery.of(context).size;

    if (_dragOffset > size.height - 185) {
      // Trigger pull down action
      widget.onPulledDown(_dragOffset);
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
        child: OnboardCard(data: widget.data),
      ),
    );
  }
}

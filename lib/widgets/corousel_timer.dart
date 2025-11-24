import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui';

class CarouselTimer extends StatefulWidget {
  final Duration duration;
  final VoidCallback? onTimerComplete;
  final ValueChanged<bool>? onUrgentStateChanged;
  final Color? borderColor;
  final Color? textColor;
  final Color? backgroundColor;

  const CarouselTimer({
    super.key,
    required this.duration,
    this.onTimerComplete,
    this.onUrgentStateChanged,
    this.borderColor,
    this.textColor,
    this.backgroundColor,
  });

  @override
  State<CarouselTimer> createState() => _CarouselTimerState();
}

class _CarouselTimerState extends State<CarouselTimer> {
  late Duration _remainingTime;
  Timer? _timer;
  bool _isUrgent = false;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.duration;
    _isUrgent = _remainingTime.inSeconds <= 60;
    // Notify initial state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onUrgentStateChanged?.call(_isUrgent);
    });
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds <= 0) {
        timer.cancel();
        widget.onTimerComplete?.call();
      } else {
        final newRemainingTime = Duration(seconds: _remainingTime.inSeconds - 1);
        final wasUrgent = _isUrgent;
        final isNowUrgent = newRemainingTime.inSeconds <= 60;
        
        setState(() {
          _remainingTime = newRemainingTime;
          _isUrgent = isNowUrgent;
        });
        
        // Notify if urgent state changed
        if (wasUrgent != isNowUrgent) {
          widget.onUrgentStateChanged?.call(isNowUrgent);
        }
      }
    });
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if 1 minute or less remaining
    final bool isUrgent = _remainingTime.inSeconds <= 60;
    
    // Define colors based on urgency
    final Color displayBorderColor = isUrgent 
        ? const Color(0xFFD94A3D) // Red border
        : (widget.borderColor ?? const Color(0xFF4A6B8A));
    
    final Color displayTextColor = isUrgent
        ? const Color(0xFFFF6B5A) // Orange-red text
        : (widget.textColor ?? Colors.white);
    
    final Color displayBackgroundColor = isUrgent
        ? const Color(0xFF4A1F1F).withOpacity(0.3) // Dark red background
        : (widget.backgroundColor ?? Colors.white.withOpacity(0.1));

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
          decoration: BoxDecoration(
            color: displayBackgroundColor,
            border: Border.all(
              color: displayBorderColor,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            style: TextStyle(
              color: displayTextColor,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
              fontFeatures: const [
                FontFeature.tabularFigures(), // Ensures monospaced numbers
              ],
            ),
            child: Text(_formatTime(_remainingTime)),
          ),
        ),
      ),
    );
  }
}

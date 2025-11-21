import 'package:flutter/material.dart';

class CarouselItem {
  final String id;
  final String title;
  final String image; // Asset path or URL
  final Color color;

  const CarouselItem({
    required this.id,
    required this.title,
    required this.image,
    required this.color,
  });
}

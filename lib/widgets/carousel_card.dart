import 'package:corousel_fe/widgets/item.dart';
import 'package:flutter/material.dart';

class CarouselCard extends StatelessWidget {
  final CarouselItem item;

  const CarouselCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFB5DDFF), // Light blue
              Color(0xFFFFFFFF), // Purple-blue
            ],
            stops: [0.1, 1.0],
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  Positioned(
                    top: 0,
                    right: 0,
                    left: 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(3),
                          bottomRight: Radius.circular(3),
                        ),
                        color: Color(0xFFFF4A75),
                      ),
                      child: Text(
                        "ONLY 2 LEFT".toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Image.asset(
                      'lib/image/sample.png',
                      width: 140,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: Text(
                      "View Details".toUpperCase(),
                      style: TextStyle(
                        color: Color(0xFF3F6FD9),
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0xFF3F6FD9),
                        height: 1.5,
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 10),
              child: Text(
                      "Hubberholme".toUpperCase(),
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
            ),
            Container(
              margin: EdgeInsets.only(top: 4),
              width: 150,
              child: Text(
                "beige and linen formal look",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  height: 1.2,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "₹3,000",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    "₹5,499",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: Colors.grey,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    "20% off",
                    style: TextStyle(
                      color: Color(0xFF4CAF50),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:corousel_fe/models/onboard_card.dart';

class OnboardCard extends StatelessWidget {
  final OnboardCardData data;

  const OnboardCard({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: Container(
        width: screenWidth * 0.6, // Match the carousel viewportFraction
        height:
            360, // Match carousel height (400) minus vertical margins (20 top + 20 bottom)
        margin: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: AssetImage(data.imageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.0),
                          Colors.black.withOpacity(0.4),
                          Colors.transparent,
                        ],
                        stops: [0.0, 0.3, 2.0],
                      ),
                    ),
                    child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          data.participants.toString(),
                          style: TextStyle(
                            color: Color(0xFFD0FF58),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 4),
                          child: Text(
                            "Others Joined".toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 6),
                      child: Text(
                        data.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                      ),
                    ),
                    Container(
                      width: 200,
                      margin: EdgeInsets.only(top: 6),
                      child: Text(
                        data.description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
          ],
        ),
      ),
    );
  }
}

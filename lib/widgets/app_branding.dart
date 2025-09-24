import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppBranding extends StatelessWidget {
  final Color? backgroundColor;
  final double? height;

  const AppBranding({
    super.key,
    this.backgroundColor,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            backgroundColor ?? Colors.blue[700]!,
            backgroundColor?.withOpacity(0.8) ?? Colors.blue[500]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: SvgPicture.asset(
                  'assets/applogo.svg',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  placeholderBuilder: (context) => Icon(
                      Icons.health_and_safety,
                      color: backgroundColor ?? Colors.blue[700],
                      size: 30,
                    ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Health',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'Digital Health Records Management',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
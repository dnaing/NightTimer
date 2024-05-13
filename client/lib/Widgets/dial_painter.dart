import 'package:flutter/material.dart';
import 'dart:math';

class CustomDial extends StatefulWidget {
  const CustomDial({super.key});

  @override
  State<CustomDial> createState() => _CustomDialState();
}

class _CustomDialState extends State<CustomDial> {

  int minutes = 0;
  double canvasWidth = 400;
  double canvasHeight = 400;
  late double dialDotCenterX;
  late double dialDotCenterY;
  double dialDotRadius = 18;
  late double dialRadius;

  _CustomDialState() {
    dialRadius = min(canvasWidth, canvasHeight) / 2.5;
    dialDotCenterX = canvasWidth / 2;
    dialDotCenterY = (canvasHeight / 2) - dialRadius;
    dialDotRadius *= 10;
  }

  bool isWithinDialDot(Offset localPosition) {

    Offset dialDotCenterPosition = Offset(dialDotCenterX, dialDotCenterY);
    double distance = (localPosition - dialDotCenterPosition).distance;
    return distance <= dialDotRadius;
  }

  void updateDialDot(DragUpdateDetails details) {
    // Set dial to local position but only if local position is on dial circumference
    Offset dialCenter = Offset(canvasWidth / 2, canvasHeight / 2);
    Offset dialVector = details.localPosition - dialCenter; // This tells a vector (x,y) of how to reach local position from center
    double distance = dialVector.distance; // This gets the distance between center of dial and our local position
    Offset normalizedDialVector = dialVector / distance; // Dividing these two normalizes our vector so x and y are both between 0 and 1
    Offset adjustedDialVector = normalizedDialVector * dialRadius;
    setState(() {
      dialDotCenterX = dialCenter.dx + adjustedDialVector.dx;
      dialDotCenterY = dialCenter.dy + adjustedDialVector.dy;
    });

  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: SizedBox(
        child: GestureDetector(
          onPanUpdate: (DragUpdateDetails details) {
            if (isWithinDialDot(details.localPosition)) {
              updateDialDot(details);
            }   
          },
          child: CustomPaint(
            painter: DialPainter(minutes, dialDotCenterX, dialDotCenterY),
            size: Size(canvasWidth, canvasHeight)
          )
        ),
      ),
    );
  }
}


class DialPainter extends CustomPainter {

  int minutes;
  double dialDotCenterX;
  double dialDotCenterY;
  DialPainter(this.minutes, this.dialDotCenterX, this.dialDotCenterY);

  @override
    void paint(Canvas canvas, Size size) {

      final dialCenter = Offset(size.width / 2, size.height / 2); // Center of dial
      final radius = min(size.width, size.height) / 2.5; // Radius of dial

      // Offset dialDotCenter = Offset(size.width / 2, (size.height / 2) - radius); // Center of dial dot
      Offset dialDotCenter = Offset(dialDotCenterX, dialDotCenterY);
      Paint myPaint;

      // Draw the dial outline
      myPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7;
      canvas.drawCircle(
        dialCenter, 
        radius, 
        myPaint
      );

      // Draw the dial controller dot
      myPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill
        ..strokeWidth = 5;
      canvas.drawCircle(
        dialDotCenter,
        18,
        myPaint
      );

      // Draw text inside the dial
      TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: minutes.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 80,
            fontWeight: FontWeight.bold,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      Offset textOffset = Offset(dialCenter.dx - textPainter.width / 2, dialCenter.dy - textPainter.height / 2);
      textPainter.paint(canvas, textOffset);

    }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
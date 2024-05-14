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

  double dialDotOriginX = 200;
  double dialDotOriginY = 40;
  late double dialDotCenterX;
  late double dialDotCenterY;
  double dialDotRadius = 18;

  late double dialRadius; 

  Set<List<double>> clockIncrements = {};
  int currentTick = 0;

  _CustomDialState() {
    dialRadius = min(canvasWidth, canvasHeight) / 2.5; // 160
    dialDotCenterX = canvasWidth / 2;
    dialDotCenterY = (canvasHeight / 2) - dialRadius;
    dialDotRadius *= 10;
    

    double angle = 0;
    for (int i = 0; i < 60; i++) {
      List<double> curIncrement = [200 + (dialRadius * cos(angle * (pi / 180))), 200 + (dialRadius * sin(angle * (pi / 180)))];
      clockIncrements.add(curIncrement);
      angle += 6;
    }
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
      
      // Dial not allowed to move counterclockwise at <= 0 minutes
      if (minutes <= 0 && adjustedDialVector.dx < 0) {
        dialDotCenterX = dialDotOriginX;
        dialDotCenterY = dialDotOriginY;
      } else {
        dialDotCenterX = dialCenter.dx + adjustedDialVector.dx;
        dialDotCenterY = dialCenter.dy + adjustedDialVector.dy;
      }
      
      updateTick(dialDotCenterX, dialDotCenterY, dialCenter.dx, dialCenter.dy);
    });

  }

  void updateTick(double dialDotCenterX, double dialDotCenterY, double dialCenterX, double dialCenterY) {
      double angleInDegrees = (atan2(dialDotCenterY - dialCenterY, dialDotCenterX - dialCenterX)) * (180 / pi);
      double normalizedAngle = (angleInDegrees - 270) % 360;


      int newTick = normalizedAngle ~/ 6;

      if (newTick != currentTick) {
        if (currentTick == 59 && newTick == 0) {
          minutes += 1;
        } else if (currentTick == 0 && newTick == 59) {
          minutes -= 1;
        } else if (newTick > currentTick) {
          minutes += newTick - currentTick;
        } else {
          minutes -= (currentTick - newTick + 60) % 60;
        }
        currentTick = newTick;

      }

  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: SizedBox(
        child: GestureDetector(
          onPanStart: (DragStartDetails details) {
            // print([details.localPosition.dx, details.localPosition.dy]);
          },
          onPanUpdate: (DragUpdateDetails details) {
            if (isWithinDialDot(details.localPosition)) {
              updateDialDot(details);
            }   
          },
          child: CustomPaint(
            painter: DialPainter(minutes, dialDotCenterX, dialDotCenterY, clockIncrements),
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
  Set<List<double>> clockIncrements;
  DialPainter(this.minutes, this.dialDotCenterX, this.dialDotCenterY, this.clockIncrements);
  

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

      for (final increment in clockIncrements) {
        canvas.drawCircle(
          Offset(increment.elementAt(0), increment.elementAt(1)),
          5,
          myPaint
        );
      }



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
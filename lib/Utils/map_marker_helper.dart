import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapMarkerHelper {
  /// Generates a sleek, modern compact bitmap marker with icon and label (e.g. "Driver", "Customer", "Store")
  static Future<BitmapDescriptor> createLabeledMarker({
    required String label,
    required IconData icon,
    required Color primaryColor,
    required Color textColor,
    Color badgeColor = Colors.white,
  }) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    // Sleek compact dimensions matching standard Foodpanda / Uber map chips
    const double width = 136.0;
    const double height = 54.0;
    const double pillHeight = 36.0;
    const double radius = 14.0;
    const double tailHeight = 10.0;
    const double tailHalfWidth = 7.0;

    // 1. Drop Shadow
    final Path shadowPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(4, 3, width - 8, pillHeight),
          const Radius.circular(radius),
        ),
      );
    canvas.drawShadow(shadowPath, Colors.black, 4.0, true);

    // 2. Pill Background
    final Paint bgPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    final RRect pillRRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(4, 2, width - 8, pillHeight),
      const Radius.circular(radius),
    );
    canvas.drawRRect(pillRRect, bgPaint);

    // 3. Crisp White Border
    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(pillRRect, borderPaint);

    // 4. Pin Tail (Downward pointer)
    final Path pointerPath = Path();
    pointerPath.moveTo((width / 2) - tailHalfWidth, 2 + pillHeight);
    pointerPath.lineTo(width / 2, 2 + pillHeight + tailHeight);
    pointerPath.lineTo((width / 2) + tailHalfWidth, 2 + pillHeight);
    pointerPath.close();
    canvas.drawPath(pointerPath, bgPaint);

    final Path pointerBorder = Path();
    pointerBorder.moveTo((width / 2) - tailHalfWidth, 2 + pillHeight);
    pointerBorder.lineTo(width / 2, 2 + pillHeight + tailHeight);
    pointerBorder.lineTo((width / 2) + tailHalfWidth, 2 + pillHeight);
    canvas.drawPath(pointerBorder, borderPaint);

    // 5. Left Circular Icon Badge
    const double iconBadgeSize = 24.0;
    final Paint iconBadgePaint = Paint()
      ..color = badgeColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      const Offset(4 + 6 + iconBadgeSize / 2, 2 + pillHeight / 2),
      iconBadgeSize / 2,
      iconBadgePaint,
    );

    // 6. Draw Icon
    final TextPainter iconPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    iconPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: 14.0,
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        color: primaryColor,
      ),
    );
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset(
        4 + 6 + (iconBadgeSize - iconPainter.width) / 2,
        2 + (pillHeight - iconPainter.height) / 2,
      ),
    );

    // 7. Draw Label Text
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );
    textPainter.text = TextSpan(
      text: label,
      style: TextStyle(
        fontSize: 12.0,
        fontWeight: FontWeight.w800,
        color: textColor,
        letterSpacing: 0.3,
      ),
    );
    textPainter.layout(maxWidth: width - 42);
    textPainter.paint(
      canvas,
      Offset(
        4 + 6 + iconBadgeSize + 6,
        2 + (pillHeight - textPainter.height) / 2,
      ),
    );

    final ui.Image image = await pictureRecorder.endRecording().toImage(
      width.toInt(),
      height.toInt(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    return BitmapDescriptor.bytes(bytes);
  }

  /// Generates a sleek, modern compact circular pin icon (Zero text, small clean circle with pin pointer)
  static Future<BitmapDescriptor> createCircularMarker({
    required IconData icon,
    required Color primaryColor,
    Color iconColor = Colors.white,
    double diameter = 48.0,
  }) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final double width = diameter;
    final double height = diameter + 8.0;
    final double radius = diameter / 2;

    // 1. Drop Shadow
    final Path shadowPath = Path()
      ..addOval(Rect.fromCircle(center: Offset(radius, radius + 2), radius: radius - 2));
    canvas.drawShadow(shadowPath, Colors.black, 4.0, true);

    // 2. White Outer Border
    final Paint rimPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(radius, radius), radius, rimPaint);

    // 3. Inner Colored Circle
    final Paint bgPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(radius, radius), radius - 3.0, bgPaint);

    // 4. Downward Pin Pointer / Tail
    final Path pointerPath = Path();
    pointerPath.moveTo(radius - 5, diameter - 3);
    pointerPath.lineTo(radius, height);
    pointerPath.lineTo(radius + 5, diameter - 3);
    pointerPath.close();
    canvas.drawPath(pointerPath, bgPaint);

    final Paint pointerBorder = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(pointerPath, pointerBorder);

    // 5. Draw Icon in Center
    final TextPainter iconPainter = TextPainter(textDirection: TextDirection.ltr);
    iconPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: diameter * 0.46,
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        color: iconColor,
      ),
    );
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset(
        radius - (iconPainter.width / 2),
        radius - (iconPainter.height / 2),
      ),
    );

    final ui.Image image = await pictureRecorder.endRecording().toImage(
      width.toInt(),
      height.toInt(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    return BitmapDescriptor.bytes(bytes);
  }
}

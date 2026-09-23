import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapMarkerHelper {
  /// Generates a customized bitmap marker with an icon, pill background, and text label (e.g. "Driver", "Customer")
  static Future<BitmapDescriptor> createLabeledMarker({
    required String label,
    required IconData icon,
    required Color primaryColor,
    required Color textColor,
    Color badgeColor = Colors.white,
  }) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    const double width = 280.0;
    const double height = 110.0;
    const double pillHeight = 70.0;
    const double radius = 24.0;

    // Outer shadow
    final Path shadowPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(8, 6, width - 16, pillHeight),
          const Radius.circular(radius),
        ),
      );
    canvas.drawShadow(shadowPath, Colors.black, 8.0, true);

    // Pill background
    final Paint bgPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    final RRect pillRRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(8, 4, width - 16, pillHeight),
      const Radius.circular(radius),
    );
    canvas.drawRRect(pillRRect, bgPaint);

    // Pill Border
    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(pillRRect, borderPaint);

    // Pin tail (pointing downward)
    final Path pointerPath = Path();
    pointerPath.moveTo((width / 2) - 18, 4 + pillHeight);
    pointerPath.lineTo(width / 2, 4 + pillHeight + 20);
    pointerPath.lineTo((width / 2) + 18, 4 + pillHeight);
    pointerPath.close();
    canvas.drawPath(pointerPath, bgPaint);

    // Tail border
    final Path pointerBorder = Path();
    pointerBorder.moveTo((width / 2) - 18, 4 + pillHeight);
    pointerBorder.lineTo(width / 2, 4 + pillHeight + 20);
    pointerBorder.lineTo((width / 2) + 18, 4 + pillHeight);
    canvas.drawPath(pointerBorder, borderPaint);

    // Circular icon badge on the left
    const double iconBadgeSize = 46.0;
    final Paint iconBadgePaint = Paint()
      ..color = badgeColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      const Offset(8 + 12 + iconBadgeSize / 2, 4 + pillHeight / 2),
      iconBadgeSize / 2,
      iconBadgePaint,
    );

    // Draw Icon inside the circle
    final TextPainter iconPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    iconPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: 26.0,
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        color: primaryColor,
      ),
    );
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset(
        8 + 12 + (iconBadgeSize - iconPainter.width) / 2,
        4 + (pillHeight - iconPainter.height) / 2,
      ),
    );

    // Draw Label Text
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );
    textPainter.text = TextSpan(
      text: label,
      style: TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.w900,
        color: textColor,
        letterSpacing: 0.5,
      ),
    );
    textPainter.layout(maxWidth: width - 85);
    textPainter.paint(
      canvas,
      Offset(
        8 + 12 + iconBadgeSize + 14,
        4 + (pillHeight - textPainter.height) / 2,
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

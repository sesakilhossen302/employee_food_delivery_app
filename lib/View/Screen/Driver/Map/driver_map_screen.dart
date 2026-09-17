import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../../../Utils/AppColors/app_colors.dart';
import '../Controller/driver_controller.dart';

class DriverMapScreen extends StatelessWidget {
  const DriverMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DriverController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Stack(
          children: [
            /// 1. Map Canvas
            Positioned.fill(
              child: Container(
                color: const Color(0xFFF0FDF4),
                child: CustomPaint(
                  painter: _DriverMapPainter(),
                ),
              ),
            ),

            /// 2. Top Navigation Banner
            Positioned(
              top: 16.h,
              left: 16.w,
              right: 16.w,
              child: Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        color: AppColors.primaryAmber,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: const Center(
                        child: Icon(Icons.turn_right_rounded, color: Colors.white, size: 28),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Turn right onto Maple St',
                            style: GoogleFonts.inter(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'In 200m · Customer on left side',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// 3. Bottom Delivery ETA & Actions Card
            Positioned(
              bottom: 16.h,
              left: 16.w,
              right: 16.w,
              child: Obx(() {
                final order = controller.activeOrder.value;
                if (order == null) {
                  return Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Center(
                      child: Text('No active delivery route right now', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    ),
                  );
                }

                return Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '8 mins (3.2 km)',
                                style: GoogleFonts.inter(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF10B981),
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                order.deliveryAddress,
                                style: GoogleFonts.inter(fontSize: 12.sp, color: const Color(0xFF6B7280)),
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Text(
                              'Collect: \$${order.totalCashToCollect.toStringAsFixed(2)}',
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFD97706),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 14.h),
                      SizedBox(
                        width: double.infinity,
                        height: 46.h,
                        child: ElevatedButton(
                          onPressed: () => controller.markArrived(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryAmber,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          ),
                          child: Text(
                            'Arrived at Destination',
                            style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _DriverMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = const Color(0xFFE2F4E8)
      ..style = PaintingStyle.fill;

    // Draw blocks
    for (int i = 0; i < 5; i++) {
      for (int j = 0; j < 7; j++) {
        final rect = Rect.fromLTWH(
          i * (size.width / 4.5) + 6,
          j * (size.height / 6.5) + 6,
          (size.width / 4.5) - 12,
          (size.height / 6.5) - 12,
        );
        canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), roadPaint);
      }
    }

    // Draw Route
    final routePaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width * 0.25, size.height * 0.65);
    path.lineTo(size.width * 0.50, size.height * 0.65);
    path.lineTo(size.width * 0.50, size.height * 0.35);
    path.lineTo(size.width * 0.75, size.height * 0.35);
    path.lineTo(size.width * 0.75, size.height * 0.45);

    canvas.drawPath(path, routePaint);

    // Origin (Store)
    canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.65), 10, Paint()..color = const Color(0xFF111827));
    // Destination (Customer)
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.45), 12, Paint()..color = const Color(0xFFF59E0B));
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.45), 6, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

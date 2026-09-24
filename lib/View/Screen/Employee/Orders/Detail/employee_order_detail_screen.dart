import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import '../../../../../Utils/AppColors/app_colors.dart';
import '../Model/employee_order_models.dart';
import '../Tracking/live_order_tracking_screen.dart';

class EmployeeOrderDetailScreen extends StatelessWidget {
  final OrderModel order;

  const EmployeeOrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            /// 1. Top App Bar
            _buildAppBar(),

            /// 2. Scrollable Body
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Mini Map Graphic (Shown for active deliveries like #ORD-1001)
                    if (order.isDelivery) ...[
                      _buildMiniMapWidget(),
                      SizedBox(height: 16.h),
                    ],

                    /// Order Progress Stepper Card
                    _buildOrderProgressCard(),
                    SizedBox(height: 16.h),

                    /// Delivering to Card (if Delivery)
                    if (order.isDelivery) ...[
                      _buildDeliveringToCard(),
                      SizedBox(height: 16.h),
                    ],

                    /// Estimated Arrival Card
                    _buildEstimatedArrivalCard(),
                    SizedBox(height: 16.h),

                    /// Items Ordered Card
                    _buildItemsOrderedCard(),
                    SizedBox(height: 16.h),

                    /// Payment Summary Card
                    _buildPaymentSummaryCard(),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// --------------------------------------------------------------------------
  /// APP BAR
  /// --------------------------------------------------------------------------
  Widget _buildAppBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 38.w,
                  height: 38.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.chevron_left_rounded,
                      size: 24,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.id,
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Thu, ${order.date}',
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ],
          ),

          /// Status Pill
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: order.statusBgColor,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6.w,
                  height: 6.w,
                  decoration: BoxDecoration(
                    color: order.statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  order.statusText,
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: order.statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// --------------------------------------------------------------------------
  /// MINI MAP WIDGET (Image 2)
  /// --------------------------------------------------------------------------
  Widget _buildMiniMapWidget() {
    final custLoc = LatLng(
      order.customerLat ?? 23.8103,
      order.customerLng ?? 90.4125,
    );

    final bool isOutForDelivery = order.status == OrderStatus.outForDelivery;

    final miniMarkers = <Marker>{
      Marker(
        markerId: const MarkerId('mini_cust'),
        position: custLoc,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: InfoWindow(title: 'Delivery Address', snippet: order.deliveryAddress),
      ),
    };

    return GestureDetector(
      onTap: () => Get.to(() => LiveOrderTrackingScreen(order: order)),
      child: Container(
        width: double.infinity,
        height: 200.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: Stack(
            children: [
              /// Google Map preview centered on customer location
              Positioned.fill(
                child: AbsorbPointer(
                  absorbing: true,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: custLoc,
                      zoom: 15.0,
                    ),
                    markers: miniMarkers,
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                    compassEnabled: false,
                    mapToolbarEnabled: false,
                  ),
                ),
              ),

              /// Dynamic status floating pill
              Positioned(
                top: 14.h,
                right: 16.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: isOutForDelivery ? AppColors.primaryAmber : const Color(0xFF1E3A8A),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: (isOutForDelivery ? AppColors.primaryAmber : const Color(0xFF1E3A8A)).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isOutForDelivery ? Icons.local_shipping_rounded : Icons.schedule_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        isOutForDelivery ? 'On the way' : order.statusText,
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// Bottom "Track Live on Google Map" Bar
              Positioned(
                left: 12.w,
                right: 12.w,
                bottom: 10.h,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111827),
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: BoxDecoration(
                              color: isOutForDelivery ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            isOutForDelivery
                                ? 'Live Driver GPS (5s Sync)'
                                : 'Waiting for Driver Assignment',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'Track Live',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryAmber,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 16,
                            color: AppColors.primaryAmber,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// --------------------------------------------------------------------------
  /// ORDER PROGRESS STEPPER CARD (Images 2, 3, 4, 5)
  /// --------------------------------------------------------------------------
  Widget _buildOrderProgressCard() {
    final steps = [
      'Order Received',
      'Confirmed',
      'Preparing',
      order.isDelivery ? 'Ready for Driver' : 'Ready for Pickup',
      if (order.isDelivery) 'Out for Delivery',
      'Delivered',
    ];

    int activeIndex = 0;
    switch (order.status) {
      case OrderStatus.orderReceived:
        activeIndex = 0;
        break;
      case OrderStatus.confirmed:
        activeIndex = 1;
        break;
      case OrderStatus.preparing:
        activeIndex = 2;
        break;
      case OrderStatus.readyForDriver:
        activeIndex = 3;
        break;
      case OrderStatus.outForDelivery:
        activeIndex = 4;
        break;
      case OrderStatus.delivered:
        activeIndex = steps.length - 1;
        break;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Progress',
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            ),
          ),
          SizedBox(height: 16.h),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: steps.length,
            itemBuilder: (context, index) {
              final isPassed = index < activeIndex;
              final isCurrent = index == activeIndex;
              final isLast = index == steps.length - 1;

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Stepper Icon & Connecting Line
                    Column(
                      children: [
                        if (isPassed)
                          Container(
                            width: 22.w,
                            height: 22.w,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryAmber,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(Icons.check, size: 14, color: Colors.white),
                            ),
                          )
                        else if (isCurrent)
                          Container(
                            width: 22.w,
                            height: 22.w,
                            decoration: BoxDecoration(
                              color: order.status == OrderStatus.orderReceived
                                  ? const Color(0xFF6B7280)
                                  : AppColors.primaryAmber,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Container(
                                width: 8.w,
                                height: 8.w,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          )
                        else
                          Container(
                            width: 22.w,
                            height: 22.w,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF3F4F6),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Container(
                                width: 6.w,
                                height: 6.w,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFD1D5DB),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),

                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2.w,
                              color: isPassed ? AppColors.primaryAmber : const Color(0xFFE5E7EB),
                              margin: EdgeInsets.symmetric(vertical: 4.h),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(width: 14.w),

                    /// Step Title & Subtitle
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: isLast ? 0 : 20.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              steps[index],
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: (isPassed || isCurrent)
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: (isPassed || isCurrent)
                                    ? const Color(0xFF111827)
                                    : const Color(0xFF9CA3AF),
                              ),
                            ),
                            if (isCurrent) ...[
                              SizedBox(height: 2.h),
                              Text(
                                'In progress',
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: order.status == OrderStatus.orderReceived
                                      ? const Color(0xFF6B7280)
                                      : AppColors.primaryAmber,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// --------------------------------------------------------------------------
  /// DELIVERING TO CARD
  /// --------------------------------------------------------------------------
  Widget _buildDeliveringToCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: const Center(
              child: Icon(Icons.location_on_outlined, color: Color(0xFFD97706), size: 20),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivering to',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  order.deliveryAddress,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'Note: ${order.deliveryNote}',
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
    );
  }

  /// --------------------------------------------------------------------------
  /// ESTIMATED ARRIVAL CARD
  /// --------------------------------------------------------------------------
  Widget _buildEstimatedArrivalCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        children: [
          Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: const Center(
              child: Icon(Icons.access_time_rounded, color: Color(0xFFD97706), size: 20),
            ),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Estimated arrival',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Text(
                    order.estimatedTime.replaceFirst('Est. ', ''),
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    '(${order.estimatedRange})',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// --------------------------------------------------------------------------
  /// ITEMS ORDERED CARD
  /// --------------------------------------------------------------------------
  Widget _buildItemsOrderedCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Items Ordered',
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            ),
          ),
          SizedBox(height: 14.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order.items.length,
            separatorBuilder: (context, index) => Divider(height: 20.h, color: const Color(0xFFF3F4F6)),
            itemBuilder: (context, index) {
              final item = order.items[index];

              return Row(
                children: [
                  Container(
                    width: 54.w,
                    height: 54.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: const Color(0xFFE5E7EB), width: 0.8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: item.imageUrl.isNotEmpty
                          ? Image.network(
                              item.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: const Color(0xFFFEF3C7),
                                  child: const Center(
                                    child: Icon(Icons.fastfood_rounded, size: 24, color: AppColors.primaryAmber),
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: const Color(0xFFFEF3C7),
                              child: const Center(
                                child: Icon(Icons.fastfood_rounded, size: 24, color: AppColors.primaryAmber),
                              ),
                            ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF111827),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Qty: ${item.qty}',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\$${item.price.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// --------------------------------------------------------------------------
  /// PAYMENT SUMMARY CARD
  /// --------------------------------------------------------------------------
  Widget _buildPaymentSummaryCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Summary',
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            ),
          ),
          SizedBox(height: 14.h),
          _buildSummaryRow('Subtotal', '\$${order.subtotal.toStringAsFixed(2)}'),
          SizedBox(height: 10.h),
          _buildSummaryRow('Tax', '\$${order.tax.toStringAsFixed(2)}'),
          if (order.isDelivery) ...[
            SizedBox(height: 10.h),
            _buildSummaryRow('Delivery fee', '\$${order.deliveryFee.toStringAsFixed(2)}'),
          ],
          if (order.tip > 0) ...[
            SizedBox(height: 10.h),
            _buildSummaryRow('Tip', '\$${order.tip.toStringAsFixed(2)}'),
          ],
          Divider(height: 22.h, color: const Color(0xFFF3F4F6)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                ),
              ),
              Text(
                '\$${order.total.toStringAsFixed(2)}',
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryAmber,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            order.paymentMethod,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 13.sp, color: const Color(0xFF6B7280)),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF111827),
          ),
        ),
      ],
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import '../../../../Utils/AppColors/app_colors.dart';
import '../../../../Utils/map_marker_helper.dart';
import '../../../../service/route_service.dart';
import '../Controller/driver_controller.dart';

class DriverMapScreen extends StatefulWidget {
  const DriverMapScreen({super.key});

  @override
  State<DriverMapScreen> createState() => _DriverMapScreenState();
}

class _DriverMapScreenState extends State<DriverMapScreen> {
  GoogleMapController? _mapController;
  final DriverController controller = Get.find<DriverController>();

  final Map<MarkerId, Marker> _markers = {};
  final Map<PolylineId, Polyline> _polylines = {};
  BitmapDescriptor? _driverIcon;
  BitmapDescriptor? _customerIcon;

  final LatLng _defaultCustomerLoc = const LatLng(48.1565, -103.6185);

  @override
  void initState() {
    super.initState();
    _loadCustomMarkers();
  }

  Future<void> _loadCustomMarkers() async {
    try {
      _driverIcon = await MapMarkerHelper.createLabeledMarker(
        label: 'Driver',
        icon: Icons.delivery_dining_rounded,
        primaryColor: const Color(0xFFF59E0B),
        textColor: Colors.white,
      );

      _customerIcon = await MapMarkerHelper.createLabeledMarker(
        label: 'Customer',
        icon: Icons.home_rounded,
        primaryColor: const Color(0xFF1E3A8A),
        textColor: Colors.white,
      );

      _updateMapEntities();
    } catch (e) {
      debugPrint('DriverMapScreen marker load note: $e');
    }
  }

  Future<void> _updateMapEntities() async {
    final driverLoc = LatLng(
      controller.currentLatitude.value,
      controller.currentLongitude.value,
    );
    final customerLoc = _defaultCustomerLoc;

    // 1. Fetch road path (not a straight line)
    final roadPath = await RouteService.getRoadRoute(
      origin: driverLoc,
      destination: customerLoc,
    );

    // 2. Markers
    final driverMarker = Marker(
      markerId: const MarkerId('driver_pin'),
      position: driverLoc,
      icon: _driverIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      infoWindow: const InfoWindow(title: 'Driver (You)', snippet: 'Current Live GPS'),
      zIndexInt: 3,
    );

    final customerMarker = Marker(
      markerId: const MarkerId('customer_pin'),
      position: customerLoc,
      icon: _customerIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: InfoWindow(
        title: 'Customer Destination',
        snippet: controller.activeOrder.value?.deliveryAddress ?? 'Customer Address',
      ),
      zIndexInt: 2,
    );

    // 3. Polylines
    final outerPolyline = Polyline(
      polylineId: const PolylineId('driver_road_outer'),
      points: roadPath,
      color: const Color(0xFF92400E),
      width: 8,
      jointType: JointType.round,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
    );

    final innerPolyline = Polyline(
      polylineId: const PolylineId('driver_road_inner'),
      points: roadPath,
      color: const Color(0xFFF59E0B),
      width: 5,
      jointType: JointType.round,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
    );

    if (mounted) {
      setState(() {
        _markers[driverMarker.markerId] = driverMarker;
        _markers[customerMarker.markerId] = customerMarker;
        _polylines[outerPolyline.polylineId] = outerPolyline;
        _polylines[innerPolyline.polylineId] = innerPolyline;
      });
    }
  }

  void _centerOnDriver() {
    if (_mapController == null) return;
    _mapController!.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(controller.currentLatitude.value, controller.currentLongitude.value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Stack(
          children: [
            /// 1. Interactive Google Map with Road Route
            Positioned.fill(
              child: Obx(() {
                final currentLat = controller.currentLatitude.value;
                final currentLng = controller.currentLongitude.value;

                return GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(currentLat, currentLng),
                    zoom: 14.8,
                  ),
                  onMapCreated: (mapCtrl) {
                    _mapController = mapCtrl;
                    _updateMapEntities();
                  },
                  markers: Set<Marker>.of(_markers.values),
                  polylines: Set<Polyline>.of(_polylines.values),
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                );
              }),
            ),

            /// 2. Top Navigation Turn Instruction Banner
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
                      color: Colors.black.withValues(alpha: 0.1),
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
                    // Live Broadcasting Tag (5s)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6.w,
                            height: 6.w,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'GPS 5s',
                            style: GoogleFonts.inter(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF047857),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// 3. Floating Re-Center Button
            Positioned(
              right: 16.w,
              bottom: 185.h,
              child: FloatingActionButton.small(
                heroTag: 'driver_recenter_fab',
                onPressed: _centerOnDriver,
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF111827),
                elevation: 4,
                child: const Icon(Icons.my_location_rounded, size: 20),
              ),
            ),

            /// 4. Bottom Delivery ETA & Actions Card
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
                      child: Text(
                        'No active delivery route right now',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      ),
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
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 18,
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '7 mins (2.1 km)',
                                  style: GoogleFonts.inter(
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF10B981),
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  order.deliveryAddress,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(fontSize: 12.sp, color: const Color(0xFF6B7280)),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8.w),
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
                        height: 48.h,
                        child: ElevatedButton(
                          onPressed: () => controller.markArrived(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryAmber,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                            elevation: 0,
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

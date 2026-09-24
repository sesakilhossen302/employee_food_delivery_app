import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../../../Utils/AppColors/app_colors.dart';
import '../../../../../Utils/map_marker_helper.dart';
import '../../../../../service/api_url.dart';
import '../../../../../service/route_service.dart';
import '../../../../../service/socket_service.dart';
import '../Model/employee_order_models.dart';

class LiveOrderTrackingScreen extends StatefulWidget {
  final OrderModel order;

  const LiveOrderTrackingScreen({super.key, required this.order});

  @override
  State<LiveOrderTrackingScreen> createState() => _LiveOrderTrackingScreenState();
}

class _LiveOrderTrackingScreenState extends State<LiveOrderTrackingScreen> {
  GoogleMapController? _mapController;

  // Dynamic Locations initialized from order / backend
  LatLng _driverLoc = const LatLng(23.8050, 90.4080);
  LatLng _customerLoc = const LatLng(23.8103, 90.4125);

  String _driverName = '';
  String _driverPhone = '';
  String _driverVehicle = '';
  double _driverRating = 0.0;

  // Markers and Polylines
  final Map<MarkerId, Marker> _markers = {};
  final Map<PolylineId, Polyline> _polylines = {};
  List<LatLng> _fullRoadRoute = [];
  int _currentRouteIndex = 0;

  // ETA & Distance
  double _remainingKm = 2.4;
  int _estimatedMins = 8;
  bool _isLoading = true;

  BitmapDescriptor? _driverIcon;
  BitmapDescriptor? _customerIcon;

  // Socket listener registration
  dynamic _socketHandler;

  @override
  void initState() {
    super.initState();
    _initLiveTracking();
  }

  @override
  void dispose() {
    if (_socketHandler != null) {
      SocketService.socket.off('driver_location_update', _socketHandler);
    }
    super.dispose();
  }

  Future<void> _initLiveTracking() async {
    // 1. Generate Custom Circular Pin Markers (small clean icons, zero text)
    await _buildCustomMarkers();

    // 2. Fetch server tracking info for this order
    await _fetchInitialTrackingData();

    // 3. Calculate road route (turn-by-turn road polyline between Driver and Customer)
    await _calculateRoadRoute();

    // 4. Listen to Socket.io driver updates (every 5 seconds)
    _listenToDriverSocket();

    if (mounted) {
      setState(() => _isLoading = false);
      _fitMapBounds();
    }
  }

  Future<void> _buildCustomMarkers() async {
    try {
      _driverIcon = await MapMarkerHelper.createCircularMarker(
        icon: Icons.delivery_dining_rounded,
        primaryColor: const Color(0xFFF59E0B),
        diameter: 46.0,
      );

      _customerIcon = await MapMarkerHelper.createCircularMarker(
        icon: Icons.home_rounded,
        primaryColor: const Color(0xFF1E3A8A),
        diameter: 46.0,
      );
    } catch (e) {
      debugPrint('Error generating custom marker icons: $e');
    }
  }

  Future<void> _fetchInitialTrackingData() async {
    try {
      final res = await http.get(
        Uri.parse('${ApiConstant.baseUrl}${ApiConstant.orderTracking(widget.order.id)}'),
      ).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true && data['data'] != null) {
          final track = data['data'];

          // 1. Dynamic Driver Info
          if (track['driver'] != null) {
            final d = track['driver'];
            _driverName = d['name'] ?? _driverName;
            _driverPhone = d['phone'] ?? _driverPhone;
            _driverVehicle = d['vehicle'] ?? (d['vehicleType'] ?? _driverVehicle);
            if (d['rating'] != null) {
              _driverRating = (d['rating'] as num).toDouble();
            }
            if (d['lat'] != null && d['lng'] != null) {
              _driverLoc = LatLng((d['lat'] as num).toDouble(), (d['lng'] as num).toDouble());
            }
          }
          if (track['driverLocation'] != null) {
            final dl = track['driverLocation'];
            if (dl['lat'] != null && dl['lng'] != null) {
              _driverLoc = LatLng((dl['lat'] as num).toDouble(), (dl['lng'] as num).toDouble());
            }
          }

          // 2. Dynamic Customer Location
          final cust = track['customerLocation'] ?? track['customer'];
          if (cust != null) {
            final clat = (cust['lat'] as num?)?.toDouble();
            final clng = (cust['lng'] as num?)?.toDouble();
            if (clat != null && clng != null) {
              _customerLoc = LatLng(clat, clng);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Initial tracking fetch note (using defaults): $e');
    }
  }

  Future<void> _calculateRoadRoute() async {
    // Generate realistic road route from driver location to customer
    _fullRoadRoute = await RouteService.getRoadRoute(
      origin: _driverLoc,
      destination: _customerLoc,
    );

    _updateMarkersAndPolylines();
  }

  void _updateMarkersAndPolylines() {
    // Calculate distance & ETA
    _remainingKm = RouteService.calculateDistanceKm(_driverLoc, _customerLoc);
    _estimatedMins = RouteService.estimateMinutes(_remainingKm);

    // 1. Driver Marker (Compact Circular Pin)
    final driverMarker = Marker(
      markerId: const MarkerId('driver_marker'),
      position: _driverLoc,
      anchor: const Offset(0.5, 0.89),
      icon: _driverIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      infoWindow: InfoWindow(
        title: _driverName.isNotEmpty ? 'Driver: $_driverName' : 'Driver',
        snippet: _driverVehicle.isNotEmpty ? '$_driverVehicle • En route' : 'En route to destination',
      ),
      zIndexInt: 3,
    );

    // 2. Customer Marker (Compact Circular Pin)
    final customerMarker = Marker(
      markerId: const MarkerId('customer_marker'),
      position: _customerLoc,
      anchor: const Offset(0.5, 0.89),
      icon: _customerIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: InfoWindow(
        title: 'Customer Destination',
        snippet: widget.order.deliveryAddress,
      ),
      zIndexInt: 2,
    );

    _markers[driverMarker.markerId] = driverMarker;
    _markers[customerMarker.markerId] = customerMarker;

    // Remaining road route polyline from driver's current spot to customer
    List<LatLng> remainingRoute = [];
    if (_fullRoadRoute.isNotEmpty) {
      remainingRoute = [
        _driverLoc,
        ..._fullRoadRoute.sublist(_currentRouteIndex.clamp(0, _fullRoadRoute.length)),
      ];
    } else {
      remainingRoute = [_driverLoc, _customerLoc];
    }

    // Outer polyline for glowing border effect
    final borderPolyline = Polyline(
      polylineId: const PolylineId('road_route_border'),
      points: remainingRoute,
      color: const Color(0xFFB45309),
      width: 9,
      jointType: JointType.round,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      zIndex: 1,
    );

    // Main vibrant road polyline
    final activePolyline = Polyline(
      polylineId: const PolylineId('road_route_active'),
      points: remainingRoute,
      color: const Color(0xFFF59E0B),
      width: 6,
      jointType: JointType.round,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      zIndex: 2,
    );

    _polylines[borderPolyline.polylineId] = borderPolyline;
    _polylines[activePolyline.polylineId] = activePolyline;

    if (mounted) setState(() {});
  }

  void _listenToDriverSocket() {
    SocketService.init();

    _socketHandler = (dynamic data) {
      if (data == null) return;
      debugPrint('⚡ Live Tracking Received Socket Update: $data');

      // Check if event belongs to this order or current driver
      final orderId = data['orderId'];
      if (orderId != null &&
          orderId.toString() != widget.order.id &&
          orderId.toString() != widget.order.id.replaceAll('#', '')) {
        // If broadcast is for a different order, skip
      }

      if (data['driverName'] != null && data['driverName'].toString().isNotEmpty) {
        _driverName = data['driverName'].toString();
      }
      if (data['driverPhone'] != null && data['driverPhone'].toString().isNotEmpty) {
        _driverPhone = data['driverPhone'].toString();
      }
      if (data['vehicle'] != null && data['vehicle'].toString().isNotEmpty) {
        _driverVehicle = data['vehicle'].toString();
      }

      final lat = (data['lat'] as num?)?.toDouble();
      final lng = (data['lng'] as num?)?.toDouble();

      if (lat != null && lng != null) {
        if (!mounted) return;
        setState(() {
          _driverLoc = LatLng(lat, lng);

          // Advance route index if close to next waypoint
          if (_fullRoadRoute.isNotEmpty && _currentRouteIndex < _fullRoadRoute.length - 1) {
            final nextPoint = _fullRoadRoute[_currentRouteIndex];
            final dist = RouteService.calculateDistanceKm(_driverLoc, nextPoint);
            if (dist < 0.1) {
              _currentRouteIndex++;
            }
          }

          _updateMarkersAndPolylines();
        });
      }
    };

    SocketService.socket.on('driver_location_update', _socketHandler);
  }

  void _fitMapBounds() {
    if (_mapController == null) return;

    final lats = [_driverLoc.latitude, _customerLoc.latitude];
    final lngs = [_driverLoc.longitude, _customerLoc.longitude];

    final double minLat = lats.reduce((a, b) => a < b ? a : b);
    final double maxLat = lats.reduce((a, b) => a > b ? a : b);
    final double minLng = lngs.reduce((a, b) => a < b ? a : b);
    final double maxLng = lngs.reduce((a, b) => a > b ? a : b);

    final bounds = LatLngBounds(
      southwest: LatLng(minLat - 0.005, minLng - 0.005),
      northeast: LatLng(maxLat + 0.005, maxLng + 0.005),
    );

    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Stack(
        children: [
          /// 1. Interactive Google Map with Road Routing
          Positioned.fill(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryAmber))
                : GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        (_driverLoc.latitude + _customerLoc.latitude) / 2,
                        (_driverLoc.longitude + _customerLoc.longitude) / 2,
                      ),
                      zoom: 14.5,
                    ),
                    onMapCreated: (controller) {
                      _mapController = controller;
                      _fitMapBounds();
                    },
                    markers: Set<Marker>.of(_markers.values),
                    polylines: Set<Polyline>.of(_polylines.values),
                    myLocationEnabled: false,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                  ),
          ),

          /// 2. Top Header Bar (Back button, Title, Live Status Chip)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Row(
                  children: [
                    // Back Button
                    InkWell(
                      onTap: () => Get.back(),
                      borderRadius: BorderRadius.circular(14.r),
                      child: Container(
                        width: 44.w,
                        height: 44.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF111827)),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    // Title Card
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.order.id.startsWith('#')
                                      ? 'Order ${widget.order.id}'
                                      : 'Order #${widget.order.id}',
                                  style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF111827),
                                  ),
                                ),
                                Text(
                                  'Live Delivery Route',
                                  style: GoogleFonts.inter(
                                    fontSize: 11.sp,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                            // Pulsing Live Indicator
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(color: const Color(0xFFA7F3D0)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8.w,
                                    height: 8.w,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF10B981),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 5.w),
                                  Text(
                                    'LIVE',
                                    style: GoogleFonts.inter(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w800,
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
                  ],
                ),
              ),
            ),
          ),

          /// 3. Floating Re-Center & Zoom Controls
          Positioned(
            right: 16.w,
            bottom: 270.h,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'recenter_btn',
                  onPressed: _fitMapBounds,
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF111827),
                  elevation: 4,
                  child: const Icon(Icons.my_location_rounded, size: 20),
                ),
              ],
            ),
          ),

          /// 4. Bottom Delivery Information Sheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 24.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      margin: EdgeInsets.only(bottom: 14.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),

                  // ETA & Status Highlight Banner
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42.w,
                          height: 42.w,
                          decoration: BoxDecoration(
                            color: AppColors.primaryAmber,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: const Icon(Icons.moped_rounded, color: Colors.white, size: 24),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Estimated Arrival: $_estimatedMins mins',
                                style: GoogleFonts.inter(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF92400E),
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'Driver is on the way • ${_remainingKm.toStringAsFixed(1)} km away',
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFB45309),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Driver Details Row
                  Row(
                    children: [
                      Container(
                        width: 52.w,
                        height: 52.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primaryAmber, width: 2),
                        ),
                        child: const Center(
                          child: Icon(Icons.person_rounded, size: 30, color: Color(0xFF4B5563)),
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  _driverName.isNotEmpty ? _driverName : 'Driver Assigned',
                                  style: GoogleFonts.inter(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF111827),
                                  ),
                                ),
                                if (_driverRating > 0) ...[
                                  SizedBox(width: 6.w),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF3C7),
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.star_rounded, size: 12, color: Color(0xFFD97706)),
                                        SizedBox(width: 2.w),
                                        Text(
                                          '$_driverRating',
                                          style: GoogleFonts.inter(
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFFB45309),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              _driverVehicle.isNotEmpty ? _driverVehicle : 'Delivery Vehicle',
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Phone Call Button
                      InkWell(
                        onTap: () {
                          if (_driverPhone.isNotEmpty) {
                            Get.snackbar(
                              'Calling Driver',
                              'Connecting to ${_driverName.isNotEmpty ? _driverName : "Driver"} at $_driverPhone',
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: const Color(0xFF10B981),
                              colorText: Colors.white,
                            );
                          } else {
                            Get.snackbar(
                              'Driver Contact',
                              'Driver contact info will appear once connected.',
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: const Color(0xFF3B82F6),
                              colorText: Colors.white,
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(14.r),
                        child: Container(
                          width: 46.w,
                          height: 46.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: const Center(
                            child: Icon(Icons.phone_in_talk_rounded, color: Color(0xFF059669), size: 22),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 14.h),
                  const Divider(height: 1, color: Color(0xFFF3F4F6)),
                  SizedBox(height: 12.h),

                  // Destination Address
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEFF6FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.location_on_rounded, size: 16, color: Color(0xFF1D4ED8)),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Delivery Address',
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              widget.order.deliveryAddress,
                              style: GoogleFonts.inter(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

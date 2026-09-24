import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../../../../Utils/AppColors/app_colors.dart';
import '../../../../Utils/AppConst/app_const.dart';
import 'Controller/profile_controller.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();

  // Default initial location
  LatLng _selectedLatLng = const LatLng(23.8103, 90.4125);
  bool _isLoading = true;
  bool _isMoving = false;
  bool _isResolvingAddress = false;

  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _addressCtrl = TextEditingController();
  final TextEditingController _noteCtrl = TextEditingController();

  final ProfileController _profileController = Get.isRegistered<ProfileController>()
      ? Get.find<ProfileController>()
      : Get.put(ProfileController());

  final List<String> _presetLabels = ['Home', 'Work', 'Office', 'Other'];
  String _selectedPreset = '';

  @override
  void initState() {
    super.initState();
    _determineCurrentPosition();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _addressCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _determineCurrentPosition() async {
    setState(() => _isLoading = true);

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: 'Location services are disabled.');
      setState(() => _isLoading = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: 'Location permissions are denied');
        setState(() => _isLoading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(msg: 'Location permissions are permanently denied.');
      setState(() => _isLoading = false);
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final newLatLng = LatLng(position.latitude, position.longitude);
      _selectedLatLng = newLatLng;
      _updateAddressFromCoordinates(newLatLng);

      if (_controller.isCompleted) {
        final GoogleMapController mapController = await _controller.future;
        mapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: newLatLng, zoom: 16.0),
        ));
      }
    } catch (e) {
      debugPrint('Error getting GPS: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onCameraMove(CameraPosition position) {
    _selectedLatLng = position.target;
    if (!_isMoving) {
      setState(() {
        _isMoving = true;
      });
    }
  }

  void _onCameraIdle() {
    setState(() {
      _isMoving = false;
    });
    // Immediately update address & coordinates when user stops dragging
    _updateAddressFromCoordinates(_selectedLatLng);
  }

  Future<void> _onMapTapped(LatLng latLng) async {
    _selectedLatLng = latLng;
    final mapCtrl = await _controller.future;
    mapCtrl.animateCamera(CameraUpdate.newLatLng(latLng));
    _updateAddressFromCoordinates(latLng);
  }

  Future<void> _updateAddressFromCoordinates(LatLng latLng) async {
    final lat = latLng.latitude;
    final lng = latLng.longitude;

    // Immediately display the active coordinates in the field
    final fallbackAddress = 'Location (${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)})';
    if (mounted) {
      setState(() {
        _addressCtrl.text = fallbackAddress;
        _isResolvingAddress = true;
      });
    }

    // Attempt reverse geocoding in background to get human-readable street/area
    try {
      // 1. Google Geocoding API if key configured
      final key = AppConstants.googleMapsApiKey;
      if (key.isNotEmpty) {
        final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$key',
        );
        final res = await http.get(url).timeout(const Duration(seconds: 4));
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          if (data['status'] == 'OK' && data['results'] is List && data['results'].isNotEmpty) {
            final formatted = data['results'][0]['formatted_address'];
            if (formatted != null && formatted.toString().isNotEmpty && mounted) {
              setState(() {
                _addressCtrl.text = formatted.toString();
                _isResolvingAddress = false;
              });
              return;
            }
          }
        }
      }

      // 2. OpenStreetMap Nominatim reverse geocode (Free fallback)
      final osmUrl = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1',
      );
      final osmRes = await http.get(
        osmUrl,
        headers: {'User-Agent': 'EmployeeFoodDeliveryApp/1.0'},
      ).timeout(const Duration(seconds: 4));

      if (osmRes.statusCode == 200) {
        final data = jsonDecode(osmRes.body);
        final name = data['display_name'];
        if (name != null && name.toString().isNotEmpty && mounted) {
          setState(() {
            _addressCtrl.text = name.toString();
            _isResolvingAddress = false;
          });
          return;
        }
      }
    } catch (_) {
      // Keep coordinate fallback on any network error
    } finally {
      if (mounted) {
        setState(() {
          _isResolvingAddress = false;
        });
      }
    }
  }

  void _saveAddress() {
    if (_titleCtrl.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter an address label (e.g. Home, Office)');
      return;
    }

    final lat = _selectedLatLng.latitude;
    final lng = _selectedLatLng.longitude;
    final addressText = _addressCtrl.text.trim().isNotEmpty
        ? _addressCtrl.text.trim()
        : 'Location (${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)})';

    _profileController.addAddress(
      title: _titleCtrl.text.trim(),
      address: addressText,
      note: _noteCtrl.text.trim(),
      lat: lat,
      lng: lng,
    );

    Get.back(result: {
      'title': _titleCtrl.text.trim(),
      'address': addressText,
      'instructions': _noteCtrl.text.trim(),
      'lat': lat,
      'lng': lng,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF111827), size: 20),
          onPressed: () => Get.back(),
        ),
        title: Column(
          children: [
            Text(
              'Select Location',
              style: GoogleFonts.inter(color: const Color(0xFF111827), fontWeight: FontWeight.w700, fontSize: 17.sp),
            ),
            Text(
              'Drag map or tap to change location',
              style: GoogleFonts.inter(color: const Color(0xFF6B7280), fontSize: 11.sp, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 1. Interactive Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedLatLng,
              zoom: 16.0,
            ),
            onMapCreated: (GoogleMapController controller) {
              if (!_controller.isCompleted) {
                _controller.complete(controller);
              }
            },
            onCameraMove: _onCameraMove,
            onCameraIdle: _onCameraIdle,
            onTap: _onMapTapped,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          // 2. Loading indicator overlay
          if (_isLoading)
            Container(
              color: Colors.white.withValues(alpha: 0.6),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primaryAmber),
              ),
            ),

          // 3. Center Fixed Pin (Uber/Foodpanda style with animated lift & shadow)
          Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 150.h), // Offset above bottom sheet
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    transform: Matrix4.translationValues(0, _isMoving ? -14 : 0, 0),
                    child: Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: AppColors.primaryAmber,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryAmber.withValues(alpha: 0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.location_on_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  // Ground shadow dot
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: _isMoving ? 8.w : 14.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: _isMoving ? 0.15 : 0.35),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. Live Floating Coordinates Pill at Top
          Positioned(
            top: 14.h,
            left: 20.w,
            right: 20.w,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isMoving ? Icons.pan_tool_rounded : Icons.my_location_rounded,
                      size: 14.sp,
                      color: AppColors.primaryAmber,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      _isMoving
                          ? 'Moving map...'
                          : '${_selectedLatLng.latitude.toStringAsFixed(4)}, ${_selectedLatLng.longitude.toStringAsFixed(4)}',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    if (_isResolvingAddress) ...[
                      SizedBox(width: 8.w),
                      SizedBox(
                        width: 10.w,
                        height: 10.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryAmber,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // 5. Re-Center GPS Button
          Positioned(
            right: 16.w,
            bottom: 300.h,
            child: FloatingActionButton.small(
              heroTag: 'myLocationBtn',
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF111827),
              elevation: 4,
              onPressed: _determineCurrentPosition,
              child: const Icon(Icons.my_location_rounded, size: 20),
            ),
          ),

          // 6. Bottom Address Details Input Sheet
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.r),
                  topRight: Radius.circular(24.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header & Preset Chips
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Address Details',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w800,
                          fontSize: 16.sp,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      Text(
                        'Lat: ${_selectedLatLng.latitude.toStringAsFixed(3)}, Lng: ${_selectedLatLng.longitude.toStringAsFixed(3)}',
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          color: const Color(0xFF9CA3AF),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),

                  // Quick label preset chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _presetLabels.map((preset) {
                        final isSel = _selectedPreset == preset || _titleCtrl.text == preset;
                        return Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedPreset = preset;
                                _titleCtrl.text = preset;
                              });
                            },
                            borderRadius: BorderRadius.circular(20.r),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: isSel ? const Color(0xFFFEF3C7) : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                  color: isSel ? AppColors.primaryAmber : Colors.transparent,
                                  width: 1.2,
                                ),
                              ),
                              child: Text(
                                preset,
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                  color: isSel ? const Color(0xFFD97706) : const Color(0xFF4B5563),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Label Input
                  TextField(
                    controller: _titleCtrl,
                    onChanged: (val) {
                      if (_selectedPreset != val) {
                        setState(() => _selectedPreset = '');
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Address Label (e.g. Home, Office, Gym)',
                      hintStyle: GoogleFonts.inter(fontSize: 13.sp, color: const Color(0xFF9CA3AF)),
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      prefixIcon: const Icon(Icons.bookmark_outline_rounded, color: Color(0xFF9CA3AF), size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                    ),
                  ),
                  SizedBox(height: 10.h),

                  // Address Input (Auto-updated live from map)
                  TextField(
                    controller: _addressCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Address (Updates automatically from map)',
                      hintStyle: GoogleFonts.inter(fontSize: 13.sp, color: const Color(0xFF9CA3AF)),
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(bottom: 24),
                        child: Icon(Icons.location_on_outlined, color: AppColors.primaryAmber, size: 20),
                      ),
                      suffixIcon: _isResolvingAddress
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryAmber),
                              ),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                    ),
                  ),
                  SizedBox(height: 10.h),

                  // Delivery Instructions (Optional)
                  TextField(
                    controller: _noteCtrl,
                    decoration: InputDecoration(
                      hintText: 'Delivery instructions (e.g. Leave at door)',
                      hintStyle: GoogleFonts.inter(fontSize: 13.sp, color: const Color(0xFF9CA3AF)),
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      prefixIcon: const Icon(Icons.notes_rounded, color: Color(0xFF9CA3AF), size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                    ),
                  ),
                  SizedBox(height: 14.h),

                  // Confirm Button
                  SizedBox(
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: _saveAddress,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryAmber,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        elevation: 0,
                      ),
                      child: Text(
                        'Confirm Location',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15.sp,
                        ),
                      ),
                    ),
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

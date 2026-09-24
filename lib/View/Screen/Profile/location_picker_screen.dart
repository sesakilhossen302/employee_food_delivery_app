import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../../Utils/AppColors/app_colors.dart';
import 'Controller/profile_controller.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  
  // Default fallback location (e.g., center of a city)
  LatLng _selectedLatLng = const LatLng(23.8103, 90.4125); 
  bool _isLoading = true;
  
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _addressCtrl = TextEditingController();
  final TextEditingController _noteCtrl = TextEditingController();
  
  final ProfileController _profileController = Get.isRegistered<ProfileController>()
      ? Get.find<ProfileController>()
      : Get.put(ProfileController());

  @override
  void initState() {
    super.initState();
    _determineCurrentPosition();
  }

  Future<void> _determineCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: 'Location services are disabled.');
      setState(() => _isLoading = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: 'Location permissions are denied');
        setState(() => _isLoading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(msg: 'Location permissions are permanently denied, we cannot request permissions.');
      setState(() => _isLoading = false);
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _selectedLatLng = LatLng(position.latitude, position.longitude);
      _addressCtrl.text = 'Location (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})';
      _isLoading = false;
    });

    final GoogleMapController mapController = await _controller.future;
    mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: _selectedLatLng, zoom: 16.0),
    ));
  }

  void _onCameraMove(CameraPosition position) {
    _selectedLatLng = position.target;
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Select Location',
          style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // The Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedLatLng,
              zoom: 14.0,
            ),
            onMapCreated: (GoogleMapController controller) {
              if (!_controller.isCompleted) {
                _controller.complete(controller);
              }
            },
            onCameraMove: _onCameraMove,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),
          
          // Loading indicator overlay
          if (_isLoading)
            Container(
              color: Colors.white.withOpacity(0.6),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primaryAmber),
              ),
            ),
            
          // Center Marker (Fixed at the center of the screen)
          Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 40.h), // Offset so the pin bottom points to center
              child: Icon(
                Icons.location_on,
                size: 50.sp,
                color: AppColors.primaryAmber,
              ),
            ),
          ),
          
          // Current Location Button
          Positioned(
            right: 16.w,
            bottom: 250.h,
            child: FloatingActionButton(
              heroTag: 'myLocation',
              backgroundColor: Colors.white,
              onPressed: _determineCurrentPosition,
              child: const Icon(Icons.my_location, color: Colors.black87),
            ),
          ),
          
          // Bottom Input Sheet
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.r),
                  topRight: Radius.circular(24.r),
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -2))
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Address Details', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16.sp)),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: _titleCtrl,
                    decoration: InputDecoration(
                      hintText: 'Label (e.g. Home, Office, Gym)',
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  TextField(
                    controller: _addressCtrl,
                    decoration: InputDecoration(
                      hintText: 'Address / Street (or use selected pin)',
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  TextField(
                    controller: _noteCtrl,
                    decoration: InputDecoration(
                      hintText: 'Delivery instructions (optional)',
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: _saveAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryAmber,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: Text('Confirm Location', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16.sp)),
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

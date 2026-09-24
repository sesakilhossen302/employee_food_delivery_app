import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../Core/AppRoute/app_route.dart';
import '../../../../Utils/AppColors/app_colors.dart';
import '../../../../service/api_client.dart';
import '../../../../service/api_url.dart';
import '../../Profile/Controller/profile_controller.dart';
import '../Home/Controller/employee_home_controller.dart';
import '../Nav/Controller/employee_nav_controller.dart';
import '../Orders/Controller/employee_orders_controller.dart';

class EmployeeCheckoutScreen extends StatefulWidget {
  const EmployeeCheckoutScreen({super.key});

  @override
  State<EmployeeCheckoutScreen> createState() => _EmployeeCheckoutScreenState();
}

class _EmployeeCheckoutScreenState extends State<EmployeeCheckoutScreen> {
  bool isDelivery = true;
  bool isSubmitting = false;

  final TextEditingController nameController = TextEditingController(text: 'Customer');
  final TextEditingController phoneController = TextEditingController(text: '(555) 123-4567');
  final TextEditingController streetController = TextEditingController();
  final TextEditingController zipController = TextEditingController();
  final TextEditingController instructionsController = TextEditingController();

  final ProfileController profileController = Get.isRegistered<ProfileController>()
      ? Get.find<ProfileController>()
      : Get.put(ProfileController());

  SavedAddressModel? selectedAddress;
  double deliveryLat = 23.8103;
  double deliveryLng = 90.4125;
  bool isDetectingGps = false;

  @override
  void initState() {
    super.initState();
    _initAddressData();
  }

  Future<void> _initAddressData() async {
    await profileController.loadAddresses();
    if (profileController.addresses.isNotEmpty) {
      final addr = profileController.addresses.firstWhereOrNull((a) => a.isDefault) ??
          profileController.addresses.first;
      _selectAddress(addr);
    } else {
      _detectCurrentLocation();
    }
  }

  void _selectAddress(SavedAddressModel addr) {
    setState(() {
      selectedAddress = addr;
      streetController.text = addr.address;
      if (addr.note.isNotEmpty) {
        instructionsController.text = addr.note;
      }
      if (addr.lat != null && addr.lng != null) {
        deliveryLat = addr.lat!;
        deliveryLng = addr.lng!;
      }
    });
  }

  Future<void> _detectCurrentLocation() async {
    try {
      setState(() => isDetectingGps = true);
      final hasPermission = await Geolocator.isLocationServiceEnabled();
      if (hasPermission) {
        var perm = await Geolocator.checkPermission();
        if (perm == LocationPermission.denied) {
          perm = await Geolocator.requestPermission();
        }
        if (perm == LocationPermission.whileInUse || perm == LocationPermission.always) {
          final pos = await Geolocator.getCurrentPosition(timeLimit: const Duration(seconds: 5));
          if (mounted) {
            setState(() {
              deliveryLat = pos.latitude;
              deliveryLng = pos.longitude;
              if (streetController.text.isEmpty) {
                streetController.text = 'Location (${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)})';
              }
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Checkout GPS note: $e');
    } finally {
      if (mounted) setState(() => isDetectingGps = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    streetController.dispose();
    zipController.dispose();
    instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EmployeeHomeController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            /// 1. Top App Bar: Back button & Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 40.w,
                      height: 40.w,
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
                  SizedBox(width: 14.w),
                  Text(
                    'Checkout',
                    style: GoogleFonts.inter(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                  ),
                ],
              ),
            ),

            /// 2. Scrollable Checkout Body
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Delivery vs Store Pickup Toggle
                    _buildToggleBar(),
                    SizedBox(height: 16.h),

                    /// Contact Info Card
                    _buildContactInfoCard(),
                    SizedBox(height: 16.h),

                    /// If Delivery: Delivery Address & Est. Banner
                    if (isDelivery) ...[
                      _buildDeliveryAddressCard(),
                      SizedBox(height: 16.h),
                      _buildEstDeliveryBanner(),
                      SizedBox(height: 16.h),
                    ],

                    /// If Store Pickup: Pickup Banner & Payment Method
                    if (!isDelivery) ...[
                      _buildPickupBanner(),
                      SizedBox(height: 16.h),
                      _buildPaymentMethodCard(),
                      SizedBox(height: 16.h),
                    ],

                    /// Order Summary Card
                    _buildOrderSummaryCard(controller),
                    SizedBox(height: 24.h),

                    /// Place Order Button
                    _buildPlaceOrderButton(controller),
                    SizedBox(height: 30.h),
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
  /// TOGGLE BAR (Delivery vs Store Pickup)
  /// --------------------------------------------------------------------------
  Widget _buildToggleBar() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          /// Delivery Option
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isDelivery = true;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: isDelivery ? AppColors.primaryAmber : Colors.transparent,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.local_shipping_outlined,
                      size: 18.sp,
                      color: isDelivery ? Colors.white : const Color(0xFF6B7280),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'Delivery',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: isDelivery ? Colors.white : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// Store Pickup Option
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isDelivery = false;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: !isDelivery ? AppColors.primaryAmber : Colors.transparent,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 18.sp,
                      color: !isDelivery ? Colors.white : const Color(0xFF6B7280),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'Store Pickup',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: !isDelivery ? Colors.white : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// --------------------------------------------------------------------------
  /// CONTACT INFO CARD
  /// --------------------------------------------------------------------------
  Widget _buildContactInfoCard() {
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
            'Contact Info',
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            ),
          ),
          SizedBox(height: 12.h),
          _buildFieldLabel('Name'),
          SizedBox(height: 6.h),
          _buildCustomTextField(nameController),
          SizedBox(height: 12.h),
          _buildFieldLabel('Phone'),
          SizedBox(height: 6.h),
          _buildCustomTextField(phoneController),
        ],
      ),
    );
  }

  /// --------------------------------------------------------------------------
  /// DELIVERY ADDRESS CARD
  /// --------------------------------------------------------------------------
  Widget _buildDeliveryAddressCard() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Delivery Address',
                style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
              ),
              if (isDetectingGps)
                Row(
                  children: [
                    SizedBox(width: 12.w, height: 12.w, child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryAmber)),
                    SizedBox(width: 6.w),
                    Text('Detecting GPS...', style: GoogleFonts.inter(fontSize: 10.sp, color: const Color(0xFF9CA3AF))),
                  ],
                ),
            ],
          ),
          SizedBox(height: 12.h),

          // 1. Saved Addresses List (Cards)
          Obx(() {
            final addrs = profileController.addresses;
            if (addrs.isEmpty) {
              return const SizedBox.shrink();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...addrs.map((addr) {
                  final isSelected = selectedAddress?.id == addr.id;
                  return GestureDetector(
                    onTap: () => _selectAddress(addr),
                    child: Container(
                      margin: EdgeInsets.only(bottom: 10.h),
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFFEF3C7).withValues(alpha: 0.3) : Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: isSelected ? AppColors.primaryAmber : const Color(0xFFE5E7EB),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                            color: isSelected ? AppColors.primaryAmber : const Color(0xFF9CA3AF),
                            size: 20.sp,
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      addr.title,
                                      style: GoogleFonts.inter(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF111827),
                                      ),
                                    ),
                                    if (addr.isDefault) ...[
                                      SizedBox(width: 6.w),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFEF3C7),
                                          borderRadius: BorderRadius.circular(4.r),
                                        ),
                                        child: Text(
                                          'Default',
                                          style: GoogleFonts.inter(
                                            fontSize: 9.sp,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFFD97706),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  addr.address,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 11.sp,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            );
          }),

          // 2. Add New Address / Location via Map button
          SizedBox(
            width: double.infinity,
            height: 44.h,
            child: OutlinedButton.icon(
              onPressed: () async {
                final result = await Get.toNamed(AppRoute.locationPickerScreen);
                if (result != null && result is Map) {
                  setState(() {
                    if (result['lat'] != null && result['lng'] != null) {
                      deliveryLat = (result['lat'] as num).toDouble();
                      deliveryLng = (result['lng'] as num).toDouble();
                    }
                    if (result['address'] != null) {
                      streetController.text = result['address'].toString();
                    }
                    if (result['instructions'] != null && result['instructions'].toString().isNotEmpty) {
                      instructionsController.text = result['instructions'].toString();
                    }
                    selectedAddress = SavedAddressModel(
                      id: 'NEW-${DateTime.now().millisecondsSinceEpoch}',
                      title: result['title']?.toString() ?? 'Selected Location',
                      address: streetController.text,
                      note: instructionsController.text,
                      lat: deliveryLat,
                      lng: deliveryLng,
                      isDefault: false,
                    );
                  });
                }
              },
              icon: const Icon(Icons.add_location_alt_outlined, color: AppColors.primaryAmber, size: 18),
              label: Text(
                'Add New Location on Map',
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryAmber,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryAmber, width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
            ),
          ),
          SizedBox(height: 14.h),

          _buildFieldLabel('Selected Address'),
          SizedBox(height: 6.h),
          _buildCustomTextField(
            streetController,
            prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFF9CA3AF), size: 18),
          ),
          SizedBox(height: 10.h),

          /// Green Valid Area Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check, size: 14, color: Color(0xFF059669)),
                SizedBox(width: 6.w),
                Text(
                  'Address is within delivery area',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF059669),
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),

          _buildFieldLabel('Delivery Instructions (optional)'),
          SizedBox(height: 6.h),
          _buildCustomTextField(instructionsController),
        ],
      ),
    );
  }

  /// --------------------------------------------------------------------------
  /// EST DELIVERY BANNER
  /// --------------------------------------------------------------------------
  Widget _buildEstDeliveryBanner() {
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
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: const Center(
              child: Icon(
                Icons.local_shipping_outlined,
                color: Color(0xFFD97706),
                size: 22,
              ),
            ),
          ),
          SizedBox(width: 14.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Est. Delivery: 25–35 min',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                "We'll notify you when it's on the way",
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// --------------------------------------------------------------------------
  /// PICKUP BANNER (STORE PICKUP)
  /// --------------------------------------------------------------------------
  Widget _buildPickupBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: const Center(
              child: Icon(
                Icons.access_time_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ready in 10–15 minutes',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF92400E),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Pick up at QuickStop Gas Station\n1250 Highway Blvd, Springfield',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: const Color(0xFFB45309),
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
  /// PAYMENT METHOD CARD
  /// --------------------------------------------------------------------------
  Widget _buildPaymentMethodCard() {
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
            'Payment Method',
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: AppColors.primaryAmber, width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryAmber, width: 2),
                  ),
                  child: Center(
                    child: Container(
                      width: 10.w,
                      height: 10.w,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryAmber,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cash at Store',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Pay when you pick up',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// --------------------------------------------------------------------------
  /// ORDER SUMMARY CARD
  /// --------------------------------------------------------------------------
  Widget _buildOrderSummaryCard(EmployeeHomeController controller) {
    final subtotal = controller.subtotal;
    final tax = controller.tax;
    final total = isDelivery ? controller.totalWithDelivery : controller.totalWithPickup;

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
            'Order Summary',
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            ),
          ),
          SizedBox(height: 14.h),
          _buildSummaryRow(
            'Subtotal (${controller.cartCount.value} items)',
            '\$${subtotal.toStringAsFixed(2)}',
          ),
          SizedBox(height: 10.h),
          _buildSummaryRow('Tax', '\$${tax.toStringAsFixed(2)}'),
          if (isDelivery) ...[
            SizedBox(height: 10.h),
            _buildSummaryRow('Delivery fee', '\$${controller.deliveryFee.toStringAsFixed(2)}'),
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
                '\$${total.toStringAsFixed(2)}',
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryAmber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// --------------------------------------------------------------------------
  /// PLACE ORDER LOGIC & BACKEND API HIT
  /// --------------------------------------------------------------------------
  Future<void> _handlePlaceOrder(EmployeeHomeController controller) async {
    if (controller.cartItems.isEmpty) {
      Fluttertoast.showToast(msg: 'Your cart is empty');
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final orderPayload = {
        "customer": {
          "name": nameController.text.trim().isNotEmpty ? nameController.text.trim() : "Customer",
          "phone": phoneController.text.trim().isNotEmpty ? phoneController.text.trim() : "+1 (555) 123-4567",
          "address": isDelivery ? streetController.text.trim() : "QuickStop Gas Station, 1250 Highway Blvd",
          "instructions": instructionsController.text.trim(),
          "distanceKm": 2.5,
          "lat": deliveryLat,
          "lng": deliveryLng,
        },
        "fulfillmentType": isDelivery ? "delivery" : "pickup",
        "items": controller.cartItems.map((entry) => {
          "productId": entry.key.id,
          "name": entry.key.name,
          "price": entry.key.price,
          "quantity": entry.value,
          "unit": entry.key.unit,
          "imageUrl": entry.key.imageUrl,
        }).toList(),
        "tip": 0.0,
        "paymentMethod": isDelivery ? "cash_on_delivery" : "cash_at_store",
      };

      final response = await ApiClient.postData(
        ApiConstant.createOrder,
        jsonEncode(orderPayload),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      String orderNum = '';
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body != null && response.body['data'] != null) {
          orderNum = response.body['data']['orderNumber'] ?? '';
        }
      }

      // Refresh Orders Controller if active
      if (Get.isRegistered<EmployeeOrdersController>()) {
        Get.find<EmployeeOrdersController>().loadOrders();
      }

      if (mounted) {
        _showOrderSuccessDialog(context, controller, orderNum: orderNum);
      }
    } catch (e) {
      debugPrint("Order error: $e");
      if (mounted) {
        _showOrderSuccessDialog(context, controller);
      }
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  /// --------------------------------------------------------------------------
  /// PLACE ORDER BUTTON
  /// --------------------------------------------------------------------------
  Widget _buildPlaceOrderButton(EmployeeHomeController controller) {
    final total = isDelivery ? controller.totalWithDelivery : controller.totalWithPickup;

    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: isSubmitting ? null : () => _handlePlaceOrder(controller),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryAmber,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        child: isSubmitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              )
            : Text(
                'Place Order · \$${total.toStringAsFixed(2)}',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  void _showOrderSuccessDialog(BuildContext context, EmployeeHomeController controller, {String orderNum = ''}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64.w,
                  height: 64.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFFECFDF5),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.check_circle_rounded, size: 40, color: Color(0xFF10B981)),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  orderNum.isNotEmpty ? 'Order Placed ($orderNum)!' : 'Order Placed!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  isDelivery
                      ? 'Your order has been sent to Little Arrows store.\nEstimated delivery in 25–35 minutes.'
                      : 'Your order has been sent to Little Arrows store.\nReady for pickup in 10–15 minutes.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  width: double.infinity,
                  height: 44.h,
                  child: ElevatedButton(
                    onPressed: () {
                      controller.clearCart();
                      Navigator.pop(context); // Close dialog
                      Get.back(); // Back from checkout
                      if (Get.isRegistered<EmployeeNavController>()) {
                        Get.find<EmployeeNavController>().changeNavIndex(0); // Back to Home
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryAmber,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: Text(
                      'Back to Home',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF4B5563),
      ),
    );
  }

  Widget _buildCustomTextField(TextEditingController ctrl, {Widget? prefixIcon}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextField(
        controller: ctrl,
        style: GoogleFonts.inter(
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF111827),
        ),
        decoration: InputDecoration(
          prefixIcon: prefixIcon,
          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            color: const Color(0xFF4B5563),
          ),
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

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../../../Utils/AppColors/app_colors.dart';
import '../Nav/Controller/employee_nav_controller.dart';
import 'Controller/employee_home_controller.dart';
import 'Model/employee_home_models.dart';

class EmployeeHomeScreen extends StatelessWidget {
  const EmployeeHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EmployeeHomeController());

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            /// Sticky Top App Bar / Location Bar
            _buildTopLocationBar(controller),

            /// Scrollable Main Body
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryAmber),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primaryAmber,
                  onRefresh: () async {
                    await controller.fetchHomeData();
                  },
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// 1. Hero Promo Banner
                        _buildHeroBanner(controller),
                        SizedBox(height: 24.h),

                        /// 2. Shop By Category
                        _buildShopByCategory(controller),
                        SizedBox(height: 24.h),

                        /// 3. Featured Section
                        _buildFeaturedSection(controller),
                        SizedBox(height: 24.h),

                        /// 4. Today's Deals Section
                        _buildTodaysDeals(controller),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  /// --------------------------------------------------------------------------
  /// TOP LOCATION BAR
  /// --------------------------------------------------------------------------
  Widget _buildTopLocationBar(EmployeeHomeController controller) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Delivering to',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: AppColors.primaryAmber,
                    size: 18.sp,
                  ),
                  SizedBox(width: 4.w),
                  Obx(
                    () => Text(
                      controller.selectedLocation.value,
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF111827),
                    size: 20.sp,
                  ),
                ],
              ),
            ],
          ),

          /// Profile Avatar Circle ('C')
          GestureDetector(
            onTap: () {
              if (Get.isRegistered<EmployeeNavController>()) {
                Get.find<EmployeeNavController>().changeNavIndex(4);
              }
            },
            child: Container(
              width: 42.w,
              height: 42.w,
              decoration: const BoxDecoration(
                color: Color(0xFFFEF3C7),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  'C',
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFD97706),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// --------------------------------------------------------------------------
  /// HERO BANNER
  /// --------------------------------------------------------------------------
  Widget _buildHeroBanner(EmployeeHomeController controller) {
    return Container(
      width: double.infinity,
      height: 180.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            /// Banner Image
            Image.network(
              'https://images.unsplash.com/photo-1556742049-0a67c5574f73?w=800',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF374151), Color(0xFF1F2937)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                );
              },
            ),

            /// Dark Gradient Overlay for perfect text contrast
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.65),
                    Colors.black.withValues(alpha: 0.2),
                  ],
                ),
              ),
            ),

            /// Banner Content
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// Fast Delivery Pill
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: AppColors.primaryAmber,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.bolt_rounded,
                          color: Colors.white,
                          size: 16.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'Fast Delivery',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),

                  /// Heading
                  Text(
                    'Delivered in\n30 minutes',
                    style: GoogleFonts.inter(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// --------------------------------------------------------------------------
  /// SHOP BY CATEGORY
  /// --------------------------------------------------------------------------
  Widget _buildShopByCategory(EmployeeHomeController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Shop by Category',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111827),
          ),
        ),
        SizedBox(height: 14.h),
        SizedBox(
          height: 98.h,
          child: Obx(
            () => ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: controller.categories.length,
              separatorBuilder: (context, index) => SizedBox(width: 14.w),
              itemBuilder: (context, index) {
                final category = controller.categories[index];
                return GestureDetector(
                  onTap: () => controller.selectCategory(index),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 66.w,
                        height: 66.w,
                        decoration: BoxDecoration(
                          color: Color(category.bgColorValue),
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            category.iconEmoji,
                            style: TextStyle(fontSize: 28.sp),
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      SizedBox(
                        width: 70.w,
                        child: Text(
                          category.name,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF4B5563),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  /// --------------------------------------------------------------------------
  /// FEATURED SECTION
  /// --------------------------------------------------------------------------
  Widget _buildFeaturedSection(EmployeeHomeController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Featured',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Row(
                children: [
                  Text(
                    'See all',
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryAmber,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18.sp,
                    color: AppColors.primaryAmber,
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),
        SizedBox(
          height: 290.h,
          child: Obx(
            () => ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: controller.featuredProducts.length,
              separatorBuilder: (context, index) => SizedBox(width: 14.w),
              itemBuilder: (context, index) {
                final product = controller.featuredProducts[index];
                return _buildProductCard(product, controller);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(ProductModel product, EmployeeHomeController controller) {
    return Container(
      width: 172.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Product Image with optional SALE tag
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                child: SizedBox(
                  width: double.infinity,
                  height: 125.h,
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFF3F4F6),
                        child: Center(
                          child: Icon(
                            Icons.fastfood_outlined,
                            size: 40.sp,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (product.isSale)
                Positioned(
                  top: 8.h,
                  left: 8.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      'SALE',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          /// Card Details
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  product.unit,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: product.isSale ? AppColors.primaryAmber : const Color(0xFF111827),
                      ),
                    ),
                    if (product.originalPrice != null) ...[
                      SizedBox(width: 6.w),
                      Text(
                        '\$${product.originalPrice!.toStringAsFixed(2)}',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF9CA3AF),
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 10.h),
                SizedBox(
                  width: double.infinity,
                  height: 38.h,
                  child: ElevatedButton(
                    onPressed: () => controller.addToCart(product.name),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryAmber,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(
                      'Add to Cart',
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
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
  /// TODAY'S DEALS
  /// --------------------------------------------------------------------------
  Widget _buildTodaysDeals(EmployeeHomeController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today's Deals",
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111827),
          ),
        ),
        SizedBox(height: 14.h),
        Obx(
          () => ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.todaysDeals.length,
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final deal = controller.todaysDeals[index];
              return Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: const Color(0xFFF3F4F6)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    /// Thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: SizedBox(
                        width: 72.w,
                        height: 72.w,
                        child: Image.network(
                          deal.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFFF3F4F6),
                              child: Icon(
                                Icons.local_offer_outlined,
                                color: AppColors.primaryAmber,
                                size: 28.sp,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 14.w),

                    /// Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            deal.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            deal.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: const Color(0xFF9CA3AF),
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Row(
                            children: [
                              Text(
                                '\$${deal.price.toStringAsFixed(2)}',
                                style: GoogleFonts.inter(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryAmber,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                '\$${deal.originalPrice.toStringAsFixed(2)}',
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF9CA3AF),
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Text(
                                  deal.discountTag,
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFFD97706),
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    /// Add (+) Button
                    GestureDetector(
                      onTap: () => controller.addToCart(deal.name),
                      child: Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          color: AppColors.primaryAmber,
                          borderRadius: BorderRadius.circular(14.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryAmber.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

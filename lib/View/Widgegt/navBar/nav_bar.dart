import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../Utils/AppColors/app_colors.dart';

class NavBarItem {
  final IconData selectedIcon;
  final IconData unselectedIcon;
  final String label;

  const NavBarItem({
    required this.selectedIcon,
    required this.unselectedIcon,
    required this.label,
  });
}

class NavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final int cartCount;

  const NavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.cartCount = 0,
  });

  static const List<NavBarItem> defaultItems = [
    NavBarItem(
      selectedIcon: Icons.home_rounded,
      unselectedIcon: Icons.home_outlined,
      label: 'Home',
    ),
    NavBarItem(
      selectedIcon: Icons.search_rounded,
      unselectedIcon: Icons.search_rounded,
      label: 'Browse',
    ),
    NavBarItem(
      selectedIcon: Icons.shopping_cart_rounded,
      unselectedIcon: Icons.shopping_cart_outlined,
      label: 'Cart',
    ),
    NavBarItem(
      selectedIcon: Icons.access_time_filled_rounded,
      unselectedIcon: Icons.access_time_rounded,
      label: 'Orders',
    ),
    NavBarItem(
      selectedIcon: Icons.person_rounded,
      unselectedIcon: Icons.person_outline_rounded,
      label: 'Account',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(defaultItems.length, (index) {
              final item = defaultItems[index];
              final isSelected = currentIndex == index;
              final isCart = index == 2;

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /// Active Top Indicator Line
                      Container(
                        height: 3.h,
                        width: 32.w,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryAmber : Colors.transparent,
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(3.r)),
                        ),
                      ),

                      /// Icon with Cart Badge
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            isSelected ? item.selectedIcon : item.unselectedIcon,
                            size: 24.sp,
                            color: isSelected ? AppColors.primaryAmber : const Color(0xFF9CA3AF),
                          ),
                          if (isCart && cartCount > 0)
                            Positioned(
                              right: -8.w,
                              top: -4.h,
                              child: Container(
                                padding: EdgeInsets.all(4.w),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEF4444),
                                  shape: BoxShape.circle,
                                ),
                                constraints: BoxConstraints(minWidth: 16.w, minHeight: 16.w),
                                child: Text(
                                  cartCount > 99 ? '99+' : cartCount.toString(),
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),

                      /// Label
                      Text(
                        item.label,
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? AppColors.primaryAmber : const Color(0xFF9CA3AF),
                        ),
                      ),
                      SizedBox(height: 4.h),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

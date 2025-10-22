import 'package:flutter/material.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  
  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF42A5F5), // Blue from upper navbar
            Color(0xFFE91E63), // Pink from upper navbar
          ],
          stops: [0.0, 1.0],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE91E63).withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home, // Home is now first
                label: 'Home',
                index: 0,
                isActive: currentIndex == 0,
              ),
              _buildNavItem(
                icon: Icons.favorite,
                label: 'Friends',
                index: 1,
                isActive: currentIndex == 1,
              ),
              _buildNavItem(
                icon: Icons.chat,
                label: 'Messages',
                index: 2,
                isActive: currentIndex == 2,
              ),
              _buildNavItem(
                icon: Icons.group,
                label: 'Discover',
                index: 3,
                isActive: currentIndex == 3,
              ),
              _buildNavItem(
                icon: Icons.person, // Profile is now last
                label: 'Profile',
                index: 4,
                isActive: currentIndex == 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive 
            ? Colors.white.withOpacity(0.2) 
            : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isActive ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive 
                ? Colors.white 
                : Colors.black,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive 
                  ? Colors.white 
                  : Colors.black,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  void _navigateToPage(BuildContext context, int index) {
    // Prevent duplicate navigation
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, 'home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, 'collection');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, 'camera');
        break;
      case 3:
        // AI Chat Bot - future use, no navigation for now
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('AI Chat Bot - Coming soon!'),
            duration: Duration(milliseconds: 800),
          ),
        );
        break;
      case 4:
        Navigator.pushReplacementNamed(context, 'profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        currentIndex: currentIndex,
        onTap: (index) {
          onTap(index);
          _navigateToPage(context, index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dashboard'),
          BottomNavigationBarItem(
            icon: Icon(Icons.collections),
            label: 'Collection',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'Scan'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'AI Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        selectedItemColor: const Color(0xFF1E6FE8),
        unselectedItemColor: Colors.grey.shade500,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

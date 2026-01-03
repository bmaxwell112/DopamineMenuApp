import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dopamine_menu/models/user.dart'; 
import 'package:dopamine_menu/models/dopMenu.dart'; 

class DopamineAppBar extends StatelessWidget implements PreferredSizeWidget {
  final UserProfile? user;
  final VoidCallback onAddPressed;

  const DopamineAppBar({
    super.key, 
    required this.user, 
    required this.onAddPressed
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 28),
        onPressed: onAddPressed,
      ),
      centerTitle: true,
      title: const Text(
        "DOPAMINE MENU",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.white54),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.yellow.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.yellow.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.stars, color: Colors.yellow, size: 18),
                  const SizedBox(width: 6),
                  Text("${user?.totalPoints ?? 0}",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60.0);
}

class DopamineNavBar extends StatelessWidget {
  final int selectedIndex;
  final MenuCategory selectedCategory;
  final UserProfile? user;
  final Function(int, MenuCategory?) onSelect;

  const DopamineNavBar({
    super.key,
    required this.selectedIndex,
    required this.selectedCategory,
    required this.user,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.only(bottom: 20, top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navButton(Icons.bakery_dining, MenuCategory.starter, 0),
          _navButton(Icons.set_meal, MenuCategory.entree, 1),
          _navButton(Icons.restaurant, MenuCategory.side, 2),
          _navButton(Icons.icecream, MenuCategory.dessert, 3),
          _profileButton(),
        ],
      ),
    );
  }

  Widget _navButton(IconData icon, MenuCategory category, int index) {
    bool isActive = selectedIndex == index && selectedCategory == category;
    return GestureDetector(
      onTap: () => onSelect(index, category),
      child: CircleAvatar(
        radius: 20,
        backgroundColor: isActive ? Colors.white : Colors.grey[900],
        child: Icon(icon, color: isActive ? Colors.black : Colors.white),
      ),
    );
  }

  Widget _profileButton() {
    bool isActive = selectedIndex == 4;
    return GestureDetector(
      onTap: () => onSelect(4, null),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: isActive ? Colors.white : Colors.transparent, width: 1.5),
        ),
        child: CircleAvatar(
          radius: 14,
          backgroundColor: Colors.grey[900],
          backgroundImage: (user?.avatar != null && user!.avatar.isNotEmpty) ? FileImage(File(user!.avatar)) : null,
          child: (user?.avatar == null || user!.avatar.isEmpty)
              ? Icon(Icons.person_outline, size: 20, color: isActive ? Colors.black : Colors.white)
              : null,
        ),
      ),
    );
  }
}
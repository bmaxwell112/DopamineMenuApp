import 'package:flutter/material.dart';
import 'package:dopamine_menu/models/dopMenu.dart';
import 'package:dopamine_menu/models/user.dart';
import 'package:dopamine_menu/database/databaseHelper.dart';

class HomeController extends ChangeNotifier {
  // --- Data State ---
  List<DopMenu> allDbItems = [];
  UserProfile? currentUser;
  bool isLoading = true;
  bool _isJumping = false;

  // --- Navigation State ---
  int selectedIndex = 0;
  MenuCategory selectedCategory = MenuCategory.starter;
  int? targetItemIndex;

  final List<MenuCategory> categories = MenuCategory.values;

  // Initialize the App
  Future<void> init() async {
    isLoading = true;
    notifyListeners();

    await DatabaseHelper.instance.checkAndResetDailyPoints();
    await refreshData();

    isLoading = false;
    notifyListeners();
  }

  // Refresh data from Database
  Future<void> refreshData() async {
    allDbItems = await DatabaseHelper.instance.readAllItems();
    currentUser = await DatabaseHelper.instance.getUser();
    notifyListeners();
  }

  // Handle Point Completion
  Future<void> completeItem(int points) async {
    await DatabaseHelper.instance.addPoints(points);
    await refreshData();
  }

  // Navigation Logic
  void updateNavigation(int index, MenuCategory? category, PageController categoryController) {
    // If this was called from a Swipe, but we are in the middle of a Button Jump, ignore it.
    if (_isJumping && category != null) return; 
  
    selectedIndex = index;
    
    if (category != null) {
      selectedCategory = category;
      targetItemIndex = null;
      
      if (categoryController.hasClients) {
        _isJumping = true; // Set flag before animating
        categoryController.animateToPage(
          categories.indexOf(category),
          duration: const Duration(milliseconds: 400), // Slightly slower for smoothness
          curve: Curves.easeInOut,
        ).then((_) => _isJumping = false); // Reset flag when done
      }
    }
    notifyListeners();
  }

  // Logic for jumping from Favorites
  void jumpToFavorite(DopMenu item, PageController categoryController) {
    int catIndex = categories.indexOf(item.category);

    // Get the items for this category
    final catItems = allDbItems.where((i) => i.category == item.category).toList();

    // SEARCH BY ID instead of object instance
    int itemIndex = catItems.indexWhere((i) => i.id == item.id);

    // Safety check: if for some reason it's still not found, default to 0
    if (itemIndex == -1) itemIndex = 0;

    selectedIndex = catIndex;
    selectedCategory = item.category;
    targetItemIndex = itemIndex;

    notifyListeners();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (categoryController.hasClients) {
        categoryController.jumpToPage(catIndex);
      }
    });
  }

  void clearTarget() {
    targetItemIndex = null;
    // We don't necessarily need notifyListeners here 
    // unless you want to force a specific UI change
  }
}
import 'package:flutter/material.dart';
import 'package:dopamine_menu/views/addItem.dart';
import 'package:dopamine_menu/views/registrationScreen.dart';
import 'package:dopamine_menu/views/profileView.dart';
import 'package:dopamine_menu/views/navigation.dart';
import 'package:dopamine_menu/controllers/homeController.dart';
import 'package:dopamine_menu/views/categoryPageView.dart';

void main() => runApp(const DopamineApp());

class DopamineApp extends StatelessWidget {
  const DopamineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController _controller = HomeController();
  final PageController _categoryPageController = PageController();

  @override
  void initState() {
    super.initState();
    _controller.init();
    // Listen for changes to trigger rebuilds
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_controller.currentUser == null) {
      return RegistrationScreen(onUserCreated: _controller.init);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _controller.selectedIndex == 4 
          ? null 
          : DopamineAppBar(
              user: _controller.currentUser, 
              onAddPressed: () => AddItemSheet.show(context, _controller.selectedCategory, _controller.refreshData)
            ),
      body: _buildBody(),
      bottomNavigationBar: DopamineNavBar(
        selectedIndex: _controller.selectedIndex,
        selectedCategory: _controller.selectedCategory,
        user: _controller.currentUser,
        onSelect: (index, cat) => _controller.updateNavigation(index, cat, _categoryPageController),
      ),
    );
  }

  Widget _buildBody() {
    // Profile View logic
    if (_controller.selectedIndex == 4) {
      return ProfileView(
        user: _controller.currentUser!,
        onUpdate: _controller.refreshData,
        onSelectFavorite: (item) => _controller.jumpToFavorite(item, _categoryPageController),
      );
    }
  
    // Main Menu logic
    return PageView.builder(
      controller: _categoryPageController,
      itemCount: _controller.categories.length,
      onPageChanged: (index) {
        // Only trigger if it's a real change and NOT a profile view (index 4)
        if (index != _controller.selectedIndex && index < _controller.categories.length) {
          _controller.updateNavigation(
            index, 
            _controller.categories[index], 
            _categoryPageController
          );
        }
      },
      itemBuilder: (context, catIndex) {
        final category = _controller.categories[catIndex];
        final categoryItems = _controller.allDbItems
            .where((item) => item.category == category)
            .toList();
        final targetItemIndex = _controller.targetItemIndex;
        return CategoryPageView(
          category: category,
          items: categoryItems,
          targetItemIndex: targetItemIndex,
          onRefresh: _controller.refreshData,
        );
      },
    );
  }
}
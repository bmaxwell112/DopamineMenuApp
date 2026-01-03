import 'package:flutter/material.dart';
import 'package:dopamine_menu/models/dopMenu.dart';
import 'package:dopamine_menu/views/menuFullScreenCard.dart';

class CategoryPageView extends StatefulWidget { // Change to StatefulWidget
  final MenuCategory category;
  final List<DopMenu> items;
  final int? targetItemIndex;
  final Future<void> Function() onRefresh;

  const CategoryPageView({
    super.key,
    required this.category,
    required this.items,
    this.targetItemIndex,
    required this.onRefresh,
  });

  @override
  State<CategoryPageView> createState() => _CategoryPageViewState();
}

class _CategoryPageViewState extends State<CategoryPageView> {
  late PageController _verticalController;

  @override
  void initState() {
    super.initState();
    _verticalController = PageController(initialPage: widget.targetItemIndex ?? 0);
  }

  @override
  void didUpdateWidget(CategoryPageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Check if a new target index was provided and it's different from before
    if (widget.targetItemIndex != null && 
        widget.targetItemIndex != oldWidget.targetItemIndex) {
      
      // Use jumpToPage to move immediately without animation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_verticalController.hasClients) {
          _verticalController.jumpToPage(widget.targetItemIndex!);
        }
      });
    }
  }

  @override
  void dispose() {
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return _buildEmptyState();

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: PageView.builder(
        scrollDirection: Axis.vertical,
        controller: _verticalController, // Use the initialized controller
        itemBuilder: (context, itemIndex) {
          final item = widget.items[itemIndex % widget.items.length];
          return MenuFullScreenCard(
            key: ValueKey("${item.id}_${widget.category.name}"),
            item: item,
            onDelete: widget.onRefresh,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.hourglass_empty, color: Colors.grey, size: 64),
          const SizedBox(height: 16),
          Text(
            "No ${widget.category.name}s available",
            style: const TextStyle(color: Colors.white54, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dopamine_menu/models/user.dart';
import 'package:dopamine_menu/database/databaseHelper.dart';
import 'package:dopamine_menu/views/registrationScreen.dart';
import 'package:dopamine_menu/models/dopMenu.dart';

class ProfileView extends StatelessWidget {
  final UserProfile user;
  final VoidCallback onUpdate;
  final Function(DopMenu) onSelectFavorite;

  const ProfileView({super.key, required this.user, required this.onUpdate, required this.onSelectFavorite});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          // Sleek Header
          SliverAppBar(
            expandedHeight: 300,
            backgroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _buildAvatar(),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // User Info & Stats
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "@${user.username}",
                    style: const TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                  const SizedBox(height: 30),
                  
                  // Points Display
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.yellow.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatColumn("POINTS", user.totalPoints.toString()),
                        _buildStatColumn("FAVORITES", user.favoriteIds.length.toString()),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _editProfile(context),
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text("EDIT PROFILE"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white24),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverToBoxAdapter(
              child: Text(
                "MY FAVORITES",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5),
              ),
            ),
          ),
          FutureBuilder<List<DopMenu>>(
            future: DatabaseHelper.instance.readAllItems().then((items) => 
              items.where((i) => user.favoriteIds.contains(i.id)).toList()),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(child: Text("No favorites yet", style: TextStyle(color: Colors.white24))),
                );
              }

              final favs = snapshot.data!;
              return SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => GestureDetector(
                    onTap: () => onSelectFavorite(favs[index]),
                    onLongPress: () async {
                      await DatabaseHelper.instance.toggleFavorite(favs[index].id!);
                      onUpdate();
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _buildGridImage(favs[index]), // Now this is defined!
                    ),
                  ),
                  childCount: favs.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    if (user.avatar.isEmpty) {
      return Container(
        color: Colors.grey[800],
        child: const Icon(Icons.person, size: 100, color: Colors.white24),
      );
    }
    return Image.file(File(user.avatar), fit: BoxFit.cover);
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 1)),
      ],
    );
  }

  Widget _buildGridImage(DopMenu item) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // The Image Base
        _buildImageSource(item),
  
        // Top Category Label
        Positioned(
          top: 4,
          left: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              item.category.name.toUpperCase(),
              style: const TextStyle(
                color: Colors.yellow,
                fontSize: 8,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
  
        // Bottom Title Overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.8), Colors.transparent],
              ),
            ),
            padding: const EdgeInsets.all(6),
            child: Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  // Helper to keep the Stack clean
  Widget _buildImageSource(DopMenu item) {
    if (item.image.isEmpty) {
      return Container(color: Colors.grey[900], child: const Icon(Icons.fastfood, color: Colors.white10));
    }
  
    if (item.image.startsWith('http')) {
      return Image.network(item.image, fit: BoxFit.cover);
    } else if (item.image.startsWith('assets/')) {
      return Image.asset(item.image, fit: BoxFit.cover);
    } else {
      return Image.file(File(item.image), fit: BoxFit.cover);
    }
  }

  void _editProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegistrationScreen(
          onUserCreated: onUpdate, // This refreshes the ProfileView when done
          userToEdit: user,
        ),
        fullscreenDialog: true, // Makes it feel like an edit overlay
      ),
    );
  }
}
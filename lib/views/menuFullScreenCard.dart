import 'dart:io'; 
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:dopamine_menu/models/dopMenu.dart';
import 'package:dopamine_menu/database/databaseHelper.dart';
import 'package:dopamine_menu/views/addItem.dart';

class MenuFullScreenCard extends StatefulWidget {
  final DopMenu item;
  final VoidCallback onDelete;

  const MenuFullScreenCard({super.key, required this.item, required this.onDelete});

  @override
  State<MenuFullScreenCard> createState() => _MenuFullScreenCardState();
}

class _MenuFullScreenCardState extends State<MenuFullScreenCard> {
  late ConfettiController _confettiController;
  bool _isFavorited = false;

  @override
  void initState() {
    super.initState();
    // Duration defines how long the confetti shoots
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
    _checkIfFavorited();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Widget _buildBackground() {
    if (widget.item.image.isEmpty) {
      return Container(color: Colors.grey[900]);
    }
    
    if (widget.item.image.startsWith('http')) {
      return Image.network(
        widget.item.image, 
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[900]),
      );
    } else if (widget.item.image.startsWith('assets/')) {
      return Image.asset(
        widget.item.image, 
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[900]),
      );
    } else {
      // For images picked from gallery/camera stored on device
      return Image.file(
        File(widget.item.image),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[900]),
      );
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text("Delete Item?", style: TextStyle(color: Colors.white)),
          content: Text("Are you sure you want to remove '${widget.item.title}'?", style: const TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCEL", style: TextStyle(color: Colors.white54)),
            ),
            TextButton(
              onPressed: () async {
                if (widget.item.id != null) {
                  await DatabaseHelper.instance.delete(widget.item.id!);
                  widget.onDelete();
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text("DELETE", style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _checkIfFavorited() async {
    final user = await DatabaseHelper.instance.getUser();
    if (user != null && mounted) {
      setState(() {
        _isFavorited = user.favoriteIds.contains(widget.item.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background Image
        _buildBackground(),

        // Gradient Overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.4),
                Colors.transparent,
                Colors.black.withOpacity(0.9)
              ],
              stops: const [0.0, 0.4, 0.9],
            ),
            
          ),
        ),

        // TOP RIGHT: Management Buttons
        Positioned(
          top: 50,
          right: 10,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white70, size: 26),
                onPressed: () => AddItemSheet.show(context, widget.item.category, widget.onDelete, itemToEdit: widget.item),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white54, size: 26),
                onPressed: () => _confirmDelete(context),
              ),
              IconButton(
                icon: Icon(
                  _isFavorited ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorited ? Colors.red : Colors.white70,
                  size: 28,
                ),
                onPressed: () async {
                  await DatabaseHelper.instance.toggleFavorite(widget.item.id!);
                  setState(() {
                    _isFavorited = !_isFavorited;
                  });
                  // Optional: provide a refresh to the profile if it's open
                  widget.onDelete(); 
                },
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive, // Shoots in all directions
            shouldLoop: false,
            colors: const [Colors.yellow, Colors.white, Colors.orange, Colors.blue],
            numberOfParticles: 20,
            gravity: 0.1,
          ),
        ),
        // BOTTOM CONTENT: Info & Complete Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.item.category.name.toUpperCase(),
                style: const TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                widget.item.title,
                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                widget.item.description,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 24),
              
              // Points Display and Complete Button Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Points Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Text(
                      '${widget.item.points} PTS',
                      style: const TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold),
                    ),
                  ),

                  // COMPLETE BUTTON
                  ElevatedButton.icon(
                    onPressed: () async {
                      _confettiController.play();
                      await DatabaseHelper.instance.addPoints(widget.item.points);
                      widget.onDelete(); // Refresh UI to update total points in Top Bar
                      
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Success! +${widget.item.points} Dopamine Points"),
                            backgroundColor: Colors.green[700],
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.check_circle_outline, size: 20),
                    label: const Text("COMPLETE", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60), // Navigation Bar Padding
            ],
          ),
        ),
      ],
    );
  }
}
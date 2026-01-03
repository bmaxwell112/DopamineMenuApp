import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dopamine_menu/models/dopMenu.dart';
import 'package:dopamine_menu/database/databaseHelper.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class AddItemSheet {
  static void show(
    BuildContext context, 
    MenuCategory initialCategory, 
    VoidCallback onComplete, 
    {DopMenu? itemToEdit}
  ) {
    // Pre-fill controllers if editing, otherwise leave empty
    final titleController = TextEditingController(text: itemToEdit?.title ?? '');
    final descController = TextEditingController(text: itemToEdit?.description ?? '');
    final pointsController = TextEditingController(text: itemToEdit?.points.toString() ?? '10');
    final String? existingImagePath = itemToEdit?.image;
    
    MenuCategory selectedCat = itemToEdit?.category ?? initialCategory;
    String? tempImagePath = existingImagePath;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20, right: 20, top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  itemToEdit == null ? "Add New Item" : "Edit Item", 
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  ),
                ),
                TextField(
                  controller: descController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  ),
                ),
                // --- NEW POINTS FIELD ---
                TextField(
                  controller: pointsController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number, // Shows numeric keypad
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Prevents letters/decimals
                  decoration: const InputDecoration(
                    labelText: 'Points',
                    hintText: 'e.g. 10, 50, 100',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.image, color: Colors.blue),
                  label: Text(tempImagePath == null ? "Pick Image" : "Image Selected!", 
                         style: const TextStyle(color: Colors.blue)),
                  onPressed: () async {
                    final picker = ImagePicker();
                    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

                    if (pickedFile != null) {
                      // Get the app's permanent directory
                      final directory = await getApplicationDocumentsDirectory();
                      final fileName = p.basename(pickedFile.path);
                      final savedPath = p.join(directory.path, fileName);

                      // Copy the file from temp to permanent storage
                      await File(pickedFile.path).copy(savedPath);

                      setModalState(() {
                        tempImagePath = savedPath; // Store this path to save in DB
                      });
                    }
                  },
                ),
                const SizedBox(height: 20),
                DropdownButton<MenuCategory>(
                  value: selectedCat,
                  dropdownColor: Colors.grey[900],
                  isExpanded: true,
                  items: MenuCategory.values.map((cat) {
                    return DropdownMenuItem(
                      value: cat, 
                      child: Text(cat.name.toUpperCase(), style: const TextStyle(color: Colors.white))
                    );
                  }).toList(),
                  onChanged: (val) => setModalState(() => selectedCat = val!),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, minimumSize: const Size(double.infinity, 50)),
                  onPressed: () async {
                    if (titleController.text.isNotEmpty) {
                      final updatedItem = DopMenu(
                        id: itemToEdit?.id, // Crucial: keep the same ID for updates
                        category: selectedCat,
                        title: titleController.text,
                        description: descController.text,
                        points: int.tryParse(pointsController.text) ?? 10,
                        image: tempImagePath ?? '',
                      );

                      if (itemToEdit == null) {
                        await DatabaseHelper.instance.create(updatedItem);
                      } else {
                        await DatabaseHelper.instance.update(updatedItem); // Call update
                      }
                      
                      onComplete();
                      Navigator.pop(context);
                    }
                  },
                  child: Text(itemToEdit == null ? "Save to Menu" : "Update Item"),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
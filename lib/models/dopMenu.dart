class DopMenu {
  final int? id;
  final MenuCategory category;
  final String title;
  final String description;
  final String image;
  final int points;

  DopMenu({
    this.id,
    required this.category,
    required this.title,
    required this.description,
    this.image = '',
    this.points = 10,
  });

  // Convert a Map (from DB) into a DopMenu object
  factory DopMenu.fromMap(Map<String, dynamic> map) {
    return DopMenu(
      id: map['id'],
      category: MenuCategory.values.firstWhere((e) => e.name == map['category']),
      title: map['title'],
      description: map['description'],
      image: map['image'],
      points: map['points'],
    );
  }

  // Convert a DopMenu object into a Map (to save to DB)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category.name, // Store enum as string
      'title': title,
      'description': description,
      'image': image,
      'points': points,
    };
  }
}

enum MenuCategory { starter, entree, side, dessert }
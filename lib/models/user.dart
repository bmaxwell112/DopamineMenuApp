class UserProfile {
  final int? id;
  final String username;
  final String name;
  final String dob;
  final String avatar;
  final int totalPoints;
  final List<int> favoriteIds;
  final String lastResetDate;

  UserProfile({
    this.id,
    required this.username,
    required this.name,
    required this.dob,
    this.avatar = '',
    this.totalPoints = 0,
    this.favoriteIds = const [],
    required this.lastResetDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'dob': dob,
      'avatar': avatar,
      'totalPoints': totalPoints,
      'favorites': favoriteIds.join(','), // Convert list to "1,2,3"
      'lastResetDate': lastResetDate,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      username: map['username'],
      name: map['name'],
      dob: map['dob'],
      avatar: map['avatar'] ?? '',
      totalPoints: map['totalPoints'] ?? 0,
      favoriteIds: map['favorites'] != null && map['favorites'].toString().isNotEmpty
          ? map['favorites'].toString().split(',').map(int.parse).toList()
          : [],
      lastResetDate: map['lastResetDate'] ?? '',
    );
  }
}
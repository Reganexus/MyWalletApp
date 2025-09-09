import 'dart:typed_data';

class Profile {
  final int? id;
  final String username;
  final Uint8List? profileImage;
  final String? colorPreference;

  Profile({
    this.id,
    required this.username,
    this.profileImage,
    this.colorPreference,
  });

  Profile copyWith({
    int? id,
    String? username,
    Uint8List? profileImage,
    String? colorPreference,
  }) {
    return Profile(
      id: id ?? this.id,
      username: username ?? this.username,
      profileImage: profileImage,
      colorPreference: colorPreference ?? this.colorPreference,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'profile_image': profileImage,
      'color_preference': colorPreference,
    };
  }

  factory Profile.fromMap(Map<String, dynamic> map) {
    Uint8List? imageBytes;

    if (map['profile_image'] != null) {
      if (map['profile_image'] is Uint8List) {
        imageBytes = map['profile_image'] as Uint8List;
      } else if (map['profile_image'] is List<int>) {
        imageBytes = Uint8List.fromList(map['profile_image'] as List<int>);
      }
    }

    return Profile(
      id: map['id'] as int?,
      username: map['username'] ?? '',
      profileImage: imageBytes,
      colorPreference: map['color_preference'] as String?,
    );
  }
}

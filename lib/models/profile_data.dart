class ProfileData {
  const ProfileData({
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
    required this.dob,
    required this.bio,
    required this.photoUrl,
    required this.pushEnabled,
    required this.soundEnabled,
    required this.notificationCategories,
    required this.focusAreas,
  });

  final String name;
  final String email;
  final String phone;
  final String location;
  final String dob;
  final String bio;
  final String photoUrl;
  final bool pushEnabled;
  final bool soundEnabled;
  final Map<String, bool> notificationCategories;
  final List<String> focusAreas;

  factory ProfileData.fromMap(
    Map<String, dynamic>? map, {
    required String fallbackName,
    required String fallbackEmail,
    required String fallbackPhotoUrl,
  }) {
    final categoriesRaw = map?['notificationCategories'];
    final focusRaw = map?['focusAreas'];
    final categories = <String, bool>{
      'goals': true,
      'finance': true,
      'health': true,
      'wellness': false,
      'analytics': true,
      'email': false,
    };

    if (categoriesRaw is Map) {
      for (final entry in categoriesRaw.entries) {
        final key = entry.key.toString();
        final value = entry.value;
        categories[key] = value == true;
      }
    }

    return ProfileData(
      name: map?['name'] as String? ?? fallbackName,
      email: map?['email'] as String? ?? fallbackEmail,
      phone: map?['phone'] as String? ?? '',
      location: map?['location'] as String? ?? '',
      dob: map?['dob'] as String? ?? '',
      bio: map?['bio'] as String? ?? '',
      photoUrl: map?['photoUrl'] as String? ?? fallbackPhotoUrl,
      pushEnabled: map?['pushEnabled'] as bool? ?? true,
      soundEnabled: map?['soundEnabled'] as bool? ?? true,
      notificationCategories: categories,
      focusAreas: focusRaw is List
          ? focusRaw.map((e) => e.toString()).toList(growable: false)
          : const <String>[],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'location': location,
      'dob': dob,
      'bio': bio,
      'photoUrl': photoUrl,
      'pushEnabled': pushEnabled,
      'soundEnabled': soundEnabled,
      'notificationCategories': notificationCategories,
      'focusAreas': focusAreas,
    };
  }

  ProfileData copyWith({
    String? name,
    String? email,
    String? phone,
    String? location,
    String? dob,
    String? bio,
    String? photoUrl,
    bool? pushEnabled,
    bool? soundEnabled,
    Map<String, bool>? notificationCategories,
    List<String>? focusAreas,
  }) {
    return ProfileData(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      dob: dob ?? this.dob,
      bio: bio ?? this.bio,
      photoUrl: photoUrl ?? this.photoUrl,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      notificationCategories: notificationCategories ?? this.notificationCategories,
      focusAreas: focusAreas ?? this.focusAreas,
    );
  }
}



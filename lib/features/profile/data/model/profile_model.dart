/// Profile model representing user profile data
class ProfileModel {
  final int id;
  final String username;
  final String? email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String fullName;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProfileModel({
    required this.id,
    required this.username,
    this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.fullName,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
  return ProfileModel(
    id: json['id'] ?? 0,
    username: json['username'] ?? "",
    email: json['email'] ?? "",
    firstName: json['firstName'] ?? "",
    lastName: json['lastName'] ?? "",
    phoneNumber: json['phoneNumber'] ?? "",
    fullName: json['fullName'] ?? "",
    isActive: json['isActive'] ?? false,
    createdAt: json['createdAt'] != null 
        ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
        : DateTime.now(),
    updatedAt: json['updatedAt'] != null 
        ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
        : DateTime.now(),
  );
}

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'fullName': fullName,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Creates a copy of this ProfileModel with the given fields replaced
  ProfileModel copyWith({
    int? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? fullName,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fullName: fullName ?? this.fullName,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ProfileModel(id: $id, username: $username, email: $email, '
        'firstName: $firstName, lastName: $lastName, phoneNumber: $phoneNumber, '
        'fullName: $fullName, isActive: $isActive, createdAt: $createdAt, '
        'updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProfileModel &&
        other.id == id &&
        other.username == username &&
        other.email == email &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.phoneNumber == phoneNumber &&
        other.fullName == fullName &&
        other.isActive == isActive &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      username,
      email,
      firstName,
      lastName,
      phoneNumber,
      fullName,
      isActive,
      createdAt,
      updatedAt,
    );
  }
}
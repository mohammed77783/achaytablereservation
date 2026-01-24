class UserModel {
  final int id;
  final String username;
  final String? email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final bool isActive;
  final List<String> roles;

  const UserModel({
    required this.id,
    required this.username,
    this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.isActive,
    required this.roles,
  });

  /// Computed full name
  String get fullName => '$firstName $lastName';

  /// Create from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String?,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phoneNumber: json['phoneNumber'] as String,
      isActive: json['isActive'] as bool? ?? true,
      roles: json['roles'] != null
          ? List<String>.from(json['roles'] as List)
          : <String>[],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'isActive': isActive,
      'roles': roles,
    };
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    int? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    bool? isActive,
    List<String>? roles,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isActive: isActive ?? this.isActive,
      roles: roles ?? this.roles,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, username: $username, email: $email, firstName: $firstName, lastName: $lastName, phoneNumber: $phoneNumber, isActive: $isActive, roles: $roles)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.id == id &&
        other.username == username &&
        other.email == email &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.phoneNumber == phoneNumber &&
        other.isActive == isActive &&
        _listEquals(other.roles, roles);
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
      isActive,
      roles,
    );
  }

  /// Helper method to compare lists
  bool _listEquals<E>(List<E>? a, List<E>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}

/// Request model for updating profile
class UpdateProfileRequest {
  final String? username;
  final String? email;
  final String? firstName;
  final String? lastName;

  UpdateProfileRequest({
    this.username,
    this.email,
    this.firstName,
    this.lastName,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (username != null) json['username'] = username;
    if (email != null) json['email'] = email;
    if (firstName != null) json['firstName'] = firstName;
    if (lastName != null) json['lastName'] = lastName;
    return json;
  }

  @override
  String toString() {
    return 'UpdateProfileRequest(username: $username, email: $email, '
        'firstName: $firstName, lastName: $lastName)';
  }
}

/// Request model for updating password
class UpdatePasswordRequest {
  final String oldPassword;
  final String newPassword;
  final String confirmPassword;

  UpdatePasswordRequest({
    required this.oldPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    };
  }

  @override
  String toString() {
    return 'UpdatePasswordRequest(oldPassword: ***, newPassword: ***, '
        'confirmPassword: ***)';
  }
}

/// Request model for changing phone number
class ChangePhoneNumberRequest {
  final String newPhoneNumber;

  ChangePhoneNumberRequest({
    required this.newPhoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'newPhoneNumber': newPhoneNumber,
    };
  }

  @override
  String toString() {
    return 'ChangePhoneNumberRequest(newPhoneNumber: $newPhoneNumber)';
  }
}

/// Request model for verifying phone number change
class VerifyPhoneChangeRequest {
  final String newPhoneNumber;
  final String otpCode;

  VerifyPhoneChangeRequest({
    required this.newPhoneNumber,
    required this.otpCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'newPhoneNumber': newPhoneNumber,
      'otpCode': otpCode,
    };
  }

  @override
  String toString() {
    return 'VerifyPhoneChangeRequest(newPhoneNumber: $newPhoneNumber, '
        'otpCode: $otpCode)';
  }
}

/// Request model for deleting account
class DeleteAccountRequest {
  final String password;

  DeleteAccountRequest({
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'password': password,
    };
  }

  @override
  String toString() {
    return 'DeleteAccountRequest(password: ***)';
  }
}
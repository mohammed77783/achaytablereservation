import 'dart:convert';

import 'package:achaytablereservation/core/constants/storage_constants.dart';
import 'package:achaytablereservation/core/services/storage_service.dart';
import 'package:achaytablereservation/core/shared/model/user_model.dart';
import 'package:achaytablereservation/features/profile/data/model/profile_model.dart';
import 'package:achaytablereservation/features/profile/data/repositories/profile_repository.dart';
import 'package:achaytablereservation/features/homepage/logic/homepage_controller.dart';
import 'package:achaytablereservation/features/authentication/logic/authstate_Controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:achaytablereservation/core/base/base_controller.dart';

/// Controller for Update Profile screen
class UpdateProfileController extends BaseController {
  final ProfileRepository _profileRepository;
  final _storage = Get.find<StorageService>();
  UpdateProfileController({required ProfileRepository profileRepository})
    : _profileRepository = profileRepository;

  // Text Controllers
  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;

  // Form key
  final formKey = GlobalKey<FormState>();

  // Observable states
  final RxString successMessage = ''.obs;

  // Original profile for comparison
  ProfileModel? originalProfile;

  @override
  void onInit() {
    super.onInit();
    _initControllers();
    _loadInitialData();
  }

  void _initControllers() {
    usernameController = TextEditingController();
    emailController = TextEditingController();
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
  }

  void _loadInitialData() {
    // Get profile from arguments
    if (Get.arguments != null && Get.arguments is ProfileModel) {
      originalProfile = Get.arguments as ProfileModel;
      usernameController.text = originalProfile?.username ?? '';
      emailController.text = originalProfile?.email ?? '';
      firstNameController.text = originalProfile?.firstName ?? '';
      lastNameController.text = originalProfile?.lastName ?? '';
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    emailController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    super.onClose();
  }

  /// Validate username
  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    if (value.length < 3) {
      return 'اسم المستخدم يجب أن يكون 3 أحرف على الأقل';
    }
    if (value.length > 200) {
      return 'اسم المستخدم يجب أن يكون أقل من 200 حرف';
    }
    return null;
  }

  /// Validate email
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    if (!GetUtils.isEmail(value)) {
      return 'البريد الإلكتروني غير صحيح';
    }
    return null;
  }

  /// Validate first name
  String? validateFirstName(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    if (value.length < 2) {
      return 'الاسم الأول يجب أن يكون حرفين على الأقل';
    }
    if (value.length > 100) {
      return 'الاسم الأول يجب أن يكون أقل من 100 حرف';
    }
    return null;
  }

  /// Validate last name
  String? validateLastName(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    if (value.length < 2) {
      return 'الاسم الأخير يجب أن يكون حرفين على الأقل';
    }
    if (value.length > 100) {
      return 'الاسم الأخير يجب أن يكون أقل من 100 حرف';
    }
    return null;
  }

  /// Check if there are changes
  bool get hasChanges {
    if (originalProfile == null) return false;
    return usernameController.text != (originalProfile?.username ?? '') ||
        emailController.text != (originalProfile?.email ?? '') ||
        firstNameController.text != (originalProfile?.firstName ?? '') ||
        lastNameController.text != (originalProfile?.lastName ?? '');
  }

  /// Clear success message
  void clearSuccessMessage() {
    successMessage.value = '';
  }

  /// Update profile
  Future<void> updateProfile() async {
    if (!formKey.currentState!.validate()) return;

    if (!hasChanges) {
      showError('لا توجد تغييرات لحفظها');
      return;
    }

    showLoading();
    successMessage.value = '';

    final result = await _profileRepository.updateProfile(
      username: usernameController.text.isNotEmpty
          ? usernameController.text
          : null,
      email: emailController.text.isNotEmpty ? emailController.text : null,
      firstName: firstNameController.text.isNotEmpty
          ? firstNameController.text
          : null,
      lastName: lastNameController.text.isNotEmpty
          ? lastNameController.text
          : null,
    );

    result.fold(
      (failure) {
        showErrorFromFailure(failure);
      },
      (updatedProfile) async {
        hideLoading();
        successMessage.value = 'تم تحديث الملف الشخصي بنجاح';
        originalProfile = updatedProfile;
        // Update stored user data
        var userresult = await _storage.read(StorageConstants.userData);
        UserModel user = UserModel.fromJson(userresult);
        // Create updated user with new profile data
        UserModel updatedUser = user.copyWith(
          firstName: updatedProfile.firstName,
          lastName: updatedProfile.lastName,
          email: updatedProfile.email,
          username: updatedProfile.username,
        );

        try {
          await _storage.write(
            StorageConstants.userData,
            jsonEncode(updatedUser.toJson()),
          );
          // Store individual user fields for easy access
          await _storage.write(StorageConstants.userId, updatedProfile.id);
          await _storage.write(
            StorageConstants.userName,
            updatedProfile.fullName,
          );
          await _storage.write(
            StorageConstants.userEmail,
            updatedProfile.email,
          );
        } catch (e) {
          print("error updating storage: ${e.toString()}");
        }

        // Refresh user data in homepage and auth state
        _refreshUserDataInOtherControllers(updatedUser);

        // Go back and refresh profile
        Future.delayed(const Duration(seconds: 1), () {
          Get.back(result: true);
        });
      },
    );
  }

  /// Refresh user data in homepage and auth state controllers
  void _refreshUserDataInOtherControllers(UserModel updatedUser) {
    try {
      // Update homepage controller if it exists
      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        homeController.refreshUserData();
      }

      // Update auth state controller if it exists
      if (Get.isRegistered<AuthStateController>()) {
        final authController = Get.find<AuthStateController>();
        authController.setAuthenticatedState(updatedUser);
      }

      // Note: ProfileController will refresh itself when we return with result: true
      // This is handled in ProfileController.goToUpdateProfile() method
    } catch (e) {
      print("error refreshing controllers: ${e.toString()}");
    }
  }
}

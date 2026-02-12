import 'package:achaytablereservation/app/routes/app_routes.dart';
import 'package:achaytablereservation/core/constants/app_constants.dart';
import 'package:achaytablereservation/features/authentication/logic/authstate_Controller.dart';
import 'package:achaytablereservation/features/profile/data/model/profile_model.dart';
import 'package:achaytablereservation/features/profile/data/repositories/profile_repository.dart';
import 'package:get/get.dart';
import 'package:achaytablereservation/core/base/base_controller.dart';
import 'package:achaytablereservation/core/services/storage_service.dart';

/// Controller for Profile screen
/// Handles loading user data and logout functionality
class ProfileController extends BaseController {
  final ProfileRepository _profileRepository;
  final StorageService _storageService;

  ProfileController({
    required ProfileRepository profileRepository,
    required StorageService storageService,
  }) : _profileRepository = profileRepository,
       _storageService = storageService;

  // Observable states
  final Rx<ProfileModel?> profile = Rx<ProfileModel?>(null);
  final RxBool isLoggingOut = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  /// Load user profile from API
  Future<void> loadProfile() async {
    showLoading();

    final result = await _profileRepository.getProfile();

    result.fold(
      (failure) {
        showErrorFromFailure(failure);
      },
      (profileData) {
        profile.value = profileData;

        hideLoading();
      },
    );
  }

  /// Refresh profile data
  Future<void> refreshProfile() async {
    await loadProfile();
  }

  /// Logout user
  Future<void> logout() async {
    isLoggingOut.value = true;

    try {
      // Use AuthStateController to properly clear all auth state
      final authController = Get.find<AuthStateController>();
      await authController.logout();

      // Navigate to home screen (as guest)
      Get.offAllNamed(AppRoutes.MAIN_NAVIGATION);
    } catch (e) {
      showError('فشل في تسجيل الخروج');
    } finally {
      isLoggingOut.value = false;
    }
  }

  /// Navigate to update profile screen
  void goToUpdateProfile() async {
    var result = await Get.toNamed(
      AppRoutes.UpdateProfile,
      arguments: profile.value,
    );
    if (result != null && result == true) {
      refreshProfile();
    }
  }

  /// Navigate to update password screen
  void goToUpdatePassword() {
    Get.toNamed(AppRoutes.UpdatePassword);
  }

  /// Navigate to change phone number screen
  void goToChangePhoneNumber() {
    Get.toNamed(AppRoutes.ChangePhone);
  }
}

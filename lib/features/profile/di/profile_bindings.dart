import 'package:achaytablereservation/core/network/api_client.dart';
import 'package:achaytablereservation/core/services/storage_service.dart';
import 'package:achaytablereservation/features/profile/data/datasources/profile_data_source.dart';
import 'package:achaytablereservation/features/profile/data/repositories/profile_repository.dart';
import 'package:achaytablereservation/features/profile/logic/controller/change_phone_controller.dart';
import 'package:achaytablereservation/features/profile/logic/controller/profile_controller.dart';
import 'package:achaytablereservation/features/profile/logic/controller/update_password_controller.dart';
import 'package:achaytablereservation/features/profile/logic/controller/update_profile_controller.dart';
import 'package:get/get.dart';

/// Bindings for Profile screen
class ProfileBindings extends Bindings {
  @override
  void dependencies() {
    // Register ProfileDataSource
    Get.lazyPut<ProfileDataSource>(
      () => ProfileDataSourceImpl(apiClient: Get.find<ApiClient>()),
    );

    // Register ProfileRepository
    Get.lazyPut<ProfileRepository>(
      () => ProfileRepository(profileDataSource: Get.find<ProfileDataSource>()),
    );

    // Register ProfileController
    Get.lazyPut<ProfileController>(
      () => ProfileController(
        profileRepository: Get.find<ProfileRepository>(),
        storageService: Get.find<StorageService>(),
      ),
    );
  }
}

/// Bindings for Update Profile screen
class UpdateProfileBindings extends Bindings {
  @override
  void dependencies() {
    // Ensure repository is available
    if (!Get.isRegistered<ProfileRepository>()) {
      Get.lazyPut<ProfileDataSource>(
        () => ProfileDataSourceImpl(apiClient: Get.find<ApiClient>()),
      );
      Get.lazyPut<ProfileRepository>(
        () =>
            ProfileRepository(profileDataSource: Get.find<ProfileDataSource>()),
      );
    }

    // Register UpdateProfileController
    Get.lazyPut<UpdateProfileController>(
      () => UpdateProfileController(
        profileRepository: Get.find<ProfileRepository>(),
      ),
    );
  }
}

/// Bindings for Update Password screen
class UpdatePasswordBindings extends Bindings {
  @override
  void dependencies() {
    // Ensure repository is available
    if (!Get.isRegistered<ProfileRepository>()) {
      Get.lazyPut<ProfileDataSource>(
        () => ProfileDataSourceImpl(apiClient: Get.find<ApiClient>()),
      );
      Get.lazyPut<ProfileRepository>(
        () =>
            ProfileRepository(profileDataSource: Get.find<ProfileDataSource>()),
      );
    }

    // Register UpdatePasswordController
    Get.lazyPut<UpdatePasswordController>(
      () => UpdatePasswordController(
        profileRepository: Get.find<ProfileRepository>(),
      ),
    );
  }
}

/// Bindings for Change Phone screen
class ChangePhoneBindings extends Bindings {
  @override
  void dependencies() {
    // Ensure repository is available
    if (!Get.isRegistered<ProfileRepository>()) {
      Get.lazyPut<ProfileDataSource>(
        () => ProfileDataSourceImpl(apiClient: Get.find<ApiClient>()),
      );
      Get.lazyPut<ProfileRepository>(
        () =>
            ProfileRepository(profileDataSource: Get.find<ProfileDataSource>()),
      );
    }

    // Register ChangePhoneController
    Get.lazyPut<ChangePhoneController>(
      () => ChangePhoneController(
        profileRepository: Get.find<ProfileRepository>(),
      ),
    );
  }
}

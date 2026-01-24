import 'package:get/get.dart';
import 'package:achaytablereservation/core/shared/model/user_model.dart';
import 'package:achaytablereservation/features/homepage/data/repositories/homepage_repository.dart';
import 'package:achaytablereservation/features/homepage/data/model/branch_models.dart';
import 'package:achaytablereservation/core/errors/error_handler.dart';
import 'package:achaytablereservation/app/routes/app_routes.dart';

/// Homepage controller managing state and business logic for the homepage
class HomeController extends GetxController {
  final HomepageRepository _repository;

  HomeController({required HomepageRepository repository})
    : _repository = repository;

  // Reactive variables for state management
  final branches = <Branch>[].obs;
  final user = Rxn<UserModel>();
  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final selectedLocation = 'الرياض'.obs;
  final isLoadingBranches = false.obs;
  final isLoadingUser = false.obs;

  // User location coordinates for distance calculation
  final userLatitude = Rxn<double>();
  final userLongitude = Rxn<double>();

  // Default coordinates for Saudi Arabian cities
  static const Map<String, Map<String, double>> _cityCoordinates = {
    'الرياض': {'lat': 24.7136, 'lng': 46.6753},
    'جدة': {'lat': 21.5433, 'lng': 39.1728},
    'مكةالمكرمة': {'lat': 21.4225, 'lng': 39.8262},
    'المدينة المنورة': {'lat': 24.5247, 'lng': 39.5692},
    'بريدة': {'lat': 26.3260, 'lng': 43.9750},
    'الدمام': {'lat': 26.4207, 'lng': 50.0888},
    'الخبر': {'lat': 26.2172, 'lng': 50.1971},
    'الظهران': {'lat': 26.2361, 'lng': 50.0393},
    'تبوك': {'lat': 28.3838, 'lng': 36.5550},
    'أبها': {'lat': 18.2164, 'lng': 42.5053},
    'الطائف': {'lat': 21.2703, 'lng': 40.4158},
  };

  // Getters for computed properties
  bool get hasUser => user.value != null;
  bool get hasBranches => branches.isNotEmpty;
  bool get isInitialLoading => isLoading.value;
  bool get hasUserLocation =>
      userLatitude.value != null && userLongitude.value != null;

  @override
  void onInit() {
    super.onInit();
    // Set default location coordinates for Riyadh
    _setLocationCoordinates('الرياض');
    // Load initial data when controller initializes
    _loadInitialData();
  }

  /// Set location coordinates based on city name
  void _setLocationCoordinates(String cityName) {
    final coordinates = _cityCoordinates[cityName];
    if (coordinates != null) {
      userLatitude.value = coordinates['lat'];
      userLongitude.value = coordinates['lng'];
    }
  }

  /// Load initial data (user and branches)
  Future<void> _loadInitialData() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      // Load user data and branches concurrently
      await Future.wait([loadUserData(), loadBranches()]);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load initial data';
      ErrorHandler.logError(
        'Failed to load initial data',
        StackTrace.current,
        context: 'HomeController._loadInitialData',
        additionalData: {'error': e.toString()},
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Load user data with proper error handling
  Future<void> loadUserData() async {
    try {
      isLoadingUser.value = true;
      final result = await _repository.userdata();
      result.fold(
        (failure) {
          // Handle failure case
          ErrorHandler.logFailure(
            failure,
            context: 'HomeController.loadUserData',
          );
          // Don't show error for user data as it might be expected (not logged in)
          user.value = null;
        },
        (userData) {
          // Handle success case
          user.value = userData;
          if (userData == null) {
            ErrorHandler.logInfo(
              'No user data found in storage',
              context: 'HomeController.loadUserData',
            );
          }
        },
      );
    } catch (e) {
      ErrorHandler.logError(
        'Unexpected error loading user data',
        StackTrace.current,
        context: 'HomeController.loadUserData',
        additionalData: {'error': e.toString()},
      );
      user.value = null;
    } finally {
      isLoadingUser.value = false;
    }
  }

  /// Load branches data with proper error handling
  Future<void> loadBranches() async {
    try {
      isLoadingBranches.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final result = await _repository.getBranches(
        city: selectedLocation.value,
        sortBy: 'distance',
        pageNumber: 1,
        pageSize: 20,
      );

      result.fold(
        (failure) {
          // Handle failure case
          hasError.value = true;
          errorMessage.value = ErrorHandler.getErrorMessage(failure);
          branches.clear();

          ErrorHandler.logFailure(
            failure,
            context: 'HomeController.loadBranches',
            additionalData: {
              'city': selectedLocation.value,
              'sortBy': 'distance',
            },
          );

          // Show user-friendly error message
          Get.snackbar(
            'error'.tr,
            errorMessage.value,
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        (branchesData) {
          // Handle success case
          branches.assignAll(branchesData.items);
          hasError.value = false;
          errorMessage.value = '';
        },
      );
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Unexpected error occurred';
      branches.clear();

      ErrorHandler.logError(
        'Unexpected error loading branches',
        StackTrace.current,
        context: 'HomeController.loadBranches',
        additionalData: {'error': e.toString(), 'city': selectedLocation.value},
      );

      Get.snackbar(
        'error'.tr,
        'Failed to load branches',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingBranches.value = false;
    }
  }

  /// Update user location and refresh branch data
  void updateLocation(String cityName, double latitude, double longitude) {
    if (selectedLocation.value != cityName) {
      selectedLocation.value = cityName;

      // Update user coordinates for distance calculation
      userLatitude.value = latitude;
      userLongitude.value = longitude;

      // Log location update
      ErrorHandler.logInfo(
        'Location updated to $cityName',
        context: 'HomeController.updateLocation',
        additionalData: {
          'city': cityName,
          'latitude': latitude,
          'longitude': longitude,
        },
      );

      // Reload branches with new location
      loadBranches();
    }
  }

  /// Navigate to branch details page
  void navigateToBranchInfo(Branch branch) {
    try {
      // For now, we'll navigate to a generic route since branch details page isn't defined yet
      // This can be updated when the branch details page is implemented
      ErrorHandler.logInfo(
        'Navigating to branch details',
        context: 'HomeController.navigateToBranchInfo',
        additionalData: {
          'branchId': branch.id,
          'branchName': branch.branchName,
        },
      );

      Get.toNamed(AppRoutes.branchinfor, arguments: branch);
    } catch (e) {
      ErrorHandler.logError(
        'Failed to navigate to branch info',
        StackTrace.current,
        context: 'HomeController.navigateToBranchInfo',
        additionalData: {'branchId': branch.id, 'error': e.toString()},
      );
    }
  }

  /// Navigate to profile page
  void navigateToProfile() {
    try {
      if (user.value == null) {
        // User not logged in, redirect to login
        Get.offAllNamed(AppRoutes.LOGIN);
        return;
      }

      ErrorHandler.logInfo(
        'Navigating to profile page',
        context: 'HomeController.navigateToProfile',
        additionalData: {
          'userId': user.value?.id,
          'username': user.value?.username,
        },
      );

      // Navigate to profile page
      Get.toNamed(AppRoutes.PROFILE);
    } catch (e) {
      ErrorHandler.logError(
        'Failed to navigate to profile',
        StackTrace.current,
        context: 'HomeController.navigateToProfile',
        additionalData: {'error': e.toString(), 'hasUser': user.value != null},
      );

      Get.snackbar(
        'error'.tr,
        'Failed to open profile',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Retry loading data after error
  void retryLoadData() {
    _loadInitialData();
  }

  /// Refresh branches data (for pull-to-refresh)
  Future<void> refreshBranches() async {
    await loadBranches();
  }

  /// Clear error state
  void clearError() {
    hasError.value = false;
    errorMessage.value = '';
  }

  /// Refresh user data (called after profile updates)
  Future<void> refreshUserData() async {
    await loadUserData();
  }
}

import 'package:get/get.dart';
import 'package:achaytablereservation/core/services/storage_service.dart';
import 'package:achaytablereservation/core/errors/error_handler.dart';
import 'package:achaytablereservation/features/authentication/logic/authstate_Controller.dart';
import 'package:achaytablereservation/core/shared/widgets/login_required_dialog.dart';

/// Main navigation controller managing bottom navigation bar state
/// Handles page switching, state persistence, and navigation index management
class MainNavigationController extends GetxController {
  final StorageService _storageService;

  MainNavigationController({required StorageService storageService})
    : _storageService = storageService;

  // Storage key for navigation state
  static const String _navigationStateKey = 'navigation_state';

  /// Observable current page index (0: Home, 1: Bookings, 2: Notifications, 3: More)
  final RxInt currentIndex = 0.obs;

  /// Total number of navigation pages
  static const int totalPages = 4;

  @override
  void onInit() {
    super.onInit();
    // Restore last navigation state on initialization
    _restoreNavigationState();
  }

  /// Change the current page index
  /// Validates the index is within bounds [0, 3] before updating
  /// Saves the new state to storage for persistence
  /// [index] - The page index to navigate to (0-3)
  void changePage(int index) {
    try {
      // Validate index is within bounds
      if (index < 0 || index >= totalPages) {
        ErrorHandler.logWarning(
          'Invalid navigation index: $index. Must be between 0 and ${totalPages - 1}',
          context: 'MainNavigationController.changePage',
          additionalData: {'attemptedIndex': index},
        );
        // Default to Home page on invalid index
        currentIndex.value = 0;
        _saveNavigationState();
        return;
      }

      // Block guests from accessing Bookings tab (index 1)
      if (index == 1) {
        final authController = Get.find<AuthStateController>();
        if (authController.isGuest) {
          LoginRequiredDialog.show();
          return;
        }
      }

      // Update current index
      currentIndex.value = index;

      // Save state to storage
      _saveNavigationState();

      ErrorHandler.logInfo(
        'Navigation page changed to index $index',
        context: 'MainNavigationController.changePage',
        additionalData: {'newIndex': index},
      );
    } catch (e) {
      ErrorHandler.logError(
        'Failed to change navigation page',
        StackTrace.current,
        context: 'MainNavigationController.changePage',
        additionalData: {'index': index, 'error': e.toString()},
      );
      // Fallback to Home page on error
      currentIndex.value = 0;
    }
  }

  /// Save current navigation state to storage
  Future<void> _saveNavigationState() async {
    try {
      await _storageService.write(_navigationStateKey, currentIndex.value);
    } catch (e) {
      ErrorHandler.logError(
        'Failed to save navigation state',
        StackTrace.current,
        context: 'MainNavigationController._saveNavigationState',
        additionalData: {
          'currentIndex': currentIndex.value,
          'error': e.toString(),
        },
      );
    }
  }

  /// Restore navigation state from storage
  Future<void> _restoreNavigationState() async {
    try {
      final savedIndex = await _storageService.read<int>(_navigationStateKey);
      if (savedIndex != null && savedIndex >= 0 && savedIndex < totalPages) {
        currentIndex.value = savedIndex;
        ErrorHandler.logInfo(
          'Navigation state restored to index $savedIndex',
          context: 'MainNavigationController._restoreNavigationState',
          additionalData: {'restoredIndex': savedIndex},
        );
      } else {
        // Default to Home page if no valid saved state
        currentIndex.value = 0;
        ErrorHandler.logInfo(
          'No valid navigation state found, defaulting to Home',
          context: 'MainNavigationController._restoreNavigationState',
        );
      }
    } catch (e) {
      ErrorHandler.logError(
        'Failed to restore navigation state',
        StackTrace.current,
        context: 'MainNavigationController._restoreNavigationState',
        additionalData: {'error': e.toString()},
      );
      // Default to Home page on error
      currentIndex.value = 0;
    }
  }

  @override
  void onClose() {
    // Save state before controller is disposed
    _saveNavigationState();
    super.onClose();
  }
}

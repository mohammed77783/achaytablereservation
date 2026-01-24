import 'package:get/get.dart';
import '../errors/failures.dart';
import '../errors/error_handler.dart';

/// Base controller class that provides common functionality for all controllers
/// Includes loading state management and error handling
abstract class BaseController extends GetxController {
  /// Observable for tracking loading state
  final isLoading = false.obs;

  /// Observable for tracking error messages
  final errorMessage = ''.obs;

  /// Show loading indicator
  void showLoading() {
    isLoading.value = true;
    clearError();
  }

  /// Hide loading indicator
  void hideLoading() {
    isLoading.value = false;
  }

  /// Show error message
  void showError(String message) {
    errorMessage.value = message;
    hideLoading();
  }

  /// Show error from a Failure object
  /// Converts the failure to a localized user-friendly message
  void showErrorFromFailure(Failure failure) {
    final message = ErrorHandler.getErrorMessage(failure);
    showError(message);
    ErrorHandler.logFailure(failure, context: runtimeType.toString());
  }

  /// Clear error message
  void clearError() {
    errorMessage.value = '';
  }

  /// Handle a result from a use case or repository
  /// Automatically shows loading, handles errors, and processes success
  Future<void> handleResult<T>({
    required Future<T> Function() call,
    required Function(T) onSuccess,
    Function(Failure)? onError,
  }) async {
    try {
      showLoading();
      final result = await call();
      hideLoading();
      onSuccess(result);
    } catch (e, stackTrace) {
      hideLoading();
      ErrorHandler.logError(
        e,
        stackTrace,
        context: '${runtimeType.toString()} - handleResult',
      );
      final failure = UnknownFailure(e.toString());
      if (onError != null) {
        onError(failure);
      } else {
        showErrorFromFailure(failure);
      }
    }
  }
}

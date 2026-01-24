// lib/features/branch_info/presentation/controllers/branch_info_controller.dart

import 'package:achaytablereservation/features/homepage/data/model/gallery_photo_model.dart';
import 'package:achaytablereservation/features/homepage/data/model/business_hour_model.dart';
import 'package:achaytablereservation/features/homepage/data/repositories/homepage_repository.dart';
import 'package:get/get.dart';
import 'package:dartz/dartz.dart';
import 'package:achaytablereservation/core/base/base_controller.dart';
import 'package:achaytablereservation/core/errors/failures.dart';
import 'package:achaytablereservation/features/homepage/data/model/branch_models.dart';
import 'package:achaytablereservation/app/routes/app_routes.dart';
import 'package:achaytablereservation/features/reservation/logic/controller/reservation_controller.dart';

/// Controller for the Branch Info page
class BranchInfoController extends BaseController {
  final HomepageRepository _repository;

  BranchInfoController({required HomepageRepository repository})
    : _repository = repository;
  // Branch data
  final branch = Rxn<Branch>();
  // Gallery state
  final galleryPhotos = <GalleryPhoto>[].obs;
  final isLoadingGallery = false.obs;
  final galleryError = Rxn<String>();
  // Media viewer state
  final selectedMediaIndex = 0.obs;
  final isMediaViewerOpen = false.obs;
  // Business hours state
  final businessHours = <BusinessHour>[].obs;
  final isLoadingBusinessHours = false.obs;
  final businessHoursError = Rxn<String>();
  final isBusinessHoursExpanded = false.obs;
  @override
  void onInit() {
    super.onInit();
    _loadBranch();
  }

  void _loadBranch() {
    final args = Get.arguments;
    if (args is Branch) {
      branch.value = args;
      fetchGalleryPhotos();
      fetchBusinessHours();
    }
  }

  /// Fetch gallery photos from server using Either result handling
  Future<void> fetchGalleryPhotos() async {
    if (branch.value == null) return;
    _setGalleryLoading(true);
    final result = await _repository.getGalleryPhotos(branch.value!.id);
    _handleGalleryResult(result);
  }

  /// Handle the Either result from repository
  void _handleGalleryResult(Either<Failure, List<GalleryPhoto>> result) {
    result.fold(
      (failure) {
        galleryError.value = failure.message;
        _setGalleryLoading(false);
        showErrorFromFailure(failure);
      },
      (photos) {
        galleryPhotos.assignAll(photos);
        galleryError.value = null;
        _setGalleryLoading(false);
        clearError();
      },
    );
  }

  /// Set gallery loading state
  void _setGalleryLoading(bool loading) {
    isLoadingGallery.value = loading;
    if (loading) {
      galleryError.value = null;
    }
  }

  /// Retry fetching gallery photos
  Future<void> retryFetchGallery() async {
    await fetchGalleryPhotos();
  }

  /// Fetch business hours from server
  Future<void> fetchBusinessHours() async {
    if (branch.value == null) return;
    isLoadingBusinessHours.value = true;
    businessHoursError.value = null;

    final result = await _repository.getBusinessHours(branch.value!.id);
    result.fold(
      (failure) {
        businessHoursError.value = failure.message;
        isLoadingBusinessHours.value = false;
      },
      (hours) {
        businessHours.assignAll(hours);
        businessHoursError.value = null;
        isLoadingBusinessHours.value = false;
      },
    );
  }

  /// Toggle business hours expanded state
  void toggleBusinessHours() {
    isBusinessHoursExpanded.value = !isBusinessHoursExpanded.value;
  }

  /// Retry fetching business hours
  Future<void> retryFetchBusinessHours() async {
    await fetchBusinessHours();
  }

  // ============ Getters ============

  bool get isArabic => Get.locale?.languageCode == 'ar';

  String get displayName => branch.value?.fullName ?? '';

  String get displayAddress => branch.value?.address ?? '';

  String? get primaryImageUrl {
    return branch.value?.primaryImage;
  }

  List<GalleryPhoto> get mediaItems => galleryPhotos;
  List<GalleryPhoto> get images =>
      galleryPhotos.where((photo) => photo.isImage).toList();
  List<GalleryPhoto> get videos =>
      galleryPhotos.where((photo) => photo.isVideo).toList();
  bool get hasGalleryError => galleryError.value != null;
  bool get isGalleryEmpty =>
      !isLoadingGallery.value && galleryPhotos.isEmpty && !hasGalleryError;
  GalleryPhoto? get currentMediaItem {
    if (galleryPhotos.isEmpty) return null;
    return galleryPhotos[selectedMediaIndex.value.clamp(
      0,
      galleryPhotos.length - 1,
    )];
  }

  // ============ Media Viewer Methods ============

  void openMediaViewer(int index) {
    if (galleryPhotos.isEmpty) return;
    selectedMediaIndex.value = index.clamp(0, galleryPhotos.length - 1);
    isMediaViewerOpen.value = true;
  }

  void closeMediaViewer() {
    isMediaViewerOpen.value = false;
  }

  void nextMedia() {
    if (selectedMediaIndex.value < galleryPhotos.length - 1) {
      selectedMediaIndex.value++;
    }
  }

  void previousMedia() {
    if (selectedMediaIndex.value > 0) {
      selectedMediaIndex.value--;
    }
  }

  // ============ Navigation Methods ============
  void navigateToReservation() {
    if (branch.value != null) {
      // Delete existing ReservationController if it exists to start fresh
      if (Get.isRegistered<ReservationController>()) {
        Get.delete<ReservationController>();
      }

      Get.toNamed(
        AppRoutes.reservationpage,
        arguments: {'restaurantId': branch.value!.id},
      );
    }
  }

  void goBack() {
    Get.back();
  }
}

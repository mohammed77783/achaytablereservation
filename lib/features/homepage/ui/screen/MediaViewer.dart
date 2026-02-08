// lib/features/branch_info/presentation/widgets/media_viewer.dart

import 'package:achaytablereservation/app/themes/light_theme.dart';
import 'package:achaytablereservation/features/homepage/data/model/gallery_photo_model.dart';
import 'package:achaytablereservation/features/homepage/logic/mediaviewercontroller.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconsax/iconsax.dart';
import 'package:achaytablereservation/core/utils/responsive_utils.dart';

/// Full screen media viewer with swipe navigation
class MediaViewer extends StatefulWidget {
  final List<GalleryPhoto> items;
  final int initialIndex;
  final VoidCallback onClose;

  /// Optional external controller
  final MediaViewerController? controller;

  const MediaViewer({
    super.key,
    required this.items,
    required this.initialIndex,
    required this.onClose,
    this.controller,
  });

  @override
  State<MediaViewer> createState() => _MediaViewerState();
}

class _MediaViewerState extends State<MediaViewer> {
  late MediaViewerController _controller;
  bool _isInternalController = false;
  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    if (widget.controller != null) {
      _controller = widget.controller!;
      _isInternalController = false;
    } else {
      _controller = MediaViewerController(
        items: widget.items,
        initialIndex: widget.initialIndex,
        onClose: widget.onClose,
      );
      _isInternalController = true;
    }
    _controller.addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(MediaViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _controller.removeListener(_onControllerUpdate);
      if (_isInternalController) {
        _controller.dispose();
      }
      _initController();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    if (_isInternalController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: LightTheme.primaryDark,
      body: SafeArea(
        child: Stack(
          children: [
            // Page view for images
            _buildPageView(),
            // Top bar with close button
            _buildTopBar(theme),
            // Navigation arrows (for tablet/desktop)
            if (ResponsiveUtils.getDeviceType(context) !=
                DeviceType.mobile) ...[
              _buildPreviousButton(),
              _buildNextButton(),
            ],
            // Dots indicator
            _buildDotsIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildPageView() {
    return PageView.builder(
      controller: _controller.pageController,
      itemCount: _controller.totalItems,
      onPageChanged: _controller.onPageChanged,
      itemBuilder: (context, index) {
        final item = _controller.items[index];
        return InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Center(
            child: CachedNetworkImage(
              imageUrl: item.fileUrl,
              fit: BoxFit.contain,
              placeholder: (context, url) =>
                  const CircularProgressIndicator(color: Colors.black),
              errorWidget: (context, url, error) =>
                  Icon(Iconsax.image, color: LightTheme.textHint, size: 64),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar(ThemeData theme) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.all(
          ResponsiveUtils.spacing(context, LightTheme.spacingMedium),
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              LightTheme.primaryDark.withOpacity(0.8),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Close button
            _buildIconButton(
              icon: Iconsax.close_circle,
              onTap: _controller.close,
            ),
            // Counter
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: LightTheme.spacingMedium,
                vertical: LightTheme.spacingSmall,
              ),
              decoration: BoxDecoration(
                color: LightTheme.primaryColor.withOpacity(0.6),
                borderRadius: BorderRadius.circular(
                  LightTheme.borderRadiusLarge,
                ),
              ),
              child: Text(
                _controller.counterText,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: LightTheme.textOnPrimary,
                ),
              ),
            ),
            // Spacer for alignment
            const SizedBox(width: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviousButton() {
    if (!_controller.hasPrevious) return const SizedBox.shrink();

    return Positioned(
      left: LightTheme.spacingMedium,
      top: 0,
      bottom: 0,
      child: Center(
        child: _buildIconButton(
          icon: Iconsax.arrow_left_2,
          onTap: _controller.previousPage,
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    if (!_controller.hasNext) return const SizedBox.shrink();

    return Positioned(
      right: LightTheme.spacingMedium,
      top: 0,
      bottom: 0,
      child: Center(
        child: _buildIconButton(
          icon: Iconsax.arrow_right_3,
          onTap: _controller.nextPage,
        ),
      ),
    );
  }

  Widget _buildDotsIndicator() {
    return Positioned(
      bottom: ResponsiveUtils.spacing(context, LightTheme.spacingLarge),
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          _controller.totalItems,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: EdgeInsets.symmetric(
              horizontal: LightTheme.spacingXSmall / 2,
            ),
            width: index == _controller.currentIndex ? 24.0 : 8.0,
            height: 8.0,
            decoration: BoxDecoration(
              color: index == _controller.currentIndex
                  ? LightTheme.secondaryColor
                  : LightTheme.textOnPrimary.withOpacity(0.4),
              borderRadius: BorderRadius.circular(4.0),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: ResponsiveUtils.value(context, mobile: 40.0, tablet: 48.0),
        height: ResponsiveUtils.value(context, mobile: 40.0, tablet: 48.0),
        decoration: BoxDecoration(
          color: LightTheme.primaryColor.withOpacity(0.6),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: LightTheme.textOnPrimary,
          size: LightTheme.iconSizeMedium,
        ),
      ),
    );
  }
}

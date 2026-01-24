// ============================================================================
// STEP 7: Updated HorizontalCardWidget with Cardholder Name
// ============================================================================
// File: lib/features/payment/ui/widget/horizontal_card_widget.dart
// ============================================================================

import 'dart:io';
import 'package:achaytablereservation/app/themes/light_theme.dart';
import 'package:flutter/material.dart';

/// Horizontal Card Widget (Standard style) - Updated with cardholder name
/// Landscape-oriented card with horizontal number display
class HorizontalCardWidget extends StatelessWidget {
  final File? cardImage;
  final String cardNumber;
  final String expirationDate;
  final String cardHolderName; // NEW: Cardholder name
  final VoidCallback? onTap;

  const HorizontalCardWidget({
    super.key,
    this.cardImage,
    this.cardNumber = '',
    this.expirationDate = '',
    this.cardHolderName = '', // NEW
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: cardImage == null
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    LightTheme.primaryLight,
                    LightTheme.primaryColor,
                    LightTheme.primaryDark,
                  ],
                )
              : null,
          image: cardImage != null
              ? DecorationImage(
                  image: FileImage(cardImage!),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.4),
                    BlendMode.darken,
                  ),
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Glassmorphism overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.transparent,
                    Colors.black.withOpacity(0.1),
                  ],
                ),
              ),
            ),

            // Decorative circles
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              bottom: -60,
              left: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.03),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top row - Logo and card brand
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Bank logo placeholder
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'BANK',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      // Card brand indicator
                      _buildCardBrandIndicator(),
                    ],
                  ),

                  // Middle row - Chip and contactless
                  Row(
                    children: [
                      // Chip - Silver/White
                      _buildChip(),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.contactless,
                        color: Colors.white.withOpacity(0.8),
                        size: 28,
                      ),
                    ],
                  ),

                  // Bottom section - Card number, expiry, and holder
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card number - Horizontal
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          cardNumber.isEmpty
                              ? '•••• •••• •••• ••••'
                              : cardNumber,
                          style: TextStyle(
                            color: Colors.white.withOpacity(
                              cardNumber.isEmpty ? 0.5 : 1,
                            ),
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 3,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Expiration and card holder row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Valid Thru
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'VALID THRU',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 8,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                expirationDate.isEmpty
                                    ? 'MM/YY'
                                    : expirationDate,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(
                                    expirationDate.isEmpty ? 0.5 : 1,
                                  ),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                          // Card Holder Name (UPDATED)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'CARD HOLDER',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 8,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  cardHolderName.isEmpty
                                      ? 'YOUR NAME'
                                      : cardHolderName.toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(
                                      cardHolderName.isEmpty ? 0.5 : 1,
                                    ),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1,
                                  ),
                                  textAlign: TextAlign.end,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBrandIndicator() {
    // Detect card type from number
    final cleanNumber = cardNumber.replaceAll(RegExp(r'\D'), '');

    if (cleanNumber.isEmpty) {
      return _buildDefaultBrandCircles();
    }

    // Show card brand icon based on number
    String? brandIcon;
    Color? brandColor;

    if (cleanNumber.startsWith('4')) {
      // Visa
      brandIcon = 'VISA';
      brandColor = Colors.blue;
    } else if (cleanNumber.startsWith('5') ||
        (cleanNumber.length >= 4 &&
            int.tryParse(cleanNumber.substring(0, 4)) != null &&
            int.parse(cleanNumber.substring(0, 4)) >= 2221 &&
            int.parse(cleanNumber.substring(0, 4)) <= 2720)) {
      // Mastercard
      return _buildMastercardCircles();
    } else if (cleanNumber.startsWith('34') || cleanNumber.startsWith('37')) {
      // Amex
      brandIcon = 'AMEX';
      brandColor = Colors.blue.shade800;
    } else if (_isMadaCard(cleanNumber)) {
      // Mada
      brandIcon = 'mada';
      brandColor = Colors.green;
    }

    if (brandIcon != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          brandIcon,
          style: TextStyle(
            color: brandColor ?? Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      );
    }

    return _buildDefaultBrandCircles();
  }

  Widget _buildDefaultBrandCircles() {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.3),
          ),
        ),
        Transform.translate(
          offset: const Offset(-10, 0),
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMastercardCircles() {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red.withOpacity(0.9),
          ),
        ),
        Transform.translate(
          offset: const Offset(-12, 0),
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.orange.withOpacity(0.9),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChip() {
    return Container(
      width: 50,
      height: 38,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: const LinearGradient(
          colors: [Color(0xFFE0E0E0), Color(0xFFFFFFFF), Color(0xFFE0E0E0)],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: const Color(0xFFBDBDBD), width: 1),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: const Color(0xFFBDBDBD).withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(child: Container()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isMadaCard(String number) {
    const madaBins = [
      '440795',
      '440647',
      '421141',
      '474491',
      '588845',
      '968208',
      '457997',
      '457865',
      '468540',
      '468541',
      '468542',
      '468543',
      '417633',
      '446672',
      '484783',
      '446393',
      '439954',
      '458456',
    ];
    if (number.length >= 6) {
      return madaBins.contains(number.substring(0, 6));
    }
    return false;
  }
}

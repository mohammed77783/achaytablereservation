import 'package:achaytablereservation/app/themes/light_theme.dart';
import 'package:achaytablereservation/features/profile/data/model/profile_model.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

/// Card widget displaying user profile information
class ProfileInfoCard extends StatelessWidget {
  final ProfileModel profile;

  const ProfileInfoCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(LightTheme.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'معلومات الحساب',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: LightTheme.spacingMedium),
            _buildInfoRow(
              context,
              icon: Icons.phone_android,
              label: 'رقم الجوال',
              value: _formatPhoneNumber(profile.phoneNumber),
            ),
            const Divider(height: LightTheme.spacingLarge),
            _buildInfoRow(
              context,
              icon: Icons.email_outlined,
              label: 'البريد الإلكتروني',
              value: profile.email ?? 'غير محدد',
              isNA: profile.email == null,
            ),
            const Divider(height: LightTheme.spacingLarge),
            _buildInfoRow(
              context,
              icon: Icons.calendar_today_outlined,
              label: 'تاريخ الانضمام',
              value: _formatDate(profile.createdAt),
            ),
            const Divider(height: LightTheme.spacingLarge),
            _buildInfoRow(
              context,
              icon: Icons.update,
              label: 'آخر تحديث',
              value: _formatDateTime(profile.updatedAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    bool isNA = false,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(LightTheme.spacingSmall),
          decoration: BoxDecoration(
            color: LightTheme.surfaceGray,
            borderRadius: BorderRadius.circular(LightTheme.borderRadius),
          ),
          child: Icon(icon, size: 20, color: LightTheme.primaryColor),
        ),
        const SizedBox(width: LightTheme.spacingMedium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: LightTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isNA ? LightTheme.textHint : LightTheme.textPrimary,
                  fontStyle: isNA ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatPhoneNumber(String phone) {
    // Format: 966 5X XXX XXXX
    if (phone.startsWith('966') && phone.length == 12) {
      return '+${phone.substring(0, 3)} ${phone.substring(3, 5)} ${phone.substring(5, 8)} ${phone.substring(8)}';
    }
    return phone;
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy', 'ar').format(date);
  }

  String _formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy - hh:mm a', 'ar').format(date);
  }
}

import 'package:achaytablereservation/app/themes/light_theme.dart';
import 'package:achaytablereservation/features/profile/logic/controller/profile_controller.dart';
import 'package:achaytablereservation/features/profile/ui/widget/profile_header_widget.dart';
import 'package:achaytablereservation/features/profile/ui/widget/profile_info_card.dart';
import 'package:achaytablereservation/features/profile/ui/widget/profile_menu_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Main Profile Screen
/// Displays user information and profile management options
class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        actions: [
          IconButton(
            onPressed: controller.refreshProfile,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty &&
            controller.profile.value == null) {
          return _buildErrorState(context);
        }

        return _buildContent(context);
      }),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(LightTheme.spacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: LightTheme.errorColor),
            const SizedBox(height: LightTheme.spacingMedium),
            Text(
              controller.errorMessage.value,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: LightTheme.spacingLarge),
            ElevatedButton.icon(
              onPressed: controller.loadProfile,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final profile = controller.profile.value;

    return RefreshIndicator(
      onRefresh: controller.refreshProfile,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(LightTheme.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            if (profile != null) ProfileHeaderWidget(profile: profile),

            const SizedBox(height: LightTheme.spacingLarge),

            // Profile Info Card
            if (profile != null) ProfileInfoCard(profile: profile),

            const SizedBox(height: LightTheme.spacingLarge),

            // Menu Section
            Text('الإعدادات', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: LightTheme.spacingSmall),

            // Menu Items
            Card(
              child: Column(
                children: [
                  ProfileMenuItem(
                    icon: Icons.person_outline,
                    title: 'تعديل الملف الشخصي',
                    subtitle: 'تحديث المعلومات الشخصية',
                    onTap: controller.goToUpdateProfile,
                  ),
                  const Divider(height: 1),
                  ProfileMenuItem(
                    icon: Icons.lock_outline,
                    title: 'تغيير كلمة المرور',
                    subtitle: 'تحديث كلمة المرور',
                    onTap: controller.goToUpdatePassword,
                  ),
                  const Divider(height: 1),
                  ProfileMenuItem(
                    icon: Icons.phone_android,
                    title: 'تغيير رقم الجوال',
                    subtitle: 'تحديث رقم الجوال',
                    onTap: controller.goToChangePhoneNumber,
                  ),
                ],
              ),
            ),

            const SizedBox(height: LightTheme.spacingLarge),

            // Logout Button
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: controller.isLoggingOut.value
                      ? null
                      : () => _showLogoutDialog(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: LightTheme.errorColor,
                    side: const BorderSide(color: LightTheme.errorColor),
                  ),
                  icon: controller.isLoggingOut.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.logout),
                  label: Text(
                    controller.isLoggingOut.value
                        ? 'جاري تسجيل الخروج...'
                        : 'تسجيل الخروج',
                  ),
                ),
              ),
            ),

            const SizedBox(height: LightTheme.spacingMedium),

            // Delete Account Button
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: controller.isDeletingAccount.value
                      ? null
                      : () => _showDeleteAccountDialog(context),
                  style: TextButton.styleFrom(
                    foregroundColor: LightTheme.errorColor,
                  ),
                  icon: controller.isDeletingAccount.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.delete_forever),
                  label: Text(
                    controller.isDeletingAccount.value
                        ? 'جاري حذف الحساب...'
                        : 'حذف الحساب',
                  ),
                ),
              ),
            ),

            const SizedBox(height: LightTheme.spacingXLarge),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Obx(
          () => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: LightTheme.errorColor),
                const SizedBox(width: 8),
                const Text('حذف الحساب'),
              ],
            ),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'هل أنت متأكد من حذف حسابك؟',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'سيتم حذف جميع بياناتك بشكل نهائي بعد 30 يوم من تاريخ الطلب. '
                      'خلال هذه الفترة يمكنك التواصل معنا لاستعادة حسابك.',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'كلمة المرور',
                        hintText: 'أدخل كلمة المرور للتأكيد',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال كلمة المرور';
                        }
                        return null;
                      },
                    ),
                    if (controller.deleteAccountError.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          controller.deleteAccountError.value,
                          style: TextStyle(
                            color: LightTheme.errorColor,
                            fontSize: 13,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  controller.deleteAccountError.value = '';
                  Navigator.pop(context);
                },
                child: const Text('إلغاء'),
              ),
              Obx(
                () => ElevatedButton(
                  onPressed: controller.isDeletingAccount.value
                      ? null
                      : () {
                          if (formKey.currentState!.validate()) {
                            controller
                                .deleteAccount(passwordController.text);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LightTheme.errorColor,
                  ),
                  child: controller.isDeletingAccount.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('حذف الحساب'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تسجيل الخروج'),
          content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                controller.logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: LightTheme.errorColor,
              ),
              child: const Text('تسجيل الخروج'),
            ),
          ],
        ),
      ),
    );
  }
}

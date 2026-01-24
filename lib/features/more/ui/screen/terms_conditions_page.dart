import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/themes/light_theme.dart';
import '../../../../app/themes/dark_theme.dart';

/// Terms and Conditions page
/// Displays the app's terms and conditions
class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? DarkTheme.backgroundColor
          : LightTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'terms_and_conditions'.tr,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? DarkTheme.textPrimary : LightTheme.textPrimary,
          ),
        ),
        backgroundColor: isDark
            ? DarkTheme.surfaceColor
            : LightTheme.surfaceColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? DarkTheme.textPrimary : LightTheme.textPrimary,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context: context,
              title: '1. استخدام التطبيق',
              content: '''
يخضع استخدام تطبيق آجا للحجز للشروط والأحكام التالية. باستخدامك للتطبيق، فإنك توافق على الالتزام بهذه الشروط.

- يجب أن يكون عمرك 18 عامًا أو أكثر لاستخدام هذه الخدمة
- أنت مسؤول عن الحفاظ على سرية معلومات حسابك
- يجب عليك تقديم معلومات دقيقة وكاملة عند إنشاء الحساب
              ''',
              isDark: isDark,
            ),
            const SizedBox(height: 20),
            _buildSection(
              context: context,
              title: '2. الحجوزات',
              content: '''
- جميع الحجوزات تخضع للتوافر
- يجب الوصول في الوقت المحدد للحجز
- قد يتم إلغاء الحجز في حالة التأخر لأكثر من 15 دقيقة
- يحق للمطعم رفض أو إلغاء أي حجز لأي سبب
              ''',
              isDark: isDark,
            ),
            const SizedBox(height: 20),
            _buildSection(
              context: context,
              title: '3. سياسة الإلغاء',
              content: '''
- يمكنك إلغاء حجزك قبل 24 ساعة على الأقل من موعد الحجز
- قد تُفرض رسوم إلغاء في حالة الإلغاء المتأخر
- الإلغاءات المتكررة قد تؤدي إلى تقييد حسابك
              ''',
              isDark: isDark,
            ),
            const SizedBox(height: 20),
            _buildSection(
              context: context,
              title: '4. الدفع',
              content: '''
- جميع الأسعار معروضة بالريال السعودي
- قد تُطلب دفعة مقدمة لبعض الحجوزات
- نقبل بطاقات الائتمان والخصم الرئيسية
- جميع المعاملات المالية مؤمنة ومشفرة
              ''',
              isDark: isDark,
            ),
            const SizedBox(height: 20),
            _buildSection(
              context: context,
              title: '5. الخصوصية',
              content: '''
نحن نحترم خصوصيتك ونلتزم بحماية بياناتك الشخصية. لمزيد من المعلومات، يرجى الاطلاع على سياسة الخصوصية الخاصة بنا.
              ''',
              isDark: isDark,
            ),
            const SizedBox(height: 20),
            _buildSection(
              context: context,
              title: '6. التعديلات',
              content: '''
نحتفظ بالحق في تعديل هذه الشروط والأحكام في أي وقت. سيتم إخطارك بأي تغييرات جوهرية.
              ''',
              isDark: isDark,
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                'آخر تحديث: يناير 2026',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  color: isDark
                      ? DarkTheme.textSecondary
                      : LightTheme.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required String content,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? DarkTheme.surfaceColor : LightTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? DarkTheme.secondaryColor
                  : LightTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content.trim(),
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              height: 1.6,
              color: isDark ? DarkTheme.textPrimary : LightTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

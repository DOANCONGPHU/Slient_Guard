import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/utils/app_colors.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  // Mock local state
  final Map<String, bool> _preferences = {
    'Cảnh báo té ngã': true,
    'Cảnh báo camera mất kết nối': true,
    'Lời mời gia đình': true,
    'Báo cáo hằng ngày': true,
    'Nhắc kiểm tra người thân': false,
    'Cập nhật tự động hóa': false,
    'Bảo trì thiết bị': false,
    'Cảnh báo bảo mật tài khoản': true,
    'Gợi ý theo thời tiết': false,
    'Cập nhật hệ thống': false,
    'Hỗ trợ khách hàng': false,
    'Phản hồi & cải tiến': false,
  };

  final List<String> _keys = [
    'Cảnh báo té ngã',
    'Cảnh báo camera mất kết nối',
    'Lời mời gia đình',
    'Báo cáo hằng ngày',
    'Nhắc kiểm tra người thân',
    'Cập nhật tự động hóa',
    'Bảo trì thiết bị',
    'Cảnh báo bảo mật tài khoản',
    'Gợi ý theo thời tiết',
    'Cập nhật hệ thống',
    'Hỗ trợ khách hàng',
    'Phản hồi & cải tiến',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark
        ? theme.colorScheme.surface
        : AppColors.surface;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, theme, isDark),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: AppSpacing.xxxl),
                itemCount: _keys.length,
                itemBuilder: (context, index) {
                  final key = _keys[index];
                  final value = _preferences[key] ?? false;
                  return _NotificationPreferenceTile(
                    title: key,
                    value: value,
                    onChanged: (newValue) {
                      setState(() {
                        _preferences[key] = newValue;
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, bool isDark) {
    final textColor = isDark ? theme.colorScheme.onSurface : AppColors.darkText;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: textColor,
              size: 22,
            ),
            onPressed: () => context.pop(),
            tooltip: 'Quay lại',
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
            splashRadius: 24,
          ),
          Expanded(
            child: Text(
              'Cài đặt thông báo',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ),
          // Placeholder to balance the left back button
          const SizedBox(width: 38),
        ],
      ),
    );
  }
}

class _NotificationPreferenceTile extends StatelessWidget {
  const _NotificationPreferenceTile({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final titleColor = isDark
        ? theme.colorScheme.onSurface
        : AppColors.darkText;

    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pagePadding,
          vertical: 18,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: titleColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 16),
            CupertinoSwitch(
              value: value,
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.border,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

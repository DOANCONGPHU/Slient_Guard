import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/utils/app_colors.dart';
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile/features/auth/presentation/widgets/app_logo.dart';
import 'package:mobile/features/phone_verification/presentation/cubit/phone_number_cubit.dart';
import 'package:mobile/features/phone_verification/presentation/cubit/phone_number_state.dart';
import 'package:mobile/injection_container.dart';

class PhoneRequiredPage extends StatefulWidget {
  const PhoneRequiredPage({super.key});

  @override
  State<PhoneRequiredPage> createState() => _PhoneRequiredPageState();
}

class _PhoneRequiredPageState extends State<PhoneRequiredPage> {
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: BlocConsumer<PhoneNumberCubit, PhoneNumberState>(
        listener: (context, state) {
          if (state.isSuccess) {
            context.go('/home');
            return;
          }
          if (state.isFailure && state.isUnauthorized) {
            unawaited(sl<AuthRepository>().signOut());
            context.go('/welcome');
          }
        },
        builder: (context, state) {
          final normalizedPreview = PhoneNumberCubit.normalizePhoneNumber(
            _phoneController.text,
          );
          final canSubmit = !state.isSubmitting && normalizedPreview != null;

          return Scaffold(
            backgroundColor: AppColors.surface,
            resizeToAvoidBottomInset: true,
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.pagePadding,
                      26,
                      AppSpacing.pagePadding,
                      24,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 440,
                          minHeight: (constraints.maxHeight - 50).clamp(
                            0.0,
                            double.infinity,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Center(child: AppLogo()),
                            const SizedBox(height: 30),
                            Text(
                              'Hoàn tất thông tin liên hệ',
                              style: Theme.of(context).textTheme.displayLarge
                                  ?.copyWith(
                                    color: AppColors.darkText,
                                    fontSize: 28,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'SilentGuard cần số điện thoại để gửi cảnh báo khẩn cấp và hỗ trợ liên hệ khi có sự cố.',
                              style: TextStyle(
                                color: AppColors.mutedText,
                                fontSize: 15,
                                height: 1.45,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 24),
                            const _EmergencyInfoPanel(),
                            const SizedBox(height: 26),
                            const _FieldLabel('Số điện thoại'),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.done,
                              enabled: !state.isSubmitting,
                              onChanged: context
                                  .read<PhoneNumberCubit>()
                                  .phoneChanged,
                              onSubmitted: (_) {
                                if (canSubmit) {
                                  context.read<PhoneNumberCubit>().submitted();
                                }
                              },
                              decoration: InputDecoration(
                                hintText: '0912345678',
                                prefixIcon: const Icon(
                                  Icons.phone_outlined,
                                  color: AppColors.mutedText,
                                ),
                                suffixIcon: normalizedPreview == null
                                    ? null
                                    : const Icon(
                                        Icons.check_circle_rounded,
                                        color: AppColors.safe,
                                      ),
                                errorText: state.isFailure
                                    ? state.message
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 12),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 180),
                              child: normalizedPreview == null
                                  ? const _FieldHint(
                                      key: ValueKey('phone-hint'),
                                      icon: Icons.info_outline_rounded,
                                      text:
                                          'Bạn có thể nhập số Việt Nam dạng 0912345678 hoặc chuẩn quốc tế +84123456789.',
                                    )
                                  : _FieldHint(
                                      key: const ValueKey('phone-preview'),
                                      icon: Icons.verified_outlined,
                                      text:
                                          'Sẽ lưu dưới dạng $normalizedPreview',
                                      color: AppColors.primary,
                                    ),
                            ),
                            const SizedBox(height: 28),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: FilledButton.icon(
                                onPressed: canSubmit
                                    ? context.read<PhoneNumberCubit>().submitted
                                    : null,
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: AppColors.primary
                                      .withValues(alpha: 0.45),
                                  shape: const StadiumBorder(),
                                ),
                                icon: state.isSubmitting
                                    ? const SizedBox.square(
                                        dimension: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.arrow_forward_rounded),
                                label: Text(
                                  state.isSubmitting
                                      ? 'Đang lưu...'
                                      : 'Lưu và tiếp tục',
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            const Center(
                              child: Text(
                                'Thông tin này chỉ dùng cho cảnh báo an toàn.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.mutedText,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EmergencyInfoPanel extends StatelessWidget {
  const _EmergencyInfoPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.lightBlue,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelIcon(),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cảnh báo đến đúng người',
                  style: TextStyle(
                    color: AppColors.darkText,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Khi phát hiện té ngã hoặc sự cố nghiêm trọng, hệ thống sẽ dùng số này để ưu tiên thông báo khẩn cấp.',
                  style: TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PanelIcon extends StatelessWidget {
  const _PanelIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.notifications_active_outlined,
        color: AppColors.primary,
        size: 22,
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.darkText,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _FieldHint extends StatelessWidget {
  const _FieldHint({
    super.key,
    required this.icon,
    required this.text,
    this.color = AppColors.mutedText,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 13,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

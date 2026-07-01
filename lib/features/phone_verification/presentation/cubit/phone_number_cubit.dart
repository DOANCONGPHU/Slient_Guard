import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/phone_verification/presentation/cubit/phone_number_state.dart';
import 'package:mobile/features/session/domain/failures/session_failure.dart';
import 'package:mobile/features/session/domain/repositories/session_repository.dart';

class PhoneNumberCubit extends Cubit<PhoneNumberState> {
  PhoneNumberCubit(this._sessionRepository) : super(const PhoneNumberState());

  final SessionRepository _sessionRepository;

  void phoneChanged(String value) {
    emit(
      state.copyWith(
        phone: value,
        status: PhoneNumberStatus.initial,
        clearMessage: true,
        clearFailureKind: true,
      ),
    );
  }

  Future<void> submitted() async {
    final normalizedPhone = normalizePhoneNumber(state.phone);
    if (normalizedPhone == null) {
      emit(
        state.copyWith(
          status: PhoneNumberStatus.failure,
          message: 'Vui lòng nhập số điện thoại hợp lệ, ví dụ +84123456789.',
          clearFailureKind: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: PhoneNumberStatus.submitting,
        phone: normalizedPhone,
        clearMessage: true,
        clearFailureKind: true,
      ),
    );

    final result = await _sessionRepository.updatePhoneNumber(normalizedPhone);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: PhoneNumberStatus.failure,
          message: _messageForFailure(failure),
          failureKind: failure.kind,
        ),
      ),
      (_) => emit(
        state.copyWith(
          status: PhoneNumberStatus.success,
          phone: normalizedPhone,
          clearMessage: true,
          clearFailureKind: true,
        ),
      ),
    );
  }

  static String? normalizePhoneNumber(String value) {
    final compact = value.replaceAll(RegExp(r'[\s\-\(\)\.]'), '').trim();
    if (compact.isEmpty) return null;

    String normalized;
    if (compact.startsWith('+')) {
      normalized = compact;
    } else if (compact.startsWith('0')) {
      normalized = '+84${compact.substring(1)}';
    } else if (compact.startsWith('84')) {
      normalized = '+$compact';
    } else {
      normalized = '+84$compact';
    }

    if (!RegExp(r'^\+[1-9]\d{7,14}$').hasMatch(normalized)) {
      return null;
    }
    return normalized;
  }

  String _messageForFailure(SessionFailure failure) {
    return switch (failure.kind) {
      SessionFailureKind.unauthorized =>
        'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
      SessionFailureKind.forbidden =>
        'Tài khoản không có quyền cập nhật thông tin này.',
      _ =>
        failure.message.isEmpty
            ? 'Không thể cập nhật số điện thoại. Vui lòng thử lại.'
            : failure.message,
    };
  }
}

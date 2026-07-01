import 'package:equatable/equatable.dart';
import 'package:mobile/features/session/domain/failures/session_failure.dart';

enum PhoneNumberStatus { initial, submitting, success, failure }

class PhoneNumberState extends Equatable {
  const PhoneNumberState({
    this.status = PhoneNumberStatus.initial,
    this.phone = '',
    this.message,
    this.failureKind,
  });

  final PhoneNumberStatus status;
  final String phone;
  final String? message;
  final SessionFailureKind? failureKind;

  bool get isSubmitting => status == PhoneNumberStatus.submitting;
  bool get isSuccess => status == PhoneNumberStatus.success;
  bool get isFailure => status == PhoneNumberStatus.failure;
  bool get isUnauthorized => failureKind == SessionFailureKind.unauthorized;

  PhoneNumberState copyWith({
    PhoneNumberStatus? status,
    String? phone,
    String? message,
    SessionFailureKind? failureKind,
    bool clearMessage = false,
    bool clearFailureKind = false,
  }) {
    return PhoneNumberState(
      status: status ?? this.status,
      phone: phone ?? this.phone,
      message: clearMessage ? null : message ?? this.message,
      failureKind: clearFailureKind ? null : failureKind ?? this.failureKind,
    );
  }

  @override
  List<Object?> get props => [status, phone, message, failureKind];
}

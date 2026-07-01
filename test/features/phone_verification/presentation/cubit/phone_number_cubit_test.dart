import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/phone_verification/presentation/cubit/phone_number_cubit.dart';
import 'package:mobile/features/phone_verification/presentation/cubit/phone_number_state.dart';
import 'package:mobile/features/session/domain/entities/backend_session.dart';
import 'package:mobile/features/session/domain/entities/backend_user.dart';
import 'package:mobile/features/session/domain/entities/household.dart';
import 'package:mobile/features/session/domain/failures/session_failure.dart';
import 'package:mobile/features/session/domain/repositories/session_repository.dart';

void main() {
  group('PhoneNumberCubit', () {
    test('normalizes and submits a valid Vietnamese phone number', () async {
      final repository = _FakeSessionRepository();
      final cubit = PhoneNumberCubit(repository);
      final states = <PhoneNumberState>[];
      final subscription = cubit.stream.listen(states.add);

      cubit.phoneChanged('0912 345 678');
      await cubit.submitted();

      expect(repository.updatedPhone, '+84912345678');
      expect(
        states.map((state) => state.status),
        containsAllInOrder([
          PhoneNumberStatus.initial,
          PhoneNumberStatus.submitting,
          PhoneNumberStatus.success,
        ]),
      );

      await subscription.cancel();
      await cubit.close();
    });

    test('emits failure when phone format is invalid', () async {
      final repository = _FakeSessionRepository();
      final cubit = PhoneNumberCubit(repository);
      final states = <PhoneNumberState>[];
      final subscription = cubit.stream.listen(states.add);

      cubit.phoneChanged('abc');
      await cubit.submitted();

      expect(repository.updatedPhone, isNull);
      expect(states.last.status, PhoneNumberStatus.failure);
      expect(states.last.message, contains('số điện thoại hợp lệ'));

      await subscription.cancel();
      await cubit.close();
    });

    test('emits failure message from repository submission failure', () async {
      final repository = _FakeSessionRepository(
        failure: const SessionFailure('Máy chủ đang bận.'),
      );
      final cubit = PhoneNumberCubit(repository);
      final states = <PhoneNumberState>[];
      final subscription = cubit.stream.listen(states.add);

      cubit.phoneChanged('+84123456789');
      await cubit.submitted();

      expect(repository.updatedPhone, '+84123456789');
      expect(states.last.status, PhoneNumberStatus.failure);
      expect(states.last.message, 'Máy chủ đang bận.');

      await subscription.cancel();
      await cubit.close();
    });
  });
}

class _FakeSessionRepository implements SessionRepository {
  _FakeSessionRepository({this.failure});

  final SessionFailure? failure;
  String? updatedPhone;

  @override
  BackendSession? get currentSession => _session;

  @override
  Household? get currentHousehold => currentSession?.household;

  @override
  String? get currentHouseholdId => currentSession?.householdId;

  @override
  Stream<BackendSession?> get sessionChanges => const Stream.empty();

  @override
  Future<Either<SessionFailure, BackendSession>> provisionSession({
    String? inviteCode,
  }) async {
    return Right(_session);
  }

  @override
  Future<Either<SessionFailure, void>> logout({String? idToken}) async {
    return const Right(null);
  }

  @override
  Future<Either<SessionFailure, void>> switchHousehold(
    String householdId,
  ) async {
    return const Right(null);
  }

  @override
  Future<Either<SessionFailure, BackendSession>> updatePhoneNumber(
    String phone,
  ) async {
    updatedPhone = phone;
    final failure = this.failure;
    if (failure != null) return Left(failure);
    return Right(
      BackendSession(
        backendUser: _session.backendUser.copyWith(phone: phone),
        household: _session.household,
      ),
    );
  }

  @override
  void clearCachedSession() {}
}

const _session = BackendSession(
  backendUser: BackendUser(
    id: 'user-1',
    firebaseUid: 'firebase-1',
    fullName: 'Test User',
    email: 'test@example.com',
    role: 'member',
  ),
  household: Household(
    householdId: 'household-1',
    role: 'member',
    elderlyName: 'Elder',
  ),
);

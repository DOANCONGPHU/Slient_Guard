import 'package:dartz/dartz.dart';
import 'package:mobile/features/session/domain/entities/backend_session.dart';
import 'package:mobile/features/session/domain/entities/household.dart';
import 'package:mobile/features/session/domain/failures/session_failure.dart';

abstract interface class SessionRepository {
  BackendSession? get currentSession;
  Household? get currentHousehold;
  String? get currentHouseholdId;
  Stream<BackendSession?> get sessionChanges;

  Future<Either<SessionFailure, BackendSession>> provisionSession({
    String? inviteCode,
  });

  Future<Either<SessionFailure, void>> logout({String? idToken});

  Future<Either<SessionFailure, void>> switchHousehold(String householdId);

  Future<Either<SessionFailure, BackendSession>> updatePhoneNumber(
    String phone,
  );

  void clearCachedSession();
}

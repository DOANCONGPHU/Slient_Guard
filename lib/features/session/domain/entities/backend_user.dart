import 'package:equatable/equatable.dart';

class BackendUser extends Equatable {
  const BackendUser({
    required this.id,
    required this.firebaseUid,
    required this.fullName,
    required this.email,
    required this.role,
    this.phone,
  });

  final String id;
  final String firebaseUid;
  final String fullName;
  final String email;
  final String role;
  final String? phone;

  BackendUser copyWith({
    String? id,
    String? firebaseUid,
    String? fullName,
    String? email,
    String? role,
    String? phone,
  }) {
    return BackendUser(
      id: id ?? this.id,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
    );
  }

  @override
  List<Object?> get props => [id, firebaseUid, fullName, email, role, phone];
}

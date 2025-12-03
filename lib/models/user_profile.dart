import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final int targetWaterAmount; // Ціль споживання води (Вимога 4.4)
  final DateTime registrationDate;

  const UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.targetWaterAmount,
    required this.registrationDate,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map, String id) {
    final rawDate = map['registrationDate'];
    final date = rawDate is Timestamp
        ? rawDate.toDate()
        : (rawDate is String ? DateTime.tryParse(rawDate) : null);
    return UserProfile(
      id: id,
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      targetWaterAmount: map['targetWaterAmount'] ?? 2000,
      // Конвертація Timestamp з Firestore у Dart DateTime (з запасним варіантом)
      registrationDate: date ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'targetWaterAmount': targetWaterAmount,
      // Конвертація Dart DateTime у Timestamp для Firestore
      'registrationDate': Timestamp.fromDate(registrationDate),
    };
  }
  
  @override
  List<Object?> get props => [id, firstName, lastName, email, targetWaterAmount, registrationDate];
}

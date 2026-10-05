import 'package:cloud_firestore/cloud_firestore.dart';

class FamilyInfo {
  final String familyName;
  final String role;
  final DateTime joinedDate;

  FamilyInfo({
    required this.familyName,
    required this.role,
    required this.joinedDate,
  });

  factory FamilyInfo.fromMap(Map<String, dynamic> map) {
    return FamilyInfo(
      familyName: map['familyName'] ?? '',
      role: map['role'] ?? 'member',
      joinedDate: map['joinedDate'] != null
          ? (map['joinedDate'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'familyName': familyName,
      'role': role,
      'joinedDate': joinedDate,
    };
  }
}

class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final FamilyInfo familyInfo;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.familyInfo,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      familyInfo: map['familyInfo'] != null
          ? FamilyInfo.fromMap(Map<String, dynamic>.from(map['familyInfo']))
          : FamilyInfo(
              familyName: '',
              role: 'member',
              joinedDate: DateTime.now(),
            ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'familyInfo': familyInfo.toMap(),
    };
  }
}

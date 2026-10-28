import 'package:cloud_firestore/cloud_firestore.dart';

class ClanModel {
  final String id;
  final String name;
  final String description;
  final String createdByUserId;
  final List<String> memberIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? location;
  final double balance;

  ClanModel({
    required this.id,
    required this.name,
    required this.description,
    required this.createdByUserId,
    required this.memberIds,
    required this.createdAt,
    required this.updatedAt,
    this.location,
    this.balance = 0.0,
  });

  factory ClanModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return ClanModel(
      id: id ?? map['id'] ?? '',
      name: map['name'] ?? 'Unnamed Clan',
      description: map['description'] ?? '',
      createdByUserId: map['createdByUserId'] ?? '',
      memberIds: (map['memberIds'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      location: map['location'],
      balance: (map['balance'] is num) ? (map['balance'] as num).toDouble() : 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdByUserId': createdByUserId,
      'memberIds': memberIds,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'location': location,
      'balance': balance,
    };
  }
}

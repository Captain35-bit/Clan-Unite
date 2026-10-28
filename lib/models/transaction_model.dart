import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String clanId;
  final String type;
  final double amount;
  final String description;
  final String createdByUserId;
  final String category;
  final DateTime createdAt;
  final String status;

  TransactionModel({
    required this.id,
    required this.clanId,
    required this.type,
    required this.amount,
    required this.description,
    required this.createdByUserId,
    required this.category,
    required this.createdAt,
    this.status = 'approved',
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return TransactionModel(
      id: id ?? map['id'] ?? '',
      clanId: map['clanId'] ?? '',
      type: map['type'] ?? 'other',
      amount: (map['amount'] is num) ? (map['amount'] as num).toDouble() : 0.0,
      description: map['description'] ?? '',
      createdByUserId: map['createdByUserId'] ?? '',
      category: map['category'] ?? 'general',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      status: map['status'] ?? 'approved',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clanId': clanId,
      'type': type,
      'amount': amount,
      'description': description,
      'createdByUserId': createdByUserId,
      'category': category,
      'createdAt': createdAt,
      'status': status,
    };
  }
}

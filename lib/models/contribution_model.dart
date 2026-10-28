import 'package:cloud_firestore/cloud_firestore.dart';

class ContributionModel {
  final String id;
  final String clanId;
  final String memberId;
  final double amount;
  final String description;
  final DateTime createdAt;
  final String status;

  ContributionModel({
    required this.id,
    required this.clanId,
    required this.memberId,
    required this.amount,
    required this.description,
    required this.createdAt,
    this.status = 'paid',
  });

  factory ContributionModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return ContributionModel(
      id: id ?? map['id'] ?? '',
      clanId: map['clanId'] ?? '',
      memberId: map['memberId'] ?? '',
      amount: (map['amount'] is num) ? (map['amount'] as num).toDouble() : 0.0,
      description: map['description'] ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      status: map['status'] ?? 'paid',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clanId': clanId,
      'memberId': memberId,
      'amount': amount,
      'description': description,
      'createdAt': createdAt,
      'status': status,
    };
  }
}

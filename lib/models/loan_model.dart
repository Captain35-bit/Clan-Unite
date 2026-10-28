import 'package:cloud_firestore/cloud_firestore.dart';

class LoanModel {
  final String id;
  final String clanId;
  final String memberId;
  final String lenderId;
  final double amount;
  final String purpose;
  final DateTime createdAt;
  final DateTime? dueDate;
  final String status;

  LoanModel({
    required this.id,
    required this.clanId,
    required this.memberId,
    required this.lenderId,
    required this.amount,
    required this.purpose,
    required this.createdAt,
    this.dueDate,
    this.status = 'pending',
  });

  factory LoanModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return LoanModel(
      id: id ?? map['id'] ?? '',
      clanId: map['clanId'] ?? '',
      memberId: map['memberId'] ?? '',
      lenderId: map['lenderId'] ?? '',
      amount: (map['amount'] is num) ? (map['amount'] as num).toDouble() : 0.0,
      purpose: map['purpose'] ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      dueDate: map['dueDate'] != null
          ? (map['dueDate'] as Timestamp).toDate()
          : null,
      status: map['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clanId': clanId,
      'memberId': memberId,
      'lenderId': lenderId,
      'amount': amount,
      'purpose': purpose,
      'createdAt': createdAt,
      'dueDate': dueDate,
      'status': status,
    };
  }
}

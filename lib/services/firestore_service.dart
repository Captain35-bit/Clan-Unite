import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/clan_model.dart';
import '../models/contribution_model.dart';
import '../models/loan_model.dart';
import '../models/transaction_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _usersCollection() =>
      _db.collection('users');

  CollectionReference<Map<String, dynamic>> _clansCollection() =>
      _db.collection('clans');

  CollectionReference<Map<String, dynamic>> _transactionsCollection(String clanId) =>
      _clansCollection().doc(clanId).collection('transactions');

  CollectionReference<Map<String, dynamic>> _contributionsCollection(String clanId) =>
      _clansCollection().doc(clanId).collection('contributions');

  CollectionReference<Map<String, dynamic>> _loansCollection(String clanId) =>
      _clansCollection().doc(clanId).collection('loans');

  Future<void> saveUser(UserModel user) async {
    await _usersCollection().doc(user.id).set(user.toMap(), SetOptions(merge: true));
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _usersCollection().doc(uid).get();
    if (!doc.exists || doc.data() == null) {
      return null;
    }
    return UserModel.fromMap(doc.data()!);
  }

  Future<void> updateUser(String uid, Map<String, dynamic> updates) async {
    await _usersCollection().doc(uid).update({...updates, 'updatedAt': DateTime.now()});
  }

  Future<void> createClan(ClanModel clan) async {
    await _clansCollection().doc(clan.id).set(clan.toMap(), SetOptions(merge: true));
  }

  Future<ClanModel?> getClan(String clanId) async {
    final doc = await _clansCollection().doc(clanId).get();
    if (!doc.exists || doc.data() == null) {
      return null;
    }
    return ClanModel.fromMap(doc.data()!, id: doc.id);
  }

  Future<List<ClanModel>> getClans() async {
    final snapshot = await _clansCollection().orderBy('updatedAt', descending: true).get();
    return snapshot.docs
        .map((doc) => ClanModel.fromMap(doc.data(), id: doc.id))
        .toList();
  }

  Stream<List<ClanModel>> streamClans() {
    return _clansCollection()
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ClanModel.fromMap(doc.data(), id: doc.id))
            .toList());
  }

  Future<void> updateClan(String clanId, Map<String, dynamic> updates) async {
    await _clansCollection().doc(clanId).update({...updates, 'updatedAt': DateTime.now()});
  }

  Future<void> addTransaction(String clanId, TransactionModel transaction) async {
    await _transactionsCollection(clanId)
        .doc(transaction.id)
        .set(transaction.toMap(), SetOptions(merge: true));
  }

  Future<List<TransactionModel>> getTransactions(String clanId) async {
    final snapshot = await _transactionsCollection(clanId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => TransactionModel.fromMap(doc.data(), id: doc.id))
        .toList();
  }

  Stream<List<TransactionModel>> streamTransactions(String clanId) {
    return _transactionsCollection(clanId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromMap(doc.data(), id: doc.id))
            .toList());
  }

  Future<void> addContribution(String clanId, ContributionModel contribution) async {
    await _contributionsCollection(clanId)
        .doc(contribution.id)
        .set(contribution.toMap(), SetOptions(merge: true));
  }

  Future<List<ContributionModel>> getContributions(String clanId) async {
    final snapshot = await _contributionsCollection(clanId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => ContributionModel.fromMap(doc.data(), id: doc.id))
        .toList();
  }

  Future<void> addLoan(String clanId, LoanModel loan) async {
    await _loansCollection(clanId)
        .doc(loan.id)
        .set(loan.toMap(), SetOptions(merge: true));
  }

  Future<List<LoanModel>> getLoans(String clanId) async {
    final snapshot = await _loansCollection(clanId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => LoanModel.fromMap(doc.data(), id: doc.id))
        .toList();
  }
}

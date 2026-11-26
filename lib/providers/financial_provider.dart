import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/clan_model.dart';
import '../models/contribution_model.dart';
import '../models/loan_model.dart';
import '../models/transaction_model.dart';
import '../services/firestore_service.dart';

class FinancialProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final Uuid _uuid = const Uuid();

  ClanModel? _selectedClan;
  List<ContributionModel> _contributions = [];
  List<LoanModel> _loans = [];
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  ClanModel? get selectedClan => _selectedClan;
  List<ContributionModel> get contributions => _contributions;
  List<LoanModel> get loans => _loans;
  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadClanData(ClanModel clan) async {
    _selectedClan = clan;
    _contributions = [];
    _loans = [];
    _transactions = [];
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _firestoreService.getClan(clan.id),
        _firestoreService.getContributions(clan.id),
        _firestoreService.getLoans(clan.id),
        _firestoreService.getTransactions(clan.id),
      ]);
      _selectedClan = results[0] as ClanModel? ?? clan;
      _contributions = results[1] as List<ContributionModel>;
      _loans = results[2] as List<LoanModel>;
      _transactions = results[3] as List<TransactionModel>;
    } catch (error) {
      _errorMessage = 'Unable to load this clan’s financial activity.';
      debugPrint('FinancialProvider.loadClanData error: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> recordContribution({
    required String memberId,
    required double amount,
    required String description,
  }) async {
    if (!_isValidEntry(memberId, amount, description)) return false;
    final clan = _selectedClan;
    if (clan == null) {
      _errorMessage = 'Select a clan before recording a contribution.';
      notifyListeners();
      return false;
    }

    final now = DateTime.now();
    final contribution = ContributionModel(
      id: _uuid.v4(),
      clanId: clan.id,
      memberId: memberId,
      amount: amount,
      description: description,
      createdAt: now,
    );

    return _saveEntry(
      () => _firestoreService.recordContribution(contribution),
      clan,
      'Unable to record the contribution.',
    );
  }

  Future<bool> recordExpense({
    required String memberId,
    required double amount,
    required String description,
  }) async {
    if (!_isValidEntry(memberId, amount, description)) return false;
    final clan = _selectedClan;
    if (clan == null) {
      _errorMessage = 'Select a clan before recording an expense.';
      notifyListeners();
      return false;
    }

    final now = DateTime.now();
    final expense = TransactionModel(
      id: _uuid.v4(),
      clanId: clan.id,
      type: 'expense',
      amount: amount,
      description: description,
      createdByUserId: memberId,
      category: 'expense',
      createdAt: now,
    );

    return _saveEntry(
      () => _firestoreService.recordExpense(expense),
      clan,
      'Unable to record the expense.',
    );
  }

  Future<bool> _saveEntry(
    Future<void> Function() save,
    ClanModel clan,
    String fallbackMessage,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await save();
      await loadClanData(clan);
      return true;
    } catch (error) {
      _errorMessage = error is StateError
          ? error.message.toString()
          : fallbackMessage;
      debugPrint('FinancialProvider.saveEntry error: $error');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _isValidEntry(String memberId, double amount, String description) {
    if (memberId.trim().isEmpty ||
        !amount.isFinite ||
        amount <= 0 ||
        description.trim().isEmpty) {
      _errorMessage = 'Enter a valid amount and description.';
      notifyListeners();
      return false;
    }
    return true;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

import 'package:intl/intl.dart';

import '../models/contribution_model.dart';
import '../models/loan_model.dart';
import '../models/transaction_model.dart';

class FinancialService {
  final NumberFormat _currencyFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  double calculateTotalContributions(List<ContributionModel> contributions) {
    return contributions.fold<double>(0, (sum, item) => sum + item.amount);
  }

  double calculateTotalLoans(List<LoanModel> loans) {
    return loans
        .where((loan) => loan.status == 'active' || loan.status == 'approved' || loan.status == 'pending')
        .fold<double>(0, (sum, loan) => sum + loan.amount);
  }

  double calculateClanBalance({
    required double currentBalance,
    required List<TransactionModel> transactions,
  }) {
    double total = currentBalance;

    for (final transaction in transactions) {
      if (transaction.type == 'contribution' ||
          transaction.type == 'income' ||
          transaction.type == 'refund') {
        total += transaction.amount;
      } else if (transaction.type == 'expense' ||
          transaction.type == 'withdrawal' ||
          transaction.type == 'loan') {
        total -= transaction.amount;
      }
    }

    return total;
  }

  String formatCurrency(double value) {
    return _currencyFormatter.format(value);
  }
}

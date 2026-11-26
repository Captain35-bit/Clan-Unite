import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/clan_model.dart';
import '../../models/transaction_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/clan_provider.dart';
import '../../providers/financial_provider.dart';
import '../../services/financial_service.dart';

class FinanceDashboardScreen extends StatefulWidget {
  const FinanceDashboardScreen({super.key});

  @override
  State<FinanceDashboardScreen> createState() => _FinanceDashboardScreenState();
}

class _FinanceDashboardScreenState extends State<FinanceDashboardScreen> {
  final FinancialService _financialService = FinancialService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadClans());
  }

  Future<void> _loadClans() async {
    final userId = context.read<AuthProvider>().currentUser?.uid;
    if (userId == null) return;

    final clansProvider = context.read<ClanProvider>();
    await clansProvider.loadClans(userId);
    if (!mounted || clansProvider.clans.isEmpty) return;

    final financeProvider = context.read<FinancialProvider>();
    var clanToLoad = clansProvider.clans.first;
    for (final clan in clansProvider.clans) {
      if (clan.id == financeProvider.selectedClan?.id) {
        clanToLoad = clan;
        break;
      }
    }
    await financeProvider.loadClanData(clanToLoad);
  }

  Future<void> _selectClan(ClanModel clan) async {
    await context.read<FinancialProvider>().loadClanData(clan);
  }

  Future<void> _createClan() async {
    await Navigator.pushNamed(context, '/clan-create');
    if (mounted) await _loadClans();
  }

  Future<void> _showEntryDialog({required bool isContribution}) async {
    final userId = context.read<AuthProvider>().currentUser?.uid;
    if (userId == null) return;

    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _FinanceEntryDialog(
        memberId: userId,
        isContribution: isContribution,
      ),
    );
    if (!mounted || saved != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isContribution
              ? 'Contribution recorded.'
              : 'Expense recorded.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clansProvider = context.watch<ClanProvider>();
    final financeProvider = context.watch<FinancialProvider>();
    final clans = clansProvider.clans;
    final selectedClan = financeProvider.selectedClan;

    return Scaffold(
      appBar: AppBar(title: const Text('Finance')),
      body: SafeArea(
        child: clansProvider.isLoading && clans.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : clans.isEmpty
                ? clansProvider.errorMessage == null
                    ? _buildNoClanState(context)
                    : _buildClanLoadError(context, clansProvider.errorMessage!)
                : RefreshIndicator(
                    onRefresh: _loadClans,
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        DropdownButtonFormField<String>(
                          value: selectedClan?.id,
                          decoration: const InputDecoration(
                            labelText: 'Clan',
                            prefixIcon: Icon(Icons.groups_outlined),
                          ),
                          items: clans
                              .map(
                                (clan) => DropdownMenuItem(
                                  value: clan.id,
                                  child: Text(
                                    clan.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (id) {
                            for (final clan in clans) {
                              if (clan.id == id) {
                                _selectClan(clan);
                                break;
                              }
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        if (financeProvider.errorMessage != null)
                          _ErrorBanner(
                            message: financeProvider.errorMessage!,
                            onDismiss: financeProvider.clearError,
                          ),
                        if (financeProvider.isLoading)
                          const LinearProgressIndicator(),
                        const SizedBox(height: 16),
                        _BalanceCard(
                          balance: selectedClan?.balance ?? 0,
                          formatCurrency: _financialService.formatCurrency,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _SummaryCard(
                                title: 'Contributions',
                                amount: _financialService
                                    .calculateTotalContributions(
                                  financeProvider.contributions,
                                ),
                                icon: Icons.savings_outlined,
                                color: Colors.green,
                                formatCurrency:
                                    _financialService.formatCurrency,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _SummaryCard(
                                title: 'Active loans',
                                amount: _financialService.calculateTotalLoans(
                                  financeProvider.loans,
                                ),
                                icon: Icons.handshake_outlined,
                                color: Colors.orange,
                                formatCurrency:
                                    _financialService.formatCurrency,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: financeProvider.isLoading
                                    ? null
                                    : () => _showEntryDialog(
                                          isContribution: true,
                                        ),
                                icon: const Icon(Icons.add),
                                label: const Text('Contribution'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: financeProvider.isLoading
                                    ? null
                                    : () => _showEntryDialog(
                                          isContribution: false,
                                        ),
                                icon: const Icon(Icons.remove),
                                label: const Text('Expense'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'Recent activity',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        if (financeProvider.transactions.isEmpty)
                          const _EmptyActivity()
                        else
                          ...financeProvider.transactions.map(
                            (transaction) => _TransactionTile(
                              transaction: transaction,
                              formatCurrency:
                                  _financialService.formatCurrency,
                            ),
                          ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildNoClanState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.account_balance_outlined, size: 56),
            const SizedBox(height: 16),
            Text(
              'No clan finances yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Create a clan to track contributions, expenses, and loans.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _createClan,
              child: const Text('Create a clan'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClanLoadError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 48),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _loadClans,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FinanceEntryDialog extends StatefulWidget {
  const _FinanceEntryDialog({
    required this.memberId,
    required this.isContribution,
  });

  final String memberId;
  final bool isContribution;

  @override
  State<_FinanceEntryDialog> createState() => _FinanceEntryDialogState();
}

class _FinanceEntryDialogState extends State<_FinanceEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final financeProvider = context.read<FinancialProvider>();
    final amount = double.parse(_amountController.text.trim());
    final description = _descriptionController.text.trim();
    final saved = widget.isContribution
        ? await financeProvider.recordContribution(
            memberId: widget.memberId,
            amount: amount,
            description: description,
          )
        : await financeProvider.recordExpense(
            memberId: widget.memberId,
            amount: amount,
            description: description,
          );

    if (!mounted) return;
    if (saved) {
      Navigator.pop(context, true);
    } else {
      setState(() => _isSaving = false);
      final message = financeProvider.errorMessage;
      if (message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final entryName = widget.isContribution ? 'Contribution' : 'Expense';

    return AlertDialog(
      title: Text('Record $entryName'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '\$ ',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                final amount = double.tryParse(value?.trim() ?? '');
                if (amount == null || !amount.isFinite || amount <= 0) {
                  return 'Enter an amount greater than zero';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter a description'
                  : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.balance,
    required this.formatCurrency,
  });

  final double balance;
  final String Function(double) formatCurrency;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Available balance'),
            const SizedBox(height: 8),
            Text(
              formatCurrency(balance),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    required this.formatCurrency,
  });

  final String title;
  final double amount;
  final IconData icon;
  final Color color;
  final String Function(double) formatCurrency;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              formatCurrency(amount),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.transaction,
    required this.formatCurrency,
  });

  final TransactionModel transaction;
  final String Function(double) formatCurrency;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == 'contribution' ||
        transaction.type == 'income' ||
        transaction.type == 'refund';
    final color = isIncome ? Colors.green : Colors.red;
    final prefix = isIncome ? '+' : '-';

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.12),
          child: Icon(
            isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            color: color,
          ),
        ),
        title: Text(transaction.description),
        subtitle: Text(
          '${toBeginningOfSentenceCase(transaction.type) ?? transaction.type} · '
          '${DateFormat.yMMMd().format(transaction.createdAt)}',
        ),
        trailing: Text(
          '$prefix${formatCurrency(transaction.amount)}',
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _EmptyActivity extends StatelessWidget {
  const _EmptyActivity();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Text('No transactions have been recorded for this clan yet.'),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({
    required this.message,
    required this.onDismiss,
  });

  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return MaterialBanner(
      content: Text(message),
      leading: const Icon(Icons.error_outline),
      actions: [
        TextButton(onPressed: onDismiss, child: const Text('Dismiss')),
      ],
    );
  }
}

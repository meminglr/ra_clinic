import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:ra_clinic/model/costumer_model.dart';
import 'package:ra_clinic/model/financial_model.dart';
import 'package:ra_clinic/providers/customer_provider.dart';
import 'package:cupertino_calendar_picker/cupertino_calendar_picker.dart';
import 'package:ra_clinic/constants/app_constants.dart';
import 'package:pull_down_button/pull_down_button.dart';

// 1. Özet Kartı (SliverToBoxAdapter içinde kullanılacak)
class FinancialSummaryCard extends StatelessWidget {
  final CustomerModel customer;
  const FinancialSummaryCard({super.key, required this.customer});

  // Hesaplama getterları
  double get totalDebt => customer.transactions
      .where((t) => t.type == TransactionType.debt)
      .fold(0, (sum, t) => sum + t.amount);

  double get totalPayment => customer.transactions
      .where((t) => t.type == TransactionType.payment)
      .fold(0, (sum, t) => sum + t.amount);

  double get balance => totalDebt - totalPayment;

  void _showAddTransactionSheet(BuildContext context) async {
    final FinancialTransaction? transaction =
        await showModalBottomSheet<FinancialTransaction>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          showDragHandle: true,
          builder: (context) => const AddTransactionSheet(),
        );

    if (transaction != null && context.mounted) {
      final updatedList = List<FinancialTransaction>.from(
        customer.transactions,
      );
      updatedList.add(transaction);

      final updatedCustomer = customer.copyWith(transactions: updatedList);
      context.read<CustomerProvider>().editCustomer(updatedCustomer);
    }
  }

  @override
  Widget build(BuildContext context) {
    Color balanceColor;
    if (balance > 0) {
      balanceColor = Theme.of(context).colorScheme.error;
    } else if (balance < 0) {
      balanceColor = Colors.green;
    } else {
      balanceColor = Theme.of(context).disabledColor;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          // Summary Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSummaryItem(
                      context,
                      "Toplam Borç",
                      totalDebt,
                      Theme.of(context).colorScheme.error,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Theme.of(context).dividerColor,
                    ),
                    _buildSummaryItem(
                      context,
                      "Toplam Ödeme",
                      totalPayment,
                      Colors.green,
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Kalan Bakiye",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${balance.toStringAsFixed(2)} ₺",
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: balanceColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _showAddTransactionSheet(context),
                    icon: const Icon(Icons.add),
                    label: const Text("İşlem Ekle"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String title,
    double amount,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "${amount.toStringAsFixed(2)} ₺",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// 2. İşlem Ekleme Bottom Sheet
class AddTransactionSheet extends StatefulWidget {
  final FinancialTransaction? transaction;
  const AddTransactionSheet({super.key, this.transaction});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late TransactionType _type;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.transaction?.amount.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.transaction?.description ?? '',
    );
    _type = widget.transaction?.type ?? TransactionType.debt;
    _selectedDate = widget.transaction?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      final transaction = FinancialTransaction(
        id: widget.transaction?.id ?? const Uuid().v4(),
        amount: amount,
        type: _type,
        description: _descriptionController.text,
        date: _selectedDate,
      );
      Navigator.pop(context, transaction);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.transaction == null
                    ? "Finansal İşlem Ekle"
                    : "İşlemi Düzenle",
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SegmentedButton<TransactionType>(
                    segments: const [
                      ButtonSegment(
                        value: TransactionType.debt,
                        label: Text("Borç"),
                        icon: Icon(Icons.remove_circle_outline),
                      ),
                      ButtonSegment(
                        value: TransactionType.payment,
                        label: Text("Ödeme"),
                        icon: Icon(Icons.add_circle_outline),
                      ),
                    ],
                    selected: {_type},
                    onSelectionChanged: (Set<TransactionType> newSelection) {
                      setState(() {
                        _type = newSelection.first;
                      });
                    },
                    style: ButtonStyle(
                      foregroundColor: WidgetStateProperty.resolveWith<Color?>((
                        Set<WidgetState> states,
                      ) {
                        if (states.contains(WidgetState.selected)) {
                          return _type == TransactionType.debt
                              ? Colors.red
                              : _type == TransactionType.payment
                              ? Colors.green
                              : null;
                        }
                        return null;
                      }),
                      backgroundColor: WidgetStateProperty.resolveWith<Color?>((
                        Set<WidgetState> states,
                      ) {
                        if (states.contains(WidgetState.selected)) {
                          return _type == TransactionType.debt
                              ? Colors.red.shade100
                              : _type == TransactionType.payment
                              ? Colors.green.shade100
                              : null;
                        }
                        return null;
                      }),
                      iconColor: WidgetStateProperty.resolveWith<Color?>((
                        Set<WidgetState> states,
                      ) {
                        if (states.contains(WidgetState.selected)) {
                          return _type == TransactionType.debt
                              ? Colors.red
                              : _type == TransactionType.payment
                              ? Colors.green
                              : null;
                        }
                        return null;
                      }),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                autofocus: widget.transaction == null,
                decoration: const InputDecoration(
                  labelText: "Tutar (TL)",
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Tutar giriniz";
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return "Geçerli bir tutar giriniz";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: "Açıklama (İsteğe Bağlı)",
                  prefixIcon: Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_month_outlined,
                          size: 20,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        CupertinoCalendarPickerButton(
                          buttonDecoration: PickerButtonDecoration(
                            textStyle: TextStyle(
                              fontSize: 16,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                            backgroundColor: Colors.transparent,
                          ),
                          minimumDateTime: DateTime(2000, 1, 1),
                          maximumDateTime: DateTime(2050, 12, 31),
                          initialDateTime: _selectedDate,
                          barrierColor: Colors.transparent,
                          containerDecoration: PickerContainerDecoration(
                            backgroundColor: AppConstants.dropDownButtonsColor(
                              context,
                            ),
                            backgroundType: PickerBackgroundType.plainColor,
                          ),
                          mode: CupertinoCalendarMode.date,
                          timeLabel: 'Saat',
                          onDateTimeChanged: (date) {
                            setState(() {
                              _selectedDate = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                _selectedDate.hour,
                                _selectedDate.minute,
                              );
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 24,
                    color: Theme.of(context).dividerColor,
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 20,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        CupertinoTimePickerButton(
                          buttonDecoration: PickerButtonDecoration(
                            textStyle: TextStyle(
                              fontSize: 16,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                            backgroundColor: Colors.transparent,
                          ),
                          initialTime: TimeOfDay.fromDateTime(_selectedDate),
                          barrierColor: Colors.transparent,
                          containerDecoration: PickerContainerDecoration(
                            backgroundColor: AppConstants.dropDownButtonsColor(
                              context,
                            ),
                            backgroundType: PickerBackgroundType.plainColor,
                          ),
                          onTimeChanged: (time) {
                            setState(() {
                              _selectedDate = DateTime(
                                _selectedDate.year,
                                _selectedDate.month,
                                _selectedDate.day,
                                time.hour,
                                time.minute,
                              );
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saveTransaction,
                child: Text(widget.transaction == null ? "Kaydet" : "Güncelle"),
              ),
              const SizedBox(height: 48), // Bottom padding for ease of use
            ],
          ),
        ),
      ),
    );
  }
}

// 3. İşlem Listesi (Doğrudan SliverList döndürür)
class FinancialsSliverList extends StatelessWidget {
  final CustomerModel customer;
  const FinancialsSliverList({super.key, required this.customer});

  void _deleteTransaction(
    BuildContext context,
    FinancialTransaction transaction,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("İşlemi Sil"),
        content: const Text("Bu işlemi silmek istediğinize emin misiniz?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("İptal"),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              final updatedList = List<FinancialTransaction>.from(
                customer.transactions,
              );
              updatedList.remove(transaction);

              final updatedCustomer = customer.copyWith(
                transactions: updatedList,
              );
              context.read<CustomerProvider>().editCustomer(updatedCustomer);
            },
            child: const Text("Sil"),
          ),
        ],
      ),
    );
  }

  void _editTransaction(
    BuildContext context,
    FinancialTransaction transaction,
  ) async {
    final FinancialTransaction? updatedTransaction =
        await showModalBottomSheet<FinancialTransaction>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          showDragHandle: true,
          builder: (context) => AddTransactionSheet(transaction: transaction),
        );

    if (updatedTransaction != null && context.mounted) {
      final updatedList = List<FinancialTransaction>.from(
        customer.transactions,
      );
      final index = updatedList.indexWhere((t) => t.id == transaction.id);

      if (index != -1) {
        updatedList[index] = updatedTransaction;
        final updatedCustomer = customer.copyWith(transactions: updatedList);
        context.read<CustomerProvider>().editCustomer(updatedCustomer);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (customer.transactions.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "Henüz işlem yok",
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
            ),
          ),
        ),
      );
    }

    final sortedList = List<FinancialTransaction>.from(customer.transactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    return SliverList.separated(
      itemCount: sortedList.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = sortedList[index];
        final isDebt = item.type == TransactionType.debt;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: isDebt
                  ? Theme.of(context).colorScheme.errorContainer
                  : Colors.green.withValues(alpha: 0.1),
              child: Icon(
                isDebt ? Icons.remove : Icons.add,
                color: isDebt
                    ? Theme.of(context).colorScheme.error
                    : Colors.green,
              ),
            ),
            title: Text(
              item.description.isEmpty
                  ? (isDebt ? "Borç" : "Ödeme")
                  : item.description,
            ),
            subtitle: Text(DateFormat('dd.MM.yyyy HH:mm').format(item.date)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${item.amount.toStringAsFixed(2)} ₺",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isDebt
                        ? Theme.of(context).colorScheme.error
                        : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                PullDownButton(
                  routeTheme: PullDownMenuRouteTheme(
                    backgroundColor: AppConstants.dropDownButtonsColor(context),
                  ),
                  itemBuilder: (context) => [
                    PullDownMenuItem(
                      title: 'Düzenle',
                      icon: Icons.edit_outlined,
                      onTap: () => _editTransaction(context, item),
                    ),
                    PullDownMenuItem(
                      title: 'Sil',
                      icon: Icons.delete_outline,
                      isDestructive: true,
                      onTap: () => _deleteTransaction(context, item),
                    ),
                  ],
                  buttonBuilder: (context, showMenu) => IconButton(
                    onPressed: showMenu,
                    icon: const Icon(Icons.more_vert),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/financial_goal.dart';

class GoalFormDialog extends StatefulWidget {
  final FinancialGoal? initialGoal;
  final void Function(FinancialGoal goal) onSave;
  final VoidCallback? onDelete;

  const GoalFormDialog({
    super.key,
    this.initialGoal,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<GoalFormDialog> createState() => _GoalFormDialogState();
}

class _GoalFormDialogState extends State<GoalFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _currentAmountController;
  late final TextEditingController _targetAmountController;
  late GoalCategory _selectedCategory;
  late DateTime _deadline;

  bool get _isEdit => widget.initialGoal != null;

  @override
  void initState() {
    super.initState();
    final goal = widget.initialGoal;
    _nameController = TextEditingController(text: goal?.name ?? '');
    _descriptionController = TextEditingController(text: goal?.description ?? '');
    _currentAmountController =
        TextEditingController(text: (goal?.currentAmount ?? 0).toStringAsFixed(0));
    _targetAmountController =
        TextEditingController(text: (goal?.targetAmount ?? 0).toStringAsFixed(0));
    _selectedCategory = goal?.category ?? GoalCategory.other;
    _deadline = goal?.deadline ?? DateTime.now().add(const Duration(days: 365));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _currentAmountController.dispose();
    _targetAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _isEdit ? 'Edit Goal' : 'Add New Goal',
                        style: AppTextStyles.h3,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Goal Name'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter a name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration:
                      const InputDecoration(labelText: 'Description (Optional)'),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _currentAmountController,
                  decoration: const InputDecoration(
                    labelText: 'Current Savings',
                    prefixText: '\$ ',
                  ),
                  keyboardType: TextInputType.number,
                  validator: _validateNumber,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _targetAmountController,
                  decoration: const InputDecoration(
                    labelText: 'Target Amount',
                    prefixText: '\$ ',
                  ),
                  keyboardType: TextInputType.number,
                  validator: _validateNumber,
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Deadline'),
                  subtitle: Text(DateFormat('MMM dd, yyyy').format(_deadline)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _deadline,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (date != null) {
                      setState(() => _deadline = date);
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<GoalCategory>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: GoalCategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_getCategoryIcon(category), size: 20),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              _getCategoryName(category),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedCategory = value);
                    }
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    if (widget.onDelete != null)
                      OutlinedButton.icon(
                        onPressed: widget.onDelete,
                        icon: const Icon(Icons.delete_outline, color: AppColors.error),
                        label: const Text('Delete'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                        ),
                      ),
                    if (widget.onDelete != null) const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveGoal,
                        child: Text(_isEdit ? 'Update Goal' : 'Add Goal'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _validateNumber(String? value) {
    if (value?.isEmpty ?? true) return 'Please enter a value';
    return double.tryParse(value!) == null ? 'Please enter a valid number' : null;
  }

  void _saveGoal() {
    if (!_formKey.currentState!.validate()) return;

    final goal = FinancialGoal(
      id: widget.initialGoal?.id,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      currentAmount: double.parse(_currentAmountController.text),
      targetAmount: double.parse(_targetAmountController.text),
      deadline: _deadline,
      category: _selectedCategory,
      createdAt: widget.initialGoal?.createdAt,
    );

    widget.onSave(goal);
    Navigator.pop(context);
  }

  String _getCategoryName(GoalCategory category) {
    final raw = category.toString().split('.').last;
    return raw[0].toUpperCase() + raw.substring(1);
  }

  IconData _getCategoryIcon(GoalCategory category) {
    switch (category) {
      case GoalCategory.house:
        return Icons.home;
      case GoalCategory.car:
        return Icons.directions_car;
      case GoalCategory.wedding:
        return Icons.favorite;
      case GoalCategory.education:
        return Icons.school;
      case GoalCategory.vacation:
        return Icons.flight;
      case GoalCategory.emergency:
        return Icons.health_and_safety;
      default:
        return Icons.savings;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Quick add expense dialog with minimal friction
/// Categories: Groceries, Dining, Transportation, Utilities, Entertainment, Healthcare, Shopping, Rent, Goals, Other
class QuickAddExpenseDialog extends StatefulWidget {
  final Function(double amount, String category, String? note) onAdd;
  final List<String> availableGoals; // For goal contributions

  const QuickAddExpenseDialog({
    super.key,
    required this.onAdd,
    this.availableGoals = const [],
  });

  @override
  State<QuickAddExpenseDialog> createState() => _QuickAddExpenseDialogState();
}

class _QuickAddExpenseDialogState extends State<QuickAddExpenseDialog> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String? _selectedCategory;
  String? _selectedGoal;
  bool _isLoading = false;

  final List<CategoryOption> _categories = [
    CategoryOption('groceries', 'Groceries', Icons.shopping_cart, AppColors.emerald),
    CategoryOption('dining', 'Dining', Icons.restaurant, AppColors.orange),
    CategoryOption('transportation', 'Transport', Icons.directions_car, AppColors.accentCyan),
    CategoryOption('utilities', 'Utilities', Icons.lightbulb, AppColors.warning),
    CategoryOption('entertainment', 'Fun', Icons.movie, AppColors.purple),
    CategoryOption('healthcare', 'Health', Icons.local_hospital, AppColors.error),
    CategoryOption('shopping', 'Shopping', Icons.shopping_bag, AppColors.pink),
    CategoryOption('rent', 'Rent', Icons.home, AppColors.info),
    CategoryOption('other', 'Other', Icons.category, AppColors.textSecondary),
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.primaryDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: AppColors.glassLight, width: 1),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accentCyan.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: AppColors.glowingShadow(color: AppColors.accentCyan, blur: 10),
                  ),
                  child: const Icon(
                    Icons.add_circle_outline,
                    color: AppColors.accentCyan,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Add Expense',
                    style: AppTextStyles.h2,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ).animate().fadeIn().slideY(begin: -0.2),
            const SizedBox(height: 24),

            // Amount Input - Big and prominent
            Text('Amount', style: AppTextStyles.labelLarge)
                .animate(delay: 100.ms)
                .fadeIn(),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              style: AppTextStyles.h1.copyWith(color: AppColors.accentCyan),
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 8),
                  child: Text('\$', style: AppTextStyles.h2),
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 0),
                hintText: '0.00',
                hintStyle: AppTextStyles.h1.copyWith(
                  color: AppColors.textTertiary,
                ),
                filled: true,
                fillColor: AppColors.primaryLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
              ),
            ).animate(delay: 150.ms).fadeIn().scale(),
            const SizedBox(height: 24),

            // Category Selection - Visual grid
            Text('Category', style: AppTextStyles.labelLarge)
                .animate(delay: 200.ms)
                .fadeIn(),
            const SizedBox(height: 12),
            _buildCategoryGrid().animate(delay: 250.ms).fadeIn().scale(),
            const SizedBox(height: 20),

            // Goal Selection (if any goals exist)
            if (widget.availableGoals.isNotEmpty) ...[
              Text('Or contribute to a goal', style: AppTextStyles.labelLarge)
                  .animate(delay: 300.ms)
                  .fadeIn(),
              const SizedBox(height: 8),
              _buildGoalSelector().animate(delay: 350.ms).fadeIn(),
              const SizedBox(height: 20),
            ],

            // Optional Note
            TextField(
              controller: _noteController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Note (optional)',
                hintText: 'What was this for?',
                filled: true,
                fillColor: AppColors.primaryLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ).animate(delay: 400.ms).fadeIn(),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleAdd,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentCyan,
                      foregroundColor: AppColors.primaryDark,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.primaryDark,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Add Expense'),
                  ),
                ),
              ],
            ).animate(delay: 450.ms).fadeIn(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _categories.map((cat) {
        final isSelected = _selectedCategory == cat.value;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCategory = cat.value;
              _selectedGoal = null; // Deselect goal if category is selected
            });
          },
          child: Container(
            width: 90,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? cat.color.withValues(alpha: 0.2)
                  : AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? cat.color : AppColors.glassLight,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? AppColors.glowingShadow(color: cat.color, blur: 10)
                  : null,
            ),
            child: Column(
              children: [
                Icon(
                  cat.icon,
                  color: isSelected ? cat.color : AppColors.textSecondary,
                  size: 28,
                ),
                const SizedBox(height: 4),
                Text(
                  cat.label,
                  style: AppTextStyles.caption.copyWith(
                    color: isSelected ? cat.color : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGoalSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _selectedGoal != null ? AppColors.emerald : AppColors.glassLight,
          width: _selectedGoal != null ? 2 : 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedGoal,
          hint: const Text('Select a goal'),
          isExpanded: true,
          dropdownColor: AppColors.primaryMid,
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('None (regular expense)'),
            ),
            ...widget.availableGoals.map((goal) {
              return DropdownMenuItem<String>(
                value: goal,
                child: Row(
                  children: [
                    const Icon(Icons.flag, color: AppColors.emerald, size: 20),
                    const SizedBox(width: 8),
                    Text(goal),
                  ],
                ),
              );
            }),
          ],
          onChanged: (value) {
            setState(() {
              _selectedGoal = value;
              if (value != null) {
                _selectedCategory = null; // Deselect category if goal is selected
              }
            });
          },
        ),
      ),
    );
  }

  void _handleAdd() async {
    final amountText = _amountController.text.trim();

    if (amountText.isEmpty) {
      _showError('Please enter an amount');
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      _showError('Please enter a valid amount');
      return;
    }

    if (_selectedCategory == null && _selectedGoal == null) {
      _showError('Please select a category or goal');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final category = _selectedGoal != null ? 'goal' : _selectedCategory!;
      final note = _selectedGoal != null
          ? 'Saved to $_selectedGoal${_noteController.text.isNotEmpty ? ' - ${_noteController.text}' : ''}'
          : _noteController.text.isNotEmpty
              ? _noteController.text
              : null;

      await widget.onAdd(amount, category, note);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to add expense: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }
}

class CategoryOption {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  CategoryOption(this.value, this.label, this.icon, this.color);
}

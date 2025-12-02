import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart' as provider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/cards/glass_container.dart';
import '../../providers/currency_provider.dart';
import '../../presentation/providers/auth_state_provider.dart';
import '../api_test_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String _selectedAvatar = 'person'; // Default avatar
  final List<Map<String, dynamic>> _avatarOptions = [
    {'icon': Icons.person, 'name': 'person'},
    {'icon': Icons.account_circle, 'name': 'account_circle'},
    {'icon': Icons.face, 'name': 'face'},
    {'icon': Icons.emoji_emotions, 'name': 'emoji_emotions'},
    {'icon': Icons.sentiment_satisfied, 'name': 'sentiment_satisfied'},
    {'icon': Icons.psychology, 'name': 'psychology'},
    {'icon': Icons.rocket_launch, 'name': 'rocket_launch'},
    {'icon': Icons.spa, 'name': 'spa'},
    {'icon': Icons.star, 'name': 'star'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile & Settings', style: AppTextStyles.h3),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar with luminous ring
            GestureDetector(
              onTap: _showAvatarPicker,
              child: _buildAvatar(),
            ),
            const SizedBox(height: 24),

            // User Info - Show real user data from API
            Builder(
              builder: (context) {
                final authState = ref.watch(authStateProvider);
                final user = authState.user;
                
                return Column(
                  children: [
                    Text(
                      user?.fullName ?? 'John Doe',
                      style: AppTextStyles.h2,
                    ).animate().fadeIn(),
                    const SizedBox(height: 8),
                    Text(
                      user?.email ?? user?.phoneNumber ?? 'john.doe@example.com',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ).animate(delay: 100.ms).fadeIn(),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),

            // Settings Sections
            _buildSettingsSection(
              'Preferences',
              [
                _buildSettingTile(
                  'Notifications',
                  Icons.notifications_outlined,
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {},
                    activeThumbColor: AppColors.accentCyan,
                  ),
                ),
                provider.Consumer<CurrencyProvider>(
                  builder: (context, currencyProvider, child) {
                    return _buildSettingTile(
                      'Currency',
                      Icons.attach_money,
                      subtitle: '${currencyProvider.currencyCode} (${currencyProvider.currencySymbol})',
                      onTap: () => _showCurrencyDialog(context, currencyProvider),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            Builder(
              builder: (context) {
                final authState = ref.watch(authStateProvider);
                final user = authState.user;
                
                return _buildSettingsSection(
                  'Account',
                  [
                    _buildSettingTile(
                      'Change Name',
                      Icons.person_outline,
                      onTap: () => _showChangeDialog('Name', user?.fullName ?? 'Not set'),
                    ),
                    _buildSettingTile(
                      'Change Email',
                      Icons.email_outlined,
                      onTap: () => _showChangeDialog('Email', user?.email ?? 'Not set'),
                    ),
                    _buildSettingTile(
                      'Change Phone Number',
                      Icons.phone_outlined,
                      onTap: () => _showChangeDialog('Phone Number', user?.phoneNumber ?? 'Not set'),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            _buildSettingsSection(
              'Security',
              [
                _buildSettingTile(
                  'Biometric Login',
                  Icons.fingerprint,
                  trailing: Switch(
                    value: false,
                    onChanged: (value) {},
                    activeThumbColor: AppColors.accentCyan,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildSettingsSection(
              'About',
              [
                _buildSettingTile(
                  'Terms & Conditions',
                  Icons.description_outlined,
                ),
                _buildSettingTile(
                  'Privacy Policy',
                  Icons.privacy_tip_outlined,
                ),
                _buildSettingTile(
                  'App Version',
                  Icons.info_outline,
                  subtitle: '1.0.0',
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildSettingsSection(
              'Developer Tools',
              [
                _buildSettingTile(
                  'Test API Connection',
                  Icons.wifi_tethering,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ApiTestScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Logout Button
            GestureDetector(
              onTap: () => _handleLogout(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout, color: AppColors.error),
                    const SizedBox(width: 8),
                    Text(
                      'Log Out',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 600.ms).scale(begin: const Offset(0.9, 0.9)),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final selectedIconData = _avatarOptions.firstWhere(
      (option) => option['name'] == _selectedAvatar,
      orElse: () => _avatarOptions[0],
    )['icon'] as IconData;

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.accentGradient,
        boxShadow: AppColors.glowingShadow(
          color: AppColors.accentCyan,
          blur: 30,
          spread: 5,
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primaryMid,
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                selectedIconData,
                size: 60,
                color: AppColors.accentCyan,
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentCyan,
                  boxShadow: AppColors.glowingShadow(
                    color: AppColors.accentCyan,
                    blur: 10,
                  ),
                ),
                child: const Icon(
                  Icons.edit,
                  size: 16,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: 2000.ms,
          color: AppColors.accentCyan.withValues(alpha: 0.3),
        );
  }

  void _showAvatarPicker() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text('Choose Profile Picture', style: AppTextStyles.h3),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: _avatarOptions.map((option) {
                  final isSelected = option['name'] == _selectedAvatar;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedAvatar = option['name']);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? AppColors.accentCyan.withValues(alpha: 0.2)
                            : AppColors.primaryLight,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.accentCyan
                              : AppColors.glassLight,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        option['icon'] as IconData,
                        size: 36,
                        color:
                            isSelected ? AppColors.accentCyan : AppColors.textSecondary,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangeDialog(String field, String currentValue) {
    final controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text('Change $field', style: AppTextStyles.h3),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(dialogContext),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: field,
                ),
                keyboardType: field == 'Email'
                    ? TextInputType.emailAddress
                    : field == 'Phone Number'
                        ? TextInputType.phone
                        : TextInputType.text,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      final newValue = controller.text.trim();

                      if (newValue.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Field cannot be empty'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                        return;
                      }

                      // Close dialog
                      Navigator.pop(dialogContext);

                      // Phone number updates require OTP flow (not implemented yet)
                      if (field == 'Phone Number') {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Phone number updates require OTP verification (coming soon)'),
                              backgroundColor: AppColors.warning,
                            ),
                          );
                        }
                        return;
                      }

                      // Update name or email via API
                      final success = await ref.read(authStateProvider.notifier).updateProfile(
                        fullName: field == 'Name' ? newValue : null,
                        email: field == 'Email' ? newValue : null,
                      );

                      if (mounted) {
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$field updated successfully'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        } else {
                          final error = ref.read(authStateProvider).error;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(error ?? 'Failed to update $field'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context, CurrencyProvider currencyProvider) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text('Select Currency', style: AppTextStyles.h3),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildCurrencyOption(
                context,
                currencyProvider,
                Currency.usd,
                'US Dollar',
                'USD (\$)',
                Icons.attach_money,
              ),
              const SizedBox(height: 12),
              _buildCurrencyOption(
                context,
                currencyProvider,
                Currency.uzs,
                'Uzbek Sum',
                'UZS (so\'m)',
                Icons.money,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accentCyan.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.accentCyan.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.accentCyan,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Exchange rate: 1 USD = 12,000 UZS',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencyOption(
    BuildContext context,
    CurrencyProvider currencyProvider,
    Currency currency,
    String name,
    String code,
    IconData icon,
  ) {
    final isSelected = currencyProvider.selectedCurrency == currency;
    
    return GestureDetector(
      onTap: () {
        currencyProvider.setCurrency(currency);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Currency changed to $code'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accentCyan.withValues(alpha: 0.15)
              : AppColors.primaryLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.accentCyan
                : AppColors.glassLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.accentCyan.withValues(alpha: 0.2)
                    : AppColors.primaryMid,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.accentCyan : AppColors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.accentCyan : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    code,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.accentCyan,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        GlassContainer(
          padding: EdgeInsets.zero,
          child: Column(
            children: tiles,
          ),
        ),
      ],
    ).animate().fadeIn().slideX(begin: -0.2);
  }

  Widget _buildSettingTile(
    String title,
    IconData icon, {
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.accentCyan.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.accentCyan, size: 20),
      ),
      title: Text(title, style: AppTextStyles.bodyMedium),
      subtitle: subtitle != null
          ? Text(subtitle, style: AppTextStyles.caption)
          : null,
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: trailing == null ? (onTap ?? () {}) : null,
    );
  }

  Future<void> _handleLogout() async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Sign out
      await ref.read(authStateProvider.notifier).signOut();
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logged out successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        
        // Navigation will be handled automatically by main.dart
        // when auth state changes
      }
    }
  }
}

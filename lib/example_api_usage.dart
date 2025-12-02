// ignore_for_file: avoid_print

library;

/// Example file showing how to use the API integration
///
/// This file demonstrates all API endpoints with working code examples.
/// You can copy these examples into your actual screens/widgets.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/errors/api_exception.dart';
import 'data/models/chat_model.dart';
import 'data/models/debt_model.dart';
import 'data/models/expense_model.dart';
import 'data/models/goal_model.dart';
import 'data/models/user_model.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/chat_repository.dart';
import 'data/repositories/dashboard_repository.dart';
import 'data/repositories/debt_repository.dart';
import 'data/repositories/expense_repository.dart';
import 'data/repositories/goal_repository.dart';

/// Example: Complete Authentication Flow
class AuthenticationExample extends ConsumerStatefulWidget {
  const AuthenticationExample({super.key});

  @override
  ConsumerState<AuthenticationExample> createState() =>
      _AuthenticationExampleState();
}

class _AuthenticationExampleState extends ConsumerState<AuthenticationExample> {
  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  String? message;

  // Step 1: Sign Up
  Future<void> signUp() async {
    final authRepo = ref.read(authRepositoryProvider);

    try {
      final request = SignUpRequest(
        phoneNumber: phoneController.text,
        fullName: 'John Doe',
        email: 'john@example.com',
      );

      final response = await authRepo.signUp(request);
      setState(() {
        message = '✅ ${response.message}. User ID: ${response.userId}';
      });
    } on BadRequestException catch (e) {
      setState(() => message = '❌ ${e.message}');
    } catch (e) {
      setState(() => message = '❌ Error: $e');
    }
  }

  // Step 2: Request OTP
  Future<void> requestOtp() async {
    final authRepo = ref.read(authRepositoryProvider);

    try {
      final response = await authRepo.requestOtp(phoneController.text);
      setState(() {
        message = '✅ ${response.message}';
        if (response.otpCode != null) {
          message = '$message\n🔑 OTP: ${response.otpCode}';
        }
      });
    } catch (e) {
      setState(() => message = '❌ Error: $e');
    }
  }

  // Step 3: Verify OTP & Sign In
  Future<void> verifyOtp() async {
    final authRepo = ref.read(authRepositoryProvider);

    try {
      await authRepo.verifyOtp(
        phoneController.text,
        otpController.text,
      );
      setState(() {
        message = '✅ Signed in successfully!\n🎫 Token saved automatically';
      });
    } on UnauthorizedException catch (e) {
      setState(() => message = '❌ ${e.message}');
    } catch (e) {
      setState(() => message = '❌ Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Authentication Example')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
            ),
            TextField(
              controller: otpController,
              decoration: const InputDecoration(labelText: 'OTP Code'),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(onPressed: signUp, child: const Text('Sign Up')),
                ElevatedButton(
                    onPressed: requestOtp, child: const Text('Request OTP')),
                ElevatedButton(
                    onPressed: verifyOtp, child: const Text('Verify OTP')),
              ],
            ),
            const SizedBox(height: 20),
            if (message != null) Text(message!),
          ],
        ),
      ),
    );
  }
}

/// Example: Get User Profile (Using Provider)
class ProfileExample extends ConsumerWidget {
  const ProfileExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile Example')),
      body: userAsync.when(
        data: (user) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('👤 Name: ${user.fullName}',
                  style: const TextStyle(fontSize: 18)),
              Text('📱 Phone: ${user.phoneNumber}'),
              Text('📧 Email: ${user.email ?? "Not set"}'),
              Text('🎂 DOB: ${user.dateOfBirth ?? "Not set"}'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final authRepo = ref.read(authRepositoryProvider);
                  try {
                    final request = UpdateProfileRequest(
                      fullName: 'Updated Name',
                      email: 'newemail@example.com',
                    );
                    await authRepo.updateProfile(request);
                    // Refresh profile
                    ref.invalidate(currentUserProvider);
                  } catch (e) {
                    print('Error updating profile: $e');
                  }
                },
                child: const Text('Update Profile'),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

/// Example: Dashboard
class DashboardExample extends ConsumerWidget {
  const DashboardExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Example')),
      body: dashboardAsync.when(
        data: (dashboard) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(dashboardProvider);
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        '\$${dashboard.netWorth.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      const Text('Net Worth'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('💡 Insights',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...dashboard.insights.map((insight) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text('• $insight'),
                          )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('📊 Overview',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...dashboard.overview.map((sector) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                                '${sector.sector}: ${sector.portionPercent.toStringAsFixed(1)}%'),
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

/// Example: Expenses
class ExpensesExample extends ConsumerWidget {
  const ExpensesExample({super.key});

  Future<void> addExpense(WidgetRef ref) async {
    final expenseRepo = ref.read(expenseRepositoryProvider);

    try {
      final request = AddExpenseRequest(
        amount: 42.50,
        category: 'groceries',
        note: 'Weekly shopping',
      );

      final response = await expenseRepo.addExpense(request);
      print('✅ ${response.message}');

      // Refresh expenses list
      ref.invalidate(expensesProvider);
    } catch (e) {
      print('❌ Error: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ExpenseFilter(limit: 50);
    final expensesAsync = ref.watch(expensesProvider(filter));

    return Scaffold(
      appBar: AppBar(title: const Text('Expenses Example')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addExpense(ref),
        child: const Icon(Icons.add),
      ),
      body: expensesAsync.when(
        data: (expenses) => ListView.builder(
          itemCount: expenses.length,
          itemBuilder: (context, index) {
            final expense = expenses[index];
            return ListTile(
              leading: Text(
                '\$${expense.amount}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              title: Text(expense.category),
              subtitle: Text(expense.note ?? ''),
              trailing: Text(expense.timestamp.substring(0, 10)),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

/// Example: Goals
class GoalsExample extends ConsumerWidget {
  const GoalsExample({super.key});

  Future<void> createGoal(WidgetRef ref) async {
    final goalRepo = ref.read(goalRepositoryProvider);

    try {
      final request = CreateGoalRequest(
        name: 'Emergency Fund',
        icon: '💰',
        description: 'Save for emergencies',
        totalContribution: 10000,
        monthlyRecurringContribution: 500,
        color: '#4CAF50',
      );

      final response = await goalRepo.createGoal(request);
      print('✅ ${response.message}');

      // Refresh goals list
      ref.invalidate(goalsProvider);
    } catch (e) {
      print('❌ Error: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Goals Example')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => createGoal(ref),
        child: const Icon(Icons.add),
      ),
      body: goalsAsync.when(
        data: (goals) => ListView.builder(
          itemCount: goals.length,
          itemBuilder: (context, index) {
            final goal = goals[index];
            return ListTile(
              leading: Text(goal.icon ?? '🎯', style: const TextStyle(fontSize: 24)),
              title: Text(goal.name),
              subtitle: LinearProgressIndicator(
                value: goal.progress / 100,
                backgroundColor: Colors.grey[300],
              ),
              trailing: Text('${goal.progress.toStringAsFixed(1)}%'),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

/// Example: Chat
class ChatExample extends ConsumerStatefulWidget {
  const ChatExample({super.key});

  @override
  ConsumerState<ChatExample> createState() => _ChatExampleState();
}

class _ChatExampleState extends ConsumerState<ChatExample> {
  final messageController = TextEditingController();
  String? threadId;
  final List<ChatMessage> messages = [];

  Future<void> sendMessage() async {
    if (messageController.text.isEmpty) return;

    final chatRepo = ref.read(chatRepositoryProvider);

    try {
      final request = ChatRequest(
        message: messageController.text,
        threadId: threadId,
      );

      final response = await chatRepo.sendMessage(request);

      setState(() {
        // Add user message
        messages.add(ChatMessage(
          role: 'user',
          content: messageController.text,
          timestamp: DateTime.now().toIso8601String(),
        ));

        // Add AI response
        messages.add(ChatMessage(
          role: 'assistant',
          content: response.reply,
          timestamp: DateTime.now().toIso8601String(),
        ));

        threadId = response.threadId;
        messageController.clear();
      });
    } catch (e) {
      print('❌ Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat Example')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[messages.length - 1 - index];
                final isUser = message.role == 'user';
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      message.content,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: sendMessage,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Example: Debts
class DebtsExample extends ConsumerWidget {
  const DebtsExample({super.key});

  Future<void> addDebt(WidgetRef ref) async {
    final debtRepo = ref.read(debtRepositoryProvider);

    try {
      final request = AddDebtRequest(
        creditor: 'Chase Credit Card',
        totalAmount: 5000,
        remainingAmount: 3250,
        monthlyPayment: 250,
        dueDate: 15,
      );

      final response = await debtRepo.addDebt(request);
      print('✅ ${response.message}');

      // Refresh debt summary
      ref.invalidate(debtSummaryProvider);
    } catch (e) {
      print('❌ Error: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(debtSummaryProvider(null));

    return Scaffold(
      appBar: AppBar(title: const Text('Debts Example')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addDebt(ref),
        child: const Icon(Icons.add),
      ),
      body: summaryAsync.when(
        data: (summary) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      '\$${summary.totalDebt.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.red),
                    ),
                    const Text('Total Debt'),
                    const SizedBox(height: 8),
                    Text(
                      '\$${summary.monthlyObligations.toStringAsFixed(2)}/month',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...summary.debts.map(
              (debt) => Card(
                child: ListTile(
                  title: Text(debt.creditor),
                  subtitle: Text(
                    '\$${debt.remainingAmount} / \$${debt.totalAmount}',
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('\$${debt.monthlyPayment}/mo'),
                      Text('Due: ${debt.dueDate}'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

/// Example: Error Handling
class ErrorHandlingExample extends ConsumerWidget {
  const ErrorHandlingExample({super.key});

  Future<void> handleApiCall(WidgetRef ref, BuildContext context) async {
    final authRepo = ref.read(authRepositoryProvider);

    try {
      final user = await authRepo.getProfile();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Welcome ${user.fullName}!')),
        );
      }
    } on UnauthorizedException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('🔒 ${e.message}')),
        );
        // Navigate to login screen
        Navigator.pushReplacementNamed(context, '/login');
      }
    } on NetworkException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('📡 ${e.message}')),
        );
      }
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ ${e.message}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ An unexpected error occurred')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error Handling Example')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => handleApiCall(ref, context),
          child: const Text('Test Error Handling'),
        ),
      ),
    );
  }
}

import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../data/repositories/chat_repository.dart';
import '../data/models/chat_model.dart' as api;
import '../core/constants/app_config.dart';
import '../core/errors/api_exception.dart';
import 'dart:math';

class ChatProvider with ChangeNotifier {
  ChatRepository? _chatRepository;
  final List<ChatMessage> _messages = [];
  bool _isAITyping = false;
  String? _currentThreadId;

  ChatProvider({ChatRepository? chatRepository}) : _chatRepository = chatRepository;

  /// Update the chat repository (e.g., when user logs in)
  void updateRepository(ChatRepository? chatRepository) {
    _chatRepository = chatRepository;
  }

  List<ChatMessage> get messages => _messages;
  bool get isAITyping => _isAITyping;
  String? get currentThreadId => _currentThreadId;

  void sendMessage(String content, {bool isVoice = false}) async {
    final userMessage = ChatMessage(
      content: content,
      sender: MessageSender.user,
      isVoice: isVoice,
    );

    _messages.insert(0, userMessage);
    notifyListeners();

    // Use real API or simulate
    if (AppConfig.useMockData || _chatRepository == null) {
      _simulateAIResponse(content);
    } else {
      await _sendToAPI(content);
    }
  }

  Future<void> _sendToAPI(String content) async {
    _isAITyping = true;
    notifyListeners();

    try {
      final request = api.ChatRequest(
        message: content,
        threadId: _currentThreadId,
      );

      final response = await _chatRepository!.sendMessage(request);
      
      // Save thread ID for conversation continuity
      _currentThreadId = response.threadId;

      final aiMessage = ChatMessage(
        content: response.reply,
        sender: MessageSender.ai,
      );

      _messages.insert(0, aiMessage);
    } on ServerException catch (e) {
      final errorMessage = ChatMessage(
        content: '⚠️ Server error (${e.statusCode}). The backend AI service may be having issues. Please try again in a moment.',
        sender: MessageSender.ai,
      );
      _messages.insert(0, errorMessage);
    } on NetworkException {
      final errorMessage = ChatMessage(
        content: '📡 Network error. Please check your internet connection.',
        sender: MessageSender.ai,
      );
      _messages.insert(0, errorMessage);
    } catch (e) {
      final errorMessage = ChatMessage(
        content: '⚠️ Error: ${e.toString()}\n\nThe AI backend may be temporarily unavailable. Try again in a moment.',
        sender: MessageSender.ai,
      );
      _messages.insert(0, errorMessage);
    } finally {
      _isAITyping = false;
      notifyListeners();
    }
  }

  void _simulateAIResponse(String userMessage) {
    _isAITyping = true;
    notifyListeners();

    // Simulate typing delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      final response = _generateAIResponse(userMessage);
      final aiMessage = ChatMessage(
        content: response,
        sender: MessageSender.ai,
      );

      _messages.insert(0, aiMessage);
      _isAITyping = false;
      notifyListeners();
    });
  }

  String _generateAIResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('income') || lowerMessage.contains('earn')) {
      return 'Based on your recent trends, your income has been stable at around \$4,500 per month. I predict a slight increase of 5% next month due to your freelance projects.';
    } else if (lowerMessage.contains('save') || lowerMessage.contains('saving')) {
      return 'You\'re doing great! You\'re currently saving 18% of your income. To reach your goals faster, I recommend increasing this to 25% by reducing entertainment expenses.';
    } else if (lowerMessage.contains('expense') || lowerMessage.contains('spending')) {
      return 'Your total expenses this month are \$3,200. The largest categories are: Food (\$410), Bills (\$750), and Shopping (\$520). Consider reducing shopping expenses as you\'re over budget.';
    } else if (lowerMessage.contains('budget')) {
      return 'You\'ve exceeded your Shopping budget by \$120. Your Food budget is at 82%. I suggest allocating more to Food and less to Shopping next month.';
    } else if (lowerMessage.contains('goal') || lowerMessage.contains('target')) {
      return 'You have 4 active goals totaling \$120,000. At your current pace, you\'ll reach your Emergency Fund goal in 2 months. Great progress on your wedding fund!';
    } else if (lowerMessage.contains('subscription')) {
      return 'You\'re spending \$142 monthly on subscriptions. Netflix, Spotify, and Gym are your main subscriptions. Consider canceling Adobe Creative Cloud if you\'re not using it regularly.';
    } else if (lowerMessage.contains('hello') || lowerMessage.contains('hi')) {
      return 'Hello! I\'m your AI Financial Advisor. How can I help you manage your finances today?';
    } else if (lowerMessage.contains('help')) {
      return 'I can help you with:\n• Income predictions\n• Expense tracking\n• Budget management\n• Savings goals\n• Subscription analysis\n• Financial insights\n\nWhat would you like to know?';
    } else {
      final responses = [
        'That\'s an interesting question. Let me analyze your financial data to provide accurate insights.',
        'Based on your spending patterns, I\'d recommend reviewing your monthly budget allocation.',
        'I\'ve noticed some interesting trends in your financial behavior. Would you like me to explain?',
        'Your financial health is looking good overall. Keep up the consistent saving habits!',
      ];
      return responses[Random().nextInt(responses.length)];
    }
  }

  void clearChat() {
    _messages.clear();
    notifyListeners();
  }
}

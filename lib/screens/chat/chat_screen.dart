import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/cards/ai_chat_bubble.dart';
import '../../widgets/animations/waveform_animation.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen>createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _currentText = '';

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    await _speech.initialize();
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              _currentText = result.recognizedWords;
              _textController.text = _currentText;
            });
          },
        );
      }
    }
  }

  void _stopListening() {
    setState(() => _isListening = false);
    _speech.stop();
    if (_currentText.isNotEmpty) {
      _sendMessage(isVoice: true);
    }
  }

  void _sendMessage({bool isVoice = false}) {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      context.read<ChatProvider>().sendMessage(text, isVoice: isVoice);
      _textController.clear();
      setState(() => _currentText = '');
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.emerald,
                shape: BoxShape.circle,
                boxShadow: AppColors.glowingShadow(
                  color: AppColors.emerald,
                  blur: 10,
                ),
              ),
            )
                .animate(onPlay: (controller) => controller.repeat())
                .fadeIn(duration: 1000.ms)
                .then()
                .fadeOut(duration: 1000.ms),
            const SizedBox(width: 12),
            const SizedBox.shrink(),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              context.read<ChatProvider>().clearChat();
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryDark,
              AppColors.primaryMid.withValues(alpha: 0.5),
              AppColors.primaryDark,
            ],
          ),
        ),
        child: Column(
          children: [
            // Chat messages
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, chatProvider, child) {
                  if (chatProvider.messages.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: chatProvider.messages.length +
                        (chatProvider.isAITyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (chatProvider.isAITyping && index == 0) {
                        return _buildTypingIndicator();
                      }

                      final messageIndex = chatProvider.isAITyping
                          ? index - 1
                          : index;
                      final message = chatProvider.messages[messageIndex];

                      return AIChatBubble(
                        message: message.content,
                        isAI: message.isAI,
                        timestamp: message.timestamp,
                      );
                    },
                  );
                },
              ),
            ),

            // Input area
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentCyan.withValues(alpha: 0.1),
              boxShadow: AppColors.glowingShadow(
                color: AppColors.accentCyan,
                blur: 30,
              ),
            ),
            child: const Icon(
              Icons.psychology_outlined,
              size: 60,
              color: AppColors.accentCyan,
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 2000.ms, color: AppColors.accentCyan.withValues(alpha: 0.3)),
          const SizedBox(height: 24),
          Text(
            'Hi! I\'m Puldon AI',
            style: AppTextStyles.h2,
          ).animate().fadeIn().slideY(begin: 0.2),
          const SizedBox(height: 12),
          Text(
            'Ask me anything about your finances',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2),
          const SizedBox(height: 32),
          _buildSuggestionChips(),
        ],
      ),
    );
  }

  Widget _buildSuggestionChips() {
    final suggestions = [
      'How are my expenses?',
      'Show my savings goals',
      'Income prediction',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: suggestions.map((suggestion) {
        return GestureDetector(
          onTap: () {
            _textController.text = suggestion;
            _sendMessage();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.glassLight,
                width: 1,
              ),
            ),
            child: Text(
              suggestion,
              style: AppTextStyles.bodySmall,
            ),
          ),
        );
      }).toList(),
    )
        .animate()
        .fadeIn(delay: 400.ms)
        .slideY(begin: 0.3);
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accentCyan.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.accentCyan.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: WaveformAnimation(
              isAnimating: true,
              color: AppColors.accentCyan,
              height: 24,
              barCount: 5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryMid,
        border: Border(
          top: BorderSide(color: AppColors.glassLight, width: 1),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Text input
            Expanded(
              child: Container(
                // height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: _isListening
                        ? AppColors.accentCyan
                        : AppColors.glassLight,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: TextField(
                    controller: _textController,
                    style: AppTextStyles.bodyMedium,
                    decoration: InputDecoration(
                      hintText: _isListening ? 'Listening...' : 'Ask anything...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                    maxLines: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Voice button
            GestureDetector(
              onTap: _isListening ? _stopListening : _startListening,
              onLongPressStart: (_) => _startListening(),
              onLongPressEnd: (_) => _stopListening(),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isListening
                      ? AppColors.accentCyan
                      : AppColors.primaryLight,
                  boxShadow: _isListening
                      ? AppColors.glowingShadow(
                          color: AppColors.accentCyan,
                          blur: 20,
                        )
                      : null,
                ),
                child: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: _isListening
                      ? AppColors.primaryDark
                      : AppColors.textPrimary,
                ),
              ),
            )
                .animate(
                  target: _isListening ? 1 : 0,
                  onPlay: (controller) =>
                      _isListening ? controller.repeat() : null,
                )
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.1, 1.1),
                  duration: 500.ms,
                ),
            const SizedBox(width: 12),

            // Send button
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentCyan,
                  boxShadow: AppColors.glowingShadow(
                    color: AppColors.accentCyan,
                    blur: 15,
                  ),
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

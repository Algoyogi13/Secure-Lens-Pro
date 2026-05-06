import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/services/api_service.dart';
import '../../core/utils/responsive.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Hi, how can I help you?',
      'isBot': true,
    },
  ];

  bool _loading = false;
  bool _streaming = false;

  bool get _busy => _loading || _streaming;

  String _cleanResponse(String text) {
    return text
        .replaceAll('**', '')
        .replaceAll('*', '')
        .replaceAll('###', '')
        .replaceAll('##', '')
        .replaceAll('#', '')
        .trim();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _busy) return;

    setState(() {
      _messages.add({'text': text, 'isBot': false});
      _loading = true;
    });

    _controller.clear();
    _scrollToBottom();

    try {
      final result = await _apiService.sendChatMessage(text);
      final reply = _cleanResponse(
        result['reply']?.toString() ?? 'No response received.',
      );

      if (!mounted) return;

      setState(() {
        _loading = false;
        _streaming = true;
        _messages.add({'text': '', 'isBot': true});
      });

      await _animateBotReply(reply);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _messages.add({
          'text': 'We could not generate a response right now. Please try again.',
          'isBot': true,
        });
      });
    } finally {
      if (mounted) {
        setState(() => _streaming = false);
        _scrollToBottom();
      }
    }
  }

  Future<void> _animateBotReply(String reply) async {
    final index = _messages.length - 1;
    final words = reply
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();

    if (words.isEmpty) {
      setState(() {
        _messages[index]['text'] = 'No response received.';
      });
      return;
    }

    var current = '';
    for (final word in words) {
      if (!mounted) return;
      current = current.isEmpty ? word : '$current $word';
      setState(() {
        _messages[index]['text'] = current;
      });
      _scrollToBottom();
      await Future<void>.delayed(
        Duration(milliseconds: word.length > 8 ? 75 : 50),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final compact = Responsive.isCompact(context);
    final horizontalPadding = Responsive.horizontalPadding(context);
    final isTablet = Responsive.isTablet(context);

    return Scaffold(
      backgroundColor: const Color(0xFF221E1D),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2B2524), Color(0xFF221E1D)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final contentWidth = isTablet ? 680.0 : constraints.maxWidth;

              return Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: contentWidth,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          compact ? 12 : 14,
                          horizontalPadding,
                          compact ? 10 : 12,
                        ),
                        child: Text(
                          'AI Assistant',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: Responsive.titleSize(context),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            8,
                            horizontalPadding,
                            10,
                          ),
                          itemCount: _messages.length + (_loading ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (_loading && index == _messages.length) {
                              return const Padding(
                                padding: EdgeInsets.only(bottom: 12),
                                child: _TypingBubble(),
                              );
                            }

                            final message = _messages[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _ChatBubble(
                                compact: compact,
                                isBot: message['isBot'] as bool,
                                text: message['text'] as String,
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding - 2,
                          0,
                          horizontalPadding - 2,
                          compact ? 12 : 16,
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: compact ? 10 : 12,
                            vertical: compact ? 8 : 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF342E2C),
                            borderRadius: BorderRadius.circular(compact ? 18 : 20),
                            border: Border.all(color: const Color(0xFF675B57)),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF2A47F).withOpacity(0.08),
                                blurRadius: 14,
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _controller,
                                  minLines: 1,
                                  maxLines: 4,
                                  keyboardType: TextInputType.multiline,
                                  textInputAction: TextInputAction.newline,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: compact ? 14 : 15,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Ask your cybersecurity question...',
                                    hintStyle: TextStyle(
                                      color: const Color(0xFFC7B9B2),
                                      fontSize: compact ? 13.5 : 15,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                ),
                              ),
                              SizedBox(width: compact ? 6 : 8),
                              GestureDetector(
                                onTap: _busy ? null : _sendMessage,
                                child: Container(
                                  width: compact ? 40 : 42,
                                  height: compact ? 40 : 42,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFE68F66), Color(0xFFF6B493)],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFF2A47F).withOpacity(0.24),
                                        blurRadius: 16,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    _busy
                                        ? Icons.hourglass_top_rounded
                                        : Icons.arrow_upward_rounded,
                                    color: const Color(0xFF2B2524),
                                    size: compact ? 18 : 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    final compact = Responsive.isCompact(context);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 14,
          vertical: compact ? 10 : 12,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF3A3431),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0x66F0B292)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Dot(compact: compact),
            SizedBox(width: compact ? 5 : 6),
            _Dot(compact: compact),
            SizedBox(width: compact ? 5 : 6),
            _Dot(compact: compact),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: compact ? 6 : 7,
      height: compact ? 6 : 7,
      decoration: const BoxDecoration(
        color: Color(0xFFFFCEB6),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.isBot,
    required this.text,
    required this.compact,
  });

  final bool isBot;
  final String text;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final align = isBot ? Alignment.centerLeft : Alignment.centerRight;
    final borderColor =
        isBot ? const Color(0x66F0B292) : const Color(0x66F1A17D);
    final bg = isBot ? const Color(0xFF3A3431) : const Color(0xFF554640);

    return Align(
      alignment: align,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: compact ? 260 : 320,
        ),
        child: Container(
          padding: EdgeInsets.all(compact ? 12 : 14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: borderColor.withOpacity(0.12),
                blurRadius: 12,
              ),
            ],
          ),
          child: SelectableText(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 13.2 : 14,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

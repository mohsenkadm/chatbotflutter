import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';

class ChatController extends GetxController {
  var messages = <Map<String, dynamic>>[].obs;
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  var isTyping = false.obs;

  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    loadMessages();
  }

  void loadMessages() {
  List<dynamic>? storedMessages = box.read<List<dynamic>>('messages');
  if (storedMessages != null && storedMessages.isNotEmpty) {
    messages.assignAll(storedMessages.cast<Map<String, dynamic>>());
  } else {
    messages.assignAll([
      {'text': 'مرحبا بك كيف يمكنني مساعدتك؟', 'isQuestion': false, 'isDev': false},
      {
        'text': 'يمكنك طرح الأسئلة التالية للحصول على إجابات سريعة:',
        'isQuestion': false, 'isDev': false
      },
      {'text': '1-إذا كنت بحاجة إلى أي مساعدة، فقط أخبرني', 'isQuestion': false,'isDev': true},
      {'text': '2-كيف كانت تجربتك اليوم؟', 'isQuestion': false, 'isDev': true},
      {'text': '3-هل لديك أي اقتراحات للتحسين؟', 'isQuestion': false, 'isDev': true},
    ]);
  }

     WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 50),
        curve: Curves.easeOut,
      );
    });
  }

  void saveMessages() {
    box.write('messages', messages.toList());
  }

  Future<void> sendMessage() async {
    if (textController.text.isNotEmpty) {
      final userMessage = textController.text;
      messages.add({'text': userMessage, 'isQuestion': true, 'isDev': false});
      textController.clear();
      saveMessages();

      isTyping.value = true;

      try {
        final response = await http.post(
          Uri.parse(
              'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=AIzaSyDf_OOy--5cyWKF64lEicOLoOz8br6kx-c'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {'text': userMessage}
                ]
              }
            ],
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final candidates = data['candidates'];
          if (candidates is List && candidates.isNotEmpty) {
            final firstCandidate = candidates[0];
            if (firstCandidate is Map && firstCandidate.containsKey('content')) {
              final content = firstCandidate['content'];
              if (content is Map && content.containsKey('parts')) {
                final parts = content['parts'];
                if (parts is List && parts.isNotEmpty) {
                  final firstPart = parts[0];
                  if (firstPart is Map && firstPart.containsKey('text')) {
                    final answer = firstPart['text'];

                    isTyping.value = false;
                    // Simulate slow writing
                    var tempMessage = {'text': '', 'isQuestion': false, 'isDev': false};
                    messages.add(tempMessage);
                    for (int i = 0; i < answer.length; i++) {
                      await Future.delayed(const Duration(milliseconds: 50));
                      tempMessage['text'] = answer.substring(0, i + 1);
                      messages.refresh();
                      scrollController.animateTo(
                        scrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 50),
                        curve: Curves.easeOut,
                      );
                    }
                    saveMessages();
                    return;
                  }
                }
              }
            }
          }
          messages.add(
              {'text': 'Error: Invalid response structure', 'isQuestion': false, 'isDev': false});
        } else {
          messages.add(
              {'text': 'Error: ${response.reasonPhrase}', 'isQuestion': false, 'isDev': false});
        }
      } catch (e) {
        messages.add(
            {'text': 'Error: ${e.toString()}', 'isQuestion': false, 'isDev': false});
      }

      isTyping.value = false;
      saveMessages();
    }
  }
}

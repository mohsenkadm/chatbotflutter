 import 'package:chatbotflutter/view_model/ChatController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart'; // For typing animation

void main() async {
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ذكاء الاصطناعي',
      theme: ThemeData(
        brightness: Brightness.dark, // Enable dark mode
        primarySwatch: Colors.blue,
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl, // Set RTL direction
        child: ChatScreen(),
      ),
    );
  }
}

class ChatScreen extends StatelessWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ChatController chatController = Get.put(ChatController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('ذكاء الاصطناعي'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () {
              chatController.messages.clear();
              chatController.textController.clear();
              chatController.saveMessages();
              chatController.loadMessages();
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Obx(() {
              return ListView.builder(
                controller: chatController.scrollController,
                itemCount: chatController.messages.length,
                itemBuilder: (context, index) {
                  final message = chatController.messages[index];
                  final isQuestion = message['isQuestion'] as bool;
                  final isDev = message['isDev'] as bool;
                  return Align(
                    alignment: isQuestion
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(15.0), // More padding
                      margin: isQuestion
                          ? const EdgeInsets.fromLTRB(
                              80.0, 8.0, 12.0, 8.0) // Margin from right
                          : const EdgeInsets.fromLTRB(
                              12.0, 8.0, 80.0, 8.0), // Margin from left
                      decoration: BoxDecoration(
                        border: isDev ? Border.all(color: Colors.blue, width: 1.0) : null,
                        color: isQuestion
                            ? Colors.blue[700]
                            : Colors.grey[700], // Adjust colors for dark mode
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(15.0),
                          topRight: const Radius.circular(15.0),
                          bottomLeft: isQuestion
                              ? const Radius.circular(15.0)
                              : const Radius.circular(0.0),
                          bottomRight: isQuestion
                              ? const Radius.circular(0.0)
                              : const Radius.circular(15.0),
                        ),
                      ),
                      child: Text(
                        message['text'] as String,
                        style: const TextStyle(
                            fontSize: 16.0, color: Colors.white),
                        textAlign: TextAlign.right, // Align text to the right
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          Obx(() {
            return chatController.isTyping.value
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const SpinKitThreeBounce(
                          color: Colors.blue,
                          size: 20.0,
                        ),
                        const SizedBox(width: 8.0),
                        const Text('...يكتب',
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  )
                : Container();
          }),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[800], // Adjust color for dark mode
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: chatController.textController,
                            maxLines: null, // Allow multiple lines
                            decoration: const InputDecoration(
                              hintText: 'اكتب رسالتك هنا...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                  vertical: 10.0), // More padding
                              hintStyle: TextStyle(
                                  color: Colors.white54), // Hint text color for dark mode
                            ),
                            style: const TextStyle(
                                color: Colors.white), // Input text color for dark mode
                            textAlign: TextAlign.right, // Align text to the right
                            onSubmitted: (value) {
                              chatController.sendMessage();
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send, color: Colors.blue),
                          onPressed: chatController.sendMessage,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:handy_allinone/util/app_constants.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';


class ChatScreentaxi extends StatefulWidget {
  final String bookingId;
  final String driverId;
  final String userid;

  const ChatScreentaxi({
    Key? key,
    required this.bookingId,
    required this.driverId,
    required this.userid,
  }) : super(key: key);

  @override
  State<ChatScreentaxi> createState() => _ChatScreenTaxiState();
}

class _ChatScreenTaxiState extends State<ChatScreentaxi> {
  late final DatabaseReference _chatRef;
  final List<Message> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  late final String currentUserId; // this is the user
  late final String driverId;

  @override
  void initState() {
    super.initState();

    currentUserId = widget.userid.trim();
    driverId = widget.driverId.trim();

    _chatRef = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:  AppConstants.firebaseDBURL,
    ).ref().child('chats').child(widget.bookingId);

    _listenToMessages();
  }

  void _listenToMessages() {
    _chatRef.onChildAdded.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data == null ||
          data['message'] == null ||
          data['sendBy'] == null ||
          data['timestamp'] == null) return;

      final message = Message(
        id: event.snapshot.key!,
        message: data['message'],
        createdAt: DateTime.fromMillisecondsSinceEpoch(data['timestamp']),
        sentBy: data['sendBy'],
      );

      setState(() {
        _messages.add(message);
      });

      _scrollToBottom();
    });
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final timestamp = DateTime.now().millisecondsSinceEpoch;

    await _chatRef.push().set({
      'message': text.trim(),
      'sendBy': currentUserId,
      'timestamp': timestamp,
    });

    _messageController.clear();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final isToday = now.day == timestamp.day &&
        now.month == timestamp.month &&
        now.year == timestamp.year;

    final timeString =
        "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}";

    return isToday
        ? timeString
        : "${timestamp.day}/${timestamp.month}/${timestamp.year} $timeString";
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.lerp(Colors.white, Theme.of(context).primaryColor, 0.05),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).cardColor),
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          "Chat with Driver",
          style: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeOverLarge,
            color: Theme.of(context).cardColor,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isSender = message.sentBy == currentUserId;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    mainAxisAlignment:
                    isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSender
                              ? Colors.blue[100]
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Text(
                                  message.message,
                                  style: const TextStyle(fontSize: 16),
                                ),   const SizedBox(height: 4),
                                Text(
                                  _formatTimestamp(message.createdAt),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),

                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  if (_messageController.text.trim().isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.blue),
                      onPressed: () {
                        _sendMessage(_messageController.text);
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Message {
  final String id;
  final String message;
  final String sentBy;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.message,
    required this.sentBy,
    required this.createdAt,
  });
}

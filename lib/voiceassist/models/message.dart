// lib/voiceassist/models/message.dart

import 'package:isar/isar.dart';

part 'message.g.dart';

@Collection()
class Message {
  Id id = Isar.autoIncrement; // Unique identifier

  late String text;

  late bool isUser;

  late DateTime timestamp; // To track when the message was sent

  // Updated Constructor: All parameters are required and non-nullable
  Message({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}


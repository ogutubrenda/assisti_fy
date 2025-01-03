// lib/voiceassist/voice_page.dart
import 'dart:async';
import 'package:assisti_fy/notes/components/drawer.dart';
import 'package:assisti_fy/voiceassist/database/message_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:provider/provider.dart';

class VoicePage extends StatefulWidget {
  const VoicePage({super.key});

  @override
  State<VoicePage> createState() => _VoicePageState();
}

class _VoicePageState extends State<VoicePage> {
  final SpeechToText speechToText = SpeechToText();
  bool speechEnabled = false;
  String lastWords = '';
  bool isLoading = false;
  Timer? _debounceTimer;

  // Access the MessageDatabase via Provider
  late MessageDatabase messageDatabase;

  @override
  void initState() {
    super.initState();
    // Initialize MessageDatabase after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      messageDatabase = Provider.of<MessageDatabase>(context, listen: false);
      initSpeechToText();
      loadMessages(); // Load stored messages on startup
      _listenToApiResponses();
    });
  }

  /// Initializes the SpeechToText instance.
  Future<void> initSpeechToText() async {
    bool available = await speechToText.initialize(
      onStatus: (status) => debugPrint('Speech Status: $status'),
      onError: (errorNotification) =>
          debugPrint('Speech Error: ${errorNotification.errorMsg}'),
    );
    setState(() {
      speechEnabled = available;
    });
    if (!available) {
      debugPrint('Speech recognition not available.');
      _showDialog(
        title: 'Microphone Permission',
        content: 'Please enable microphone access in your device settings.',
      );
    } else {
      debugPrint('Speech recognition initialized successfully.');
      // Initialize conversation with a greeting message if messages are empty
      if (messageDatabase.currentMessages.isEmpty) {
        addMessage("Hello, what would you like me to do today?", false);
      }
    }
  }

  /// Starts listening to the user's speech.
  Future<void> startListening() async {
    await speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
    debugPrint('Started Listening');
  }

  /// Stops listening to the user's speech.
  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
    debugPrint('Stopped Listening');
  }

  /// Handles the speech recognition result.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
      debugPrint("Recognized Words: $lastWords");
    });

    if (result.finalResult && lastWords.isNotEmpty) {
      // Debounce to prevent multiple triggers within a short timeframe
      if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
      _debounceTimer = Timer(Duration(milliseconds: 500), () {
        addMessage(lastWords, true);
      });
    }
  }

  /// Adds a message to the conversation using MessageDatabase.
  Future<void> addMessage(String text, bool isUser) async {
    await messageDatabase.addMessage(text, isUser);
    _scrollToBottom(); // Scroll to the latest message
  }

  /// Loads stored messages from Isar.
  Future<void> loadMessages() async {
    await messageDatabase.fetchMessages();
    setState(() {}); // Trigger rebuild to display messages
    _scrollToBottom(); // Scroll to the latest message
  }

  /// Displays a dialog with a title and content.
  void _showDialog({required String title, required String content}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// Listens to API responses and handles loading indicators
  void _listenToApiResponses() {
    messageDatabase.apiResponseStream.listen((intentResponse) {
      if (intentResponse.tag == 'error') {
        addMessage("Sorry, something went wrong.", false);
        return;
      }
      // Handle other responses if needed
      // For now, all handling is done within MessageDatabase
    });
  }

  // ScrollController to manage scrolling in ListView
  final ScrollController _scrollController = ScrollController();

  /// Scrolls to the bottom of the ListView
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    speechToText.stop();
    _scrollController.dispose(); // Dispose the controller
    _debounceTimer?.cancel(); //cancel timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MyDrawer(),
      appBar: AppBar(
        title: const Text('Assistify'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 30),
            // Virtual Assistant Image
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 120,
                  width: 120,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: const BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  height: 123,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage(
                        'assets/images/virtual.png',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            // Conversation Display using Consumer<MessageDatabase>
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Consumer<MessageDatabase>(
                builder: (context, messageDb, child) {
                  return ListView.builder(
                    controller: _scrollController, // Attach the ScrollController
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: messageDb.currentMessages.length,
                    itemBuilder: (context, index) {
                      final message = messageDb.currentMessages[index];
                      return Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: 5.0),
                        child: ChatBubble(
                          clipper: message.isUser
                              ? ChatBubbleClipper1(
                                  type: BubbleType.sendBubble)
                              : ChatBubbleClipper1(
                                  type: BubbleType.receiverBubble),
                          alignment: message.isUser
                              ? Alignment.topRight
                              : Alignment.topLeft,
                          margin: EdgeInsets.only(top: 10),
                          backGroundColor: message.isUser
                              ? Colors.blueAccent
                              : Colors.grey[200],
                          child: Container(
                            constraints: BoxConstraints(maxWidth: 250),
                            child: Text(
                              message.text,
                              style: TextStyle(
                                color: message.isUser
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            // Microphone Status and Loading Indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: speechToText.isListening
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 10),
                        Text(
                          'Listening... 🎤',
                          style: TextStyle(
                              fontSize: 16, color: Colors.grey[700]),
                        ),
                      ],
                    )
                  : Text(
                      'Tap the microphone to start listening',
                      style: TextStyle(
                          fontSize: 16, color: Colors.grey[700]),
                      textAlign: TextAlign.center,
                    ),
            ),
            SizedBox(height: 10),
            // Processing Indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: isLoading
                  ? Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 10),
                        Text(
                          'Processing...',
                          style: TextStyle(
                              fontSize: 16, color: Colors.grey[700]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )
                  : Container(),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (!speechEnabled) {
            debugPrint('Speech recognition not enabled.');
            _showDialog(
              title: 'Microphone Permission',
              content:
                  'Please enable microphone access in your device settings.',
            );
            return;
          }

          if (!speechToText.isListening) {
            await startListening();
          } else {
            await stopListening();
            // The API call is now handled within MessageDatabase
          }
        },
        backgroundColor:
            speechToText.isListening ? Colors.red : Colors.blue,
        child: Icon(
            speechToText.isListening ? Icons.mic_off : Icons.mic),
      ),
    );
  }
}

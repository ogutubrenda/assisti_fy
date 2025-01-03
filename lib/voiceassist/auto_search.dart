// import 'package:assisti_fy/voiceassist/controller.dart';
// import 'package:flutter/material.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:url_launcher/url_launcher.dart';



// class VoiceAssistantWidget extends StatefulWidget {
//   final VoiceAssistantController controller;
//   VoiceAssistantWidget({required this.controller});

//   @override
//   _VoiceAssistantWidgetState createState() => _VoiceAssistantWidgetState();
// }

// class _VoiceAssistantWidgetState extends State<VoiceAssistantWidget> {
//   final stt.SpeechToText _speech = stt.SpeechToText();
//   bool _isListening = false;
//   String _lastWords = '';

//   @override
//   void initState() {
//     super.initState();
//     _startListening();
//   }

//   void _startListening() async {
//     _speech.listen(onResult: (result) {
//       setState(() {
//         _lastWords = result.recognizedWords;
//       });

//       if (_lastWords.toLowerCase().contains("hey assistify")) {
//         setState(() {
//           _isListening = true;
//         });
//         _speech.stop(); // Stop listening for the wake word
//         _waitForCommand(); // Start listening for the next command
//       }
//     });
//   }

//   void _waitForCommand() {
//     _speech.listen(onResult: (result) {
//       setState(() {
//         _lastWords = result.recognizedWords;
//       });

//       // Pass the command to the controller to handle actions
//       widget.controller.handleCommand(_lastWords);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return _isListening
//         ? Center(
//             child: Container(
//               color: Colors.green,
//               padding: const EdgeInsets.all(20),
//               child: const Icon(
//                 Icons.mic,
//                 size: 50,
//                 color: Colors.white,
//               ),
//             ),
//           )
//         : Container();
//   }
// }

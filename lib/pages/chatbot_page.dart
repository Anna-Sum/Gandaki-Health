// import 'package:flutter/material.dart';
// import '../services/dialogflow_service.dart';

// class ChatbotPage extends StatefulWidget {
//   const ChatbotPage({super.key}); // Using super parameter

//   @override
//   ChatbotPageState createState() => ChatbotPageState(); // Made public
// }

// class ChatbotPageState extends State<ChatbotPage> {
//   // Made public
//   final TextEditingController _controller = TextEditingController();
//   final ChatService _chatService = ChatService();
//   final List<String> _messages = [];

//   void _sendMessage() async {
//     final userMessage = _controller.text.trim();
//     if (userMessage.isNotEmpty) {
//       setState(() {
//         _messages.add("You: $userMessage");
//       });
//       _controller.clear();

//       final botReply = await _chatService.sendMessage(userMessage);
//       setState(() {
//         _messages.add("Bot: $botReply");
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Chatbot')),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: _messages.length,
//               itemBuilder: (context, index) {
//                 return ListTile(title: Text(_messages[index]));
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _controller,
//                     decoration: const InputDecoration(
//                       hintText: "Type a message...",
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.send),
//                   onPressed: _sendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

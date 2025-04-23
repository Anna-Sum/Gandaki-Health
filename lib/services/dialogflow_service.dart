// import 'dart:convert';
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:dialogflow_grpc/generated/google/cloud/dialogflow/v2beta1/session.pb.dart';
// import 'package:dialogflow_grpc/dialogflow_auth.dart';

// final serviceAccount = ServiceAccount.fromString(
//     '${(await rootBundle.loadString('assets/keys/agent_key.json'))}');

// DialogflowGrpc dialogflow = DialogflowGrpc.viaServiceAccount(serviceAccount);import 'package:googleapis_auth/auth_io.dart';

// class ChatService {
//   final String projectId = 'healthassistant-qrxp';
//   final String sessionId = 
//       'flutter_user_001'; // Session ID to track user interaction

//   // This function will send the user's message to Dialogflow API
//   Future<String> sendMessage(String message) async {
//     // Load service account credentials
//     final credentialsJson =
//         await rootBundle.loadString('assets/keys/agent_key.json');
//     final credentials = ServiceAccountCredentials.fromJson(credentialsJson);

//     final scopes = ['https://www.googleapis.com/auth/cloud-platform'];
//     final client = await clientViaServiceAccount(credentials, scopes);

//     final url = Uri.parse(
//         'https://dialogflow.googleapis.com/v2/projects/$projectId/agent/sessions/$sessionId:detectIntent');

//     // Request body for Dialogflow API
//     final body = jsonEncode({
//       "queryInput": {
//         "text": {"text": message, "languageCode": "en"}
//       }
//     });

//     final response = await client.post(
//       url,
//       headers: {'Content-Type': 'application/json'},
//       body: body,
//     );

//     client.close();

//     if (response.statusCode == 200) {
//       final jsonResponse = json.decode(response.body);
//       final botReply = jsonResponse['queryResult']['fulfillmentText'] ??
//           "Sorry, I didn’t understand.";
//       return botReply;
//     } else {
//       return "Error: Unable to process your request.";
//     }
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../constants/firebase_constant.dart';
import '../customs/app_bar_custom.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(
      debugShowCheckedModeBanner: false, home: MyWebListPage()));
}

class WebsiteFields {
  static const String title = 'title';
  static const String link = 'link';
  static const String isActive = 'isActive';
}

class MyWebListPage extends StatefulWidget {
  static const routeName = '/MyWebListPage';
  const MyWebListPage({super.key});

  @override
  State<MyWebListPage> createState() => _MyWebListPageState();
}

class _MyWebListPageState extends State<MyWebListPage> {
  final CollectionReference websites =
      FirebaseFirestore.instance.collection(FirebaseCollection.websites);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Important Weblinks'),
      body: StreamBuilder<QuerySnapshot>(
        stream: websites
            .where(WebsiteFields.isActive, isEqualTo: true)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.docs;
          if (data.isEmpty) {
            return const Center(child: Text('No active websites found.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final doc = data[index];
              final title = doc[WebsiteFields.title];
              final link = doc[WebsiteFields.link];

              return Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                child: ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  tileColor: Colors.grey.shade100,
                  title: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.teal,
                    ),
                  ),
                  subtitle: Text(
                    link,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  trailing: const Icon(Icons.open_in_new, color: Colors.teal),
                  onTap: () {
                    final uri = Uri.tryParse(link);
                    if (uri == null || !uri.isAbsolute) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invalid link format')),
                      );
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MyWebViewPage(link: link, title: title),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class MyWebViewPage extends StatefulWidget {
  static const routeName = '/MyWebViewPage';
  const MyWebViewPage({super.key, required this.link, required this.title});

  final String link;
  final String title;

  @override
  State<MyWebViewPage> createState() => _MyWebViewPageState();
}

class _MyWebViewPageState extends State<MyWebViewPage> {
  late WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => isLoading = true),
          onPageFinished: (_) => setState(() => isLoading = false),
          onWebResourceError: (error) {
            setState(() => isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to load: ${error.description}')),
            );
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.link));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: widget.title),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
              ),
            ),
        ],
      ),
    );
  }
}

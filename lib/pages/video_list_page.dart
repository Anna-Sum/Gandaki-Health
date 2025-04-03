import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:health_portal/customs/app_bar_custom.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../constants/constant.dart';
import '../route_manager/route_manager.dart';

class VideoModel {
  final String url;
  final String title;
  final String description;

  VideoModel({
    required this.url,
    required this.title,
    required this.description,
  });

  factory VideoModel.fromFirestore(Map<String, dynamic> data) {
    return VideoModel(
      url: data['url'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
    );
  }
}

class MyVideosListPage extends StatefulWidget {
  static const routeName = RouteNames.videosListPage;
  const MyVideosListPage({super.key});

  @override
  State<MyVideosListPage> createState() => _MyVideosListPageState();
}

class _MyVideosListPageState extends State<MyVideosListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<VideoModel> videos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVideos();
  }

  Future<void> _fetchVideos() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('videos').get();
      setState(() {
        videos = snapshot.docs
            .map((doc) =>
                VideoModel.fromFirestore(doc.data() as Map<String, dynamic>))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching videos: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.teal,
                ),
              )
            : videos.isEmpty
                ? const Center(
                    child: Text(
                      'No videos available',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: videos.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor: MyAppColors.primaryColor,
                              child: const Icon(
                                Icons.play_circle_filled,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              videos[index].title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                videos[index].description,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.teal,
                            ),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                MyYoutubeWebPage.routeName,
                                arguments: videos[index].url,
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

class MyYoutubeWebPage extends StatefulWidget {
  static const routeName = '/MyYoutubeWebPage';
  final String url;

  const MyYoutubeWebPage({super.key, required this.url});

  @override
  State<MyYoutubeWebPage> createState() => _MyYoutubeWebPageState();
}

class _MyYoutubeWebPageState extends State<MyYoutubeWebPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (url) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  void _handleReload() {
    _controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Watch Video',
        showReload: true,
        onReload: _handleReload,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: Colors.teal,
              ),
            ),
        ],
      ),
    );
  }
}

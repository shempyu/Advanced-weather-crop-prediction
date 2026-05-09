import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';

class NewsBottomSheet extends StatefulWidget {
  final String cropName;
  const NewsBottomSheet({Key? key, required this.cropName}) : super(key: key);

  @override
  State<NewsBottomSheet> createState() => _NewsBottomSheetState();
}

class _NewsBottomSheetState extends State<NewsBottomSheet> {
  bool isLoading = true;
  Map<String, dynamic>? newsData;

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    final response = await ApiService.fetchCropNews(widget.cropName.toLowerCase());
    if (mounted) {
      setState(() {
        newsData = response;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(40.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (newsData == null || newsData!['results'] == null) {
      return const Padding(
        padding: EdgeInsets.all(40.0),
        child: Center(child: Text("Failed to load news or no connection.", style: TextStyle(color: Colors.white))),
      );
    }

    final results = newsData!['results'];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("News for ${widget.cropName.toUpperCase()}",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
            const SizedBox(height: 10),
            if (results['headline1'] != null && results['link1'] != null) ...[
              _sourceLink(results['headline1'], results['link1']),
              const Divider(color: Colors.white10),
            ],
            if (results['headline2'] != null && results['link2'] != null) ...[
              _sourceLink(results['headline2'], results['link2']),
              const Divider(color: Colors.white10),
            ],
            if (results['headline3'] != null && results['link3'] != null) ...[
              _sourceLink(results['headline3'], results['link3']),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sourceLink(String title, String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(title, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 15)),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final uri = Uri.parse(url);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                  child: Text(
                    url, 
                    style: const TextStyle(color: Colors.blueAccent, fontSize: 13, decoration: TextDecoration.underline),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 18, color: Colors.white70),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: url));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Link copied to clipboard!'), duration: Duration(seconds: 2))
                  );
                },
              )
            ],
          ),
        ],
      ),
    );
  }
}

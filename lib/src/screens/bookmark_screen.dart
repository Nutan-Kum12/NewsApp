import 'package:flutter/material.dart';
import 'package:news/src/screens/article_detail_screeen.dart';
import 'package:provider/provider.dart';

import '../models/article.dart';
import '../providers/bookmark_provider.dart';
import '../widgets/news/news_card.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({Key? key}) : super(key: key);

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh bookmarks when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookmarkProvider>(context, listen: false).fetchBookmarks();
    });
  }

  void _openArticle(Article article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleDetailScreen(article: article),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<BookmarkProvider>(context, listen: false).fetchBookmarks();
            },
          ),
        ],
      ),
      body: Consumer<BookmarkProvider>(
        builder: (context, bookmarkProvider, child) {
          if (bookmarkProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (bookmarkProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${bookmarkProvider.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      bookmarkProvider.fetchBookmarks();
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          if (bookmarkProvider.bookmarks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.bookmark_border,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No bookmarks yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Save articles to read later',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: bookmarkProvider.bookmarks.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final article = bookmarkProvider.bookmarks[index];
              return NewsCard(
                article: article,
                onTap: () => _openArticle(article),
              );
            },
          );
        },
      ),
    );
  }
}


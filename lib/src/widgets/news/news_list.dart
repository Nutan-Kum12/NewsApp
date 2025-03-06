import 'package:flutter/material.dart';
import 'package:news/src/screens/article_detail_screeen.dart';
import 'package:provider/provider.dart';

import '../../models/article.dart';
import '../../providers/news_provider.dart';
import 'news_card.dart';

class NewsList extends StatefulWidget {
  const NewsList({Key? key}) : super(key: key);

  @override
  State<NewsList> createState() => _NewsListState();
}

class _NewsListState extends State<NewsList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      Provider.of<NewsProvider>(context, listen: false).loadMore();
    }
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
    final newsProvider = Provider.of<NewsProvider>(context);
    final articles = newsProvider.articles;

    return RefreshIndicator(
      onRefresh: () async {
        await newsProvider.fetchTopHeadlines(
          category: newsProvider.currentCategory,
          refresh: true,
        );
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount: articles.length + (newsProvider.hasMorePages ? 1 : 0),
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          if (index == articles.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final article = articles[index];
          return NewsCard(
            article: article,
            onTap: () => _openArticle(article),
          );
        },
      ),
    );
  }
}


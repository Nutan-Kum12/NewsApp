import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/news_provider.dart';

class NewsSearchBar extends StatefulWidget {
  const NewsSearchBar({Key? key}) : super(key: key);

  @override
  State<NewsSearchBar> createState() => _NewsSearchBarState();
}

class _NewsSearchBarState extends State<NewsSearchBar> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
    });
    Provider.of<NewsProvider>(context, listen: false)
        .fetchTopHeadlines(refresh: true);
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      Provider.of<NewsProvider>(context, listen: false)
          .searchNews(query, refresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _stopSearch,
            ),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search news...',
                prefixIcon: _isSearching ? null : const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onTap: _startSearch,
              onSubmitted: (_) => _performSearch(),
              textInputAction: TextInputAction.search,
            ),
          ),
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: _performSearch,
            ),
        ],
      ),
    );
  }
}


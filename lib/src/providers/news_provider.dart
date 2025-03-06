import 'package:flutter/foundation.dart';
import 'package:news/src/services/news_services.dart';

import '../models/article.dart';

class NewsProvider with ChangeNotifier {
  final NewsService _newsService;
  
  List<Article> _articles = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMorePages = true;
  String _currentCategory = '';
  String _searchQuery = '';
  
  NewsProvider(this._newsService) {
    fetchTopHeadlines();
  }
  
  // Getters
  List<Article> get articles => _articles;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMorePages => _hasMorePages;
  String get currentCategory => _currentCategory;
  
  // Fetch top headlines
  Future<void> fetchTopHeadlines({
    String category = '',
    bool refresh = false,
  }) async {
    try {
      if (refresh) {
        _currentPage = 1;
        _hasMorePages = true;
        _articles = [];
      }
      
      if (!_hasMorePages) return;
      
      _isLoading = true;
      _error = null;
      _currentCategory = category;
      _searchQuery = '';
      notifyListeners();
      
      final newArticles = await _newsService.getTopHeadlines(
        page: _currentPage,
        category: category.isNotEmpty ? category : null,
      );
      
      if (newArticles.isEmpty) {
        _hasMorePages = false;
      } else {
        if (refresh || _currentPage == 1) {
          _articles = newArticles;
        } else {
          _articles.addAll(newArticles);
        }
        _currentPage++;
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // Search news
  Future<void> searchNews(String query, {bool refresh = false}) async {
    try {
      if (query.isEmpty) {
        fetchTopHeadlines(refresh: true);
        return;
      }
      
      if (refresh) {
        _currentPage = 1;
        _hasMorePages = true;
        _articles = [];
      }
      
      if (!_hasMorePages) return;
      
      _isLoading = true;
      _error = null;
      _searchQuery = query;
      _currentCategory = '';
      notifyListeners();
      
      final newArticles = await _newsService.searchNews(
        query,
        page: _currentPage,
      );
      
      if (newArticles.isEmpty) {
        _hasMorePages = false;
      } else {
        if (refresh || _currentPage == 1) {
          _articles = newArticles;
        } else {
          _articles.addAll(newArticles);
        }
        _currentPage++;
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // Load more articles
  Future<void> loadMore() async {
    if (_isLoading || !_hasMorePages) return;
    
    if (_searchQuery.isNotEmpty) {
      await searchNews(_searchQuery);
    } else {
      await fetchTopHeadlines(category: _currentCategory);
    }
  }
  
  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}


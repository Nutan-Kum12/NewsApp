import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/article.dart';

class NewsService {
  final String _baseUrl = 'https://newsapi.org/v2';
  final String _apiKey = dotenv.env['NEWS_API_KEY'] ?? '';
  
  // Fetch top headlines
  Future<List<Article>> getTopHeadlines({
    String country = 'us',
    int page = 1,
    int pageSize = 20,
    String? category,
    String? query,
  }) async {
    try {
      // Build URL with parameters
      String url = '$_baseUrl/top-headlines?country=$country&page=$page&pageSize=$pageSize';
      
      if (category != null && category.isNotEmpty) {
        url += '&category=$category';
      }
      
      if (query != null && query.isNotEmpty) {
        url += '&q=$query';
      }
      
      // Add API key
      url += '&apiKey=$_apiKey';
      
      // Make HTTP request
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> articles = data['articles'];
        
        _saveToCache(articles, category, query);
        
        return articles.map((article) => Article.fromJson(article)).toList();
      } else {
        return await _getFromCache(category, query);
      }
    } catch (e) {
      return await _getFromCache(category, query);
    }
  }
  
  Future<List<Article>> searchNews(String query, {int page = 1, int pageSize = 20}) async {
    try {
      final url = '$_baseUrl/everything?q=$query&page=$page&pageSize=$pageSize&apiKey=$_apiKey';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> articles = data['articles'];
        
        _saveToCache(articles, null, query);
        
        return articles.map((article) => Article.fromJson(article)).toList();
      } else {
        return await _getFromCache(null, query);
      }
    } catch (e) {
      return await _getFromCache(null, query);
    }
  }
  
  Future<void> _saveToCache(List<dynamic> articles, String? category, String? query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getCacheKey(category, query);
      
      await prefs.setString(key, json.encode({
        'timestamp': DateTime.now().toIso8601String(),
        'articles': articles,
      }));
    } catch (e) {
      print('Cache save error: $e');
    }
  }
  
  Future<List<Article>> _getFromCache(String? category, String? query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getCacheKey(category, query);
      
      final String? cachedData = prefs.getString(key);
      
      if (cachedData != null) {
        final Map<String, dynamic> data = json.decode(cachedData);
        final List<dynamic> articles = data['articles'];
        
        return articles.map((article) => Article.fromJson(article)).toList();
      }
    } catch (e) {
      print('Cache read error: $e');
    }
    
    return [];
  }

  String _getCacheKey(String? category, String? query) {
    if (category != null && query != null) {
      return 'news_${category}_$query';
    } else if (category != null) {
      return 'news_$category';
    } else if (query != null) {
      return 'news_search_$query';
    } else {
      return 'news_headlines';
    }
  }
}


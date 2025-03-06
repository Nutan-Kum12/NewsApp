import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/article.dart';

class BookmarkProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<Article> _bookmarks = [];
  bool _isLoading = false;
  String? _error;
  
  List<Article> get bookmarks => _bookmarks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> initBookmarks() async {
    final user = _auth.currentUser;
    if (user == null) {
      _bookmarks = [];
      notifyListeners();
      return;
    }
    
    await fetchBookmarks();
  }
   String safeDocId(String id) {
    return id.replaceAll('/', '_');
  }
  
 Future<void> fetchBookmarks() async {
  try {
    final user = _auth.currentUser;
    if (user == null) {
      print("No user logged in!");
      return;
    }

    print("Fetching bookmarks for user: ${user.uid}");

    _isLoading = true;
    _error = null;
    notifyListeners();

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('bookmarks')
        .get();

    print("Fetched ${snapshot.docs.length} bookmarks");

    for (var doc in snapshot.docs) {
      print("Bookmark Data: ${doc.data()}"); 
    }

    _bookmarks = snapshot.docs.map((doc) {
      try {
        return Article.fromJson(doc.data()); 
      } catch (e) {
        print("Error parsing article: $e, Data: ${doc.data()}");
        return null;
      }
    }).whereType<Article>().toList();

    _isLoading = false;
    notifyListeners();
    print("Bookmarks updated successfully! ${_bookmarks.length} items in list");
  } catch (e) {
    _isLoading = false;
    _error = e.toString();
    notifyListeners();
    print("Error fetching bookmarks: $e");
  }
}

  Future<void> addBookmark(Article article) async {
  try {
    final user = _auth.currentUser;
    if (user == null) {
      print("User not logged in!");
      return;
    }

    print("Trying to add bookmark: ${article.id}");

    _isLoading = true;
    _error = null;
    notifyListeners();

    String docId = safeDocId(article.id);

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('bookmarks')
        .doc(docId)
        .set(article.toJson());

    print("Bookmark added to Firestore!");

    if (!_bookmarks.any((bookmark) => bookmark.id == article.id)) {
      _bookmarks.add(article);
      print("Bookmark added to local list!");
    }

  } catch (e) {
    _error = e.toString();
    print("Firestore error: $e");
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

Future<void> removeBookmark(String articleId) async {
  try {
    final user = _auth.currentUser;
    if (user == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    String docId = safeDocId(articleId);

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('bookmarks')
        .doc(docId)
        .delete();

    _bookmarks.removeWhere((bookmark) => bookmark.id == articleId);
    print("Bookmark removed from Firestore and local list!");

  } catch (e) {
    _error = e.toString();
    print("Firestore error: $e");
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

  bool isBookmarked(String articleId) {
    return _bookmarks.any((bookmark) => bookmark.id == articleId);
  }
  void clearError() {
    _error = null;
    notifyListeners();
  }
}


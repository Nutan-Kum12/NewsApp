import 'package:flutter/material.dart';
import 'package:news/src/screens/bookmark_screen.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/bookmark_provider.dart';
import '../providers/news_provider.dart';
import '../widgets/news/category_tabs.dart';
import '../widgets/news/news_list.dart';
import '../widgets/news/search_bar.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const NewsTab(),
    const BookmarksScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize bookmarks
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookmarkProvider>(context, listen: false).initBookmarks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper),
            label: 'News',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Bookmarks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class NewsTab extends StatelessWidget {
  const NewsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News Feed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<NewsProvider>(context, listen: false)
                  .fetchTopHeadlines(refresh: true);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const NewsSearchBar(),
          const CategoryTabs(),
          Expanded(
            child: Consumer<NewsProvider>(
              builder: (context, newsProvider, child) {
                if (newsProvider.error != null) {
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
                          'Error: ${newsProvider.error}',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            newsProvider.fetchTopHeadlines(refresh: true);
                          },
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                }

                if (newsProvider.articles.isEmpty && newsProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (newsProvider.articles.isEmpty) {
                  return const Center(
                    child: Text('No articles found'),
                  );
                }

                return const NewsList();
              },
            ),
          ),
        ],
      ),
    );
  }
}


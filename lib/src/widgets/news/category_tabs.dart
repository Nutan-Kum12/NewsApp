import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/news_provider.dart';

class CategoryTabs extends StatefulWidget {
  const CategoryTabs({Key? key}) : super(key: key);

  @override
  State<CategoryTabs> createState() => _CategoryTabsState();
}

class _CategoryTabsState extends State<CategoryTabs> {
  final List<String> _categories = [
    '',
    'business',
    'entertainment',
    'general',
    'health',
    'science',
    'sports',
    'technology',
  ];

  final List<String> _categoryLabels = [
    'All',
    'Business',
    'Entertainment',
    'General',
    'Health',
    'Science',
    'Sports',
    'Technology',
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(_categoryLabels[index]),
              selected: _selectedIndex == index,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedIndex = index;
                  });
                  Provider.of<NewsProvider>(context, listen: false)
                      .fetchTopHeadlines(
                    category: _categories[index],
                    refresh: true,
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}


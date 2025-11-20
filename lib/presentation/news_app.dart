import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/news_cubit.dart';
import '../bloc/news_state.dart';
import '../data/models/article_model.dart';
import '../data/repository/news_repository.dart';

void main() {
  runApp(const NewsApp());
}

class NewsApp extends StatelessWidget {
  const NewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News App (Part 2)',
      theme: ThemeData(
        primaryColor: const Color(0xFF192A56),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF192A56)),
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue).copyWith(secondary: const Color(0xFF3B82F6)),
        useMaterial3: true,
      ),
      home: RepositoryProvider(
        create: (context) => NewsRepository(),
        child: BlocProvider(
          create: (context) => NewsCubit(context.read<NewsRepository>())..loadNews(),
          child: const NewsHomePage(),
        ),
      ),
    );
  }
}

class NewsHomePage extends StatefulWidget {
  const NewsHomePage({super.key});

  @override
  State<NewsHomePage> createState() => _NewsHomePageState();
}

class _NewsHomePageState extends State<NewsHomePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      context.read<NewsCubit>().setSearchQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => FilterModal(
        onApply: (category) {
          context.read<NewsCubit>().applyCategoryFilter(category);
          Navigator.pop(ctx);
        },
        currentCategory: context.read<NewsCubit>().state.selectedCategory,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: BlocConsumer<NewsCubit, NewsState>(
        listener: (context, state) {
          // Show a snackbar for error messages
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: state.status == NewsStatus.error ? Colors.red : Colors.orange,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          final articles = state.articles;
          final isLoading = state.status == NewsStatus.loading;

          return Column(
            children: [
              Container(
                color: Theme.of(context).primaryColor,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search',
                            border: InputBorder.none,
                            prefixIcon: const Icon(Icons.search, color: Colors.grey),
                            // Part 2: Add "remove" button
                            suffixIcon: state.searchQuery.isNotEmpty
                                ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                                context.read<NewsCubit>().clearSearch();
                              },
                            )
                                : null,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Part 2: Remote Search Button (on tap)
                    IconButton(
                      icon: Icon(Icons.search, color: Colors.white),
                      onPressed: isLoading
                          ? null
                          : () => context.read<NewsCubit>().searchRemote(),
                    ),
                    // Part 2: Filter Button
                    IconButton(
                      icon: const Icon(Icons.filter_list, color: Colors.white),
                      onPressed: isLoading ? null : () => _showFilterModal(context),
                    ),
                  ],
                ),
              ),

              if (isLoading && articles.isEmpty)
                const LinearProgressIndicator(),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<NewsCubit>().loadNews(isRefresh: true);
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  child: Builder(
                    builder: (context) {
                      if (articles.isEmpty) {
                        return Center(
                          child: Text(
                            // Part 2: "No Results Found" message
                              state.searchQuery.isNotEmpty ? 'No Results Found for "${state.searchQuery}"' : 'No articles available.',
                              style: const TextStyle(fontSize: 18, color: Colors.grey)
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: articles.length,
                        itemBuilder: (context, index) {
                          final article = articles[index];
                          return NewsCard(
                            article: article,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailsScreen(article: article),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class NewsCard extends StatelessWidget {
  final ArticleModel article;
  final VoidCallback onTap;

  const NewsCard({super.key, required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  article.urlToImage,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[200],
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${article.sourceName} | ${article.author}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Category: ${article.category}',
                      style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DetailsScreen extends StatelessWidget {
  final ArticleModel article;

  const DetailsScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(article.sourceName, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                article.urlToImage,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.grey[200],
                  alignment: Alignment.center,
                  child: const Text('Image Unavailable', style: TextStyle(color: Colors.grey)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              article.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // Author (Part 2 Requirement)
            Text(
              'Author: ${article.author}',
              style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey),
            ),
            // Source (Part 2 Requirement)
            Text(
              'Source: ${article.sourceName}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.blue),
            ),
            const Divider(height: 32),
            const Text('Description:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              article.description,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 16),
            const Text('Content Snippet:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              article.content,
              style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}

class FilterModal extends StatefulWidget {
  final Function(String) onApply;
  final String currentCategory;

  const FilterModal({super.key, required this.onApply, required this.currentCategory});

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  String _selectedCategory = '';
  // Part 2: Required Categories
  final List<String> categories = ['Business', 'Entertainment', 'General', 'Health'];

  @override
  void initState() {
    super.initState();
    // Use the current category from the Cubit state
    _selectedCategory = widget.currentCategory;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: Text(
              'Select Category',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 20),
          ...categories.map((category) {
            final isSelected = category.toLowerCase() == _selectedCategory.toLowerCase();
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    // Toggles selection
                    _selectedCategory = isSelected ? '' : category.toLowerCase();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
                  foregroundColor: isSelected ? Colors.white : Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: isSelected ? 4 : 0,
                ),
                child: Text(category, style: const TextStyle(fontSize: 16)),
              ),
            );
          }),
          const SizedBox(height: 20),
          // Part 2: Apply Button
          ElevatedButton(
            onPressed: () {
              widget.onApply(_selectedCategory);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 4,
            ),
            child: const Text('Apply', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

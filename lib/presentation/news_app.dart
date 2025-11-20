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
      title: 'News App (Part 1)',
      theme: ThemeData(
        primaryColor: const Color(0xFF192A56),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF192A56)),
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue).copyWith(secondary: const Color(0xFF3B82F6)),
        useMaterial3: true,
      ),
      // Initialize the Cubit and Repository
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

class NewsHomePage extends StatelessWidget {
  const NewsHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: BlocBuilder<NewsCubit, NewsState>(
        builder: (context, state) {

          if (state.status == NewsStatus.loading && state.articles.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == NewsStatus.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 40),
                    const SizedBox(height: 10),
                    Text(
                      'Error loading news. ${state.errorMessage}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 10),
                    // Button allows retrying the initial load
                    ElevatedButton(
                      onPressed: () => context.read<NewsCubit>().loadNews(),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Display the list with Pull to Refresh
          return RefreshIndicator(
            onRefresh: () => context.read<NewsCubit>().loadNews(),
            child: ListView.builder(
              itemCount: state.articles.length,
              itemBuilder: (context, index) {
                final article = state.articles[index];
                return NewsCard(article: article, onTap: () {
                  // Part 1: Navigation is disabled/placeholder
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Navigation to Details is a Part 2 feature.')),
                  );
                });
              },
            ),
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
              // Article Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  article.urlToImage,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[200],
                    child: const Icon(Icons.error, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Article Info
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
                    // Placeholder for category/description
                    Text(
                      article.description,
                      style: const TextStyle(color: Colors.black54, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
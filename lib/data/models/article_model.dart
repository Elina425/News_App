import 'dart:convert';
import 'package:http/http.dart' as http; // Required import for network calls
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ArticleModel {
  final String title;
  final String sourceName;
  final String author;
  final String description;
  final String urlToImage;
  final String content;
  final String category;

  ArticleModel({
    required this.title,
    required this.sourceName,
    required this.author,
    required this.description,
    required this.urlToImage,
    required this.content,
    required this.category,
  });

  // Factory constructor for simple JSON parsing (adapt for real API)
  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      title: json['title'] ?? 'No Title',
      sourceName: json['sourceName'] ?? 'Unknown Source',
      author: json['author'] ?? 'Unknown Author',
      description: json['description'] ?? 'No Description',
      urlToImage: json['urlToImage'] ?? '',
      content: json['content'] ?? 'No content available.',
      category: json['category'] ?? 'general',
    );
  }
}
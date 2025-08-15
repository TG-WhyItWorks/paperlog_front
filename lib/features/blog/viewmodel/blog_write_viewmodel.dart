import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../service/blog_service.dart';

class BlogWriteViewModel extends ChangeNotifier {
  final _svc = BlogService();
  bool submitting = false;
  String? error;

  Future<void> submit({
    required String title,
    required String content,
    int? paperId,
    List<({String name, List<int> bytes})> images = const [],
  }) async {
    submitting = true;
    error = null;
    notifyListeners();
    try {
      await _svc.create(
        title: title,
        content: content,
        paperId: paperId,
        images: images,
      );
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      submitting = false;
      notifyListeners();
    }
  }
}

import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../service/blog_service.dart';

class BlogWriteViewModel extends ChangeNotifier {
  final _svc = BlogService();
  bool submitting = false;
  String? error;

  Future<void> submit({
    int? reviewId,
    required String title,
    required String content,
    int? paperId,
    List<({String name, List<int> bytes})> images = const [],
  }) async {
    submitting = true;
    error = null;
    notifyListeners();
    try {
      if (reviewId != null) {
        await _svc.update(
          reviewId: reviewId,
          title: title,
          content: content,
          paperId: paperId, // 서버가 사용 안 해도 타입 맞춤
        );
      } else {
        await _svc.create(
          title: title,
          content: content,
          paperId: paperId,
          images: images,
        );
      }
    } finally {
      submitting = false;
      notifyListeners();
    }
  }
}

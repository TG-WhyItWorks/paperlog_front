import 'package:flutter/material.dart';
import '../../../core/models/review_models.dart';

import '../service/blog_service.dart';

class BlogDetailViewModel extends ChangeNotifier {
  final _svc = BlogService();
  bool loading = false;
  String? error;
  BlogReview? review;
  bool liked = false;

  Future<void> load(int id) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      review = await _svc.detail(id);
      // 내가 좋아요 눌렀는지 확인(간단히 전체 목록에서 포함 여부로 판단)
      try {
        final likedIds = await _svc.likedReviewIds();
        liked = likedIds.contains(id);
      } catch (_) {}
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> toggleLike() async {
    if (review == null) return;
    final id = review!.id;
    try {
      int cnt;
      if (!liked) {
        cnt = await _svc.like(id);
        liked = true;
      } else {
        cnt = await _svc.unlike(id);
        liked = false;
      }
      review = BlogReview(
        id: review!.id,
        title: review!.title,
        content: review!.content,
        createDate: review!.createDate,
        modifyDate: review!.modifyDate,
        user: review!.user,
        paperId: review!.paperId,
        images: review!.images,
        comments: review!.comments,
        voteCount: cnt,
      );
      notifyListeners();
    } catch (e) {
      // 실패 시 스낵바는 화면에서 처리
    }
  }
}

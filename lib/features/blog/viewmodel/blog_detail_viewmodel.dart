import 'package:flutter/material.dart';
import '../../../core/models/review_models.dart';

import '../service/blog_service.dart';

class BlogDetailViewModel extends ChangeNotifier {
  final _svc = BlogService();
  bool loading = false;
  String? error;
  BlogReview? review;
  bool liked = false;
  bool likeBusy = false;

  Future<void> load(int id) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final r = await _svc.detail(id);
      review = r;
      try {
        final likedIds = await _svc.likedReviewIds();
        liked = likedIds.contains(id);
      } catch (_) {
        liked = false;
      }
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> toggleLike() async {
    if (review == null || likeBusy) return;

    likeBusy = true;

    final prevLiked = liked;
    final prevCount = review!.voteCount;
    liked = !liked;
    review = review!.copyWith(
      voteCount: (prevCount + (liked ? 1 : -1)).clamp(0, 1 << 31),
    );
    notifyListeners();

    try {
      final newCount = liked
          ? await _svc.like(review!.id)
          : await _svc.unlike(review!.id);
      review = review!.copyWith(voteCount: newCount);
    } catch (e) {
      // 롤백
      liked = prevLiked;
      review = review!.copyWith(voteCount: prevCount);
      rethrow;
    } finally {
      likeBusy = false;
      notifyListeners();
    }
  }

  Future<void> deleteCurrent() async {
    if (review == null) return;
    final id = review!.id;
    loading = true;
    notifyListeners();
    try {
      await _svc.delete(id);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> reload() async {
    if (review == null) return;
    await load(review!.id);
  }
}

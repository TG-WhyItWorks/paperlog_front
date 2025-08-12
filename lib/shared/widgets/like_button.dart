// lib/shared/widgets/like_button.dart
import 'package:flutter/material.dart';
import '../../core/services/like_service.dart'; // 경로 맞춰주세요

class LikeButton extends StatefulWidget {
  final String paperId;
  final int initialCount;
  final bool initialLiked;
  const LikeButton({
    super.key,
    required this.paperId,
    this.initialCount = 0,
    this.initialLiked = false,
  });

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  final _svc = LikeService();
  late int _count;
  late bool _liked;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _count = widget.initialCount;
    _liked = widget.initialLiked;
  }

  Future<void> _toggle() async {
    if (_busy) return;

    // 낙관적 업데이트
    setState(() {
      _busy = true;
      _liked = !_liked;
      _count += _liked ? 1 : -1;
      if (_count < 0) _count = 0;
    });

    try {
      final resp = _liked
          ? await _svc.like(widget.paperId)
          : await _svc.unlike(widget.paperId);

      // 서버 응답이 int 또는 Map일 수 있음
      int? serverCount;
      if (resp is int) {
        serverCount = resp;
      } else if (resp is Map) {
        final m = resp as Map;
        final v = m['likeCount'] ?? m['count'];
        if (v is int) serverCount = v;
        if (v is String) serverCount = int.tryParse(v);
      }

      if (serverCount != null && serverCount >= 0) {
        setState(() => _count = serverCount!);
      }
    } catch (e) {
      // 실패시 롤백
      setState(() {
        _liked = !_liked;
        _count += _liked ? 1 : -1;
        if (_count < 0) _count = 0;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('좋아요 처리 실패: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = _liked ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined;
    final color = _liked
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurface;

    return TextButton.icon(
      onPressed: _busy ? null : _toggle,
      icon: Icon(icon, color: color),
      label: Text('$_count'),
    );
  }
}

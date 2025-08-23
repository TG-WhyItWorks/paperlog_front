import 'package:flutter/material.dart';
import '../../../core/config/api_config.dart';
import '../../../core/services/token_storage.dart';

/// 인증 필요한 아바타도 표시 가능한 공용 위젯
class UserAvatar extends StatefulWidget {
  final String displayName;
  final String? avatarUrl;
  final double size;
  final bool useAuthHeader; // 아바타가 보호 리소스일 때 true
  const UserAvatar({
    super.key,
    required this.displayName,
    this.avatarUrl,
    this.size = 24,
    this.useAuthHeader = true,
  });

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  String? _token;
  final _tokenStorage = TokenStorage();

  @override
  void initState() {
    super.initState();
    if (widget.useAuthHeader) _loadToken();
  }

  Future<void> _loadToken() async {
    try {
      final t = await _tokenStorage.readAccessToken();
      if (mounted) setState(() => _token = t);
    } catch (_) {}
  }

  String _initial() {
    final t = widget.displayName.trim();
    if (t.isEmpty) return 'U';
    // 다국어 안전하게 첫 글자만
    return t.characters.isNotEmpty ? t.characters.first.toUpperCase() : 'U';
  }

  String? _absUrl(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    final u = url.trim();
    final parsed = Uri.tryParse(u);
    if (parsed != null && parsed.hasScheme) return u; // 이미 절대 URL
    try {
      // 상대경로면 ApiConfig.uri로 절대화
      return ApiConfig.uri(u).toString();
    } catch (_) {
      // ApiConfig.uri에 안 맞으면 baseUrl 접두도 시도 (프로젝트에 맞게 수정)
      // return '${ApiConfig.baseUrl}$u';
      return u;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).colorScheme.surfaceContainerHighest;
    final fg = Theme.of(context).colorScheme.onSurface;
    final url = _absUrl(widget.avatarUrl);

    Widget fallback() => Container(
      color: bg,
      alignment: Alignment.center,
      child: Text(
        _initial(),
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: widget.size * 0.45,
          color: fg.withOpacity(0.8),
        ),
      ),
    );

    Widget body;
    if (url != null) {
      body = Image.network(
        url,
        fit: BoxFit.cover,
        // 헤더(Authorization) 필요 시 전달
        headers:
            (widget.useAuthHeader && (_token != null && _token!.isNotEmpty))
            ? {'Authorization': 'Bearer $_token'}
            : null,
        errorBuilder: (_, __, ___) => fallback(),
        // 로딩 상태에서는 심플 플레이스홀더
        loadingBuilder: (ctx, child, prog) {
          if (prog == null) return child;
          return Container(color: bg);
        },
      );
    } else {
      body = fallback();
    }

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: ClipOval(child: body),
    );
  }
}

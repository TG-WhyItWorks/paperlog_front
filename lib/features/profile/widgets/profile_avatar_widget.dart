import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String avatarUrl;
  final double size;

  const ProfileAvatar({Key? key, required this.avatarUrl, required this.size})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl.trim();

    if (url.isEmpty) {
      return CircleAvatar(radius: size / 2, child: const Icon(Icons.person));
    }
    return ClipOval(
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return CircleAvatar(
            radius: size / 2,
            child: const Icon(Icons.person),
          );
        },
      ),
    );
  }
}

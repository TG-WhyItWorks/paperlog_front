import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String avatarUrl;
  final double size;

  const ProfileAvatar({Key? key, required this.avatarUrl, required this.size})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundImage: NetworkImage(avatarUrl),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/library_viewmodel.dart';

// 북마크 검색 입력 위젯
class LibrarySearchField extends StatelessWidget {
  const LibrarySearchField({super.key});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: TextField(
        onChanged: context.read<LibraryViewModel>().updateQuery,
        decoration: InputDecoration(
          hintText: 'Search on bookmarks...',
          prefixIcon: const Icon(Icons.search),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

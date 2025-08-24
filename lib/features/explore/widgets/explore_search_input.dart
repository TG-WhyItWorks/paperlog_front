import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/explore_viewmodel.dart';

class ExploreSearchInput extends StatelessWidget {
  const ExploreSearchInput({Key? key, required this.controller})
    : super(key: key);
  final TextEditingController controller;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: '논문을 검색해 보세요',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          suffixIcon: IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              final q = controller.text.trim();
              context.read<ExploreViewModel>().search(q);
            },
          ),
        ),
        textInputAction: TextInputAction.search,
        onSubmitted: (q) {
          context.read<ExploreViewModel>().search(q.trim());
        },
      ),
    );
  }
}

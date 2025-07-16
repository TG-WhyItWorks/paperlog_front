import 'package:flutter/material.dart';
import '../viewmodel/dashboard_viewmodel.dart';

class SearchbarWidget extends StatelessWidget {
  final MainViewModel viewModel;
  const SearchbarWidget({required this.viewModel, Key? key}) : super(key:key);

  @override
  Widget build(BuildContext context){
    return Padding(padding: const EdgeInsets.all(16), child: TextField(
      decoration: InputDecoration(
        hintText: 'Seach by keyword, author, or title',
        fillColor: const Color(0xFFEFF2F4),
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),borderSide: BorderSide.none,),
      ),
      onSubmitted: (q){
        //TODO: 검색 로직
      },
    ),
   );
  }
}
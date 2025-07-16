import 'package:flutter/material.dart';
import '../viewmodel/dashboard_viewmodel.dart';

class HeaderWidget extends StatelessWidget{
  final MainViewModel viewModel;
  const HeaderWidget({required this.viewModel, Key? key}) : super(key:key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40,vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E8EA))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('PaperLog', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          //TODO: 메뉴 버튼들
        ],
      ),
    );
  }
}
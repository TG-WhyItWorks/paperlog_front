import 'package:flutter/material.dart';

class EditBioDialog extends StatefulWidget {
  const EditBioDialog({super.key, required this.initial});
  final String initial;

  static Future<String?> show(BuildContext context, {required String initial}) {
    return showDialog<String>(
      context: context,
      builder: (_) => EditBioDialog(initial: initial),
    );
  }

  @override
  State<EditBioDialog> createState() => _EditBioDialogState();
}

class _EditBioDialogState extends State<EditBioDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial,
  );
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('자기소개 수정'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(hintText: '새로운 자기 소개를 입력하세요'),
          validator: (v) {
            if (v == null) return null;
            if (v.length > 300) return '최대 300자까지 입력할 수 있어요.';
            return null;
          },
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('저장')),
      ],
    );
  }
}

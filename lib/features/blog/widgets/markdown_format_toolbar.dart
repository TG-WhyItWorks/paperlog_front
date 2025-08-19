import 'package:flutter/material.dart';

/// 마크다운 포맷팅 툴바: 선택 영역을 감싸거나 줄 앞에 접두어를 토글합니다.
class MarkdownFormatToolbar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final void Function()? onInsertDivider;
  final void Function()? onInsertTable;
  const MarkdownFormatToolbar({
    super.key,
    required this.controller,
    this.focusNode,
    this.onInsertDivider,
    this.onInsertTable,
  });

  TextSelection get _sel => controller.selection;

  void _wrap(String left, String right, {String placeholder = '텍스트'}) {
    final text = controller.text;
    final s = _sel.start, e = _sel.end;
    final has = s >= 0 && e >= 0 && s != e;
    final mid = has ? text.substring(s, e) : placeholder;
    final newText = text.replaceRange(s, e, '$left$mid$right');
    final cursor = (s + left.length + mid.length);
    controller.value = controller.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: cursor),
      composing: TextRange.empty,
    );
    focusNode?.requestFocus();
  }

  void _togglePrefix(String prefix) {
    final text = controller.text;
    final s = _sel.start, e = _sel.end;
    if (s < 0 || e < 0) return;

    // 선택된 줄들을 찾아 접두어 토글
    final startLine = text.lastIndexOf('\n', s - 1) + 1;
    final endLine = text.indexOf('\n', e);
    final realEnd = endLine == -1 ? text.length : endLine;

    final lines = text.substring(startLine, realEnd).split('\n');
    final processed = <String>[];
    for (final line in lines) {
      if (line.startsWith(prefix)) {
        processed.add(line.substring(prefix.length));
      } else {
        processed.add('$prefix$line');
      }
    }
    final replaced = processed.join('\n');
    final newText = text.replaceRange(startLine, realEnd, replaced);

    // 대략적인 커서 보정
    controller.value = controller.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: startLine + replaced.length),
      composing: TextRange.empty,
    );
    focusNode?.requestFocus();
  }

  void _insert(String block) {
    final text = controller.text;
    final s = _sel.start, e = _sel.end;
    final pos = (s < 0 || e < 0) ? text.length : e;
    final newText = text.replaceRange(pos, pos, block);
    controller.value = controller.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: pos + block.length),
      composing: TextRange.empty,
    );
    focusNode?.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).colorScheme.onSurface;
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        _btn(Icons.title, 'H1', () => _togglePrefix('# ')),
        _btn(Icons.title, 'H2', () => _togglePrefix('## ')),
        _btn(Icons.title, 'H3', () => _togglePrefix('### ')),
        _sep(),
        _btn(Icons.format_bold, '굵게', () => _wrap('**', '**')),
        _btn(Icons.format_italic, '기울임', () => _wrap('*', '*')),
        _btn(Icons.strikethrough_s, '취소선', () => _wrap('~~', '~~')),
        _btn(Icons.code, '인라인코드', () => _wrap('`', '`')),
        _sep(),
        _btn(Icons.format_list_bulleted, '글머리', () => _togglePrefix('- ')),
        _btn(Icons.format_list_numbered, '번호', () => _togglePrefix('1. ')),
        _btn(Icons.format_quote, '인용', () => _togglePrefix('> ')),
        _btn(Icons.horizontal_rule, '구분선', () {
          if (onInsertDivider != null) {
            onInsertDivider!(); // 외부에서 주입한 핸들러가 있으면 호출
          } else {
            _insert('\n\n---\n\n'); // 없으면 기본 동작 실행
          }
        }),
        _btn(Icons.table_chart_outlined, '테이블', () {
          onInsertTable?.call();
          _insert('\n\n| 헤더1 | 헤더2 |\n| --- | --- |\n| 내용1 | 내용2 |\n\n');
        }),
        _sep(),
        _btn(Icons.code_off, '코드블록', () => _insert('\n\n```\n코드\n```\n\n')),
        _btn(Icons.link, '링크', () => _insert('[링크텍스트](https://)')),
        _btn(Icons.image_outlined, '이미지', () => _insert('![설명](https://)')),
      ],
    );
  }

  Widget _sep() => const SizedBox(width: 12);
  Widget _btn(IconData icon, String tip, VoidCallback onTap) {
    return Tooltip(
      message: tip,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Icon(icon, size: 18),
        ),
      ),
    );
  }
}

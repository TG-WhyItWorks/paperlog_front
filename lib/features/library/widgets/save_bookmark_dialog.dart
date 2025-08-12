import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/library_models.dart';
import '../../../core/models/paper_model.dart';
import '../viewmodel/library_viewmodel.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';

class SaveBookmarkDialog extends StatelessWidget {
  const SaveBookmarkDialog({super.key, required this.paper});
  final Paper paper;

  static Future<void> show(BuildContext context, {required Paper paper}) async {
    // 로그인 체크
    final auth = context.read<AuthViewModel>();
    if (!auth.isLoggedIn) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('로그인 후 이용해 주세요.')));
      return;
    }

    // 🔴 중요: 라이브러리 VM에 Auth 바인딩
    final lib = context.read<LibraryViewModel>();
    lib.bindAuth(auth);
    if (lib.folders.isEmpty) {
      await lib.refresh(); // (선택) 폴더 목록 로드
    }

    await showDialog(
      context: context,
      builder: (_) => SaveBookmarkDialog(paper: paper),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LibraryViewModel>();
    final theme = Theme.of(context);

    // 폴더 납작 리스트(들여쓰기용 depth 포함)
    final folders = vm.flattenedFolders();

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 560),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 8, 6),
              child: Row(
                children: [
                  Text(
                    '북마크에 저장',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: '닫기',
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // 리스트
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 6),
                children: [
                  // 빠른 리스트 3종
                  _CheckTile(
                    label: 'Want to read',
                    checked: vm.isInSection(
                      paper.id,
                      LibrarySection.wantToRead,
                    ),
                    onChanged: (v) =>
                        vm.setInSection(paper, LibrarySection.wantToRead, v),
                  ),
                  _CheckTile(
                    label: 'Reading',
                    checked: vm.isInSection(paper.id, LibrarySection.reading),
                    onChanged: (v) =>
                        vm.setInSection(paper, LibrarySection.reading, v),
                  ),
                  _CheckTile(
                    label: 'Completed',
                    checked: vm.isInSection(paper.id, LibrarySection.completed),
                    onChanged: (v) =>
                        vm.setInSection(paper, LibrarySection.completed, v),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 12, 16, 6),
                    child: Text(
                      '내 폴더',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),

                  // 사용자 폴더들
                  ...folders.map((e) {
                    final f = e.f;
                    final depth = e.depth;
                    final checked = vm.isInFolder(paper.id, f.id!);
                    return _CheckTile(
                      label: f.name,
                      lockIcon: true, // 우리 폴더는 기본적으로 개인용이니 잠금 표시
                      leftPadding: 16.0 + depth * 16.0,
                      checked: checked,
                      onChanged: (v) => vm.setInFolder(
                        paper: paper,
                        folderId: f.id!,
                        on: v ?? false,
                      ),
                    );
                  }),
                ],
              ),
            ),

            // 하단: 새 폴더 버튼
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.create_new_folder_outlined),
                      label: const Text('새 폴더'),
                      onPressed: () async {
                        final name = await _askFolderName(context);
                        if (name != null && name.trim().isNotEmpty) {
                          await context.read<LibraryViewModel>().createFolder(
                            name.trim(),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('완료'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<String?> _askFolderName(BuildContext context) {
    final c = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('새 폴더'),
        content: TextField(
          controller: c,
          autofocus: true,
          decoration: const InputDecoration(hintText: '폴더 이름'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, c.text),
            child: const Text('생성'),
          ),
        ],
      ),
    );
  }
}

class _CheckTile extends StatelessWidget {
  const _CheckTile({
    required this.label,
    required this.checked,
    required this.onChanged,
    this.leftPadding = 16,
    this.lockIcon = false,
  });

  final String label;
  final bool checked;
  final ValueChanged<bool> onChanged;
  final double leftPadding;
  final bool lockIcon;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return InkWell(
      onTap: () => onChanged(!checked),
      child: Padding(
        padding: EdgeInsets.only(left: leftPadding, right: 8),
        child: SizedBox(
          height: 44,
          child: Row(
            children: [
              Checkbox(value: checked, onChanged: (v) => onChanged(v ?? false)),
              const SizedBox(width: 8),
              Expanded(child: Text(label, style: t.textTheme.bodyMedium)),
              if (lockIcon) const Icon(Icons.lock_outline, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

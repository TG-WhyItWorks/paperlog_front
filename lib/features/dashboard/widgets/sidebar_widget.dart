import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/dashboard_viewmodel.dart';
import '../../../core/models/library_models.dart';
import '../../library/viewmodel/library_viewmodel.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import 'dart:math' as math;

class SidebarWidget extends StatelessWidget {
  const SidebarWidget({Key? key}) : super(key: key);
  static const double _kSidebarWidth = 320.0;

  Future<void> _addFolder(BuildContext context) async {
    final libVm = context.read<LibraryViewModel>();
    final auth = context.read<AuthViewModel>();
    if (!auth.isLoggedIn) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('로그인 후 이용해 주세요.')));
      return;
    }
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New folder'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Folder name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (name != null && name.trim().isNotEmpty) {
      await libVm.createFolder(name.trim(), parentFolderId: null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final main = context.watch<MainViewModel>();
    final lib = context.watch<LibraryViewModel>();
    final auth = context.watch<AuthViewModel>();
    final bool isOpen = main.isSidebarOpen;

    Widget libItem(String title, LibrarySection s) {
      final count = lib.section(s).length;
      return ListTile(
        contentPadding: EdgeInsets.zero,
        dense: true,
        title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
        trailing: Text('$count', style: Theme.of(context).textTheme.bodyMedium),
        onTap: () {
          // 라이브러리 페이지로 이동 (선택한 섹션 전달)
          Navigator.of(context).pushNamed('/library', arguments: s);
        },
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOutCubic,
      width: isOpen ? _kSidebarWidth : 0,
      color: Theme.of(context).colorScheme.surface,
      padding: EdgeInsets.all(isOpen ? 16 : 0),

      child: AnimatedSlide(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOutCubic,
        offset: isOpen ? Offset.zero : const Offset(-0.06, 0),
        child: ClipRect(
          child: AnimatedOpacity(
            opacity: isOpen ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            child: IgnorePointer(
              ignoring: !isOpen,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== Quick Lists =====
                    Text(
                      'My Library',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    libItem('Want to read', LibrarySection.wantToRead),
                    libItem('Reading', LibrarySection.reading),
                    libItem('Completed', LibrarySection.completed),

                    const Divider(height: 24),

                    // ===== Collections (My publications / Private / Folders) =====
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'My Collections',
                          style: Theme.of(context).textTheme.titleLarge!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (auth.isLoggedIn)
                          IconButton(
                            tooltip: 'New folder',
                            icon: Icon(
                              Icons.add,
                              color: Theme.of(context).iconTheme.color,
                            ),
                            onPressed: () => _addFolder(context),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _collectionRow(
                      context,
                      title: 'My publications',
                      count: lib.section(LibrarySection.myPublications).length,
                      icon: Icons.school_outlined,
                      onTap: () => Navigator.of(context).pushNamed(
                        '/library',
                        arguments: LibrarySection.myPublications,
                      ),
                    ),
                    if (auth.isLoggedIn)
                      _collectionRow(
                        context,
                        title: 'Private Papers',
                        count: lib.section(LibrarySection.private).length,
                        icon: Icons.lock_outline,
                        onTap: () => Navigator.of(context).pushNamed(
                          '/library',
                          arguments: LibrarySection.private,
                        ),
                      ),

                    // 사용자 폴더
                    if (auth.isLoggedIn)
                      ..._buildFolderTreeSidebar(context, lib),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // My Collections 공통 표시용
  Widget _collectionRow(
    BuildContext context, {
    required String title,
    required int count,
    required VoidCallback onTap,
    IconData icon = Icons.folder_outlined,
  }) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, size: 18, color: Theme.of(context).iconTheme.color),
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      subtitle: Text(
        '$count papers',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Theme.of(context).iconTheme.color,
      ),
      onTap: onTap,
    );
  }

  List<Widget> _buildFolderTreeSidebar(
    BuildContext context,
    LibraryViewModel vm,
  ) {
    final all = vm.folders;

    // parentId -> children
    final Map<String?, List<LibraryFolder>> byParent = {};
    for (final f in all) {
      byParent.putIfAbsent(f.parentId, () => <LibraryFolder>[]).add(f);
    }

    List<Widget> buildBranch(String? parentId) {
      final children = byParent[parentId] ?? const <LibraryFolder>[];
      return children.map((f) {
        final grand = buildBranch(f.id);
        final title = Row(
          children: [
            Expanded(
              child: Text(f.name, style: Theme.of(context).textTheme.bodyLarge),
            ),
            Text('${f.count}', style: Theme.of(context).textTheme.bodyMedium),
          ],
        );

        if (grand.isEmpty) {
          // leaf → ListTile
          return ListTile(
            dense: true,
            contentPadding: const EdgeInsets.only(left: 12),
            leading: Icon(
              Icons.folder_outlined,
              size: 18,
              color: Theme.of(context).iconTheme.color,
            ),
            title: title,
            onTap: () => Navigator.of(context).pushNamed('/library'),
          );
        }

        // has children → Smooth animated expasion
        return _SmoothExpansion(
          leading: Icon(
            Icons.folder_outlined,
            size: 18,
            color: Theme.of(context).iconTheme.color,
          ),
          title: title,
          childPadding: const EdgeInsets.only(left: 16),
          children: grand,
        );
      }).toList();
    }

    // 루트(parentId == null)부터 그리기
    return buildBranch(null);
  }
}

class _SmoothExpansion extends StatefulWidget {
  const _SmoothExpansion({
    Key? key,
    required this.title,
    required this.children,
    this.leading,
    this.duration = const Duration(milliseconds: 260),
    this.curve = Curves.easeOutCubic,
    this.reverseCurve = Curves.easeInCubic,
    this.tilePadding = const EdgeInsets.only(left: 0),
    this.childPadding,
    this.initiallyExpanded = false,
  }) : super(key: key);

  final Widget title;
  final List<Widget> children;
  final Widget? leading;
  final Duration duration;
  final Curve curve;
  final Curve reverseCurve;
  final EdgeInsetsGeometry tilePadding;
  final EdgeInsetsGeometry? childPadding;
  final bool initiallyExpanded;

  @override
  State<_SmoothExpansion> createState() => _SmoothExpansionState();
}

class _SmoothExpansionState extends State<_SmoothExpansion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _size;
  late final Animation<double> _fade;
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _size = CurvedAnimation(
      parent: _ctrl,
      curve: widget.curve,
      reverseCurve: widget.reverseCurve,
    );
    _fade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
    );
    if (_expanded) _ctrl.value = 1.0;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _ctrl.forward();
    } else {
      _ctrl.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).iconTheme.color;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _toggle,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: widget.tilePadding,
            child: Row(
              children: [
                if (widget.leading != null) ...[
                  widget.leading!,
                  const SizedBox(width: 8),
                ],
                Expanded(child: widget.title),
                AnimatedBuilder(
                  animation: _ctrl,
                  builder: (_, __) => Transform.rotate(
                    angle: _ctrl.value * math.pi,
                    child: Icon(Icons.keyboard_arrow_down, color: iconColor),
                  ),
                ),
              ],
            ),
          ),
        ),
        ClipRect(
          child: FadeTransition(
            opacity: _fade,
            child: SizeTransition(
              sizeFactor: _size,
              axisAlignment: -1.0,
              child: Padding(
                padding: widget.childPadding ?? EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.children,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/models/profile_model.dart';
import '../../dashboard/viewmodel/dashboard_viewmodel.dart';
import '../../dashboard/widgets/header_widget.dart';
import '../../dashboard/widgets/sidebar_widget.dart';
import '../service/profile_service.dart';

class EditProfilePage extends StatefulWidget {
  final ProfileModel initial;
  const EditProfilePage({super.key, required this.initial});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _bioCtrl;

  final _picker = ImagePicker();
  Uint8List? _avatarBytes; // 새로 선택한 이미지
  String? _avatarFileName;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initial.username);
    _bioCtrl = TextEditingController(text: widget.initial.bio);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    setState(() {
      _avatarBytes = bytes;
      _avatarFileName = picked.name;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final service = ProfileService();
      String? newAvatarUrl;

      if (_avatarBytes != null && _avatarFileName != null) {
        newAvatarUrl = await service.uploadAvatar(
          bytes: _avatarBytes!,
          filename: _avatarFileName!,
        );
      }

      await service.updateProfile(
        username: _nameCtrl.text.trim(),
        bio: _bioCtrl.text.trim(),
        avatarUrl: newAvatarUrl,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('프로필이 저장되었습니다.')));
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('저장 실패: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentAvatarUrl = widget.initial.avatarUrl;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: HeaderWidget(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SidebarWidget(),
            AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOutCubic,
              width: 1,
              color: context.watch<MainViewModel>().isSidebarOpen
                  ? Theme.of(context).dividerColor
                  : Colors.transparent,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWeb = constraints.maxWidth > 600;
                    final avatarSize = isWeb ? 120.0 : 96.0;
                    final cardWidth = isWeb ? 800.0 : double.infinity;

                    return Center(
                      child: Container(
                        width: cardWidth,
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 상단 타이틀 + 저장 버튼
                            Row(
                              children: [
                                Text(
                                  '프로필 수정',
                                  style: theme.textTheme.headlineSmall,
                                ),
                                const Spacer(),
                                FilledButton.icon(
                                  onPressed: _saving ? null : _save,
                                  icon: _saving
                                      ? const SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.save),
                                  label: const Text('저장'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // 아바타
                            Center(
                              child: Stack(
                                children: [
                                  ClipOval(
                                    child: _avatarBytes != null
                                        ? Image.memory(
                                            _avatarBytes!,
                                            width: avatarSize,
                                            height: avatarSize,
                                            fit: BoxFit.cover,
                                          )
                                        : (currentAvatarUrl.isNotEmpty
                                              ? Image.network(
                                                  currentAvatarUrl,
                                                  width: avatarSize,
                                                  height: avatarSize,
                                                  fit: BoxFit.cover,
                                                )
                                              : CircleAvatar(
                                                  radius: avatarSize / 2,
                                                  child: Icon(
                                                    Icons.person,
                                                    size: avatarSize * 0.4,
                                                    color: theme.hintColor,
                                                  ),
                                                )),
                                  ),
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Material(
                                      color: theme.colorScheme.primary,
                                      shape: const CircleBorder(),
                                      child: InkWell(
                                        customBorder: const CircleBorder(),
                                        onTap: _saving ? null : _pickAvatar,
                                        child: const Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Icon(
                                            Icons.edit,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // 폼
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _nameCtrl,
                                    decoration: const InputDecoration(
                                      labelText: '이름(닉네임)',
                                      hintText: '표시할 이름을 입력하세요',
                                    ),
                                    textAlign: TextAlign.start,
                                    textAlignVertical: TextAlignVertical.center,
                                    validator: (v) {
                                      final t = (v ?? '').trim();
                                      if (t.isEmpty) return '이름은 비워둘 수 없어요.';
                                      if (t.length > 32)
                                        return '최대 32자까지 가능합니다.';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _bioCtrl,
                                    minLines: 5,
                                    maxLines: 10,
                                    textAlign: TextAlign.start,
                                    textAlignVertical: TextAlignVertical.top,
                                    decoration: const InputDecoration(
                                      labelText: 'Bio',
                                      hintText: '간단한 소개를 적어주세요 (최대 300자)',
                                      alignLabelWithHint: true,
                                      contentPadding: EdgeInsets.fromLTRB(
                                        12,
                                        12,
                                        12,
                                        12,
                                      ),
                                      border: OutlineInputBorder(),
                                      enabledBorder: OutlineInputBorder(),
                                      focusedBorder: OutlineInputBorder(),
                                    ),
                                    validator: (v) {
                                      final t = (v ?? '');
                                      if (t.length > 300)
                                        return '최대 300자까지 가능합니다.';
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

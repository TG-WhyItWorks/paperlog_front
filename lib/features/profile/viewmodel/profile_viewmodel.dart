import 'package:flutter/material.dart';
import '../../../core/models/profile_model.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../../auth/service/auth_service.dart';
import 'package:flutter/foundation.dart' show debugPrint;

class ProfileViewmodel extends ChangeNotifier {
  final AuthViewModel authVm;
  final AuthService _auth = AuthService();

  ProfileViewmodel(this.authVm);

  ProfileModel _profile = ProfileModel(
    avatarUrl: '',
    username: '',
    bio: '',
    subtitle: '',
    followers: 0,
    following: 0,
  );

  ProfileModel get profile => _profile;

  Future<void> loadProfile() async {
    final u = authVm.user;
    _profile = _profile.copyWith(
      username: u?.username ?? profile.username,
      subtitle: u?.email ?? _profile.subtitle,
      avatarUrl: authVm.userAvatarUrl ?? _profile.avatarUrl,
    );
    notifyListeners();

    try {
      final me = await _auth.fetchProfile();
      _profile = _profile.copyWith(
        username: me.username,
        subtitle: me.email,
        avatarUrl: me.avatarUrl ?? _profile.avatarUrl,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('[PROFILE] fetchProfile failed: $e');
    }
  }

  Future<void> updateBio(String newBio) async {
    _profile = _profile.copyWith(bio: newBio);
    notifyListeners();
  }
}

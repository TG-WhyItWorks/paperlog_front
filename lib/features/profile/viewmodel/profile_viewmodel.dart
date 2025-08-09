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

  List<InterestStat> _interests = [];
  List<InterestStat> get interests => _interests;

  List<BadgeModel> _badges = [];
  List<BadgeModel> get badges => _badges;

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
    await _loadInterestsAndBadges();
  }

  Future<void> _loadInterestsAndBadges() async {
    try {
      //TODO: 실제 API 연동
      final sample = <InterestStat>[
        const InterestStat(field: 'Computer Vision', count: 12),
        const InterestStat(field: 'NLP', count: 9),
        const InterestStat(field: 'Reinforcement Learning', count: 5),
        const InterestStat(field: 'Systems', count: 2),
      ]..sort((a, b) => b.count.compareTo(a.count));

      _interests = sample;

      final total = sample.fold<int>(0, (sum, e) => sum + e.count);
      _badges = _evaluateBadges(total);

      _badges.sort((a, b) {
        if (a.achieved != b.achieved) return a.achieved ? -1 : 1;
        if (a.achieved && b.achieved) {
          final atA = a.achievedAt ?? DateTime.fromMillisecondsSinceEpoch(0);

          final atB = b.achievedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return atB.compareTo(atA);
        }
        return a.threshold.compareTo(b.threshold);
      });
      notifyListeners();
    } catch (e) {
      debugPrint('[Profile] interests/bagdges load failed: $e');
    }
  }

  List<BadgeModel> _evaluateBadges(int readCount) {
    final now = DateTime.now();

    final defs = <BadgeModel>[
      BadgeModel(
        code: 'novice_5',
        name: '입문 리더',
        description: '논문 5편 읽기 달성',
        threshold: 5,
        achieved: readCount >= 5,
        achievedAt: readCount >= 5 ? now : null,
      ),
      BadgeModel(
        code: 'steady_10',
        name: '꾸준한 독자',
        description: '논문 10편 읽기 달성',
        threshold: 10,
        achieved: readCount >= 10,
        achievedAt: readCount >= 10 ? now : null,
      ),
      BadgeModel(
        code: 'explorer_20',
        name: '탐구가',
        description: '논문 20편 읽기 달성',
        threshold: 20,
        achieved: readCount >= 20,
        achievedAt: readCount >= 20 ? now : null,
      ),
      BadgeModel(
        code: 'deepdiver_50',
        name: '심화 탐독가',
        description: '논문 50편 읽기 달성',
        threshold: 50,
        achieved: readCount >= 50,
        achievedAt: readCount >= 50 ? now : null,
      ),
      BadgeModel(
        code: 'reviewer_100',
        name: '백서 리뷰어',
        description: '논문 100편 읽기 달성',
        threshold: 100,
        achieved: readCount >= 100,
        achievedAt: readCount >= 100 ? now : null,
      ),
    ];
    return defs;
  }

  Future<void> updateBio(String newBio) async {
    _profile = _profile.copyWith(bio: newBio);
    notifyListeners();
  }
}

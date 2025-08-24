# PaperLog-Front
25년 여름방학 티지톤에 참가하는 '이게 왜 되지?'팀의 프론트엔드 레포지토리입니다.

연구 논문을 **검색 → 읽기 → 북마크/정리 → 리뷰 탐색**까지 한 번에 관리할 수 있도록 하는 서비스입니다.

**Dart & Flutter**를 이용해 MVVM 구조로 구현했습니다.

---

## 주요 기능

* **Explore**

  * arXiv 기반 통합 검색 (`/api/arxiv?query=...`)
  * 인기/카테고리 추천 (`/api/arxiv/papers/top/{category}`)
  * 카드형 결과(PaperCard)·빠른 북마크 저장(섹션/폴더)
* **Paper Detail**

  * 상세 조회 (`/api/arxiv/{paperId}`)
  * Abstract / 번역 / Blog Summary 탭
  * 좋아요 토글(낙관적 업데이트)
  * 관련 리뷰 포스트 인기순 목록
* **Library**

  * 빠른 섹션: Want to read / Reading / Completed
  * **폴더 트리**(중첩) + 드릴다운 목록
  * 다중 선택 후 Move/Delete, 폴더로 이동
  * **개인 PDF 업로드**(선택 폴더 업로드 지원)
* **Profile**

  * 프로필 카드, 아바타·닉네임·소개 수정
  * 아바타 업로드(`POST /users/me/avatar`), 프로필 패치(`PATCH /users/me`)
  * 관심 분야/뱃지(샘플 데이터)
* **Settings**

  * 테마: Light/Dark(시스템 기본값)
  * **날짜 표기 포맷**: ymd · ymd-dash · ymd-slash · 한국어 · 상대시간
  * (샘플) 알림/연결 패널
* **환경/상태**

  * Provider 기반 상태관리(ViewModel)
  * **SharedPreferences로 테마/날짜 포맷 영구 저장**
  * 공통 스타일(경희대 색 스킴, 텍스트 스타일)


---

## 백엔드 의존 API 요약

> `ApiConfig`가 제공하는 `baseUrl` 기준 상대경로입니다.

* 검색/추천/상세

  * `GET /api/arxiv?query=...&skip=&limit=`
  * `GET /api/arxiv/papers/top/{category}`
  * `GET /api/arxiv/{paperId}`
* 라이브러리(섹션/삭제)

  * `GET /library`
  * `POST /library/section`  body: `{ paper_ids: [string], section: 'wantToRead'|'reading'|'completed'|'none'|'private'|'myPublications' }`
  * `POST /library/papers/delete` body: `{ paper_ids: [string] }`
* 폴더

  * `GET /folders/root` (루트 없으면 **404 → 빈 리스트로 처리**)
  * `POST /folders/` body: `{ folder_name, parent_folder_id? }`
  * `PUT /folders/{id}` body: `{ id, folder_name, parent_folder_id }`
  * `DELETE /folders/{id}`
  * 폴더 항목

    * `POST /folders/{folderId}/items` body:
      `{"folder_paper_name": "...", "folder_id": int, "paper_id"?: int, "review_id"?: int}`
    * `DELETE /folders/{folderId}/items` body:
      `{"folder_id": int, "paper_id"?: int, "review_id"?: int, "paper_arxiv_id"?: string}`
* 개인 PDF 업로드

  * `POST /private-papers/upload` (multipart: file + fields + folder\_id?)
* 프로필

  * `POST /users/me/avatar` → `{ "avatarUrl": "..." }`
  * `PATCH /users/me` → `{ username?, bio?, avatarUrl? }`
* 좋아요

  * `LikeService`가 `/like`/`/unlike`류 엔드포인트 호출(서버 응답은 int 또는 `{ likeCount | count }` 허용)

> **인증**: 일부 API는 `Authorization: Bearer <accessToken>` 필요.
> `TokenStorage.readAccessToken()`을 통해 헤더에 자동 포함되도록 구현돼 있습니다.

---

## 구조(요약)

```
lib/
 ├─ core/
 │   ├─ config/api_config.dart          # baseUrl/헤더/URI 유틸(직접 구성 필요)
 │   ├─ models/                         # Paper, LibraryItem, Profile 등
 │   └─ services/                       # TokenStorage, LikeService 등
 ├─ features/
 │   ├─ explore/ (search & list)
 │   ├─ paper/   (detail, tabs, recommend, like button)
 │   ├─ library/ (sections, folders, uploads)
 │   ├─ blog/    (review list 카드 연동)
 │   ├─ profile/ (view/edit, avatar upload)
 │   ├─ settings/(dialog, appearance/notifications/connections)
 │   └─ dashboard/(Header/Sidebar/MainScreen, recent lists)
 ├─ shared/
 │   ├─ prefs/  (date_formatting, PrefsProvider)
 │   └─ theme/  (AppTheme, color_schemes, text_styles, ThemeProvider)
 └─ main.dart   (Provider 주입, routes)
```

---

## 설치 & 실행

### 1) 의존성 설치

```bash
flutter pub get
```

### 2) `ApiConfig` 준비 (중요)

`lib/core/config/api_config.dart` 파일에서 **백엔드 Base URL**과 헤더/URI 유틸을 제공합니다. 아래 예시를 참고해 프로젝트에 맞게 구현하세요.

```dart
// lib/core/config/api_config.dart (예시)
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE',
    defaultValue: 'http://localhost:8000', // 개발 기본값
  );

  static Uri uri(String path, [Map<String, dynamic>? q]) {
    final base = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    return Uri.parse('$base$path').replace(queryParameters: q?.map((k, v) => MapEntry(k, '$v')));
  }

  static Map<String, String> baseHeaders({bool json = true}) => {
    if (json) 'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static void logReq(String tag, Uri uri) {
    if (kDebugMode) dev.log('$tag $uri');
  }
}
```

> 배포 시 `--dart-define=API_BASE=https://api.example.com` 같이 지정하세요.

### 3) SharedPreferences (테마/날짜 포맷 저장)

이미 코드에 반영되어 있습니다. iOS/Android/Web 모두 기본 지원됩니다.

### 4) 실행

```bash
flutter run -d chrome      # Web
# 또는
flutter run                # 연결된 디바이스/에뮬레이터
```

---

## 라우팅

* `/` MainScreen (Dashboard)
* `/explore` (args: `initialQuery: String`)
* `/paper` (args: `paperId: String`)
* `/library` (args optional: `{ initialTab?: 0|1, section?: LibrarySection }`)
* `/blogs`, `/blog`, `/blog/new`, `/blog/edit`
* `/login`, `/profile`

---

## 상태관리

* **Provider + ChangeNotifier**

  * `ExploreViewModel` — 검색
  * `PaperDetailViewModel` — 상세 조회
  * `RecommendedPapersViewModel` — 추천
  * `LibraryViewModel` — 섹션/폴더/업로드/선택
  * `ProfileViewmodel` — 프로필/뱃지/관심분야
  * `ThemeProvider` — ThemeMode (SharedPreferences 저장)
  * `PrefsProvider` — DateFormatOption (SharedPreferences 저장)
  * `AuthViewModel` — 로그인 상태/토큰

---

## UX/동작 포인트

* **Explore**

  * 첫 진입 시 `initialQuery`로 검색
  * 검색 실패/빈 결과 시 추천 리스트 노출
* **PaperCard**

  * 상단 날짜는 사용자의 **설정한 날짜 형식**으로 표시
  * Bookmark 버튼 → 빠른 섹션/폴더 체크 다이얼로그
* **Library**

  * 다중 선택 시 상단 툴바 등장 (Move / Delete / Count / Cancel)
  * 폴더 항목 삭제 시 서버 삭제 + 로컬 카운트 동기화
  * **처음 사용하는 사용자**: `/folders/root`가 404면 **"My Collections"** 루트 생성 후 재조회
* **Private Upload**

  * 파일 선택 후 `/private-papers/upload`로 업로드, 성공 시 Private 섹션 맨 앞에 추가
  * 특정 폴더 액션에서 “Upload to this folder” 지원
* **Paper Detail**

  * 최초 로드 시 Dashboard에 “최근 본 논문”으로 기록
  * 리뷰 목록은 좋아요순 (서버 정렬 미보장 시 클라이언트에서 후정렬)
* **LikeButton**

  * 낙관적 업데이트 → 서버 실패 시 롤백
* **Settings**

  * 테마/날짜 포맷 즉시 반영 + 영구 저장
  * 상대 시간(`relative`)은 방금/분/시간/어제·오늘·내일/며칠 전·후 등 자연어 처리

---


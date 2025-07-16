import 'package:flutter/foundation.dart';
import '../../../core/models/paper_model.dart';
import '../../../core/models/folder_model.dart';

class MainViewModel extends ChangeNotifier{
  List<Paper> recommendPapers = [];
  List<Folder> folders = [];

  MainViewModel(){
    _loadInitialData();
    _loadRecommendedPapers();
  }

  void _loadRecommendedPapers() {
    //샘플 데이터 또는 API 호출 결과를 here에 할당
    recommendPapers = Paper.sampleList();
    notifyListeners();
  }

  void _loadInitialData(){
    //TODO: API 호출 또는 더미 데이터
    recommendPapers = Paper.sampleList();
    folders = Folder.defaultFolders();
    notifyListeners();
  }

  void selectFolder(Folder folder){
    //TODO: 선택 폴더에 맞추어 papers 필터링
    notifyListeners();
  }
}
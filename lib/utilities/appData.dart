class AppData {
  static final AppData _appData = AppData._internal();

  bool? isPro;

  factory AppData() {
    return _appData;
  }
  AppData._internal();
}


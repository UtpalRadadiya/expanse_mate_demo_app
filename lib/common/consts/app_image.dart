class AppImage {
  static const String splashScreenLogo = 'splash_screen_logo';
  static const String category = 'category';
  static const String icCalender = 'ic_calender';
  static const String icEdit = 'ic_edit';
  static const String icMenu = 'ic_menu';
  static const String icSort = 'ic_sort';
  static const String icFilter = 'ic_filter';

  ///In Active Icons
  static const String inActiveHome = 'in_active_home';
  static const String inActiveGroup = 'in_active_group';
  static const String inActiveActivity = 'in_active_activity';
  static const String inActiveProfile = 'in_active_profile';

  ///Active Icons
  static const String activeHome = 'active_home';
  static const String activeGroup = 'active_group';
  static const String activeActivity = 'active_activity';
  static const String activeProfile = 'active_profile';

  /* Bottom APP Bar Non selected Icons */
  static const String icHome = 'home';
  static const String icLikedFrame = 'liked_frame';
  static const String icChat = 'chat';
  static const String icFavourite = 'calender';
  static const String icProfile = 'profile';

  /* Bottom APP Bar selected Icons */
  static const String icSelectedHome = 'selected-home';
  static const String icSelectedLikedFrame = 'selected-liked-frame';
  static const String icSelectedChat = 'selected-chat';
  static const String icSelectedFavourite = 'selected-calender';
  static const String icSelectedProfile = 'selected-profile';
}

extension DisplayImageExt on String {
  static const String _basePath = 'assets/images/';

  String path() => '$_basePath$this.svg';

  String pathPNG() => '$_basePath$this.png';
}

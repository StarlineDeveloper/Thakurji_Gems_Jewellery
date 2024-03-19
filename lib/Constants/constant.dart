import 'package:intl/intl.dart';

class Constants {
  //Add clientId from web(custom.js)
  static const String clientId = "6";

  //Add baseUrl from web(custom.js)
  static const baseUrl =
      'https://starlinejewellers.co.in/api/bullion/';

  //Add baseUrlTerminal from web(custom.js)
  static const baseUrlTerminal =
      'https://starlinebuild.co.in/WebService/Terminal.asmx';

  //Add socketUrl from web(custom.js)
  static const socketUrl = 'https://www.starlinejewellers.co.in:10001';

  //Add playstore link
  static const String androidAppStoreRedirect =
      "https://play.google.com/store/apps/details?id=com.thakurjigemsandjewellery&pli=1";

  //Add android package name
  static const String androidAppRateAndUpdate = "com.thakurjigemsandjewellery";

  //Add ios app id from app store(while creating app)
  static const String iOSAppId = "6479629729";

  //Replace ios app id at the end of url(while creating app)
  static const String iOSAppRedirect =
      "https://apps.apple.com/in/app/thakur-ji-gems-and-jewellery/id$iOSAppId";

  //Add prjName from web(custom.js)
  static const String projectName = 'thakurjigems';

  //same as project name
  static const String subscriberTopic = 'thakurjigems';

  // Add static
  static String alertAndCnfTitle = 'Thakurji Gems And Jewels';

  //Headers
  static const Map<String, String> headers = {
    'Content-Type': 'application/json'
  };
  // Leave it as it is
  static const String economicCalenderUrl =
      'https://www.mql5.com/en/economic-calendar/widget?mode=1&utm_source=www.pritamspot.com';
  static bool isLogin = false;
  static const noInternet = 'Please check your internet connection.';
  static const serverError = 'Something went wrong.';
  static const noData = 'No Data Found.';
  static String startDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
  static String endDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
  static int loginId = 0;
  static String token = '';
  static String? fcmToken = '';
  static String loginName = '';
  static  String tradeType = '';
}

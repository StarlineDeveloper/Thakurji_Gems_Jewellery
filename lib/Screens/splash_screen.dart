import 'dart:async';
import 'package:thakurji_jems/Services/common_service.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:store_redirect/store_redirect.dart';
import '../Constants/app_colors.dart';
import '../Constants/constant.dart';
import '../Constants/images.dart';
import '../Functions.dart';
import '../Routes/page_route.dart';
import '../Services/notification_service.dart';
import '../Services/socket_service.dart';
import 'dart:io';
import '../Utils/shared.dart';
import '../Widgets/custom_text.dart';
import 'home_screen.dart';
import 'otr_screen.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = PageRoutes.splash;

  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Timer timer;
  Shared shared = Shared();
  var appVersion = '';
  bool isInternetConnected = false;
  bool _isSecondTime = false;
  String deviceType = '';
  Services services = Services();

  @override
  void initState() {
    super.initState();
    SocketService.getLiveRateData(context);
    final notificationService = NotificationService();
    listenToNotificationStream(notificationService);
    notificationService.getFCMToken();

    getVersion();
    // startTimer();
  }

  void getVersion() async {
    bool isConnected = await Functions.checkConnectivity();
    if (isConnected) {
      try {
        PackageInfo info = await PackageInfo.fromPlatform();
        String deviceType = Platform.isAndroid ? 'android' : 'ios';
        setState(() {
          deviceType = Platform.isAndroid ? 'android' : 'ios';
          appVersion = info.version;
        });

        final response = await services.getDeviceVersion(deviceType);
        if (response.code == 200) {
          var chekis = response.data[0]['version'];
          if (chekis.trim().isNotEmpty) {
            var apiVersion = double.parse(chekis);
            var deviceAppVersion = double.parse(appVersion);
            if (deviceAppVersion < apiVersion) {
              showUpdateDialog();
            } else {
              startTimer();
            }
          } else {
            startTimer();
          }
        } else {
          print('Error occurred while fetching device version:');
        }
      } catch (e) {
        print('Error: $e');
      }
    } else {
      startTimer();
      // Functions.showToast(Constants.noInternet);
    }
  }

  // void callForIOS() async {
  //   String objVariable = json.encode({"ClientId": Constants.clientId});
  //   List<String> fieldList = [
  //     '<?xml version="1.0" encoding="utf-8"?>',
  //     '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">',
  //     '<soap:Body>',
  //     '<GetVersionApple xmlns="http://tempuri.org/">',
  //     '<Obj>$objVariable</Obj>',
  //     '</GetVersionApple>',
  //     '</soap:Body>',
  //     '</soap:Envelope>'
  //   ];
  //   var envelope = fieldList.map((v) => v).join();
  //
  //   http.Response response = await http.post(Uri.parse(Constants.baseUrl),
  //       headers: {
  //         "Content-Type": "text/xml; charset=utf-8",
  //         "SOAPAction": "http://tempuri.org/GetVersionApple",
  //         "Host": "starlinebuild.co.in"
  //         //"Accept": "text/xml"
  //       },
  //       body: envelope);
  //
  //   var rawXmlResponse = response.body;
  //   XmlDocument parsedXml = XmlDocument.parse(rawXmlResponse);
  //
  //   var chekis = parsedXml.text;
  //   if (chekis.trim().isNotEmpty) {
  //     var apiVersion = double.parse(chekis);
  //     var deviceAppVersion = double.parse(appVersion);
  //     if (deviceAppVersion < apiVersion) {
  //       showUpdateDialog();
  //     } else {
  //       startTimer();
  //     }
  //   } else {
  //     startTimer();
  //   }
  // }
  //
  // void callForAndroid() async {
  //   String objVariable = json.encode({"ClientId": Constants.clientId});
  //
  //   List<String> fieldList = [
  //     '<?xml version="1.0" encoding="utf-8"?>',
  //     '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">',
  //     '<soap:Body>',
  //     '<GetVersionAndroid xmlns="http://tempuri.org/">',
  //     '<Obj>$objVariable</Obj>',
  //     '</GetVersionAndroid>',
  //     '</soap:Body>',
  //     '</soap:Envelope>'
  //   ];
  //   var envelope = fieldList.map((v) => v).join();
  //
  //   http.Response response = await http.post(Uri.parse(Constants.baseUrl),
  //       headers: {
  //         "Content-Type": "text/xml; charset=utf-8",
  //         "SOAPAction": "http://tempuri.org/GetVersionAndroid",
  //         "Host": "starlinesolutions.in"
  //         //"Accept": "text/xml"
  //       },
  //       body: envelope);
  //
  //   var rawXmlResponse = response.body;
  //   XmlDocument parsedXml = XmlDocument.parse(rawXmlResponse);
  //
  //   var chekis = parsedXml.text;
  //   if (chekis.trim().isNotEmpty) {
  //     var apiVersion = double.parse(chekis);
  //     var deviceAppVersion = double.parse(appVersion);
  //     if (deviceAppVersion < apiVersion) {
  //       showUpdateDialog();
  //     } else {
  //       startTimer();
  //     }
  //   } else {
  //     startTimer();
  //   }
  // }

  void listenToNotificationStream(NotificationService notificationService) {
    notificationService.behaviorSubject.listen((payload) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    });
  }

  @override
  void didUpdateWidget(SplashScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  showUpdateDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) {
        var size = MediaQuery.of(context).size;
        return Dialog(
          // backgroundColor: AppColors.hintColorLight,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0)), //this right here
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.textColor,
              borderRadius: BorderRadius.all(Radius.circular(10)),
              border: Border.all(
                color: AppColors.secondaryColor,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: Image.asset(
                    AppImagePath.headerLogo,
                    width: 150,
                    height: 100,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 15.0),
                  child: CustomText(
                    text: 'App Update Required!',
                    textColor: AppColors.secondaryColor,
                    fontWeight: FontWeight.bold,
                    size: 18,
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: CustomText(
                      text:
                          'New version is available, please update now for exploring best features of ${Constants.alertAndCnfTitle.toUpperCase()}',
                      size: 15.0,
                      textColor: AppColors.defaultColor,
                      fontWeight: FontWeight.normal,
                      noOfLines: 3,
                      align: TextAlign.center,
                    )),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    child: Container(
                        height: size.width * 0.11,
                        decoration: BoxDecoration(
                          color: AppColors.secondaryColor,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        alignment: Alignment.center,
                        child: const CustomText(
                            text: 'Update',
                            size: 15.0,
                            textColor: AppColors.defaultColor,
                            fontWeight: FontWeight.bold)),
                    onTap: () {
                      StoreRedirect.redirect(
                        androidAppId: Constants.androidAppRateAndUpdate,
                        iOSAppId: Constants.iOSAppId,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.defaultColor,
      body: Container(


        decoration: const BoxDecoration(
          // color: AppColors.textColor,
        // gradient: AppColors.secondaryGradient
        ),
        child: Center(
          child: Image.asset(
            AppImagePath.splashImage,
            scale: 4.5,
          ),
        ),
      ),
    );
  }

  void startTimer() {
    timer = Timer(const Duration(seconds: 0), navigateUser);
  }

  void navigateUser() {
    //Comment below line if without OTR
    Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
    //UnComment below code with OTR
    // checkIfSecondTime();
  }

Future<void> checkIfSecondTime() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isFirstTime = prefs.getBool('isFirstTime') ?? true;
  if (!isFirstTime) {
    setState(() {
      _isSecondTime = true;
    });
  }
  await prefs.setBool('isFirstTime', false);
  if (Platform.isIOS){
    if(_isSecondTime){
      shared.getIsFirstTimeRegister().then((isFirstTime) {
        if (!isFirstTime) {
          Navigator.of(context).pushReplacementNamed(Otr_Screen.routeName,);
        } else {
          Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
        }
      });
    }else{
      Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
    }
  }else {
    shared.getIsFirstTimeRegister().then((isFirstTime) {
      if (!isFirstTime) {
        Navigator.of(context).pushReplacementNamed(Otr_Screen.routeName,);
      } else {
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
      }
    });
  }
}
}

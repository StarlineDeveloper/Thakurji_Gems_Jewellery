// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:io';

// import 'package:app_settings/app_settings.dart';
import 'package:thakurji_jems/Screens/update_screen.dart';
import 'package:app_settings/app_settings.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';

// import 'package:in_app_review/in_app_review.dart';
import 'package:marquee/marquee.dart';
import 'package:notification_permissions/notification_permissions.dart';
import 'package:open_settings_plus/core/open_settings_plus.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Constants/app_colors.dart';
import '../Constants/constant.dart';
import '../Constants/images.dart';
import '../Constants/notify_socket_update.dart';
import '../Functions.dart';
import '../Models/client_header.dart';
import '../Popup/alert_confirm_popup.dart';
import '../Providers/liveRate_Provider.dart';
import '../Routes/page_route.dart';
import '../Services/notification_service.dart';
import '../Services/socket_service.dart';
import '../Utils/shared.dart';
import '../Widgets/custom_text.dart';
import 'bankdetails_screen.dart';
import 'contactus_screen.dart';
import 'economiccalender_scree.dart';
import 'liverate_screen.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = PageRoutes.homescreen;

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  late Future<String> permissionStatusFuture;
  var permGranted = "granted";
  var permDenied = "denied";
  var permUnknown = "unknown";
  var permProvisional = "provisional";
  int selectedIndex = 0;
  double left = 10;
  double bottom1 = 100;
  double right = 10;
  double bottom2 = 100;
  late LiveRateProvider _liverateProvider;
  ClientHeaderData clientHeaderData = ClientHeaderData();
  bool isBannerVisible = false;
  bool isInternetConnected = false;
  bool isAddVisible = true;
  List<Widget> widgetsList = [
    const LiveRateScreen(),
    // const Trade_Screen(),
    const Update_Screen(),
    // const Coin_Screen(),
    const ContactUs_Screen(),
    const BankDetail_Screen(),
    // const EconomicCalenderScreen(),
    // const ProfileScreen()
  ];
  final AdvancedDrawerController _advancedDrawerController =
      AdvancedDrawerController();
  DateTime? currentBackPressTime;
  DateTime now = DateTime.now();
  List<String> bookingNumber = [];
  bool isLoading = false;
  bool isDiscoveredOverlay = false;
  Shared shared = Shared();
  late NotificationService notificationService;
  int tapCount = 0;
  int lastTap = 0;

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    notificationService = NotificationService();
    permissionStatusFuture = getCheckNotificationPermStatus();

    if (!mounted) {
      return;
    }
    WidgetsBinding.instance.addObserver(this);
    // checkDiscovered();
    notificationService.initializePlatformNotifications();
    _liverateProvider = Provider.of<LiveRateProvider>(context, listen: false);

    NotificationPermissions.requestNotificationPermissions(
            iosSettings: const NotificationSettingsIos(
                sound: true, badge: true, alert: true))
        .then((_) {
      // when finished, check the permission status
      setState(() {
        permissionStatusFuture = getCheckNotificationPermStatus();
      });
    });

    loadLiveData();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('${message.data}');
      debugPrint('${message.senderId}');
      if (message.data['bit'] == '1') {
        showNotificationAlertDialog(
          message.data['title'],
          message.data['body'],
          message.data['bit'],
        );
      }

      if (!Platform.isIOS) {
        NotificationService().showLocalNotification(
            body: message.data['title'],
            title: message.data['body'],
            payload: 'Hello');
      }
    });
    // listenToNotificationStream();
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? message) {
      debugPrint('Opened');
      if (message != null) {
        if (message.data['bit'] == '1') {
          onItemTapped(2);
        } else {
          onItemTapped(0);
        }
      }
    });
    //on open notification while in kill mode
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        if (message.data['bit'] == '1') {
          onItemTapped(2);
        } else {
          onItemTapped(0);
        }
      }
    });

    // callGetOpenOrderDetailsApi();
    initStreamControllers();
    initConnectivityListener();
    // checkForInAppReview();
  }

  void initStreamControllers() {
    NotifySocketUpdate.controllerHome = StreamController.broadcast();

    NotifySocketUpdate.controllerHome!.stream.listen((event) {
      loadLiveData();
    });
  }

  void initConnectivityListener() {
    Connectivity().onConnectivityChanged.listen((connection) {
      if (connection == ConnectivityResult.none) {
        setState(() {
          isInternetConnected = false;
        });
      } else {
        setState(() {
          isInternetConnected = true;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<String> getCheckNotificationPermStatus() {
    return NotificationPermissions.getNotificationPermissionStatus()
        .then((status) {
      switch (status) {
        case PermissionStatus.denied:
          return permDenied;
        case PermissionStatus.granted:
          return permGranted;
        case PermissionStatus.unknown:
          return permUnknown;
        case PermissionStatus.provisional:
          return permProvisional;
        default:
          return permUnknown;
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
        debugPrint('appLifeCycleState inactive');
        break;
      case AppLifecycleState.resumed:
        debugPrint('appLifeCycleState resumed');
        setState(() {
          permissionStatusFuture = getCheckNotificationPermStatus();
        });
        // handleResumedState();
        break;
      case AppLifecycleState.paused:
        debugPrint('appLifeCycleState paused');
        break;
      case AppLifecycleState.detached:
        // shared.setisAddBannerVisible(false);
        // bool isAddVisible
        debugPrint('appLifeCycleState detached');
        break;
      case AppLifecycleState.hidden:
      // TODO: Handle this case.
    }
  }

  loadLiveData() async {
    setState(() {
      clientHeaderData = _liverateProvider.getClientHeaderData();
    });

    _liverateProvider.bannerImage!.trim().isNotEmpty
        ? isAddVisible
            ? setState(() {
                isBannerVisible = true;
                isAddVisible = false;
              })
            : null
        : setState(() {
            isAddVisible = true;
          });
    if (clientHeaderData.number1 != null &&
        clientHeaderData.number1!.trim().isNotEmpty) {
      bookingNumber.add(clientHeaderData.number1!);
    }
    if (clientHeaderData.number2 != null &&
        clientHeaderData.number2!.trim().isNotEmpty) {
      bookingNumber.add(clientHeaderData.number2!);
    }
    if (clientHeaderData.number3 != null &&
        clientHeaderData.number3!.trim().isNotEmpty) {
      bookingNumber.add(clientHeaderData.number3!);
    }
    if (clientHeaderData.number4 != null &&
        clientHeaderData.number4!.trim().isNotEmpty) {
      bookingNumber.add(clientHeaderData.number4!);
    }
    if (clientHeaderData.number5 != null &&
        clientHeaderData.number5!.trim().isNotEmpty) {
      bookingNumber.add(clientHeaderData.number5!);
    }
    if (clientHeaderData.number6 != null &&
        clientHeaderData.number6!.trim().isNotEmpty) {
      bookingNumber.add(clientHeaderData.number6!);
    }
    if (clientHeaderData.number7 != null &&
        clientHeaderData.number7!.trim().isNotEmpty) {
      bookingNumber.add(clientHeaderData.number7!);
    }
  }

  @override
  void dispose() {
    NotifySocketUpdate.controllerHome!.close();

    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _handleMenuButtonPressed() {
    _advancedDrawerController.showDrawer();
  }

  closeDrawer() {
    if (scaffoldKey.currentState != null) {
      _advancedDrawerController.hideDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AdvancedDrawer(
      // backdropColor: AppColor.defaultColor,
      controller: _advancedDrawerController,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 200),
      animateChildDecoration: true,
      rtlOpening: false,
      openRatio: 0.55,
      disabledGestures: true,
      childDecoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(12),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.primaryColor,
            offset: Offset(1.0, 0.0),
            blurRadius: 10.0,
            spreadRadius: 5.0,
          ),
        ],
      ),
      drawer: buildAppDrawer(),
      child: Stack(
        alignment: AlignmentDirectional.bottomStart,
        children: [
          Scaffold(
            backgroundColor: AppColors.defaultColor,
            // onDrawerChanged: (isOpened) {
            //   checkIsLogin();
            // },
            key: scaffoldKey,
            // backgroundColor: AppColor.defaultColor,
            appBar: AppBar(
              titleSpacing: 0,

              // systemOverlayStyle:
              //     SystemUiOverlayStyle(statusBarColor: AppColor.primaryColor),
              backgroundColor: AppColors.defaultColor,
              // automaticallyImplyLeading: false,
              toolbarHeight: 60,

                // flexibleSpace: Container(
              //   decoration:
              //       BoxDecoration(gradient: AppColors.secondaryGradient),
              // ),
              // elevation: 5.0,
              iconTheme: const IconThemeData(color: AppColors.primaryColor),
              title: Image.asset(
                AppImagePath.headerLogo,
                  height:
                  AppBar().preferredSize.height * 0.9
              ),
              centerTitle: true,
              leading: IconButton(
                onPressed: _handleMenuButtonPressed,
                icon: ValueListenableBuilder<AdvancedDrawerValue>(
                  valueListenable: _advancedDrawerController,
                  builder: (_, value, __) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Icon(
                        value.visible
                            ? Icons.menu_open_rounded
                            : Icons.menu_rounded,
                        key: ValueKey<bool>(value.visible),
                        color: AppColors.primaryTextColor,
                        size: 25.0,
                      ),
                    );
                  },
                ),
              ),
            ),
            // drawer: buildAppDrawer(),
            body: Container(
              // color: AppColors.bg,
              // decoration: BoxDecoration(
              //   // color:
              //   image: DecorationImage(
              //     image: AssetImage(AppImagePath.bg),
              //     fit: BoxFit.cover,
              //   ),
              // ),
              child: buildBody(size),
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                // gradient: AppColors.secondaryGradient,
              ),
              child: BottomNavigationBar(
                currentIndex: selectedIndex,
                showUnselectedLabels: true,
                type: BottomNavigationBarType.fixed,
                backgroundColor: AppColors.defaultColor,
                selectedItemColor: AppColors.primaryTextColor,
                unselectedItemColor: AppColors.secondaryColor,
                selectedLabelStyle: TextStyle(
                  fontSize: 12,
                ),
                unselectedLabelStyle: TextStyle(fontSize: 12),
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.bar_chart_rounded,
                      // color: selectedIndex == 0
                      //     ? AppColors.primaryColor
                      //     : AppColors.secondaryTextColor,
                      size: 24,
                    ),
                    label: 'Live Rate',
                    backgroundColor: AppColors.primaryColor,
                  ),
                  // BottomNavigationBarItem(
                  //   icon: Icon(
                  //     Icons.post_add_rounded,
                  //     color: selectedIndex == 1
                  //         ? AppColors.primaryColor
                  //         : AppColors.secondaryTextColor,
                  //     size: 24,
                  //   ),
                  //   label: 'Trade',
                  //   backgroundColor: AppColors.primaryColor,
                  // ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.notification_add_rounded,
                      // color: selectedIndex == 1
                      //     ? AppColors.primaryColor
                      //     : AppColors.secondaryTextColor,
                      size: 24,
                    ),
                    label: 'Updates',
                    backgroundColor: AppColors.primaryColor,
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.contact_phone_rounded,
                      // color: selectedIndex == 2
                      //     ? AppColors.primaryColor
                      //     : AppColors.secondaryTextColor,
                      size: 24,
                    ),
                    label: 'Contact',
                    backgroundColor: AppColors.primaryColor,
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.account_balance_rounded,
                      // color: selectedIndex == 3
                      //     ? AppColors.primaryColor
                      //     : AppColors.secondaryTextColor,
                      size: 24,
                    ),
                    label: 'Bank',
                    backgroundColor: AppColors.primaryColor,
                  ),
                ],
                onTap: (index) {
                  onItemTapped(index);
                },
              ),
            ),
          ),
          Visibility(
            visible: isBannerVisible,
            child: Container(
              color: AppColors.textColor.withOpacity(.7),
              child: Center(
                child: Stack(
                  // mainAxisSize: MainAxisSize.max,
                  alignment: Alignment.center,
                  children: <Widget>[
                    Center(
                      child: Image.network(
                        _liverateProvider.bannerImage!.trim(),
                        height: size.height * .7,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: SizedBox(
                          width: size.width * .6,
                          // margin: const EdgeInsets.only(bottom: .01),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondaryColor,
                              padding: EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: const CustomText(
                              text: 'Skip',
                              size: 16.0,
                              textColor: AppColors.defaultColor,
                              fontWeight: FontWeight.bold,
                            ),
                            onPressed: () {
                              setState(() {
                                isBannerVisible = false;
                                isAddVisible = false;
                                // shared.setisAddBannerVisible(false);
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: left,
            bottom: bottom1,
            child: GestureDetector(
              onTap: () {
                showCallDialog();
              },
              onPanUpdate: (dragDetails) {
                setState(() {
                  left += dragDetails.delta.dx;
                  bottom1 -= dragDetails.delta.dy;
                });
              },
              child: Container(
                // heroTag: 'call1',
                padding: const EdgeInsets.all(10.0),
                decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    // color: AppColors.primaryColor,
                    gradient: AppColors.primaryGradient),
                child: const Icon(
                  Icons.call,
                  color: AppColors.defaultColor,
                  size: 30.0,
                ),
              ),
            ),
          ),
          Positioned(
            right: right,
            bottom: bottom2,
            child: GestureDetector(
              onTap: () {
                openWhatsapp();
              },
              onPanUpdate: (dragDetails) {
                setState(() {
                  right -= dragDetails.delta.dx;
                  bottom2 -= dragDetails.delta.dy;
                });
              },
              child: Container(
                // heroTag: 'call1',
                padding: const EdgeInsets.all(10.0),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,

                  // color: AppColors.primaryColor,
                ),
                child: Image.asset(
                  AppImagePath.whatsapp,
                  scale: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  buildAppDrawer() {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
                color: AppColors.transparent,
                // gradient: AppColors.secondaryGradient,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12))),
            height: 160.0,
            alignment: Alignment.center,
            child: const Center(
              child: Image(
                image: AssetImage(AppImagePath.drawerLogo),
                height: 130.0,
                width: 130.0,
              ),
            ),
          ),
          const Divider(
            // height: 10.0,
            color: AppColors.primaryColor,
            thickness: .5,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 3.0),
                child: Column(
                  children: [
                    Container(
                      decoration: ShapeDecoration(
                        color: selectedIndex == 0
                            ? AppColors.secondaryLightColor.withOpacity(0.5)
                            : Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        // shadows: const [AppColor.boxShadow],
                      ),
                      child: ListTile(
                          minLeadingWidth: 10,
                          onTap: () {
                            setState(() {
                              selectedIndex = 0;
                            });
                            closeDrawer();
                            // Navigator.of(context).pop();
                          },
                          leading: Icon(
                            Icons.bar_chart_rounded,
                            color: selectedIndex == 0
                                ? AppColors.primaryColor
                                : AppColors.primaryColor,
                            size: 24,
                          ),
                          title: CustomText(
                              text: 'Live Rate',
                              size: 16,
                              textColor: selectedIndex == 0
                                  ? AppColors.primaryColor
                                  : AppColors.primaryColor,
                              fontWeight: FontWeight.normal)),
                    ),
                    // Container(
                    //   decoration: ShapeDecoration(
                    //     color: selectedIndex == 1
                    //         ? AppColors.primaryLightColor
                    //         : Colors.transparent,
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(30.0),
                    //     ),
                    //     //shadows: const [AppColor.boxShadow],
                    //   ),
                    //   child: ListTile(
                    //       onTap: () {
                    //         setState(() {
                    //           selectedIndex = 1;
                    //         });
                    //         closeDrawer();
                    //
                    //         // Navigator.of(context).pop();
                    //       },
                    //       leading: Icon(
                    //         Icons.post_add_rounded,
                    //         color: selectedIndex == 1
                    //             ? AppColors.primaryColor
                    //             : AppColors.primaryColor,
                    //         size: 24,
                    //       ),
                    //       title: CustomText(
                    //           text: 'Trade',
                    //           size: 16,
                    //           textColor: selectedIndex == 1
                    //               ? AppColors.primaryColor
                    //               : AppColors.primaryColor,
                    //           fontWeight: FontWeight.normal)),
                    // ),
                    Container(
                      decoration: ShapeDecoration(
                        color: selectedIndex == 1
                            ? AppColors.secondaryLightColor.withOpacity(0.5)
                            : Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        //shadows: const [AppColor.boxShadow],
                      ),
                      child: ListTile(
                          minLeadingWidth: 10,
                          onTap: () {
                            setState(() {
                              selectedIndex = 1;
                            });
                            closeDrawer();
                          },
                          leading: Icon(
                            Icons.notification_add_rounded,
                            color: selectedIndex == 1
                                ? AppColors.primaryColor
                                : AppColors.primaryColor,
                            size: 24,
                          ),
                          title: CustomText(
                              text: 'Updates',
                              size: 16,
                              textColor: selectedIndex == 1
                                  ? AppColors.primaryColor
                                  : AppColors.primaryColor,
                              fontWeight: FontWeight.normal)
                          // Text(
                          //   textScaleFactor: 1.0,
                          //   'Updates',
                          //   style: TextStyle(
                          //     color: selectedIndex == 2
                          //         ? AppColor.primaryColor
                          //         : AppColor.primaryColor,
                          //     fontSize: 16.0,
                          //   ),
                          // ),
                          ),
                    ),
                    // Container(
                    //   decoration: ShapeDecoration(
                    //     color: selectedIndex == 3
                    //         ? AppColors.primaryLightColor
                    //         : Colors.transparent,
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(30.0),
                    //     ),
                    //     // shadows: const [AppColor.boxShadow],
                    //   ),
                    //   child: ListTile(
                    //       onTap: () {
                    //         setState(() {
                    //           selectedIndex = 3;
                    //         });
                    //         closeDrawer();
                    //         // Navigator.of(context)
                    //         //     .pushNamed(Coin_Screen.routeName);
                    //       },
                    //       leading: Icon(
                    //         Icons.currency_bitcoin_rounded,
                    //         color: selectedIndex == 3
                    //             ? AppColors.primaryColor
                    //             : AppColors.primaryColor,
                    //         size: 24,
                    //       ),
                    //       title: CustomText(
                    //           text: 'Coins',
                    //           size: 16,
                    //           textColor: selectedIndex == 3
                    //               ? AppColors.primaryColor
                    //               : AppColors.primaryColor,
                    //           fontWeight: FontWeight.normal)),
                    // ),
                    Container(
                      decoration: ShapeDecoration(
                        color: selectedIndex == 2
                            ? AppColors.secondaryLightColor.withOpacity(0.5)
                            : Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        // shadows: const [AppColor.boxShadow],
                      ),
                      child: ListTile(
                          minLeadingWidth: 10,
                          onTap: () {
                            setState(() {
                              selectedIndex = 2;
                            });
                            closeDrawer();
                          },
                          leading: Icon(
                            Icons.contact_phone_rounded,
                            color: selectedIndex == 2
                                ? AppColors.primaryColor
                                : AppColors.primaryColor,
                            size: 24,
                          ),
                          title: CustomText(
                              text: 'Contact Us',
                              size: 16,
                              textColor: selectedIndex == 2
                                  ? AppColors.primaryColor
                                  : AppColors.primaryColor,
                              fontWeight: FontWeight.normal)),
                    ),
                    Container(
                      decoration: ShapeDecoration(
                        color: selectedIndex == 3
                            ? AppColors.secondaryLightColor.withOpacity(0.5)
                            : Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        //shadows: const [AppColor.boxShadow],
                      ),
                      child: ListTile(
                          minLeadingWidth: 10,
                          onTap: () {
                            setState(() {
                              selectedIndex = 3;
                            });
                            closeDrawer();
                          },
                          leading: Icon(
                            Icons.account_balance_rounded,
                            color: selectedIndex == 3
                                ? AppColors.primaryColor
                                : AppColors.primaryColor,
                            size: 24,
                          ),
                          title: CustomText(
                              text: 'Bank Details',
                              size: 16,
                              textColor: selectedIndex == 3
                                  ? AppColors.primaryColor
                                  : AppColors.primaryColor,
                              fontWeight: FontWeight.normal)),
                    ),
                    Container(
                      decoration: ShapeDecoration(
                        color: selectedIndex == 6
                            ? AppColors.secondaryLightColor.withOpacity(0.5)
                            : Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        // shadows: const [AppColor.boxShadow],
                      ),
                      child: ListTile(
                          minLeadingWidth: 10,
                          onTap: () {
                            // setState(() {
                            //   selectedIndex = 6;
                            // });
                            // closeDrawer();
                            Navigator.of(context)
                                .pushNamed(EconomicCalenderScreen.routeName);
                            closeDrawer();
                          },
                          leading: Icon(
                            Icons.calendar_month_rounded,
                            color: selectedIndex == 6
                                ? AppColors.primaryColor
                                : AppColors.primaryColor,
                            size: 24,
                          ),
                          title: CustomText(
                              text: 'Eco-Calender',
                              size: 16,
                              textColor: selectedIndex == 6
                                  ? AppColors.primaryColor
                                  : AppColors.primaryColor,
                              fontWeight: FontWeight.normal)),
                    ),
                    // Container(
                    //   decoration: ShapeDecoration(
                    //     color: selectedIndex == 7
                    //         ? AppColors.primaryLightColor
                    //         : Colors.transparent,
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(30.0),
                    //     ),
                    //     //  shadows: const [AppColor.boxShadow],
                    //   ),
                    //   child: Visibility(
                    //     visible: Constants.isLogin,
                    //     child: ListTile(
                    //         onTap: () {
                    //           // setState(() {
                    //           //   selectedIndex = 7;
                    //           // });
                    //
                    //           // closeDrawer();
                    //           Navigator.of(context)
                    //               .pushNamed(ProfileScreen.routeName);
                    //           closeDrawer();
                    //         },
                    //         leading: Icon(
                    //           Icons.file_copy_rounded,
                    //           color: AppColors.primaryColor,
                    //           size: 24,
                    //         ),
                    //         title: CustomText(
                    //             text: 'Profile',
                    //             size: 16,
                    //             textColor: AppColors.primaryColor,
                    //             fontWeight: FontWeight.normal)),
                    //   ),
                    // ),
                    ListTile(
                        minLeadingWidth: 10,
                        onTap: () async {
                          Platform.isIOS
                              ? Share.share(Constants.iOSAppRedirect)
                              : Share.share(Constants.androidAppStoreRedirect);
                        },
                        leading: Icon(
                          Icons.share_sharp,
                          color: AppColors.primaryColor,
                          size: 24,
                        ),
                        title: CustomText(
                            text: 'Share',
                            size: 16,
                            textColor: AppColors.primaryColor,
                            fontWeight: FontWeight.normal)),
                    ListTile(
                        minLeadingWidth: 10,
                        onTap: () {
                          StoreRedirect.redirect(
                            androidAppId: Constants.androidAppRateAndUpdate,
                            iOSAppId: Constants.iOSAppId,
                          );
                          closeDrawer();
                        },
                        leading: Icon(
                          Icons.star_rate_rounded,
                          color: AppColors.primaryColor,
                          size: 24,
                        ),
                        title: CustomText(
                            text: 'Rate App',
                            size: 16,
                            textColor: AppColors.primaryColor,
                            fontWeight: FontWeight.normal)),
                    // Visibility(
                    //   visible: Constants.isLogin,
                    //   child: ListTile(
                    //       onTap: () {
                    //         openLogoutPopup();
                    //       },
                    //       leading: Icon(
                    //         Icons.logout_rounded,
                    //         color: AppColors.primaryColor,
                    //         size: 24,
                    //       ),
                    //       title: CustomText(
                    //           text: 'Logout',
                    //           size: 16,
                    //           textColor: AppColors.primaryColor,
                    //           fontWeight: FontWeight.normal)),
                    // ),
                    // Visibility(
                    //   visible: !Constants.isLogin,
                    //   child: ListTile(
                    //       onTap: () {
                    //         closeDrawer();
                    //         Navigator.of(context).pushNamed(
                    //           Login_Screen.routeName,
                    //           arguments: const Login_Screen(
                    //             isFromSplash: false,
                    //           ),
                    //         );
                    //       },
                    //       leading: Icon(
                    //         Icons.login_rounded,
                    //         color: AppColors.primaryColor,
                    //         size: 24,
                    //       ),
                    //       title: CustomText(
                    //           text: 'Login',
                    //           size: 16,
                    //           textColor: AppColors.primaryColor,
                    //           fontWeight: FontWeight.normal)),
                    // ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  openLogoutPopup() {
    return DialogUtil.showConfirmDialog(context,
        title: Constants.alertAndCnfTitle,
        content: 'Are you sure you want to logout?',
        okBtnText: 'Logout',
        cancelBtnText: 'Cancel',
        okBtnFunctionConfirm: onLogout,
        isVisible: false);
  }

  onLogout() {
    Navigator.of(context).pop();

    shared.clear();
    if (selectedIndex == 0) {
      Constants.isLogin = false;
      closeDrawer();
      // Navigator.of(context).pop();
    }
    setState(() {
      onItemTapped(0);
      selectedIndex == 0;
      closeDrawer();
      // Navigator.of(context).pop();
    });
  }

  buildBody(Size size) {
    return WillPopScope(
      onWillPop: () {
        DialogUtil.showConfirmDialog(context,
            title: Constants.alertAndCnfTitle,
            content: 'Are you sure you want to exit app?',
            okBtnText: 'Exit',
            cancelBtnText: 'Cancel',
            okBtnFunctionConfirm: onExit,
            isVisible: false);
        return Future.value(false);
      },
      child: Stack(
        children: [
          Column(
            children: [
              Visibility(
                visible: clientHeaderData.marqueeTop != null &&
                    clientHeaderData.marqueeTop!.isNotEmpty,
                child: Container(
                  height: 25.0,
                  decoration: BoxDecoration(
                      // gradient: AppColors.primaryGradient
                      color: AppColors.secondaryColor),
                  child: Marquee(
                    textScaleFactor: 1.0,
                    text: clientHeaderData.marqueeTop != null
                        ? clientHeaderData.marqueeTop!.trim()
                        : 'No Marquee Found',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.defaultColor),
                    scrollAxis: Axis.horizontal,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    blankSpace: 400.0,
                    velocity: 40.0,
                    pauseAfterRound: const Duration(milliseconds: 10),
                    startPadding: 10.0,
                    accelerationDuration: const Duration(seconds: 1),
                    accelerationCurve: Curves.linear,
                    decelerationDuration: const Duration(milliseconds: 500),
                    decelerationCurve: Curves.easeOut,
                  ),
                ),
              ),
              widgetsList.elementAt(selectedIndex),
              Visibility(
                visible: clientHeaderData.marqueeBottom != null &&
                    clientHeaderData.marqueeBottom!.isNotEmpty,
                child: Container(
                  height: 25.0,
                  decoration: BoxDecoration(color: AppColors.secondaryColor
                      // gradient: AppColors.primaryGradient

                      ),
                  child: Marquee(
                    textScaleFactor: 1.0,
                    text: clientHeaderData.marqueeBottom != null
                        ? clientHeaderData.marqueeBottom!.trim()
                        : 'No Marquee Found',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.defaultColor),
                    scrollAxis: Axis.horizontal,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    blankSpace: 400.0,
                    velocity: 40.0,
                    pauseAfterRound: const Duration(milliseconds: 10),
                    startPadding: 10.0,
                    accelerationDuration: const Duration(seconds: 1),
                    accelerationCurve: Curves.linear,
                    decelerationDuration: const Duration(milliseconds: 500),
                    decelerationCurve: Curves.easeOut,
                  ),
                ),
              ),
              // SizedBox(height: 5,)
              // Divider(
              //   height: 1.5,
              //   color: AppColors.secondaryColor,
              // )
            ],
          ),
          Visibility(
            visible: !isInternetConnected,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(AppImagePath.nointernet),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                      onTap: () {
                        turnOnInternet();
                      },
                      child: Container(
                        height: 45.0,
                        width: (size.width) - 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          // color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: CustomText(
                          text: 'Try Again',
                          size: 15.0,
                          fontWeight: FontWeight.bold,
                          textColor: AppColors.defaultColor,
                          align: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  showNotificationAlertDialog(String title, String body, String bit) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) {
        var size = MediaQuery.of(context).size;
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0)), //this right here
          child: Container(
            // color: AppColors.primaryColor,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.secondaryColor),
              color: AppColors.defaultColor,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: size.width * 0.15,
                  width: size.width,
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: const Image(
                      image: AssetImage(AppImagePath.headerLogo),
                      // height: 50.0,
                      // width: 50.0,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Divider(
                    thickness: 1,
                    color: AppColors.secondaryColor,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomText(
                    text: title,
                    align: TextAlign.center,
                    fontWeight: FontWeight.bold,
                    textColor: AppColors.primaryTextColor,
                    noOfLines: 2,
                    size: 15.0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomText(
                    text: body,
                    noOfLines: 3,
                    align: TextAlign.center,
                    fontWeight: FontWeight.w500,
                    textColor: AppColors.textColor,
                    size: 15.0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    child: Container(
                      height: size.width * 0.11,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        // gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      alignment: Alignment.center,
                      child: CustomText(
                        text: 'Ok',
                        fontWeight: FontWeight.bold,
                        textColor: AppColors.textColor,
                        size: 15.0,
                      ),
                    ),
                    onTap: () {
                      onNotificationClick(bit);
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

  onNotificationClick(String bit) {
    if (bit == '1') {
      onItemTapped(1);
    } else {
      onItemTapped(0);
    }
    Navigator.of(context).pop();
  }

  showCallDialog() {
    showDialog(
      context: context,
      builder: (builder) {
        return AlertDialog(
          // decoration: BoxDecoration(
          //   borderRadius: BorderRadius.circular(12.0),
          //   color: AppColors.textColorLight,
          //   border: Border.all(
          //     color:Colors.grey,
          //   ),
          // ),
          backgroundColor: AppColors.defaultColor,
          shape: RoundedRectangleBorder(
              side:  BorderSide(color: AppColors.secondaryColor, width: 1.0),
              borderRadius: BorderRadius.all(Radius.circular(8.0))),
          actions: [
            Visibility(
              visible: (clientHeaderData.number1 != null &&
                          clientHeaderData.number1!.trim().isNotEmpty) &&
                      (clientHeaderData.number2 != null &&
                          clientHeaderData.number2!.trim().isNotEmpty) &&
                      (clientHeaderData.number3 != null &&
                          clientHeaderData.number3!.trim().isNotEmpty) &&
                      (clientHeaderData.number4 != null &&
                          clientHeaderData.number4!.trim().isNotEmpty) &&
                      (clientHeaderData.number5 != null &&
                          clientHeaderData.number5!.trim().isNotEmpty) &&
                      (clientHeaderData.number6 != null &&
                          clientHeaderData.number6!.trim().isNotEmpty) &&
                      (clientHeaderData.number7 != null &&
                          clientHeaderData.number7!.trim().isNotEmpty)
                  ? false
                  : true,
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 100,
                    child: Column(
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50.0),
                            border: Border.all(color: Colors.transparent),
                            gradient: AppColors.primaryGradient,
                          ),
                          padding: const EdgeInsets.all(7),
                          margin: const EdgeInsets.all(10),
                          child: Column(
                            children: const <Widget>[
                              Icon(
                                Icons.mobile_screen_share_rounded,
                                color: AppColors.defaultColor,
                                size: 30.0,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(2),
                          width: MediaQuery.of(context).size.width * 100,
                          child: CustomText(
                              text: 'BOOKING NUMBER',
                              fontWeight: FontWeight.bold,
                              textColor: AppColors.secondaryColor,
                              size: 16.0,
                              align: TextAlign.center),
                        ),
                        Visibility(
                          visible: clientHeaderData.number1 == null ||
                                  clientHeaderData.number1!.isEmpty
                              ? false
                              : true,
                          child: GestureDetector(
                            onTap: () {
                              launchUrl(
                                Uri(
                                    scheme: 'tel',
                                    path: Functions.alphaNum(
                                        clientHeaderData.number1!)),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                              width: MediaQuery.of(context).size.width * 100,
                              child: CustomText(
                                  text: clientHeaderData.number1 ?? '',
                                  fontWeight: FontWeight.normal,
                                  textColor: AppColors.textColor,
                                  size: 16.0,
                                  align: TextAlign.center),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: clientHeaderData.number2 == null ||
                                  clientHeaderData.number2!.isEmpty
                              ? false
                              : true,
                          child: GestureDetector(
                            onTap: () {
                              launchUrl(
                                Uri(
                                    scheme: 'tel',
                                    path: Functions.alphaNum(
                                        clientHeaderData.number2!)),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                              width: MediaQuery.of(context).size.width * 100,
                              child: CustomText(
                                  text: clientHeaderData.number2 ?? '',
                                  fontWeight: FontWeight.normal,
                                  textColor: AppColors.textColor,
                                  size: 16.0,
                                  align: TextAlign.center),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: clientHeaderData.number3 == null ||
                                  clientHeaderData.number3!.isEmpty
                              ? false
                              : true,
                          child: GestureDetector(
                            onTap: () {
                              launchUrl(
                                Uri(
                                    scheme: 'tel',
                                    path: Functions.alphaNum(
                                        clientHeaderData.number3!)),
                              );
                            },
                            child: Container(
                                padding: const EdgeInsets.all(2),
                                margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                width: MediaQuery.of(context).size.width * 100,
                                child: CustomText(
                                    text: clientHeaderData.number3 ?? '',
                                    fontWeight: FontWeight.normal,
                                    textColor: AppColors.textColor,
                                    size: 16.0,
                                    align: TextAlign.center)),
                          ),
                        ),
                        Visibility(
                          visible: clientHeaderData.number4 == null ||
                                  clientHeaderData.number4!.isEmpty
                              ? false
                              : true,
                          child: GestureDetector(
                            onTap: () {
                              launchUrl(
                                Uri(
                                    scheme: 'tel',
                                    path: Functions.alphaNum(
                                        clientHeaderData.number4!)),
                              );
                            },
                            child: Container(
                                padding: const EdgeInsets.all(2),
                                margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                width: MediaQuery.of(context).size.width * 100,
                                child: CustomText(
                                    text: clientHeaderData.number4 ?? '',
                                    fontWeight: FontWeight.normal,
                                    textColor: AppColors.textColor,
                                    size: 16.0,
                                    align: TextAlign.center)),
                          ),
                        ),
                        Visibility(
                          visible: clientHeaderData.number5 == null ||
                                  clientHeaderData.number5!.isEmpty
                              ? false
                              : true,
                          child: GestureDetector(
                            onTap: () {
                              launchUrl(
                                Uri(
                                    scheme: 'tel',
                                    path: Functions.alphaNum(
                                        clientHeaderData.number5!)),
                              );
                            },
                            child: Container(
                                padding: const EdgeInsets.all(2),
                                margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                width: MediaQuery.of(context).size.width * 100,
                                child: CustomText(
                                    text: clientHeaderData.number5 ?? '',
                                    fontWeight: FontWeight.normal,
                                    textColor: AppColors.textColor,
                                    size: 16.0,
                                    align: TextAlign.center)),
                          ),
                        ),
                        Visibility(
                          visible: clientHeaderData.number6 == null ||
                                  clientHeaderData.number6!.isEmpty
                              ? false
                              : true,
                          child: GestureDetector(
                            onTap: () {
                              launchUrl(
                                Uri(
                                    scheme: 'tel',
                                    path: Functions.alphaNum(
                                        clientHeaderData.number6!)),
                              );
                            },
                            child: Container(
                                padding: const EdgeInsets.all(2),
                                margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                width: MediaQuery.of(context).size.width * 100,
                                child: CustomText(
                                    text: clientHeaderData.number6 ?? '',
                                    fontWeight: FontWeight.normal,
                                    textColor: AppColors.textColor,
                                    size: 16.0,
                                    align: TextAlign.center)),
                          ),
                        ),
                        Visibility(
                          visible: clientHeaderData.number7 == null ||
                                  clientHeaderData.number7!.isEmpty
                              ? false
                              : true,
                          child: GestureDetector(
                            onTap: () {
                              launchUrl(
                                Uri(
                                    scheme: 'tel',
                                    path: Functions.alphaNum(
                                        clientHeaderData.number7!)),
                              );
                            },
                            child: Container(
                                padding: const EdgeInsets.all(2),
                                margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                width: MediaQuery.of(context).size.width * 100,
                                child: CustomText(
                                    text: clientHeaderData.number7 ?? '',
                                    fontWeight: FontWeight.normal,
                                    textColor: AppColors.textColor,
                                    size: 16.0,
                                    align: TextAlign.center)),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> openWhatsapp() async {
    var whatsapp = "+91${clientHeaderData.whatsAppNo}";
    var whatsappUrlAndroid = "whatsapp://send?phone=$whatsapp&text=";
    // var whatsappUrlIOS = "https://wa.me/$whatsapp?text=''}";
    var whatsappUrlIOS = "whatsapp://wa.me/$whatsapp/?text=";
    var urlIOS = Uri.parse(whatsappUrlIOS);
    var urlAndroid = Uri.parse(whatsappUrlAndroid);
    if (Platform.isIOS) {
      launchUrl(urlIOS).then((isLaunched) {
        if (isLaunched) {
          // Functions.showToast('Whatsapp Launched');
        } else {
          Functions.showToast('Whatsapp not Installed');
        }
      }).catchError(
        (exception) {
          Functions.showToast('Whatsapp not Found');
        },
      );
    }

    if (Platform.isAndroid) {
      launchUrl(urlAndroid).then((isLaunched) {
        if (isLaunched) {
          // Functions.showToast('Whatsapp Launched');
        } else {
          Functions.showToast('Whatsapp not Installed');
        }
      }).catchError((exception) {
        Functions.showToast('Whatsapp not Found');
      });
    }
  }

  void handleResumedState() async {
    try {
      await SocketService.getLiveRateData(context);
    } catch (error) {
      debugPrint('Error in getLiveRateData: $error');
    }
  }

  onExit() {
    return exit(0);
  }

  // Future<void> checkForInAppReview() async {
  //   final InAppReview _inAppReview = InAppReview.instance;
  //
  //   if (await _inAppReview.isAvailable()) {
  //     _inAppReview.requestReview();
  //     // _inAppReview.openStoreListing(appStoreId: Constants.iOSAppId, microsoftStoreId: Constants.androidAppRateAndUpdate);
  //   }
  // }

  void turnOnInternet() {
    var shared = OpenSettingsPlus.shared;
    // switch (shared.runtimeType) {
    //   case OpenSettingsPlusAndroid:
    //     (shared as OpenSettingsPlusAndroid).wifi();
    //     break;
    //   case OpenSettingsPlusIOS:
    //     (shared as OpenSettingsPlusIOS).wifi();
    //     break;
    //   default:
    //     throw Exception('Platform not supported');
    // }
    Platform.isAndroid
        ? AppSettings.openAppSettingsPanel(
            AppSettingsPanelType.internetConnectivity)
        : (shared as OpenSettingsPlusIOS).settings();
  }
}

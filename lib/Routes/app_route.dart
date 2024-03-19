import 'package:thakurji_jems/Screens/otr_screen.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import '../Screens/economiccalender_scree.dart';
import '../Screens/error_screen.dart';
import '../Screens/home_screen.dart';

class AppRoutes {
  Route<dynamic> onGeneratedRoutes(RouteSettings settings) {
    switch (settings.name) {
      case HomeScreen.routeName:
        return PageTransition(
          child: const HomeScreen(),
          type: PageTransitionType.rightToLeft,
          duration: const Duration(milliseconds: 300),
          reverseDuration: const Duration(milliseconds: 300),
        );

      case EconomicCalenderScreen.routeName:
        return PageTransition(
          child: const EconomicCalenderScreen(),
          type: PageTransitionType.rightToLeft,
          duration: const Duration(milliseconds: 300),
          reverseDuration: const Duration(milliseconds: 300),
        );case Otr_Screen.routeName:
        return PageTransition(
          child: const Otr_Screen(),
          type: PageTransitionType.bottomToTop,
          duration: const Duration(milliseconds: 300),
          reverseDuration: const Duration(milliseconds: 300),
        );

      default:
        return PageTransition(
          child: const ErrorScreen(),
          type: PageTransitionType.leftToRight,
          duration: const Duration(milliseconds: 300),
          reverseDuration: const Duration(milliseconds: 300),
        );
    }
  }
}

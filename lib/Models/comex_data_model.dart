import 'dart:ui';

import '../Constants/app_colors.dart';

class ComexDataModel {
  String? symbolName;
  String? bid;
  String? ask;
  String? high;
  String? low;
  String? source;
  Color askBGColor;
  Color askTextColor;
  Color bidBGColor;
  Color bidTextColor;

  ComexDataModel({
    this.symbolName,
    this.bid,
    this.ask,
    this.high,
    this.low,
    this.source,
    this.askBGColor = AppColors.textColor,
    this.askTextColor = AppColors.textColor,
    this.bidBGColor = AppColors.textColor,
    this.bidTextColor = AppColors.textColor,
  });
}

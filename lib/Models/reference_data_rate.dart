// To parse this JSON data, do
//
//     final referenceDataRate = referenceDataRateFromJson(jsonString);

import 'dart:convert';

import 'package:flutter/material.dart';

import '../Constants/app_colors.dart';


ReferenceDataRate referenceDataRateFromJson(String str) =>
    ReferenceDataRate.fromJson(json.decode(str));

String referenceDataRateToJson(ReferenceDataRate data) =>
    json.encode(data.toJson());

class ReferenceDataRate {
  ReferenceDataRate({
    this.name,
    this.bid,
    this.ask,
    this.ltp,
    this.high,
    this.low,
    this.time,
    this.open,
    this.close,
    this.symbol,
    this.difference,
    this.askBGColor = AppColors.defaultColor,
    this.askTextColor = AppColors.textColor,
    this.bidBGColor = AppColors.defaultColor,
    this.bidTextColor = AppColors.textColor,
  });

  String? name;
  dynamic bid;
  dynamic ask;
  dynamic ltp;
  dynamic high;
  dynamic low;
  dynamic time;
  dynamic open;
  dynamic close;
  String? symbol;
  dynamic difference;
  Color askBGColor;
  Color askTextColor;
  Color bidBGColor;
  Color bidTextColor;

  factory ReferenceDataRate.fromJson(Map<String, dynamic> json) =>
      ReferenceDataRate(
        name: json["Name"],
        bid: json["Bid"],
        ask: json["Ask"],
        ltp: json["LTP"],
        high: json["High"],
        low: json["Low"],
        time: json["Time"],
        open: json["Open"],
        close: json["Close"],
        symbol: json["symbol"],
        difference: json["Difference"],
      );

  Map<String, dynamic> toJson() => {
    "Name": name,
    "Bid": bid,
    "Ask": ask,
    "LTP": ltp,
    "High": high,
    "Low": low,
    "Time": time,
    "Open": open,
    "Close": close,
    "symbol": symbol,
    "Difference": difference,
      };
}

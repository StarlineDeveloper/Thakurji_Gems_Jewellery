// To parse this JSON data, do
//
//     final liverate = liverateFromJson(jsonString);

import 'dart:convert';

import 'package:flutter/material.dart';

import '../Constants/app_colors.dart';

Liverate liverateFromJson(String str) => Liverate.fromJson(json.decode(str));

String liverateToJson(Liverate data) => json.encode(data.toJson());

class Liverate {
  Liverate({
    this.id,
    this.name,
    this.src,
    this.usr,
    this.bid,
    this.ask,
    this.high,
    this.low,
    this.diff,
    this.askBGColor = AppColors.textColor,
    this.askTextColor = AppColors.textColor,
    this.bidBGColor = AppColors.textColor,
    this.bidTextColor = AppColors.textColor,
    this.askTradeBGColor = AppColors.primaryColor,
    this.askTradeTextColor = AppColors.textColor,
    this.bidTradeBGColor = AppColors.primaryColor,
    this.bidTradeTextColor = AppColors.textColor,
    this.diffBGColor = AppColors.textColor,
    this.diffTextColor = AppColors.textColor,
  });

  dynamic id;
  String? name;
  String? src;
  String? usr;
  dynamic bid;
  dynamic ask;
  dynamic high;
  dynamic low;
  dynamic diff;
  Color askBGColor;
  Color askTextColor;
  Color bidBGColor;
  Color bidTextColor;
  Color askTradeBGColor;
  Color askTradeTextColor;
  Color bidTradeBGColor;
  Color bidTradeTextColor;
  Color diffBGColor;
  Color diffTextColor;

  factory Liverate.fromJson(Map<String, dynamic> json) => Liverate(
        id: json["id"],
        name: json["name"],
        src: json["src"],
        usr: json["usr"],
        bid: json["bid"],
        ask: json["ask"],
        high: json["high"],
        low: json["low"],
        diff: json["diff"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "src": src,
        "usr": usr,
        "bid": bid,
        "ask": ask,
        "high": high,
        "low": low,
        "diff": diff,
      };
}

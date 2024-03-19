// To parse this JSON data, do
//
//     final clientHeade = clientHeadeFromJson(jsonString);

import 'dart:convert';

ClientHeaderData clientHeadeFromJson(String str) => ClientHeaderData.fromJson(json.decode(str));

String clientHeadeToJson(ClientHeaderData data) => json.encode(data.toJson());

class ClientHeaderData {
  dynamic activeUser;
  dynamic user;
  dynamic number1;
  dynamic number2;
  dynamic number3;
  dynamic number4;
  dynamic number5;
  dynamic number6;
  dynamic number7;
  dynamic marqueeTop;
  dynamic whatsAppNo;
  dynamic marqueeBottom;
  dynamic address1;
  dynamic address2;
  dynamic address3;
  dynamic email1;
  dynamic email2;
  dynamic bannerWeb;
  dynamic bannerApp;
  bool? isBuy;
  bool? isSell;
  bool? isHigh;
  bool? isLow;
  bool? isRate;

  ClientHeaderData({
    this.activeUser,
    this.user,
    this.number1,
    this.number2,
    this.number3,
    this.number4,
    this.number5,
    this.number6,
    this.number7,
    this.marqueeTop,
    this.whatsAppNo,
    this.marqueeBottom,
    this.address1,
    this.address2,
    this.address3,
    this.email1,
    this.email2,
    this.bannerWeb,
    this.bannerApp,
    this.isBuy,
    this.isSell,
    this.isHigh,
    this.isLow,
    this.isRate,
  });

  factory ClientHeaderData.fromJson(Map<String, dynamic> json) => ClientHeaderData(
    activeUser: json["activeUser"],
    user: json["user"],
    number1: json["number1"]??'',
    number2: json["number2"]??'',
    number3: json["number3"]??'',
    number4: json["number4"]??'',
    number5: json["number5"]??'',
    number6: json["number6"]??'',
    number7: json["number7"]??'',
    marqueeTop: json["marqueeTop"]??'',
    whatsAppNo: json["whatsAppNo"]??'',
    marqueeBottom: json["marqueeBottom"]??'',
    address1: json["address1"]??'',
    address2: json["address2"]??'',
    address3: json["address3"]??'',
    email1: json["email1"]??'',
    email2: json["email2"]??'',
    bannerWeb: json["bannerWeb"]??'',
    bannerApp: json["bannerApp"]??'',
    isBuy: json["isBuy"],
    isSell: json["isSell"],
    isHigh: json["isHigh"],
    isLow: json["isLow"],
    isRate: json["isRate"],
  );

  Map<String, dynamic> toJson() => {
    "activeUser": activeUser,
    "user": user,
    "number1": number1,
    "number2": number2,
    "number3": number3,
    "number4": number4,
    "number5": number5,
    "number6": number6,
    "number7": number7,
    "marqueeTop": marqueeTop,
    "whatsAppNo": whatsAppNo,
    "marqueeBottom": marqueeBottom,
    "address1": address1,
    "address2": address2,
    "address3": address3,
    "email1": email1,
    "email2": email2,
    "bannerWeb": bannerWeb,
    "bannerApp": bannerApp,
    "isBuy": isBuy,
    "isSell": isSell,
    "isHigh": isHigh,
    "isLow": isLow,
    "isRate": isRate,
  };
}

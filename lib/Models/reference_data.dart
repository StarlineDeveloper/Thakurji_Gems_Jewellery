// To parse this JSON data, do
//
//     final referenceData = referenceDataFromJson(jsonString);

import 'dart:convert';

ReferenceData referenceDataFromJson(String str) =>
    ReferenceData.fromJson(json.decode(str));

String referenceDataToJson(ReferenceData data) => json.encode(data.toJson());

class ReferenceData {
  ReferenceData({
    this.activeUser,
    this.user,
    this.name,
    this.source,
  });

  String? activeUser;
  String? user;
  String? name;
  String? source;

  factory ReferenceData.fromJson(Map<String, dynamic> json) => ReferenceData(
    activeUser: json["activeUser"],
    user: json["user"],
    name: json["name"],
    source: json["source"],
      );

  Map<String, dynamic> toJson() => {
    "activeUser": activeUser,
    "user": user,
    "name": name,
    "source": source,
      };
}

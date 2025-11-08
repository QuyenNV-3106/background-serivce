// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'dart:convert';

List<User> userFromJson(String str) =>
    List<User>.from(json.decode(str).map((x) => User.fromJson(x)));

String userToJson(List<User> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class User {
  int? id;
  int? userCd;
  String? userCode;
  String? userName;
  int? groupCd;
  String? groupCode;
  String? groupName;
  bool? notificationGroup;
  int? notifyNumber;
  String? groupTableName;
  String? lastMessTime;

  User({
    this.id,
    this.userCd,
    this.userCode,
    this.userName,
    this.groupCd,
    this.groupCode,
    this.groupName,
    this.notificationGroup,
    this.notifyNumber,
    this.groupTableName,
    this.lastMessTime,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        userCd: json["USER_CD"],
        userCode: json["USER_CODE"],
        userName: json["USER_NAME"],
        groupCd: json["GROUP_CD"],
        groupCode: json["GROUP_CODE"],
        groupName: json["GROUP_NAME"],
        notificationGroup: json["NOTIFICATION_GROUP"],
        notifyNumber: json["NOTIFY_NUMBER"],
        groupTableName: json["GROUP_TABLE_NAME"],
        lastMessTime: json["LAST_MESS_TIME"],
      );

  Map<String, dynamic> toJson() => {
        "USER_CD": userCd,
        "USER_CODE": userCode,
        "USER_NAME": userName,
        "GROUP_CD": groupCd,
        "GROUP_CODE": groupCode,
        "GROUP_NAME": groupName,
        "NOTIFICATION_GROUP": notificationGroup,
        "NOTIFY_NUMBER": notifyNumber,
        "GROUP_TABLE_NAME": groupTableName,
        "LAST_MESS_TIME": lastMessTime,
      };
}

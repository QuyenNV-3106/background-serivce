import 'dart:convert';

ApiModel apiModelFromJson(String str) => ApiModel.fromJson(json.decode(str));

String apiModelToJson(ApiModel data) => json.encode(data.toJson());

class ApiModel {
  String? statusCode;
  String? statusDesc;
  String? nextAction;
  String? data;

  ApiModel({
    this.statusCode,
    this.statusDesc,
    this.nextAction,
    this.data,
  });

  factory ApiModel.fromJson(Map<String, dynamic> json) => ApiModel(
        statusCode: json["Status_Code"],
        statusDesc: json["Status_Desc"],
        nextAction: json["Next_Action"],
        data: json["Data"],
      );

  Map<String, dynamic> toJson() => {
        "Status_Code": statusCode,
        "Status_Desc": statusDesc,
        "Next_Action": nextAction,
        "Data": data,
      };
}

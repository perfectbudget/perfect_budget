import 'dart:convert';

import 'package:equatable/equatable.dart';

List<UserModel> albumFromJson(String str) => List<UserModel>.from(
    json.decode(str).map((dynamic x) => UserModel.fromJson(x)));

String albumToJson(List<UserModel> data) =>
    json.encode(List<dynamic>.from(data.map<dynamic>((x) => x.toJson())));

class UserModel extends Equatable {
  const UserModel(
      {required this.id,
      required this.name,
      required this.email,
      this.currencyCode,
      this.currencySymbol,
      required this.uuid,
      required this.avatar,
      required this.language,
      this.datePremium});
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        uuid: json['uuid'],
        avatar: json['avatar'],
        language: json['language'],
        currencyCode: json['currency_code'] ?? 'USD',
        currencySymbol: json['currency_symbol'] ?? '\$',
        datePremium: json['date_premium'] != null
            ? DateTime.tryParse(json['date_premium'])
            : DateTime(1970));
  }

  final int id;
  final String uuid;
  final String name;
  final String email;
  final String avatar;
  final String? currencyCode;
  final String? currencySymbol;
  final DateTime? datePremium;
  final String language;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'email': email,
        'uuid': uuid,
        'avatar': avatar,
        'currency_code': currencyCode,
        'currency_symbol': currencySymbol,
        'date_premium': datePremium,
        'language': language,
      };

  @override
  List<Object> get props => [
        id,
        uuid,
        name,
        email,
        avatar,
        currencyCode!,
        currencySymbol!,
        datePremium!,
        language
      ];
}

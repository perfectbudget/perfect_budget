import 'dart:convert';

import 'package:equatable/equatable.dart';

List<CategoryModel> albumFromJson(String str) => List<CategoryModel>.from(
    json.decode(str).map((dynamic x) => CategoryModel.fromJson(x)));

String albumToJson(List<CategoryModel> data) =>
    json.encode(List<dynamic>.from(data.map<dynamic>((x) => x.toJson())));

class CategoryModel extends Equatable {
  const CategoryModel(
      {required this.name,
      required this.id,
      this.parrentId,
      required this.icon,
      required this.type,
      this.isDefault,
      this.createAt,
      this.updateAt});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      parrentId: json['parrent_id'],
      name: json['name'],
      isDefault: json['is_default'],
      icon: json['icon'],
      type: json['type'],
    );
  }
  final int id;
  final int? parrentId;
  final String name;
  final String icon;
  final String type;
  final bool? isDefault;
  final DateTime? createAt;
  final DateTime? updateAt;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'parrent_id': parrentId,
        'is_default': isDefault,
        'name': name,
        'icon': icon,
        'type': type,
      };
  @override
  List<Object?> get props =>
      [id, parrentId, name, icon, type, isDefault, createAt, updateAt];
}

import 'package:equatable/equatable.dart';

class TypeWalletModel extends Equatable {
  const TypeWalletModel(
      {required this.name, required this.icon, required this.id});

  factory TypeWalletModel.fromJson(Map<String, dynamic> json) {
    return TypeWalletModel(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
    );
  }
  final int id;
  final String name;
  final String icon;

  @override
  List<Object?> get props => [id, name, icon];
}

import 'package:equatable/equatable.dart';

class CurrencyModel extends Equatable {
  const CurrencyModel(
      {required this.name,
      required this.id,
      required this.code,
      required this.description});
  final int id;
  final String name;
  final String description;
  final String code;

  @override
  List<Object?> get props => [id, name, description, code];
}

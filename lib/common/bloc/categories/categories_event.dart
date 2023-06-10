import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class CategoriesEvent extends Equatable {
  const CategoriesEvent();
}

class InitialCategories extends CategoriesEvent {
  @override
  List<Object> get props => [];
}

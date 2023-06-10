import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../model/category_model.dart';

@immutable
abstract class CategoriesState extends Equatable {
  const CategoriesState();
}

class CategoriesLoading extends CategoriesState {
  @override
  List<Object> get props => [];
}

class CategoriesLoaded extends CategoriesState {
  const CategoriesLoaded(
      {this.categories = const <Map<String, dynamic>>[],
      this.listCategory = const <CategoryModel>[]});

  final List<Map<String, dynamic>> categories;
  final List<CategoryModel> listCategory;

  @override
  List<Object> get props => [categories, listCategory];
}

class CategoriesError extends CategoriesState {
  @override
  List<Object> get props => [];
}

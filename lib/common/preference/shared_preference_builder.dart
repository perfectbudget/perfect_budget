import 'dart:async';
import 'dart:convert';

import 'package:monsey/common/model/category_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<CategoryModel?> getCategory({String input = 'categoryIncome'}) async {
  final SharedPreferences shared = await SharedPreferences.getInstance();
  CategoryModel? categoryModel;
  if (shared.getString(input) != null) {
    final Map<String, dynamic> result = jsonDecode(shared.getString(input)!);
    categoryModel = CategoryModel.fromJson(result);
  }
  return categoryModel;
}

Future<void> setCategory(CategoryModel categoryModel,
    {String input = 'categoryIncome'}) async {
  final SharedPreferences shared = await SharedPreferences.getInstance();
  shared.setString(input, jsonEncode(categoryModel.toJson()));
}

//save amount create transaction
Future<int> getAmountTransCreate({String input = 'amountTransaction'}) async {
  final SharedPreferences shared = await SharedPreferences.getInstance();
  final int amountCreate = shared.getInt(input) ?? 0;
  return amountCreate;
}

Future<void> setAmountTransCreate() async {
  final SharedPreferences shared = await SharedPreferences.getInstance();
  final int amountCreate = shared.getInt('amountTransaction') ?? 0;
  switch (amountCreate) {
    case 0:
      shared.setInt('amountTransaction', 1);
      break;
    case 1:
      shared.setInt('amountTransaction', 2);
      break;
    case 2:
      shared.setInt('amountTransaction', 3);
      break;
    case 3:
      shared.setInt('amountTransaction', 0);
      break;
  }
}

//save amount create transaction review
Future<int> getAmountTransReview(
    {String input = 'amountTransactionReview'}) async {
  final SharedPreferences shared = await SharedPreferences.getInstance();
  final int amountCreate = shared.getInt(input) ?? 0;
  return amountCreate;
}

Future<void> setAmountTransReview() async {
  final SharedPreferences shared = await SharedPreferences.getInstance();
  int amountCreate = shared.getInt('amountTransactionReview') ?? 0;
  amountCreate++;
  if (amountCreate == 6) {
    shared.setInt('amountTransactionReview', 1);
  } else {
    shared.setInt('amountTransactionReview', amountCreate);
  }
}

Future<void> removeStorage() async {
  final SharedPreferences shared = await SharedPreferences.getInstance();
  shared.remove('category');
  shared.remove('amountTransaction');
  shared.remove('amountTransactionReview');
}

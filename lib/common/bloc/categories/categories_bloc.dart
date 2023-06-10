import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql/client.dart';
import 'package:monsey/common/model/category_model.dart';

import '../../graphql/config.dart';
import '../../graphql/queries.dart';
import 'bloc_categories.dart';

class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  CategoriesBloc() : super(CategoriesLoading()) {
    on<InitialCategories>(_onInitialCategories);
  }

  User firebaseUser = FirebaseAuth.instance.currentUser!;
  List<Map<String, dynamic>> categories = [];
  List<CategoryModel> listCategory = [];
  CategoryModel? incomeDefault;
  CategoryModel? expenseDefault;

  Future<void> _onInitialCategories(
      InitialCategories event, Emitter<CategoriesState> emit) async {
    emit(CategoriesLoading());
    try {
      categories.clear();
      listCategory.clear();
      listCategory = await getCategories();
      for (CategoryModel category in listCategory) {
        if (category.type == 'income' && category.isDefault!) {
          incomeDefault = category;
        }
        if (category.type == 'expense' && category.isDefault!) {
          expenseDefault = category;
        }
        if (category.parrentId == null) {
          categories.add(<String, dynamic>{
            'parrent': category,
            'child': <CategoryModel>[]
          });
        }
      }
      for (Map<String, dynamic> category in categories) {
        for (CategoryModel categoryDetail in listCategory) {
          if (categoryDetail.parrentId == category['parrent'].id) {
            category['child'].add(categoryDetail);
          }
        }
      }
      emit(
          CategoriesLoaded(categories: categories, listCategory: listCategory));
    } catch (_) {
      emit(CategoriesError());
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    final List<CategoryModel> categories = [];
    final String token = await firebaseUser.getIdToken();
    await Config.initializeClient(token)
        .value
        .query(QueryOptions(document: gql(Queries.getCategories)))
        .then((value) {
      if (value.data!.isNotEmpty && value.data!['Category'].length > 0) {
        for (Map<String, dynamic> type in value.data!['Category']) {
          categories.add(CategoryModel.fromJson(type));
        }
      }
    });
    return categories;
  }
}

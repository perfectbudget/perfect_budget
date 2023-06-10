import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monsey/common/constant/images.dart';
import 'package:monsey/common/model/category_model.dart';
import 'package:monsey/common/widget/animation_click.dart';

import '../../../app/widget_support.dart';
import '../../../common/bloc/categories/bloc_categories.dart';
import '../../../common/constant/colors.dart';
import '../../../common/constant/styles.dart';
import '../../../common/widget/app_bar_cpn.dart';
import '../../../translations/export_lang.dart';

class ExpenseCategories extends StatefulWidget {
  const ExpenseCategories({Key? key}) : super(key: key);

  @override
  State<ExpenseCategories> createState() => _ExpenseCategoriesState();
}

class _ExpenseCategoriesState extends State<ExpenseCategories> {
  TextEditingController searchCtl = TextEditingController();
  FocusNode searchFn = FocusNode();
  bool isExpand = false;

  @override
  void dispose() {
    searchCtl.dispose();
    searchFn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCpn(
        color: white,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Image.asset(icArrowLeft, width: 24, height: 24)),
                Text(
                  LocaleKeys.expenseCategories.tr(),
                  style: headline(context: context),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: AnimationClick(
                    function: () {
                      setState(() {
                        isExpand = !isExpand;
                      });
                    },
                    child: Text(
                      isExpand ? LocaleKeys.close.tr() : LocaleKeys.expand.tr(),
                      style: headline(color: purplePlum),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
      body: BlocBuilder<CategoriesBloc, CategoriesState>(
        builder: (context, state) {
          if (state is CategoriesLoading) {
            return const Center(child: CupertinoActivityIndicator());
          }
          if (state is CategoriesLoaded) {
            final List<Map<String, dynamic>> categories = state.categories
                .where((e) => e['parrent'].type == 'expense')
                .toList();
            return ListView(
              children: [
                Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: white, borderRadius: BorderRadius.circular(12)),
                  child: ListView.separated(
                    separatorBuilder: (context, index) {
                      return AppWidget.divider(context, vertical: 0);
                    },
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final CategoryModel category =
                          categories[index]['parrent'];
                      final List<CategoryModel> categoriesDetail =
                          categories[index]['child'];
                      return Column(
                        children: [
                          ListTile(
                            onTap: () {
                              Navigator.of(context).pop(category);
                            },
                            leading: Image.network(category.icon,
                                width: 24, height: 24),
                            title: Text(
                              category.name,
                              style: headline(context: context),
                            ),
                          ),
                          isExpand
                              ? ListView.separated(
                                  padding: const EdgeInsets.only(left: 32),
                                  separatorBuilder: (context, index) {
                                    return AppWidget.divider(context,
                                        vertical: 0);
                                  },
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: categoriesDetail.length,
                                  itemBuilder: (context, ind) {
                                    return ListTile(
                                      onTap: () {
                                        Navigator.of(context)
                                            .pop(categoriesDetail[ind]);
                                      },
                                      leading: Image.network(
                                          categoriesDetail[ind].icon,
                                          width: 24,
                                          height: 24),
                                      title: Text(
                                        categoriesDetail[ind].name,
                                        style: body(color: grey1),
                                      ),
                                    );
                                  },
                                )
                              : const SizedBox()
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

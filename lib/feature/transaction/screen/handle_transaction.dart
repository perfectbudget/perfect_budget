import 'dart:async';
import 'package:applovin_max/applovin_max.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monsey/app/widget_support.dart';
import 'package:monsey/common/bloc/categories/bloc_categories.dart';
import 'package:monsey/common/constant/colors.dart';
import 'package:monsey/common/constant/styles.dart';
import 'package:monsey/common/model/category_model.dart';
import 'package:monsey/common/model/transaction_model.dart';
import 'package:monsey/common/model/wallet_model.dart';
import 'package:monsey/common/preference/shared_preference_builder.dart';
import 'package:monsey/common/route/routes.dart';
import 'package:monsey/common/util/format_time.dart';
import 'package:monsey/common/util/upload_image.dart';
import 'package:monsey/common/widget/animation_click.dart';
import 'package:monsey/common/widget/app_bar_cpn.dart';
import 'package:monsey/common/widget/unfocus_click.dart';
import 'package:monsey/feature/home/bloc/wallets/bloc_wallets.dart';
import 'package:monsey/feature/transaction/bloc/transactions/bloc_transactions.dart';
import 'package:monsey/feature/transaction/screen/select_wallet.dart';
import 'package:monsey/feature/transaction/widget/list_photo.dart';
import 'package:monsey/translations/export_lang.dart';

import '../../../common/constant/env.dart';
import '../../../common/constant/images.dart';
import '../../../common/util/helper.dart';
import '../../../common/widget/textfield_balance.dart';
import '../../onboarding/bloc/user/bloc_user.dart';
import '../widget/calendar.dart';

const int maxFailedLoadAttempts = 3;

class HandleTransaction extends StatefulWidget {
  const HandleTransaction(
      {Key? key,
      this.transactionModel,
      required this.walletModel,
      this.preCgExpense,
      this.preCgIncome,
      this.startDate,
      this.endDate})
      : super(key: key);
  final TransactionModel? transactionModel;
  final WalletModel walletModel;
  final CategoryModel? preCgExpense;
  final CategoryModel? preCgIncome;
  final DateTime? startDate;
  final DateTime? endDate;
  @override
  State<HandleTransaction> createState() => _HandleTransactionState();
}

class _HandleTransactionState extends State<HandleTransaction>
    with SingleTickerProviderStateMixin {
  late TabController _controller;
  int _currentIndex = 0;
  bool isPremium = false;
  String? note;
  String? nameWallet;
  String? nameCgExpense;
  String? nameCgIncome;
  String? iconCgExpense;
  String? iconCgIncome;
  DateTime? date;
  Uint8List? bytes;
  String? imageUrl;

  late TextEditingController balanceCtl;
  FocusNode balanceFn = FocusNode();

  CategoryModel? cgExpense;
  CategoryModel? cgIncome;
  WalletModel? walletModel;
  late WalletsBloc walletsBloc;
  late TransactionsBloc transactionsBloc;
  String suggestOne = '';
  String suggestTwo = '';
  String suggestThree = '';

  bool isCreate = true;
  bool isExpense = true;
  bool showSuggest = false;
  bool clickedBlack = false;

  Future<void> setNameWallet() async {
    final result = await Navigator.of(context).pushNamed(Routes.selectWallet,
        arguments: const SelectWallet()) as WalletModel;
    setState(() {
      walletModel = result;
      nameWallet = result.name;
    });
  }

  Future<void> setNote() async {
    final result =
        await Navigator.of(context).pushNamed(Routes.noteTransaction) as String;
    if (result != '')
      setState(() {
        note = result;
      });
  }

  Future<void> setNameCategory() async {
    if (_currentIndex == 0) {
      final result = await Navigator.of(context)
          .pushNamed(Routes.expenseCategories) as CategoryModel?;
      if (result != null) {
        setState(() {
          cgExpense = result;
          nameCgExpense = result.name;
          iconCgExpense = result.icon;
        });
      }
    } else {
      final result = await Navigator.of(context)
          .pushNamed(Routes.incomeCategories) as CategoryModel?;
      if (result != null) {
        setState(() {
          cgIncome = result;
          nameCgIncome = result.name;
          iconCgIncome = result.icon;
        });
      }
    }
  }

  Future<void> setDate() async {
    await showModalBottomSheet<DateTime>(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: white,
      builder: (BuildContext context) {
        return CalendarCpn(previousSelectedDate: date ?? now);
      },
      context: context,
    ).then((dynamic value) {
      if (value != null) {
        setState(() {
          date = value;
        });
      }
    });
  }

  Future<void> setPhoto() async {
    await showModalBottomSheet<Uint8List>(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: white,
      builder: (BuildContext context) {
        return SizedBox(
            height: MediaQuery.of(context).size.height / 2,
            child: const ListPhoto());
      },
      context: context,
    ).then((dynamic value) async {
      if (value != null) {
        setState(() {
          bytes = value!;
        });
        uploadFile(context, uint8list: bytes!).then((url) {
          imageUrl = url;
        });
      }
    });
  }

  Widget itemTabView() {
    return ListView(
      children: [
        TextFieldBalanceCpn(
            isExpense: _currentIndex == 0,
            isCreateTransaction: true,
            controller: balanceCtl,
            focusNode: balanceFn,
            showPrefixIcon: true),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: white, borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              AnimationClick(
                function: setNameCategory,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Image.network(
                            _currentIndex == 0 ? iconCgExpense! : iconCgIncome!,
                            width: 24,
                            height: 24,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: Text(
                                (_currentIndex == 0
                                        ? nameCgExpense
                                        : nameCgIncome) ??
                                    LocaleKeys.category.tr(),
                                style: body(color: grey1),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_right_rounded,
                      color: grey3,
                    )
                  ],
                ),
              ),
              AppWidget.divider(context, vertical: 16),
              AnimationClick(
                function: setNameWallet,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          isCreate
                              ? Image.asset(
                                  icWallet,
                                  width: 24,
                                  height: 24,
                                  color: purplePlum,
                                )
                              : Image.network(
                                  widget.walletModel.typeWalletModel!.icon,
                                  width: 24,
                                  height: 24,
                                  color: purplePlum,
                                ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: Text(
                                nameWallet ?? LocaleKeys.wallet.tr(),
                                style: body(
                                    color: nameWallet == null && isCreate
                                        ? grey3
                                        : grey1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_right_rounded,
                      color: grey3,
                    )
                  ],
                ),
              ),
              AppWidget.divider(context, vertical: 16),
              AnimationClick(
                function: setDate,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Image.asset(icCalendar,
                              width: 24, height: 24, color: purplePlum),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: Text(
                                FormatTime.formatTime(
                                    dateTime: date, format: Format.EMd),
                                style: body(color: grey1),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: grey3,
                    )
                  ],
                ),
              ),
              AppWidget.divider(context, vertical: 16),
              AnimationClick(
                function: setNote,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Image.asset(
                            icNote,
                            width: 24,
                            height: 24,
                            color: purplePlum,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: Text(
                                note ?? LocaleKeys.note.tr(),
                                style: body(
                                    color: note == null && isCreate
                                        ? grey3
                                        : grey1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_right_rounded,
                      color: grey3,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 64),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: white, borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              AnimationClick(
                function: setPhoto,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Image.asset(
                            icDetails,
                            width: 24,
                            height: 24,
                            color: purplePlum,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: Text(
                                LocaleKeys.attachPhoto.tr(),
                                style: body(color: blueCrayola),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_right_rounded,
                      color: grey3,
                    )
                  ],
                ),
              ),
              bytes == null
                  ? (isCreate
                      ? const SizedBox()
                      : (widget.transactionModel!.photoUrl != null
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: AnimationClick(
                                  function: setPhoto,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      widget.transactionModel!.photoUrl!,
                                      width: double.infinity,
                                      height: 200,
                                      fit: BoxFit.cover,
                                    ),
                                  )),
                            )
                          : const SizedBox()))
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: AnimationClick(
                        function: setPhoto,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            bytes!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        )
      ],
    );
  }

  String convertString(String suggest) {
    return formatMoney(context).format(!suggest.contains('.')
        ? (int.tryParse(suggest.replaceAll(',', '')) ?? 0)
        : (double.tryParse(suggest.replaceAll(',', '')) ?? 0));
  }

  Widget suggestText(String suggest) {
    return InkWell(
        borderRadius: BorderRadius.circular(48),
        onTap: () {
          setState(() {
            balanceCtl.text = convertString(suggest);
            balanceCtl.selection =
                TextSelection.collapsed(offset: balanceCtl.text.length);
          });
        },
        child: Container(
          decoration: BoxDecoration(
              color: grey3.withOpacity(0.2),
              borderRadius: BorderRadius.circular(48)),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          child: Text(
            convertString(suggest),
            textAlign: TextAlign.center,
            style: headline(fontWeight: '700', context: context),
          ),
        ));
  }

  void editTransaction() {
    final String balance = balanceCtl.text;
    transactionsBloc.add(EditTransaction(
        context,
        TransactionModel(
            id: widget.transactionModel!.id,
            balance: double.tryParse(balance.replaceAll(',', ''))!,
            categoryModel: _currentIndex == 0 ? cgExpense : cgIncome,
            categoryId: _currentIndex == 0 ? cgExpense!.id : cgIncome!.id,
            walletId: walletModel!.id!,
            photoUrl: imageUrl,
            type: _currentIndex == 0 ? 'expense' : 'income',
            date: date ?? now,
            note: note!),
        widget.startDate,
        widget.endDate));
    Navigator.of(context).pop();
  }

  void removeTransaction() {
    if (!isCreate && widget.transactionModel != null) {
      transactionsBloc.add(RemoveTransaction(
          context, widget.transactionModel!, widget.startDate, widget.endDate));
    }
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  void handleInput() {
    final String text = balanceCtl.text.trim();
    setState(() {
      if (text.isNotEmpty && text != '0' && text != '0.00') {
        showSuggest = true;
        if (text.contains('.')) {
          final List<String> number = text.split('.');
          suggestOne = number[0] + '0.' + number[1];
          suggestTwo = number[0] + '00.' + number[1];
          suggestThree = number[0] + '000.' + number[1];
        } else {
          suggestOne = text + '0';
          suggestTwo = text + '00';
          suggestThree = text + '000';
        }
      } else {
        showSuggest = false;
      }
    });
  }

  Future<void> handleTransaction() async {
    final String balance = balanceCtl.text;

    await setCategory(_currentIndex == 0 ? cgExpense! : cgIncome!,
        input: _currentIndex == 0 ? 'categoryExpense' : 'categoryIncome');
    if (!isPremium) {
      await setAmountTransCreate();
    }
    await setAmountTransReview();
    transactionsBloc.add(CreateTransaction(
        context,
        TransactionModel(
            balance: double.tryParse(balance.replaceAll(',', ''))!,
            categoryId: _currentIndex == 0 ? cgExpense!.id : cgIncome!.id,
            categoryModel: _currentIndex == 0 ? cgExpense! : cgIncome!,
            walletId: walletModel!.id!,
            type: _currentIndex == 0 ? 'expense' : 'income',
            photoUrl: imageUrl,
            date: date ?? now,
            note: note ?? cgExpense?.name),
        widget.startDate,
        widget.endDate));

    final int amount = await getAmountTransReview();

    if (amount == 20) {
      final isAvailable = await inAppReview.isAvailable();
      if (isAvailable) {
        inAppReview.requestReview();
      }
    }
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    isPremium = checkPremium(context.read<UserBloc>().userModel!.datePremium);
    isCreate = widget.transactionModel == null;
    _currentIndex = isCreate
        ? 0
        : widget.transactionModel!.type == 'expense'
            ? 0
            : 1;
    balanceCtl = TextEditingController(
        text: isCreate
            ? ''
            : '${formatAmount(widget.transactionModel!.balance.toString().endsWith('.0') ? widget.transactionModel!.balance.toStringAsFixed(0) : widget.transactionModel!.balance.toString())}');
    balanceCtl.selection =
        TextSelection.collapsed(offset: balanceCtl.text.length);
    cgExpense = isCreate
        ? (widget.preCgExpense != null
            ? widget.preCgExpense
            : BlocProvider.of<CategoriesBloc>(context).expenseDefault)
        : (widget.transactionModel!.categoryModel!.type == 'expense'
            ? widget.transactionModel!.categoryModel
            : widget.preCgExpense != null
                ? widget.preCgExpense
                : BlocProvider.of<CategoriesBloc>(context).expenseDefault);
    cgIncome = isCreate
        ? (widget.preCgIncome != null
            ? widget.preCgIncome
            : BlocProvider.of<CategoriesBloc>(context).incomeDefault)
        : (widget.transactionModel!.categoryModel!.type == 'income'
            ? widget.transactionModel!.categoryModel
            : widget.preCgIncome != null
                ? widget.preCgIncome
                : BlocProvider.of<CategoriesBloc>(context).incomeDefault);
    nameCgExpense = cgExpense?.name;
    nameCgIncome = cgIncome?.name;
    iconCgExpense = cgExpense?.icon;
    iconCgIncome = cgIncome?.icon;

    nameWallet = widget.walletModel.name;
    date = isCreate ? null : widget.transactionModel!.date;
    note = isCreate ? null : widget.transactionModel!.note;
    imageUrl = isCreate ? null : widget.transactionModel!.photoUrl;
    walletModel = widget.walletModel;
    balanceCtl.addListener(handleInput);
    _controller =
        TabController(length: 2, vsync: this, initialIndex: _currentIndex);
    Future<dynamic>.delayed(const Duration(seconds: 1)).whenComplete(() {
      AdHelper().initializeInterstitialAds(
        onAdDisplayedCallback: (p0) async {
          await handleTransaction();
        },
      );
    });
  }

  @override
  void didChangeDependencies() {
    walletsBloc = BlocProvider.of<WalletsBloc>(context);
    transactionsBloc = BlocProvider.of<TransactionsBloc>(context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // _interstitialAd?.dispose();
    balanceCtl.dispose();
    balanceFn.dispose();
    balanceCtl.removeListener(handleInput);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool checked =
        _currentIndex == 0 ? (cgExpense != null) : (cgIncome != null);

    return UnfocusClick(
      child: Scaffold(
        body: Scaffold(
          appBar: AppBarCpn(
            color: white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    onPressed: () {
                      if (isCreate) {
                        Navigator.of(context).pop();
                      } else {
                        setState(() {
                          clickedBlack = true;
                        });
                      }
                    },
                    icon: Image.asset(icArrowLeft, width: 24, height: 24)),
                Text(
                  isCreate
                      ? LocaleKeys.createTransaction.tr()
                      : LocaleKeys.editTransaction.tr(),
                  style: headline(context: context),
                ),
                isCreate
                    ? const SizedBox()
                    : IconButton(
                        onPressed: () {
                          AppWidget.showDialogCustom(
                              LocaleKeys.removeThisTransaction.tr(),
                              context: context,
                              remove: removeTransaction);
                        },
                        icon: const Icon(Icons.delete_outline_rounded,
                            size: 24, color: grey1),
                      )
              ],
            ),
            bottom: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                  color: grey6, borderRadius: BorderRadius.circular(20)),
              child: TabBar(
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                controller: _controller,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: _currentIndex == 0 ? redCrayola : bleuDeFrance,
                ),
                labelStyle: headline(color: purplePlum),
                unselectedLabelStyle: headline(color: grey2),
                labelColor: white,
                unselectedLabelColor: grey3,
                indicatorColor: purplePlum,
                labelPadding: const EdgeInsets.symmetric(horizontal: 0),
                tabs: [
                  Tab(text: LocaleKeys.expense.tr()),
                  Tab(text: LocaleKeys.income.tr()),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 8,
              ),
              showSuggest
                  ? SizedBox(
                      height: 48,
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        scrollDirection: Axis.horizontal,
                        children: [
                          suggestText(suggestOne),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: suggestText(suggestTwo),
                          ),
                          suggestText(suggestThree)
                        ],
                      ),
                    )
                  : const SizedBox(),
              const Divider(
                color: grey4,
              ),
              Padding(
                padding: const EdgeInsets.only(
                    bottom: 12, top: 6, left: 24, right: 24),
                child: isCreate
                    ? AppWidget.typeButtonStartAction(
                        context: context,
                        input: LocaleKeys.create.tr(),
                        onPressed: checked
                            ? () async {
                                if (!isPremium) {
                                  final int amountCreate =
                                      await getAmountTransCreate();
                                  if (amountCreate == 3) {
                                    final bool isReady = (await AppLovinMAX
                                        .isInterstitialReady(AdHelper()
                                            .interstitialAdUnitIdApplovin))!;
                                    if (isReady) {
                                      AppLovinMAX.showInterstitial(AdHelper()
                                          .interstitialAdUnitIdApplovin);
                                    } else {
                                      AppLovinMAX.loadInterstitial(AdHelper()
                                          .interstitialAdUnitIdApplovin);
                                    }
                                  } else {
                                    await handleTransaction();
                                  }
                                } else {
                                  await handleTransaction();
                                }
                              }
                            : () {},
                        bgColor: checked ? emerald : grey5,
                        textColor: white)
                    : clickedBlack
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AppWidget.typeButtonStartAction(
                                  context: context,
                                  input: LocaleKeys.discardChanges.tr(),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  borderColor: purplePlum,
                                  bgColor: white,
                                  textColor: purplePlum),
                              const SizedBox(height: 16),
                              AppWidget.typeButtonStartAction(
                                  context: context,
                                  input: LocaleKeys.keepEditing.tr(),
                                  onPressed: () {
                                    setState(() {
                                      clickedBlack = false;
                                    });
                                  },
                                  bgColor: emerald,
                                  textColor: white),
                            ],
                          )
                        : AppWidget.typeButtonStartAction(
                            context: context,
                            input: LocaleKeys.save.tr(),
                            onPressed: () {
                              editTransaction();
                            },
                            bgColor: emerald,
                            textColor: white),
              ),
            ],
          ),
          body: itemTabView(),
        ),
      ),
    );
  }
}

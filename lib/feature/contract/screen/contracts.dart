import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monsey/app/widget_support.dart';
import 'package:monsey/common/constant/styles.dart';
import 'package:monsey/common/model/contract_model.dart';
import 'package:monsey/common/route/routes.dart';
import 'package:monsey/common/widget/animation_click.dart';
import 'package:monsey/feature/contract/screen/detail_contract.dart';

import '../../../common/constant/colors.dart';
import '../../../common/constant/enums.dart';
import '../../../common/util/helper.dart';
import '../../../translations/export_lang.dart';
import '../../onboarding/bloc/user/bloc_user.dart';
import '../bloc/contracts/bloc_contracts.dart';
import '../bloc/trans_contract.dart/bloc_trans_contract.dart';
import 'detail_tran_contract.dart';
import 'handle_contract.dart';

class Contracts extends StatefulWidget {
  const Contracts({Key? key}) : super(key: key);

  @override
  State<Contracts> createState() => _ContractsState();
}

class _ContractsState extends State<Contracts>
    with SingleTickerProviderStateMixin {
  User firebaseUser = FirebaseAuth.instance.currentUser!;
  bool isChecked = false;
  late UserBloc userBloc;
  late ContractsBloc contractsBloc;

  String convertString(String suggest) {
    return formatMoney(context).format(!suggest.contains('.')
        ? (int.tryParse(suggest.replaceAll(',', '')) ?? 0)
        : (double.tryParse(suggest.replaceAll(',', '')) ?? 0));
  }

  Widget listTile(BuildContext context, String avt, String name, String email,
      double money, bool isIncome, ContractModel contract) {
    return Container(
      decoration:
          BoxDecoration(color: white, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.only(top: 8, bottom: 8, right: 16),
        leading: LayoutBuilder(builder: (context, constrain) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 5,
                height: constrain.maxHeight - 12,
                decoration: BoxDecoration(
                    color: contract.status == StatusContract.DONE
                        ? mediumAquamarine
                        : contract.status == StatusContract.BORROWING
                            ? naplesYellow
                            : redCrayola,
                    borderRadius: BorderRadius.circular(8)),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child:
                    ClipOval(child: Image.network(avt, width: 48, height: 48)),
              ),
            ],
          );
        }),
        minLeadingWidth: 12,
        title: Text(
          name,
          style: subhead(context: context),
        ),
        subtitle: Text(
          email,
          style: footnote(color: grey3),
        ),
        trailing: Text(
          '${isIncome ? '' : '-'}${userBloc.userModel!.currencySymbol}${convertString(money.toString())}',
          style: subhead(color: isIncome ? bleuDeFrance : redCrayola),
        ),
      ),
    );
  }

  Widget moneyBox(String title, double money, bool isBorrow) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration:
          BoxDecoration(color: white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: body(context: context),
          ),
          const SizedBox(
            height: 16,
          ),
          FittedBox(
            child: Text(
              '${isBorrow ? '' : '-'}${userBloc.userModel!.currencySymbol}${convertString(money.toString())}',
              style: title3(color: isBorrow ? bleuDeFrance : redCrayola),
            ),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    userBloc = BlocProvider.of<UserBloc>(context);
    contractsBloc = BlocProvider.of<ContractsBloc>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppWidget.createSimpleAppBar(
        context: context,
        title: LocaleKeys.contracts.tr(),
        hasLeading: true,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: AnimationClick(
        function: () {
          Navigator.of(context).pushNamed(Routes.handleContract,
              arguments: const HandleContract());
        },
        child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: emerald, borderRadius: BorderRadius.circular(20)),
            child: const Icon(
              Icons.add,
              size: 24,
              color: white,
            )),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: moneyBox(LocaleKeys.lend.tr(),
                      contractsBloc.moneyLendTotal, false)),
              const SizedBox(width: 16),
              Expanded(
                  child: moneyBox(LocaleKeys.borrow.tr(),
                      contractsBloc.moneyBorrowTotal, true))
            ],
          ),
          BlocBuilder<TransContractBloc, TransContractState>(
              builder: (context, state) {
            if (state is TransContractLoading) {
              return const SizedBox();
            }
            if (state is TransContractLoaded) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: state.transContract.isNotEmpty ? 24 : 0,
                  ),
                  state.transContract.isNotEmpty
                      ? Text(
                          LocaleKeys.requestPaymentConfirm.tr().toUpperCase(),
                          style: title4(context: context, fontWeight: '700'),
                        )
                      : const SizedBox(),
                  SizedBox(
                    height: state.transContract.isNotEmpty ? 16 : 0,
                  ),
                  ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed(
                                Routes.detailTranContract,
                                arguments: DetailTranContract(
                                    tranContract: state.transContract[index],
                                    contractModel: state
                                        .transContract[index].contractModel!));
                          },
                          child: listTile(
                              context,
                              state.transContract[index].contractModel!
                                  .avtLender,
                              state.transContract[index].contractModel!
                                  .nameContract,
                              state.transContract[index].contractModel!
                                  .emailBorrower,
                              state.transContract[index].moneyPaid.toDouble(),
                              true,
                              state.transContract[index].contractModel!),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const SizedBox(
                          height: 24,
                        );
                      },
                      itemCount: state.transContract.length),
                ],
              );
            }
            return const SizedBox();
          }),
          const SizedBox(
            height: 24,
          ),
          Text(
            LocaleKeys.allContract.tr().toUpperCase(),
            style: title4(context: context, fontWeight: '700'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    ClipOval(
                      child: Container(
                        height: 12,
                        width: 12,
                        decoration:
                            const BoxDecoration(color: mediumAquamarine),
                      ),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      LocaleKeys.done.tr(),
                      style: body(context: context),
                    ),
                  ],
                ),
                Row(
                  children: [
                    ClipOval(
                      child: Container(
                        height: 12,
                        width: 12,
                        decoration: const BoxDecoration(color: naplesYellow),
                      ),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      LocaleKeys.borrowing.tr(),
                      style: body(context: context),
                    ),
                  ],
                ),
                Row(
                  children: [
                    ClipOval(
                      child: Container(
                        height: 12,
                        width: 12,
                        decoration: const BoxDecoration(color: redCrayola),
                      ),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      'Waiting',
                      style: body(context: context),
                    ),
                  ],
                )
              ],
            ),
          ),
          BlocBuilder<ContractsBloc, ContractsState>(builder: (context, state) {
            if (state is ContractsLoading) {
              return const Center(
                child: CupertinoActivityIndicator(
                  animating: true,
                ),
              );
            }
            if (state is ContractsLoaded) {
              return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final ContractModel contract = state.contractTotal[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(Routes.detailContract,
                            arguments: DetailContract(
                              contractModel: contract,
                            ));
                      },
                      child: listTile(
                          context,
                          contract.emailLender == userBloc.userModel!.email
                              ? contract.avtBorrower
                              : contract.avtLender,
                          contract.nameContract,
                          contract.emailBorrower == userBloc.userModel!.email
                              ? contract.emailLender
                              : contract.emailBorrower,
                          contract.money.toDouble(),
                          contract.emailBorrower == userBloc.userModel!.email,
                          contract),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const SizedBox(
                      height: 24,
                    );
                  },
                  itemCount: state.contractTotal.length);
            }
            return const SizedBox();
          }),
        ],
      ),
    );
  }
}

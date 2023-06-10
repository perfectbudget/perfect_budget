import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monsey/app/widget_support.dart';
import 'package:monsey/common/constant/colors.dart';
import 'package:monsey/common/constant/enums.dart';
import 'package:monsey/common/constant/styles.dart';
import 'package:monsey/common/model/contract_model.dart';
import 'package:monsey/common/model/transaction_contract_model.dart';
import 'package:monsey/common/widget/bottom_button.dart';
import 'package:monsey/common/widget/unfocus_click.dart';
import 'package:monsey/feature/onboarding/bloc/user/user_bloc.dart';
import 'package:monsey/translations/export_lang.dart';

import '../../../common/constant/images.dart';
import '../../../common/model/transaction_model.dart';
import '../../../common/util/form_validator.dart';
import '../../../common/util/format_time.dart';
import '../../../common/util/helper.dart';
import '../../../common/widget/animation_click.dart';
import '../../../common/widget/app_bar_cpn.dart';
import '../../../common/widget/textfield.dart';
import '../../transaction/widget/calendar.dart';
import '../bloc/contracts/bloc_contracts.dart';
import '../bloc/trans_contract.dart/bloc_trans_contract.dart';

class DetailTranContract extends StatefulWidget {
  const DetailTranContract({Key? key, this.tranContract, this.contractModel})
      : super(key: key);
  final TransactionContractModel? tranContract;
  final ContractModel? contractModel;
  @override
  State<DetailTranContract> createState() => _DetailTranContractState();
}

class _DetailTranContractState extends State<DetailTranContract> {
  TransactionContractModel? _tranContract;
  ContractModel? _contractModel;
  TextEditingController moneyPaidCtl = TextEditingController();
  FocusNode moneyPaidFn = FocusNode();
  TextEditingController dateCtl = TextEditingController();
  FocusNode dateFn = FocusNode();
  TextEditingController noteCtl = TextEditingController();
  FocusNode noteFn = FocusNode();

  late TransContractBloc transContractBloc;
  late UserBloc userBloc;

  bool isCreateTran = true;
  DateTime dateSelected = now;

  Future<void> setDate() async {
    await showModalBottomSheet<DateTime>(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: white,
      builder: (BuildContext context) {
        return CalendarCpn(previousSelectedDate: now);
      },
      context: context,
    ).then((dynamic value) {
      if (value != null) {
        setState(() {
          dateSelected = value;
          dateCtl.text =
              FormatTime.formatTime(dateTime: value, format: Format.mdy);
        });
      }
    });
  }

  String convertString(String suggest) {
    return formatMoney(context).format(!suggest.contains('.')
        ? (int.tryParse(suggest.replaceAll(',', '')) ?? 0)
        : (double.tryParse(suggest.replaceAll(',', '')) ?? 0));
  }

  Widget container({required Widget child, double? marginVer}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: marginVer ?? 16, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration:
          BoxDecoration(color: white, borderRadius: BorderRadius.circular(12)),
      child: child,
    );
  }

  void createTransContract() {
    final int money = int.tryParse(moneyPaidCtl.text) ?? 0;
    transContractBloc.add(CreateTransContract(
        context,
        TransactionContractModel(
            payDate: dateSelected,
            status: StatusTranCt.WAITING,
            moneyPaid: money,
            note: noteCtl.text,
            contractModel: _contractModel,
            contractId: _contractModel!.id!)));
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    if (widget.contractModel != null) {
      _contractModel = widget.contractModel!;
    }
    isCreateTran = widget.tranContract == null;
    if (!isCreateTran) {
      _tranContract = widget.tranContract;
    }
    super.initState();
  }

  @override
  void didChangeDependencies() {
    transContractBloc = BlocProvider.of<TransContractBloc>(context);
    userBloc = BlocProvider.of<UserBloc>(context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    dateCtl.dispose();
    dateFn.dispose();
    moneyPaidCtl.dispose();
    moneyPaidFn.dispose();
    noteCtl.dispose();
    noteFn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return UnfocusClick(
      child: Scaffold(
        appBar: AppBarCpn(
          color: white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Image.asset(icArrowLeft, width: 24, height: 24)),
                Text(
                  isCreateTran
                      ? LocaleKeys.createPaidTransaction.tr()
                      : LocaleKeys.confirmTransaction.tr(),
                  style: headline(context: context),
                ),
                const SizedBox()
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomButton(
          child: !isCreateTran
              ? Row(
                  children: [
                    Expanded(
                        child: OutlinedButton(
                      onPressed: () {
                        transContractBloc
                            .add(RemoveTransContract(context, _tranContract!));
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 13, horizontal: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(48),
                          ),
                          side: const BorderSide(color: purplePlum)),
                      child: Text(LocaleKeys.reject.tr(),
                          textAlign: TextAlign.center,
                          style: headline(color: purplePlum)),
                    )),
                    const SizedBox(width: 24),
                    Expanded(
                      child: AppWidget.typeButtonStartAction(
                          context: context,
                          input: LocaleKeys.accept.tr(),
                          onPressed: () {
                            transContractBloc.add(UpdateTransContract(
                                context, _tranContract!.id!));
                            int moneyPaid = _tranContract!.moneyPaid;
                            final List<TransactionModel> trans =
                                _tranContract!.contractModel!.transactions!;
                            if (trans.isNotEmpty && trans.length > 1) {
                              for (TransactionModel tran in trans) {
                                moneyPaid += tran.balance.toInt();
                              }
                            }
                            if (moneyPaid >=
                                _tranContract!.contractModel!.realMoneyToPay) {
                              context.read<ContractsBloc>().add(UpdateContract(
                                  context,
                                  _tranContract!.contractModel!.id!,
                                  StatusContract.DONE));
                            }
                            Navigator.of(context).pop();
                          },
                          bgColor: emerald,
                          textColor: white),
                    ),
                  ],
                )
              : AppWidget.typeButtonStartAction(
                  context: context,
                  input: LocaleKeys.send.tr(),
                  onPressed: FormValidator.isNumeric(s: moneyPaidCtl.text)
                      ? createTransContract
                      : () {},
                  bgColor: FormValidator.isNumeric(s: moneyPaidCtl.text)
                      ? emerald
                      : grey4,
                  textColor: white),
        ),
        body: ListView(
          children: [
            container(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${LocaleKeys.lender.tr()}',
                        style: body(context: context, fontWeight: '700'),
                      ),
                      Expanded(
                        child: Text(
                          _contractModel!.emailLender,
                          textAlign: TextAlign.end,
                          style: callout(context: context, fontWeight: '600'),
                        ),
                      )
                    ],
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    height: 1,
                    decoration: const BoxDecoration(color: grey6),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        LocaleKeys.borrower.tr(),
                        style: body(context: context, fontWeight: '700'),
                      ),
                      Expanded(
                        child: Text(
                          _contractModel!.emailBorrower,
                          textAlign: TextAlign.end,
                          style: callout(context: context, fontWeight: '600'),
                        ),
                      )
                    ],
                  ),
                ])),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                LocaleKeys.information.tr().toUpperCase(),
                style: title4(context: context, fontWeight: '700'),
              ),
            ),
            container(
                marginVer: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: isCreateTran
                      ? [
                          Text('${LocaleKeys.moneyPaid.tr()}',
                              style: body(context: context)),
                          const SizedBox(height: 8),
                          TextFieldCpn(
                            controller: moneyPaidCtl,
                            focusNode: moneyPaidFn,
                            hintText: '100,000',
                            showSuffixIcon: true,
                            suffixWidget: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Text(
                                userBloc.userModel!.currencyCode!,
                                style: subhead(context: context),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text('${LocaleKeys.payDate.tr()}',
                              style: body(context: context)),
                          const SizedBox(height: 8),
                          AnimationClick(
                            function: setDate,
                            child: TextFieldCpn(
                                readOnly: true,
                                prefixIcon: icCalendar,
                                showPrefixIcon: true,
                                controller: dateCtl,
                                focusNode: dateFn,
                                hintText: LocaleKeys.payDate.tr()),
                          ),
                          const SizedBox(height: 24),
                          Text('${LocaleKeys.note.tr()}',
                              style: body(context: context)),
                          const SizedBox(height: 8),
                          TextFieldCpn(
                            controller: noteCtl,
                            focusNode: noteFn,
                            hintText: LocaleKeys.enterNote.tr(),
                            maxLines: 5,
                          ),
                        ]
                      : [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                LocaleKeys.nameContract.tr(),
                                style: callout(
                                    context: context, fontWeight: '700'),
                              ),
                              const Expanded(child: SizedBox()),
                              Text(
                                _contractModel!.nameContract,
                                style: callout(context: context),
                              ),
                            ],
                          ),
                          AppWidget.divider(context, vertical: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                LocaleKeys.moneyPaid.tr(),
                                style: callout(
                                    context: context, fontWeight: '700'),
                              ),
                              const Expanded(child: SizedBox()),
                              Text('${_tranContract!.moneyPaid}',
                                  style: callout(context: context)),
                            ],
                          ),
                          AppWidget.divider(context, vertical: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                LocaleKeys.payDate.tr(),
                                style: callout(
                                    context: context, fontWeight: '700'),
                              ),
                              const Expanded(child: SizedBox()),
                              Text('${_tranContract!.payDate}',
                                  style: callout(context: context)),
                            ],
                          ),
                          AppWidget.divider(context, vertical: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                LocaleKeys.note.tr(),
                                style: callout(
                                    context: context, fontWeight: '700'),
                              ),
                              const Expanded(child: SizedBox()),
                              Text('${_tranContract!.note}',
                                  style: callout(context: context)),
                            ],
                          ),
                        ],
                )),
          ],
        ),
      ),
    );
  }
}

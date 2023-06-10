import 'package:flutter/material.dart';
import 'package:monsey/common/widget/textfield.dart';

import '../../../app/widget_support.dart';
import '../../../common/constant/colors.dart';
import '../../../common/widget/unfocus_click.dart';
import '../../../translations/export_lang.dart';

class NoteTransaction extends StatefulWidget {
  const NoteTransaction({Key? key}) : super(key: key);

  @override
  State<NoteTransaction> createState() => _NoteTransactionState();
}

class _NoteTransactionState extends State<NoteTransaction> {
  TextEditingController noteCtl = TextEditingController();
  FocusNode noteFn = FocusNode();
  @override
  void dispose() {
    noteCtl.dispose();
    noteFn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppWidget.createSimpleAppBar(
          context: context,
          title: LocaleKeys.note.tr(),
          onBack: () {
            Navigator.of(context).pop(noteCtl.text.trim());
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: AppWidget.typeButtonStartAction(
            context: context,
            input: LocaleKeys.done.tr(),
            onPressed: () {
              Navigator.of(context).pop(noteCtl.text.trim());
            },
            bgColor: emerald,
            textColor: white),
      ),
      body: UnfocusClick(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
          children: [
            TextFieldCpn(
              autoFocus: true,
              controller: noteCtl,
              focusNode: noteFn,
              hintText: LocaleKeys.writeANote.tr(),
            ),
          ],
        ),
      ),
    );
  }
}

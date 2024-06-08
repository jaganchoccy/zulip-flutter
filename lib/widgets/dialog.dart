import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/zulip_localizations.dart';

Widget _dialogActionText(String text) {
  return Text(
    text,

    // As suggested by
    //   https://api.flutter.dev/flutter/material/AlertDialog/actions.html :
    // > It is recommended to set the Text.textAlign to TextAlign.end
    // > for the Text within the TextButton, so that buttons whose
    // > labels wrap to an extra line align with the overall
    // > OverflowBar's alignment within the dialog.
    textAlign: TextAlign.end,
  );
}

Future<void> showErrorDialog({
  required BuildContext context,
  required String title,
  String? message,
  VoidCallback? onDismiss,
}) {
  final zulipLocalizations = ZulipLocalizations.of(context);
  return showDialog(
    context: context,
    // `showDialog` doesn't take an `onDismiss`, so dismissing via the barrier
    // always causes the default dismiss behavior of popping just this route.
    // When we want a non-default `onDismiss`, disable that.
    // TODO(upstream): add onDismiss to showDialog, passing through to [ModalBarrier.onDismiss]
    barrierDismissible: onDismiss == null,
    builder: (BuildContext context) => AlertDialog(
      title: Text(title),
      content: message != null ? SingleChildScrollView(child: Text(message)) : null,
      actions: [
        TextButton(
          onPressed: onDismiss ?? () => Navigator.pop(context),
          child: _dialogActionText(zulipLocalizations.errorDialogContinue)),
      ]));
}

void showSuggestedActionDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String? actionButtonText,
  required VoidCallback onActionButtonPress,
}) {
  final zulipLocalizations = ZulipLocalizations.of(context);
  showDialog<void>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(child: Text(message)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: _dialogActionText(zulipLocalizations.dialogCancel)),
        TextButton(
          onPressed: onActionButtonPress,
          child: _dialogActionText(actionButtonText ?? zulipLocalizations.dialogContinue)),
      ]));
}

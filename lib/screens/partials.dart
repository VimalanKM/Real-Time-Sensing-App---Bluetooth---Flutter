import 'package:equity_ware_app_flutter/services/ws_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:equity_ware_app_flutter/types.dart';

void alertOnUnsafe(BuildContext context, Event event) {
  showPlatformDialog(
    context: context,
    builder: (context) => BasicDialogAlert(
      title: Text("${event.description}. Do you want us to call you for help?"),
      content: const Text(
          "Our calls will be recorded and we can help you get access to safety resources."),
      actions: <Widget>[
        BasicDialogAction(
          title: const Text("Cancel"),
          onPressed: () {
            Navigator.pop(context);
            WSService().pushLog("alert", "cancelled");
          },
        ),
        BasicDialogAction(
          title: const Text("Share My Location"),
          onPressed: () {
            Navigator.pop(context);
            WSService().pushLog("alert", "share");
          },
        ),
        BasicDialogAction(
          title: const Text("Call Me"),
          onPressed: () {
            Navigator.pop(context);
            WSService().pushLog("alert", "call");
          },
        ),
      ],
    ),
  );
}

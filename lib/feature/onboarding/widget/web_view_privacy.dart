import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../app/widget_support.dart';

class WebViewPrivacy extends StatefulWidget {
  const WebViewPrivacy({this.url, this.title});
  final String? url;
  final String? title;
  @override
  _WebViewPrivacyState createState() => _WebViewPrivacyState();
}

class _WebViewPrivacyState extends State<WebViewPrivacy> {
  late final WebViewController _controller;

  Future<String> get _url async {
    await Future<dynamic>.delayed(const Duration(seconds: 1));
    return widget.url!;
  }

  @override
  void initState() {
    _controller = WebViewController()
      ..loadRequest(
        Uri.parse(widget.url!),
      );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppWidget.createSimpleAppBar(context: context, title: widget.title),
      body: FutureBuilder<String?>(
        future: _url,
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            return WebViewWidget(
              controller: _controller,
            );
          }
          return const Center(
            child: CupertinoActivityIndicator(
              animating: true,
            ),
          );
        },
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(true);
  }

  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  HeadlessInAppWebView? headlessWebView;
  PullToRefreshController? pullToRefreshController;
  InAppWebViewController? webViewController;

  String url = "";
  int progress = 0;
  bool convertFlag = false;

  @override
  void initState() {
    super.initState();

    pullToRefreshController = kIsWeb || ![TargetPlatform.iOS, TargetPlatform.android].contains(defaultTargetPlatform)
        ? null
        : PullToRefreshController(
      settings: PullToRefreshSettings(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (defaultTargetPlatform == TargetPlatform.android) {
          webViewController?.reload();
        } else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
          webViewController?.loadUrl( urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );

    headlessWebView = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: WebUri("https://rpms.reena.org")),
      pullToRefreshController: pullToRefreshController,
      onWebViewCreated: (controller) {
        webViewController = controller;

        const snackBar = SnackBar(
          content: Text('HeadlessInAppWebView created!'),
          duration: Duration(seconds: 1),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      },
      onLoadStart: (controller, url) async {
        setState(() {
          this.url = url?.toString() ?? '';
        });
      },
      onProgressChanged: (controller, progress) {
        setState(() {
          this.progress = progress;
        });
      },
      onLoadStop: (controller, url) async {
        setState(() {
          this.url = url?.toString() ?? '';
        });
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    headlessWebView?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(
              "HeadlessInAppWebView to InAppWebView",
              textScaleFactor: .8,
            )),
        body: Column(children: <Widget>[
          Container(
            padding: EdgeInsets.all(20.0),
            child: Text(
                "URL: ${(url.length > 40) ? url.substring(0, 40) + "..." : url} - $progress%"),
          ),
          !convertFlag
              ? Center(
            child: ElevatedButton(
                onPressed: () async {
                  var headlessWebView = this.headlessWebView;
                  if (headlessWebView != null && !headlessWebView.isRunning()) {
                    await headlessWebView.run();
                  }
                },
                child: Text("Run HeadlessInAppWebView")),
          )
              : Container(),
          !convertFlag
              ? Center(
            child: ElevatedButton(
                onPressed: () {
                  if (!convertFlag && progress == 100) {
                    setState(() {
                      convertFlag = true;
                    });
                  }else{
                    const snackBar = SnackBar(
                      content: Text('HeadlessInAppWebView not loaded fully!'), duration: Duration(seconds: 3),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                },
                child: Text("Convert to InAppWebView")),
          )
              : Container(),
          convertFlag
              ? Expanded(
              child: InAppWebView(
                headlessWebView: headlessWebView,
                onWebViewCreated: (controller) {
                  headlessWebView = null;
                  webViewController = controller;
                  const snackBar = SnackBar(
                    content: Text('HeadlessInAppWebView converted to InAppWebView!'), duration: Duration(seconds: 1),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
                onLoadStart: (controller, url) {
                  setState(() {
                    this.url = url?.toString() ?? "";
                  });
                },
                onProgressChanged: (controller, progress) {
                  if (progress == 100) {
                    pullToRefreshController?.endRefreshing();
                  }
                  setState(() {
                    this.progress = progress;
                  });
                },
                onLoadStop: (controller, url) {
                  pullToRefreshController?.endRefreshing();
                  setState(() {
                    this.url = url?.toString() ?? "";
                  });
                },
                onReceivedError: (controller, request, error) {
                  pullToRefreshController?.endRefreshing();
                },
              ))
              : Container()
        ]));
  }
}
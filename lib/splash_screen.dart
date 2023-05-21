import 'dart:async';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

main() {
  runApp(MyApp());
}

// ignore: use_key_in_widget_constructors
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: SplashScreen()); // define it once at root level.
  }
}

// ignore: use_key_in_widget_constructors
class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    //if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    Timer(
        // ignore: prefer_const_constructors
        Duration(seconds: 3),
        () => Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeScreen())));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: Image.asset('assets/images/en_logo.png', width: 200,)),
    );
  }
}

// ignore: use_key_in_widget_constructors
class HomeScreen extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<HomeScreen> {
  final GlobalKey webViewKey = GlobalKey();
  final String _url = "https://rpms.reena.org/";
  InAppWebViewController? webViewController;

  InAppWebViewSettings settings = InAppWebViewSettings(
      useShouldOverrideUrlLoading: true,
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
      iframeAllow: "camera; microphone",
      iframeAllowFullscreen: true);

  double progress = 0;
  num _stackToView = 1;
  int _selectedTabIndex = 0;
  PullToRefreshController? pullToRefreshController;
  final urlController = TextEditingController();

  // ignore: prefer_final_fields
  List _pages = [
    // ignore: prefer_const_constructors
    Text("Dashboard"),
    // ignore: prefer_const_constructors
    Text("Orders"),
    // ignore: prefer_const_constructors
    Text("Warranty"),
    // ignore: prefer_const_constructors
    Text("Refresh"),
    // ignore: prefer_const_constructors
    Text("Logout"),
  ];

  _changeIndex(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
    if (_selectedTabIndex == 0) {
      webViewController?.loadUrl( urlRequest: URLRequest(url: WebUri("${_url}dashboard2")));
    }
    else if (_selectedTabIndex == 1) {
      webViewController?.loadUrl(urlRequest: URLRequest(url: WebUri("${_url}tblorderslist")));

    } else if (_selectedTabIndex == 2) {
      webViewController?.loadUrl(urlRequest: URLRequest(url: WebUri("${_url}tblwarrantylist")));

    } else if (_selectedTabIndex == 3) {
      //webViewController?.clearCache();
      webViewController?.reload();
    }
    else if (_selectedTabIndex == 4) {
      webViewController?.loadUrl(urlRequest: URLRequest(url: WebUri("${_url}logout")));
    }
  }

  void _handleLoad(String value) {
    setState(() {
      _stackToView = 0;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pullToRefreshController = kIsWeb
        ? null
        : PullToRefreshController(
            settings: PullToRefreshSettings(
              color: Colors.blue,
            ),
            onRefresh: () async {
              if (defaultTargetPlatform == TargetPlatform.android) {
                webViewController?.reload();
              } else if (defaultTargetPlatform == TargetPlatform.iOS) {
                webViewController?.loadUrl(
                    urlRequest:
                        URLRequest(url: await webViewController?.getUrl()));
              }
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      // appBar: AppBar(
      //     /*  automaticallyImplyLeading: false, */
      //     leading: Padding(
      //       padding: EdgeInsets.all(10.0),
      //       child: SvgPicture.asset("assets/images/Helmet.svg"),
      //
      //       /* leadingWidth: 35, */
      //     ),
      //     actions: [
      //       IconButton(
      //         icon: SvgPicture.asset("assets/images/Helmet.svg",
      //             color: Colors.black),
      //         onPressed: () {},
      //       ),
      //     ],
      //     backgroundColor: Colors.white),
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedTabIndex,
            children: [
              Column(
                children: <Widget>[
                  Expanded(
                    child: InAppWebView(
                      key: webViewKey,
                      initialUrlRequest: URLRequest(url: WebUri(_url)),
                      initialSettings: settings,
                      pullToRefreshController: pullToRefreshController,
                      onWebViewCreated: (controller) {
                        webViewController = controller;
                      },
                      onLoadStart: (controller, url) {
                        setState(() {
                          urlController.text = url.toString();
                        });
                      },
                      onPermissionRequest: (controller, request) async {
                        return PermissionResponse(
                            resources: request.resources,
                            action: PermissionResponseAction.GRANT);
                      },
                      shouldOverrideUrlLoading:
                          (controller, navigationAction) async {
                        var uri = navigationAction.request.url!;

                        if (![
                          "http",
                          "https",
                          "file",
                          "chrome",
                          "data",
                          "javascript",
                          "about"
                        ].contains(uri.scheme)) {
                          if (await canLaunchUrl(uri)) {
                            // Launch the App
                            await launchUrl(
                              uri,
                            );
                            // and cancel the request
                            return NavigationActionPolicy.CANCEL;
                          }
                        }

                        return NavigationActionPolicy.ALLOW;
                      },
                      onLoadStop: (controller, url) async {
                        pullToRefreshController?.endRefreshing();
                        setState(() {
                          urlController.text = url.toString();
                        });
                        print("Nasir ${url}");
                      },
                      onReceivedError: (controller, request, error) {
                        pullToRefreshController?.endRefreshing();
                      },
                      onProgressChanged: (controller, progress) {
                        if (progress == 100) {
                          pullToRefreshController?.endRefreshing();
                        }
                        setState(() {
                          this.progress = progress / 100;
                          urlController.text = _url;
                        });
                      },
                      onUpdateVisitedHistory:
                          (controller, url, androidIsReload) {
                        setState(() {
                          urlController.text = url.toString();
                        });
                      },
                      onConsoleMessage: (controller, consoleMessage) {
                        //print(consoleMessage);
                      },
                    ),
                  )
                ],
              ),
              Container(
                child: Center(child: _pages[_selectedTabIndex]),
              ),
            ],
          ),
          /*AppBar(
            /*  automaticallyImplyLeading: false, */
            leading: Padding(
              padding: EdgeInsets.all(10.0),
              child: SvgPicture.asset("assets/images/Helmet.svg"),

              /* leadingWidth: 35, */
            ),
            actions: [
              IconButton(
                icon: SvgPicture.asset("assets/images/Helmet.svg",
                    color: Colors.black),
                onPressed: () {},
              ),
            ],
            backgroundColor: Colors.white,
          ),*/
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTabIndex,
        onTap: _changeIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.blueAccent,
        selectedLabelStyle: textTheme.caption,
        unselectedLabelStyle: textTheme.caption,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black.withOpacity(.60),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(FluentSystemIcons.ic_fluent_home_regular),
              activeIcon: Icon(FluentSystemIcons.ic_fluent_home_filled),
              label: "DashBoard"),
          BottomNavigationBarItem(
              icon: Icon(FluentSystemIcons.ic_fluent_list_regular),
              activeIcon: Icon(FluentSystemIcons.ic_fluent_list_filled),
              label: "Orders"),
          BottomNavigationBarItem(
              icon: Icon(FluentSystemIcons.ic_fluent_app_folder_regular),
              activeIcon: Icon(FluentSystemIcons.ic_fluent_app_folder_filled),
              label: "Warranty"),
          BottomNavigationBarItem(
              icon: Icon(Icons.refresh),
              activeIcon: Icon(Icons.refresh_outlined),
              label: "Refresh"),
          BottomNavigationBarItem(
              icon: Icon(Icons.logout),
              activeIcon: Icon(Icons.logout_outlined),
              label: "Logout"),
        ],
      ),
    );
  }
}

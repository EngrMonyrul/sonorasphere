// ignore_for_file: use_build_context_synchronously

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class WebSitePageView extends StatefulWidget {
  const WebSitePageView({super.key});

  @override
  State<WebSitePageView> createState() => _WebSitePageViewState();
}

class _WebSitePageViewState extends State<WebSitePageView> {
  InAppWebViewController? inAppWebViewController;
  PullToRefreshController? pullToRefreshController;
  late var url;
  double progressValue = 0;
  var urlController = TextEditingController();
  String initialUrl = 'https://www.google.com/';
  bool isLoading = false;
  bool showOption = false;
  int backCount = 0;
  String videoUrl = '';
  bool showCategory = false;
  var yt = YoutubeExplode();

  @override
  void initState() {
    super.initState();
    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.white,
        backgroundColor: Colors.blue,
      ),
      onRefresh: () {
        setState(() {
          inAppWebViewController!.reload();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: showOption
          ? Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: FloatingActionButton(
                onPressed: () {
                  inAppWebViewController!.reload();
                  setState(() {
                    showCategory = true;
                  });

                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog();
                    },
                  );
                },
              ),
            )
          : null,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () async {
            if (await inAppWebViewController!.canGoBack()) {
              inAppWebViewController!.goBack();
            }
          },
        ),
        title: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: TextField(
            controller: urlController,
            textAlignVertical: TextAlignVertical.center,
            cursorOpacityAnimates: true,
            decoration: const InputDecoration(
              enabledBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              hintText: 'Search websites',
              prefixIcon: Icon(CupertinoIcons.search),
            ),
            onSubmitted: (value) {
              url = Uri.parse(value);
              if (url.scheme.isEmpty) {
                url = Uri.parse('${initialUrl}search?q=$value');
              }
              inAppWebViewController!.loadUrl(urlRequest: URLRequest(url: url));
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 30, color: Colors.white),
            onPressed: () {
              setState(() {
                inAppWebViewController!.reload();
              });
            },
          ),
        ],
      ),
      body: WillPopScope(
        onWillPop: () async {
          if (await inAppWebViewController!.canGoBack()) {
            inAppWebViewController!.goBack();
          } else {
            setState(() {
              backCount++;
            });
            if (backCount == 2) {
              SystemNavigator.pop();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Center(
                    child: Text('Press Again To Exit'),
                  ),
                ),
              );
            }
            Future.delayed(const Duration(seconds: 3), () {
              setState(() {
                backCount = 0;
              });
            });
          }
          return false;
        },
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  InAppWebView(
                    onWebViewCreated: (controller) {
                      setState(() {
                        inAppWebViewController = controller;
                      });
                    },
                    onLoadStart: (controller, url) {
                      print('ok');
                      setState(() {
                        urlController.text = url.toString();
                        isLoading = true;
                        if (url.toString().contains('youtube.com') || url.toString().contains('youtu.be')) {
                          showOption = true;
                        }
                      });
                    },
                    onProgressChanged: (controller, progress) {
                      if (progress == 100) {
                        pullToRefreshController!.endRefreshing();
                      }
                      setState(() {
                        progressValue = progress / 100;
                      });
                    },
                    onJsConfirm: (controller, jsConfirmRequest) async {
                      print('confirm');
                      return null;
                    },
                    initialUrlRequest: URLRequest(url: Uri.parse(initialUrl)),
                    pullToRefreshController: pullToRefreshController,
                    onLoadStop: (controller, url) {
                      setState(() {
                        pullToRefreshController!.endRefreshing();
                        isLoading = false;
                      });
                    },
                  ),
                  Visibility(
                    visible: isLoading,
                    child: Center(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(
                              color: Colors.blue,
                            ),
                            const SizedBox(height: 10),
                            Text('${(progressValue * 100).toStringAsFixed(0)}%'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

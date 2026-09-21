import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../app/theme/app_colors.dart';

void openInAppWeb(
  BuildContext context,
  String url, {
  String? title,
}) {
  final uri = Uri.tryParse(url.trim());
  if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
    return;
  }

  Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute<void>(
      builder: (_) => InAppBrowserPage(uri: uri, title: title),
    ),
  );
}

class InAppBrowserPage extends StatefulWidget {
  const InAppBrowserPage({
    super.key,
    required this.uri,
    this.title,
  });

  final Uri uri;
  final String? title;

  @override
  State<InAppBrowserPage> createState() => _InAppBrowserPageState();
}

class _InAppBrowserPageState extends State<InAppBrowserPage> {
  late final WebViewController _controller;
  var _progress = 0;
  var _pageTitle = '';
  var _canGoBack = false;

  @override
  void initState() {
    super.initState();
    _pageTitle = widget.title?.trim() ?? '';
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.background)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (!mounted) {
              return;
            }
            setState(() => _progress = progress);
          },
          onPageFinished: (_) async {
            final title = await _controller.getTitle();
            final canGoBack = await _controller.canGoBack();
            if (!mounted) {
              return;
            }
            setState(() {
              _progress = 100;
              _canGoBack = canGoBack;
              if (_pageTitle.isEmpty &&
                  title != null &&
                  title.trim().isNotEmpty) {
                _pageTitle = title.trim();
              }
            });
          },
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (uri == null) {
              return NavigationDecision.prevent;
            }
            if (uri.scheme == 'http' || uri.scheme == 'https') {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(widget.uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _pageTitle.isEmpty ? widget.uri.host : _pageTitle,
          overflow: TextOverflow.ellipsis,
        ),
        leading: IconButton(
          tooltip: 'Cerrar',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.close_rounded),
        ),
        actions: [
          IconButton(
            tooltip: 'Atrás',
            onPressed: _canGoBack ? () => _controller.goBack() : null,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_progress < 100)
            LinearProgressIndicator(
              value: _progress == 0 ? null : _progress / 100,
              minHeight: 2,
              color: AppColors.accent,
              backgroundColor: AppColors.surfaceHigh,
            ),
          Expanded(child: WebViewWidget(controller: _controller)),
        ],
      ),
    );
  }
}

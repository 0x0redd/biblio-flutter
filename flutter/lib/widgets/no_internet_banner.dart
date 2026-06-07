import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';

class NoInternetBanner extends StatefulWidget {
  const NoInternetBanner({super.key, required this.child});

  final Widget child;

  @override
  State<NoInternetBanner> createState() => _NoInternetBannerState();
}

class _NoInternetBannerState extends State<NoInternetBanner> {
  bool _offline = false;

  @override
  void initState() {
    super.initState();
    Connectivity().onConnectivityChanged.listen((results) {
      final offline = results.every((r) => r == ConnectivityResult.none);
      if (mounted && offline != _offline) {
        setState(() => _offline = offline);
      }
    });
    _checkInitial();
  }

  Future<void> _checkInitial() async {
    final results = await Connectivity().checkConnectivity();
    final offline = results.every((r) => r == ConnectivityResult.none);
    if (mounted) setState(() => _offline = offline);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_offline)
          MaterialBanner(
            content: const Text(AppStrings.noInternet),
            backgroundColor: AppColors.error.withValues(alpha: 0.9),
            leading: const Icon(Icons.wifi_off, color: Colors.white),
            actions: const [SizedBox.shrink()],
          ),
        Expanded(child: widget.child),
      ],
    );
  }
}

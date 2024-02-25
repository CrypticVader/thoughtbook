import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:thoughtbook/src/extensions/buildContext/loc.dart';
import 'package:thoughtbook/src/extensions/buildContext/theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 64),
          const Spacer(flex: 1),
          Image.asset(
            'assets/icon/icon.png',
            height: 192,
            width: 192,
            cacheHeight: 288,
            cacheWidth: 288,
          ),
          const SizedBox(height: 32),
          Text(
            context.loc.app_title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: context.themeColors.onSurfaceVariant.withAlpha(200),
            ),
          ),
          const Spacer(flex: 1),
          SpinKitThreeBounce(
            color: context.theme.colorScheme.primary.withAlpha(200),
            size: 48,
          ),
          const SizedBox(height: 64),
        ],
      ),
    );
  }
}

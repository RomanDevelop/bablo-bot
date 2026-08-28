import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/auth/auth_session.dart';

/// Runs Telegram auth bootstrap once when the app starts.
class AuthInitializer extends StatefulWidget {
  const AuthInitializer({super.key, required this.child});

  final Widget child;

  @override
  State<AuthInitializer> createState() => _AuthInitializerState();
}

class _AuthInitializerState extends State<AuthInitializer> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AuthSession>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:health_portal/customs/app_bar_custom.dart';
import 'package:local_auth/local_auth.dart';

class LocalAuthScreen extends StatefulWidget {
  const LocalAuthScreen({super.key});

  @override
  State<LocalAuthScreen> createState() => _LocalAuthScreenState();
}

class _LocalAuthScreenState extends State<LocalAuthScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Local Authentication'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              LocalAuthService()._isAuthenticated
                  ? 'Authenticated!'
                  : 'Not Authenticated',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: LocalAuthService().loginWithBiometrics,
              child: Text('Authenticate'),
            ),
          ],
        ),
      ),
    );
  }
}

class LocalAuthService {
  final LocalAuthentication _localAuth;

  LocalAuthService({LocalAuthentication? localAuth})
      : _localAuth = localAuth ?? LocalAuthentication();

  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  Future<bool> _authenticate() async {
    try {
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!canCheckBiometrics || !isDeviceSupported) {
        log("Biometric authentication not available or not supported.");
        return false;
      }

      _isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access the app',
        options: const AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
      log(_isAuthenticated.toString());
      return _isAuthenticated;
    } catch (e) {
      log("Error during authentication: $e");
      return false;
    }
  }

  Future<bool> loginWithBiometrics() async {
    return await _authenticate();
  }

  void logout() {
    _isAuthenticated = false;
    log("User logged out.");
  }
}

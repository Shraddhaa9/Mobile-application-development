import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'home_page.dart';
import 'utils/session_manager.dart';
import 'utils/auth_service.dart';

class BattleShips extends StatefulWidget {
  const BattleShips({Key? key}) : super(key: key);

  @override
  _BattleShipsState createState() => _BattleShipsState();
}

class _BattleShipsState extends State<BattleShips> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService authService = AuthService();

  Future<void> _register() async {
    final String username = usernameController.text.trim();
    final String password = passwordController.text.trim();

    try {
      final result = await authService.registerUser(username, password);
      final String? token = result['access_token'];

      if (token != null) {
        await SessionManager.setSessionToken(token);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(currentUser: username),
          ),
        );
      } else {
        _showErrorDialog('Registration failed', 'Token is null');
      }
    } catch (e) {
      _showErrorDialog('Registration failed', e.toString());
    }
  }

  Future<void> _login() async {
    final String username = usernameController.text;
    final String password = passwordController.text;

    try {
      final result = await authService.loginUser(username, password);
      final String? token = result['access_token'];

      if (token != null) {
        await SessionManager.setSessionToken(token);
        if (kDebugMode) print('Login successful! Token: $token');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              currentUser: username,
            ),
          ),
        );
      } else {
        if (kDebugMode) print('Login failed. Token is null.');
        _showErrorDialog('Login failed', 'Token is null');
      }
    } catch (e) {
      if (kDebugMode) print('Login failed. Error: $e');
      _showErrorDialog('Login failed', e.toString());
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the alert dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BattleShips'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _login,
                  child: const Text('Login'),
                ),
                ElevatedButton(
                  onPressed: _register,
                  child: const Text('Register'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_matrix_example/room_list_page.dart';
import 'package:matrix/matrix.dart';

class LoginPage extends StatefulWidget {
  final Client client;
  const LoginPage({required this.client, super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _homeserverTextField = TextEditingController(
    text: 'matrix.org',
  );
  final TextEditingController _usernameTextField = TextEditingController();
  final TextEditingController _passwordTextField = TextEditingController();

  bool _loading = false;

  void _login() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _loading = true;
    });

    try {
      final client = widget.client;
      await client
          .checkHomeserver(Uri.https(_homeserverTextField.text.trim(), ''));
      await client.login(
        LoginType.mLoginPassword,
        password: _passwordTextField.text,
        identifier: AuthenticationUserIdentifier(user: _usernameTextField.text),
      );
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => RoomListPage(client: client)),
        (route) => false,
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _homeserverTextField,
              readOnly: _loading,
              autocorrect: false,
              decoration: const InputDecoration(
                prefixText: 'https://',
                border: OutlineInputBorder(),
                labelText: 'Homeserver',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameTextField,
              readOnly: _loading,
              autocorrect: false,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Username',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordTextField,
              readOnly: _loading,
              autocorrect: false,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const LinearProgressIndicator()
                    : const Text('Login'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

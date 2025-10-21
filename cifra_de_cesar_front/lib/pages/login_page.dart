import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userC = TextEditingController();
  final _passC = TextEditingController();

  @override
  void dispose() {
    _userC.dispose();
    _passC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthController>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomTextField(label: 'Usuário', controller: _userC),
            const SizedBox(height: 12),
            CustomTextField(label: 'Senha', controller: _passC, obscure: true),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Entrar',
              onPressed: () async {
                final ok = await auth.login(_userC.text, _passC.text);
                if (ok) {
                  if (!mounted) return;
                  Navigator.of(context).pushReplacementNamed('/encrypt');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

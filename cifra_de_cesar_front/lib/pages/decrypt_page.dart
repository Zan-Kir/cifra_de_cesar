import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/cesar_controller.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class DecryptPage extends StatefulWidget {
  const DecryptPage({Key? key}) : super(key: key);

  @override
  State<DecryptPage> createState() => _DecryptPageState();
}

class _DecryptPageState extends State<DecryptPage> {
  late TextEditingController _inputC;
  late TextEditingController _shiftC;

  @override
  void initState() {
    super.initState();
    _inputC = TextEditingController();
    _shiftC = TextEditingController(text: '3');
  }

  @override
  void dispose() {
    _inputC.dispose();
    _shiftC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Provider.of<CesarController>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Descriptografar'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/encrypt');
            },
            icon: const Icon(Icons.swap_horiz),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomTextField(label: 'Texto (criptografado)', controller: _inputC),
            const SizedBox(height: 8),
            CustomTextField(label: 'Deslocamento (shift)', controller: _shiftC, keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Descriptografar',
              onPressed: () {
                ctrl.setInput(_inputC.text);
                final s = int.tryParse(_shiftC.text) ?? 3;
                ctrl.setShift(s);
                ctrl.decrypt();
              },
            ),
            const SizedBox(height: 12),
            SelectableText('Resultado: ${ctrl.result}'),
            const SizedBox(height: 12),
            PrimaryButton(label: 'Limpar', onPressed: () {
              _inputC.clear();
              _shiftC.text = '3';
              ctrl.clear();
            })
          ],
        ),
      ),
    );
  }
}

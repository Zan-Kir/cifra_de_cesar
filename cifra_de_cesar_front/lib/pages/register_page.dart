import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import '../theme/app_theme.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with SingleTickerProviderStateMixin {
  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  final _confirmPassC = TextEditingController();
  bool _isLoading = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _emailC.dispose();
    _passC.dispose();
    _confirmPassC.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    // Validações
    if (_emailC.text.trim().isEmpty) {
      _showError('Por favor, insira um email');
      return;
    }

    if (!_emailC.text.contains('@')) {
      _showError('Por favor, insira um email válido');
      return;
    }

    if (_passC.text.isEmpty) {
      _showError('Por favor, insira uma senha');
      return;
    }

    if (_passC.text.length < 8) {
      _showError('A senha deve ter pelo menos 8 caracteres');
      return;
    }

    // Validações de senha forte
    if (!RegExp(r'[A-Z]').hasMatch(_passC.text)) {
      _showError('A senha deve conter pelo menos uma letra maiúscula');
      return;
    }

    if (!RegExp(r'[a-z]').hasMatch(_passC.text)) {
      _showError('A senha deve conter pelo menos uma letra minúscula');
      return;
    }

    if (!RegExp(r'[0-9]').hasMatch(_passC.text)) {
      _showError('A senha deve conter pelo menos um número');
      return;
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(_passC.text)) {
      _showError('A senha deve conter pelo menos um caractere especial');
      return;
    }

    if (_passC.text != _confirmPassC.text) {
      _showError('As senhas não coincidem');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ApiService.instance.register(_emailC.text.trim(), _passC.text);
      
      if (!mounted) return;
      
      // Mostra mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastro realizado com sucesso! Faça login para continuar.'),
          backgroundColor: AppTheme.successColor,
          duration: Duration(seconds: 3),
        ),
      );

      // Volta para a tela de login
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Botão voltar
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: AppTheme.elevatedShadow,
                      ),
                      child: const Icon(
                        Icons.person_add_outlined,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 32),

                    Text(
                      'Criar Conta',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Preencha os dados para se cadastrar',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textLight,
                          ),
                    ),
                    const SizedBox(height: 48),

                    Container(
                      constraints: const BoxConstraints(maxWidth: 400),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CustomTextField(
                            label: 'Email',
                            controller: _emailC,
                            prefixIcon: Icons.email_outlined,
                            hint: 'Digite seu email',
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            label: 'Senha',
                            controller: _passC,
                            obscure: true,
                            prefixIcon: Icons.lock_outline,
                            hint: 'Mín. 8 caracteres, maiúscula, minúscula, número e especial',
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            label: 'Confirmar Senha',
                            controller: _confirmPassC,
                            obscure: true,
                            prefixIcon: Icons.lock_outline,
                            hint: 'Digite sua senha novamente',
                          ),
                          const SizedBox(height: 32),
                          PrimaryButton(
                            label: 'Cadastrar',
                            icon: Icons.person_add_rounded,
                            isLoading: _isLoading,
                            onPressed: _handleRegister,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      '© 2025 Cifra de César',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textLight,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

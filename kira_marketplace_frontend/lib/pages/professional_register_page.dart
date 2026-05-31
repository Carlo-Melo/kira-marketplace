import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../widgets/loading_widget.dart';
import 'home_page.dart';

class ProfessionalRegisterPage extends StatefulWidget {
  const ProfessionalRegisterPage({super.key});

  @override
  State<ProfessionalRegisterPage> createState() =>
      _ProfessionalRegisterPageState();
}

class _ProfessionalRegisterPageState extends State<ProfessionalRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cpfController = TextEditingController();
  final _phoneController = TextEditingController();
  final _documentNumberController = TextEditingController();
  final _bioController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();

  String _documentType = 'CPF';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthProvider>().clearState();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _cpfController.dispose();
    _phoneController.dispose();
    _documentNumberController.dispose();
    _bioController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    await authProvider.registerProfessional(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      cpf: _cpfController.text.trim(),
      phone: _phoneController.text.trim(),
      documentType: _documentType,
      documentNumber: _documentNumberController.text.trim(),
      bio: _bioController.text.trim(),
      city: _cityController.text.trim(),
      address: _addressController.text.trim(),
    );

    if (!mounted || authProvider.authResponse == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cadastro realizado com sucesso!')),
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Profissional'),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _textField(_nameController, 'Nome'),
                      const SizedBox(height: 12),
                      _textField(
                        _emailController,
                        'Email',
                        keyboardType: TextInputType.emailAddress,
                        validator: _emailValidator,
                      ),
                      const SizedBox(height: 12),
                      _textField(
                        _passwordController,
                        'Senha',
                        obscureText: true,
                        validator: _passwordValidator,
                      ),
                      const SizedBox(height: 12),
                      _textField(
                        _cpfController,
                        'CPF',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      _textField(
                        _phoneController,
                        'Telefone',
                        keyboardType: TextInputType.phone,
                        isRequired: false,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _documentType,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de documento',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'CPF', child: Text('CPF')),
                          DropdownMenuItem(value: 'CNPJ', child: Text('CNPJ')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _documentType = value);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      _textField(
                        _documentNumberController,
                        'Número do documento',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      _textField(_bioController, 'Bio', maxLines: 3),
                      const SizedBox(height: 12),
                      _textField(_cityController, 'Cidade'),
                      const SizedBox(height: 12),
                      _textField(_addressController, 'Endereço'),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: authProvider.isLoading ? null : _submit,
                        icon: const Icon(Icons.check),
                        label: const Text('Criar conta'),
                      ),
                      if (authProvider.errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          authProvider.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (authProvider.isLoading)
            Container(
              color: const Color(0x77000000),
              alignment: Alignment.center,
              child: const LoadingWidget(text: 'Criando cadastro...'),
            ),
        ],
      ),
    );
  }

  Widget _textField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    int maxLines = 1,
    bool isRequired = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: validator ??
          (value) {
            if (isRequired && (value == null || value.trim().isEmpty)) {
              return 'Campo obrigatório';
            }
            return null;
          },
    );
  }

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Informe o email';
    if (!value.contains('@')) return 'Email inválido';
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Informe a senha';
    if (value.length < 6) return 'Mínimo de 6 caracteres';
    return null;
  }
}

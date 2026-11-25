import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'area_azienda_screen.dart';

class LoginAziendaScreen extends StatefulWidget {
  const LoginAziendaScreen({super.key});

  @override
  State<LoginAziendaScreen> createState() => _LoginAziendaScreenState();
}

class _LoginAziendaScreenState extends State<LoginAziendaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeAziendaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isRegistrazione = false;
  bool _caricamento = false;

  @override
  void dispose() {
    _nomeAziendaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _inviaModulo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _caricamento = true);

    try {
      if (_isRegistrazione) {
        // R1 - Registrazione nuova azienda
        await _authService.registraAzienda(
          nomeAzienda: _nomeAziendaController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registrazione completata! Ora puoi effettuare il login.'),
          ),
        );
        setState(() => _isRegistrazione = false);
      } else {
        // R2 - Login azienda
        final azienda = await _authService.loginAzienda(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AreaAziendaScreen(azienda: azienda),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _caricamento = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isRegistrazione ? 'Registrazione Azienda' : 'Accesso Azienda'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.business_center,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                _isRegistrazione
                    ? 'Crea un profilo per pubblicare annunci'
                    : 'Accedi per gestire annunci e candidature',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 28),
              if (_isRegistrazione) ...[
                TextFormField(
                  controller: _nomeAziendaController,
                  decoration: const InputDecoration(
                    labelText: 'Nome Azienda',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.apartment),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Inserisci il nome dell\'azienda'
                      : null,
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email aziendale',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Inserisci l\'email';
                  if (!v.contains('@')) return 'Inserisci un\'email valida';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (v) => (v == null || v.trim().length < 4)
                    ? 'Inserisci una password di almeno 4 caratteri'
                    : null,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _caricamento ? null : _inviaModulo,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _caricamento
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : Text(_isRegistrazione ? 'Registra Azienda' : 'Accedi'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _caricamento
                    ? null
                    : () => setState(() => _isRegistrazione = !_isRegistrazione),
                child: Text(
                  _isRegistrazione
                      ? 'Hai già un account? Accedi'
                      : 'Non hai un account? Registra la tua azienda',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
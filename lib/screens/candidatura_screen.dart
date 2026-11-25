import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/bacheca_service.dart';

class CandidaturaScreen extends StatefulWidget {
  final Annuncio annuncio;

  const CandidaturaScreen({super.key, required this.annuncio});

  @override
  State<CandidaturaScreen> createState() => _CandidaturaScreenState();
}

class _CandidaturaScreenState extends State<CandidaturaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _cognomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _service = BachecaService();

  String? _filePath;
  String? _fileName;
  bool _invioInCorso = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _cognomeController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _scegliPdf() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result.isNotEmpty && result.first.path != null) {
      setState(() {
        _filePath = result.first.path;
        _fileName = result.first.name;
      });
    }
  }

  Future<void> _inviaCandidatura() async {
    if (!_formKey.currentState!.validate()) return;

    if (_filePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Allega il tuo curriculum in formato PDF')),
      );
      return;
    }

    setState(() => _invioInCorso = true);

    try {
      await _service.inviaCandidatura(
        annuncioId: widget.annuncio.id,
        nome: _nomeController.text.trim(),
        cognome: _cognomeController.text.trim(),
        email: _emailController.text.trim(),
        filePath: _filePath!,
      );

      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Candidatura inviata'),
          content: Text(
            'La tua candidatura per "${widget.annuncio.titolo}" è stata registrata con successo.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _invioInCorso = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invia Candidatura'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.annuncio.titolo,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                widget.annuncio.nomeAzienda,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Inserisci il nome' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cognomeController,
                decoration: const InputDecoration(
                  labelText: 'Cognome',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Inserisci il cognome'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Inserisci l\'email';
                  if (!v.contains('@')) return 'Inserisci un\'email valida';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: _invioInCorso ? null : _scegliPdf,
                icon: const Icon(Icons.upload_file),
                label: Text(_fileName ?? 'Allega Curriculum (PDF)'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: _invioInCorso ? null : _inviaCandidatura,
                icon: _invioInCorso
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(Icons.check_circle_outline),
                label: Text(
                    _invioInCorso ? 'Invio in corso...' : 'Conferma candidatura'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
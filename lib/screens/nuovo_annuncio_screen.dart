import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/bacheca_service.dart';

class NuovoAnnuncioScreen extends StatefulWidget {
  final Azienda azienda;

  const NuovoAnnuncioScreen({super.key, required this.azienda});

  @override
  State<NuovoAnnuncioScreen> createState() => _NuovoAnnuncioScreenState();
}

class _NuovoAnnuncioScreenState extends State<NuovoAnnuncioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titoloController = TextEditingController();
  final _descrizioneController = TextEditingController();
  final _service = BachecaService();

  bool _salvataggio = false;

  @override
  void dispose() {
    _titoloController.dispose();
    _descrizioneController.dispose();
    super.dispose();
  }

  Future<void> _pubblica() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvataggio = true);

    try {
      await _service.pubblicaAnnuncio(
        titolo: _titoloController.text.trim(),
        descrizione: _descrizioneController.text.trim(),
        azienda: widget.azienda,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Annuncio pubblicato con successo!')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _salvataggio = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuovo Annuncio'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Pubblica come ${widget.azienda.nomeAzienda}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titoloController,
                decoration: const InputDecoration(
                  labelText: 'Titolo posizione',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Inserisci il titolo dell\'annuncio'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descrizioneController,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Descrizione, requisiti e modalità di lavoro',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Inserisci la descrizione dell\'offerta'
                    : null,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _salvataggio ? null : _pubblica,
                icon: _salvataggio
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(Icons.publish),
                label: Text(
                    _salvataggio ? 'Pubblicazione...' : 'Pubblica annuncio'),
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
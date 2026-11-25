import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/bacheca_service.dart';

class DettaglioCandidaturaScreen extends StatefulWidget {
  final Candidatura candidatura;
  final Annuncio annuncio;

  const DettaglioCandidaturaScreen({
    super.key,
    required this.candidatura,
    required this.annuncio,
  });

  @override
  State<DettaglioCandidaturaScreen> createState() =>
      _DettaglioCandidaturaScreenState();
}

class _DettaglioCandidaturaScreenState
    extends State<DettaglioCandidaturaScreen> {
  static const _rossoAcceso = Color(0xFFFF0000);

  final _service = BachecaService();
  bool _aperturaInCorso = false;

  String _formatDataOra(String iso) {
    if (iso.length < 10) return iso;
    final parts = iso.substring(0, 10).split('-');
    if (parts.length != 3) return iso;
    final data = '${parts[2]}/${parts[1]}/${parts[0]}';
    if (iso.length >= 16) {
      final ora = iso.substring(11, 16);
      return '$data alle $ora';
    }
    return data;
  }

  Future<void> _apriPdf() async {
    setState(() => _aperturaInCorso = true);

    try {
      await _service.apriCurriculum(widget.candidatura.fileSalvato);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _aperturaInCorso = false);
    }
  }

  Widget _rigaDettaglio({
    required IconData icona,
    required String etichetta,
    required String valore,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icona, size: 22, color: _rossoAcceso),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  etichetta,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  valore,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.candidatura;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dettaglio Candidatura'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Annuncio: ${widget.annuncio.titolo}',
              style: const TextStyle(
                color: _rossoAcceso,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _rigaDettaglio(
                      icona: Icons.person_outline,
                      etichetta: 'Nome',
                      valore: c.nome,
                    ),
                    const Divider(height: 1),
                    _rigaDettaglio(
                      icona: Icons.badge_outlined,
                      etichetta: 'Cognome',
                      valore: c.cognome,
                    ),
                    const Divider(height: 1),
                    _rigaDettaglio(
                      icona: Icons.email_outlined,
                      etichetta: 'Email',
                      valore: c.email,
                    ),
                    const Divider(height: 1),
                    _rigaDettaglio(
                      icona: Icons.calendar_today_outlined,
                      etichetta: 'Data invio',
                      valore: _formatDataOra(c.dataInvio),
                    ),
                    const Divider(height: 1),
                    _rigaDettaglio(
                      icona: Icons.description_outlined,
                      etichetta: 'Curriculum allegato',
                      valore: c.nomeFileOriginale,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: _aperturaInCorso ? null : _apriPdf,
            style: FilledButton.styleFrom(
              backgroundColor: _rossoAcceso,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            icon: _aperturaInCorso
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Icon(Icons.picture_as_pdf),
            label: Text(
              _aperturaInCorso ? 'Apertura PDF...' : 'Apri Curriculum PDF',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}
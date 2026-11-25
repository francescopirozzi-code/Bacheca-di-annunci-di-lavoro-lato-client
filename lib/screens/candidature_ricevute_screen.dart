import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/bacheca_service.dart';
import 'dettaglio_candidatura_screen.dart';

class CandidatureRicevuteScreen extends StatefulWidget {
  final Annuncio annuncio;

  const CandidatureRicevuteScreen({super.key, required this.annuncio});

  @override
  State<CandidatureRicevuteScreen> createState() =>
      _CandidatureRicevuteScreenState();
}

class _CandidatureRicevuteScreenState extends State<CandidatureRicevuteScreen> {
  static const _rossoAcceso = Color(0xFFFF0000);

  final _service = BachecaService();
  late Future<List<Candidatura>> _candidatureFuture;
  bool _eliminazioneInCorso = false;

  @override
  void initState() {
    super.initState();
    _candidatureFuture = _service.getCandidatureAnnuncio(widget.annuncio.id);
  }

  void _ricarica() {
    setState(() {
      _candidatureFuture = _service.getCandidatureAnnuncio(widget.annuncio.id);
    });
  }

  String _formatData(String iso) {
    if (iso.length < 10) return iso;
    final parts = iso.substring(0, 10).split('-');
    if (parts.length != 3) return iso;
    return '${parts[2]}/${parts[1]}/${parts[0]}';
  }

  Future<void> _confermaEdEliminaAnnuncio() async {
    final conferma = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Elimina annuncio'),
        content: Text(
          'Vuoi davvero eliminare "${widget.annuncio.titolo}"? Verranno rimosse anche le eventuali candidature ricevute.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: _rossoAcceso,
            ),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );

    if (conferma != true) return;

    setState(() => _eliminazioneInCorso = true);

    try {
      await _service.eliminaAnnuncio(widget.annuncio.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Annuncio eliminato')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _eliminazioneInCorso = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Candidature - ${widget.annuncio.titolo}'),
        actions: [
          IconButton(
            onPressed:
            _eliminazioneInCorso ? null : _confermaEdEliminaAnnuncio,
            tooltip: 'Elimina annuncio',
            icon: _eliminazioneInCorso
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: _rossoAcceso,
              ),
            )
                : const Icon(
              Icons.delete_outline,
              color: _rossoAcceso,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _ricarica(),
        child: FutureBuilder<List<Candidatura>>(
          future: _candidatureFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return ListView(
                padding: const EdgeInsets.all(24),
                children: const [
                  SizedBox(height: 80),
                  Icon(Icons.error_outline, size: 56, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Errore nel caricamento delle candidature.\nTrascina verso il basso per riprovare.',
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            }

            final candidature = snapshot.data ?? [];
            if (candidature.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(24),
                children: const [
                  SizedBox(height: 80),
                  Icon(Icons.inbox_outlined, size: 56, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Nessuna candidatura ricevuta per questo annuncio.',
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: candidature.length,
              itemBuilder: (context, index) {
                final c = candidature[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: _rossoAcceso.withValues(alpha: 0.12),
                      child: const Icon(
                        Icons.person,
                        color: _rossoAcceso,
                      ),
                    ),
                    title: Text(
                      '${c.nome} ${c.cognome}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text('Inviata il ${_formatData(c.dataInvio)}'),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: _rossoAcceso,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DettaglioCandidaturaScreen(
                            candidatura: c,
                            annuncio: widget.annuncio,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
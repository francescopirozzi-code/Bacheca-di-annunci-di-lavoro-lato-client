import 'package:flutter/material.dart';
import '../models/models.dart';
import 'candidatura_screen.dart';

class DettaglioAnnuncioScreen extends StatelessWidget {
  final Annuncio annuncio;

  const DettaglioAnnuncioScreen({super.key, required this.annuncio});

  String _formatData(String iso) {
    if (iso.length < 10) return iso;
    final parts = iso.substring(0, 10).split('-');
    if (parts.length != 3) return iso;
    return '${parts[2]}/${parts[1]}/${parts[0]}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dettaglio Annuncio'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              annuncio.titolo,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.business, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Text(
                  annuncio.nomeAzienda,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  'Pubblicato il ${_formatData(annuncio.dataPubblicazione)}',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                ),
              ],
            ),
            const Divider(height: 32),
            Text(
              'Descrizione dell\'offerta',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              annuncio.descrizione,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CandidaturaScreen(annuncio: annuncio),
                ),
              );
            },
            icon: const Icon(Icons.send),
            label: const Text('Candidati ora'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../services/bacheca_service.dart';
import 'candidature_ricevute_screen.dart';
import 'nuovo_annuncio_screen.dart';

class AreaAziendaScreen extends StatefulWidget {
  final Azienda azienda;

  const AreaAziendaScreen({super.key, required this.azienda});

  @override
  State<AreaAziendaScreen> createState() => _AreaAziendaScreenState();
}

class _AreaAziendaScreenState extends State<AreaAziendaScreen> {
  static const _rossoAcceso = Color(0xFFFF0000);

  final _authService = AuthService();
  final _bachecaService = BachecaService();
  late Future<List<Annuncio>> _mieiAnnunciFuture;

  @override
  void initState() {
    super.initState();
    _mieiAnnunciFuture = _bachecaService.getAnnunciAzienda(widget.azienda.id);
  }

  void _ricarica() {
    setState(() {
      _mieiAnnunciFuture = _bachecaService.getAnnunciAzienda(widget.azienda.id);
    });
  }

  Future<void> _eseguiLogout() async {
    await _authService.logout();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logout effettuato')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.azienda.nomeAzienda),
        actions: [
          IconButton(
            onPressed: _eseguiLogout,
            tooltip: 'Logout',
            icon: const Icon(
              Icons.logout,
              color: _rossoAcceso,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _ricarica(),
        child: FutureBuilder<List<Annuncio>>(
          future: _mieiAnnunciFuture,
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
                    'Errore nel caricamento dei tuoi annunci.\nTrascina verso il basso per riprovare.',
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            }

            final annunci = snapshot.data ?? [];
            if (annunci.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(24),
                children: const [
                  SizedBox(height: 80),
                  Icon(Icons.post_add, size: 56, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Non hai ancora pubblicato annunci.\nPremi "Nuovo Annuncio" in basso per iniziare.',
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
              itemCount: annunci.length,
              itemBuilder: (context, index) {
                final annuncio = annunci[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      annuncio.titolo,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        annuncio.descrizione,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.people_outline,
                      color: _rossoAcceso,
                    ),
                    onTap: () async {
                      final eliminato = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CandidatureRicevuteScreen(annuncio: annuncio),
                        ),
                      );
                      if (eliminato == true) _ricarica();
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final creato = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => NuovoAnnuncioScreen(azienda: widget.azienda),
            ),
          );
          if (creato == true) _ricarica();
        },
        backgroundColor: _rossoAcceso,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'Nuovo Annuncio',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
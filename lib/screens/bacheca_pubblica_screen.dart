import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../services/bacheca_service.dart';
import 'area_azienda_screen.dart';
import 'dettaglio_annuncio_screen.dart';
import 'login_azienda_screen.dart';

class BachecaPubblicaScreen extends StatefulWidget {
  const BachecaPubblicaScreen({super.key});

  @override
  State<BachecaPubblicaScreen> createState() => _BachecaPubblicaScreenState();
}

class _BachecaPubblicaScreenState extends State<BachecaPubblicaScreen> {
  static const _rossoAzienda = Color(0xFFFF0000);

  final _service = BachecaService();
  late Future<List<Annuncio>> _annunciFuture;

  @override
  void initState() {
    super.initState();
    _annunciFuture = _service.getAnnunciPubblici();
  }

  void _ricarica() {
    setState(() {
      _annunciFuture = _service.getAnnunciPubblici();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bacheca Annunci'),
        actions: [
          TextButton.icon(
            onPressed: () async {
              final aziendaLoggata = await AuthService().getAziendaLoggata();
              if (!mounted) return;
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => aziendaLoggata != null
                      ? AreaAziendaScreen(azienda: aziendaLoggata)
                      : const LoginAziendaScreen(),
                ),
              );
              _ricarica();
            },
            style: TextButton.styleFrom(
              foregroundColor: _rossoAzienda,
            ),
            icon: const Icon(
              Icons.business_center,
              color: _rossoAzienda,
            ),
            label: const Text(
              'Area Azienda',
              style: TextStyle(
                color: _rossoAzienda,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _ricarica(),
        child: FutureBuilder<List<Annuncio>>(
          future: _annunciFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 80),
                  const Icon(Icons.wifi_off, size: 56, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Impossibile contattare il server.\nTrascina verso il basso per riprovare.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
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
                  Icon(Icons.work_outline, size: 56, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Nessun annuncio pubblicato al momento.\nAccedi come Azienda per pubblicare il primo!',
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: annunci.length,
              itemBuilder: (context, index) {
                final annuncio = annunci[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      annuncio.titolo,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            annuncio.nomeAzienda,
                            style: const TextStyle(
                              color: _rossoAzienda,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            annuncio.descrizione,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              DettaglioAnnuncioScreen(annuncio: annuncio),
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
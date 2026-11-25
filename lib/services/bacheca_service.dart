import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import '../config/api_config.dart';
import '../models/models.dart';

class BachecaService {
  static const _jsonHeaders = {'Content-Type': 'application/json'};

  // R5 - Elenco pubblico di tutti gli annunci
  Future<List<Annuncio>> getAnnunciPubblici() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/annunci'),
    );

    if (response.statusCode != 200) {
      throw Exception('Errore nel caricamento degli annunci');
    }

    final List<dynamic> list = jsonDecode(response.body);
    return list.map((e) => Annuncio.fromJson(e)).toList();
  }

  // R7 - Annunci pubblicati da una specifica azienda
  Future<List<Annuncio>> getAnnunciAzienda(String aziendaId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/aziende/$aziendaId/annunci'),
    );

    if (response.statusCode != 200) {
      throw Exception('Errore nel caricamento dei tuoi annunci');
    }

    final List<dynamic> list = jsonDecode(response.body);
    return list.map((e) => Annuncio.fromJson(e)).toList();
  }

  // R4 - Pubblicazione nuovo annuncio
  Future<void> pubblicaAnnuncio({
    required String titolo,
    required String descrizione,
    required Azienda azienda,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/annunci'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'titolo': titolo,
        'descrizione': descrizione,
        'aziendaId': azienda.id,
        'nomeAzienda': azienda.nomeAzienda,
      }),
    );

    if (response.statusCode != 201) {
      final data = jsonDecode(response.body);
      throw Exception(data['errore'] ?? 'Errore nella pubblicazione');
    }
  }

  // R6 - Invio candidatura con upload del file PDF
  Future<void> inviaCandidatura({
    required String annuncioId,
    required String nome,
    required String cognome,
    required String email,
    required String filePath,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConfig.baseUrl}/api/annunci/$annuncioId/candidature'),
    );

    request.fields['nome'] = nome;
    request.fields['cognome'] = cognome;
    request.fields['email'] = email;
    request.files.add(
      await http.MultipartFile.fromPath('curriculum', filePath),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 201) {
      final data = jsonDecode(response.body);
      throw Exception(data['errore'] ?? 'Errore durante l\'invio della candidatura');
    }
  }

  // R7 - Elenco candidature ricevute per un annuncio
  Future<List<Candidatura>> getCandidatureAnnuncio(String annuncioId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/annunci/$annuncioId/candidature'),
    );

    if (response.statusCode != 200) {
      throw Exception('Errore nel caricamento delle candidature');
    }

    final List<dynamic> list = jsonDecode(response.body);
    return list.map((e) => Candidatura.fromJson(e)).toList();
  }

  // R7 - Scarica e apre il curriculum PDF sul telefono
  Future<void> apriCurriculum(String fileSalvato) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/uploads/$fileSalvato'),
    );

    if (response.statusCode != 200) {
      throw Exception('Impossibile scaricare il curriculum');
    }

    final tempDir = await getTemporaryDirectory();
    final fileLocale = File('${tempDir.path}/$fileSalvato');
    await fileLocale.writeAsBytes(response.bodyBytes);

    final result = await OpenFilex.open(fileLocale.path);
    if (result.type != ResultType.done) {
      throw Exception('Nessuna app disponibile per aprire il PDF (${result.message})');
    }
  }

  // Eliminazione di un annuncio pubblicato dall'azienda
  Future<void> eliminaAnnuncio(String annuncioId) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/api/annunci/$annuncioId'),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(
          data['errore'] ?? 'Errore durante l\'eliminazione dell\'annuncio');
    }
  }
}
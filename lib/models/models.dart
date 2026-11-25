class Azienda {
  final String id;
  final String nomeAzienda;
  final String email;

  Azienda({
    required this.id,
    required this.nomeAzienda,
    required this.email,
  });

  factory Azienda.fromJson(Map<String, dynamic> json) {
    return Azienda(
      id: json['id'] ?? '',
      nomeAzienda: json['nomeAzienda'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nomeAzienda': nomeAzienda,
    'email': email,
  };
}

class Annuncio {
  final String id;
  final String titolo;
  final String descrizione;
  final String aziendaId;
  final String nomeAzienda;
  final String dataPubblicazione;

  Annuncio({
    required this.id,
    required this.titolo,
    required this.descrizione,
    required this.aziendaId,
    required this.nomeAzienda,
    required this.dataPubblicazione,
  });

  factory Annuncio.fromJson(Map<String, dynamic> json) {
    return Annuncio(
      id: json['id'] ?? '',
      titolo: json['titolo'] ?? '',
      descrizione: json['descrizione'] ?? '',
      aziendaId: json['aziendaId'] ?? '',
      nomeAzienda: json['nomeAzienda'] ?? '',
      dataPubblicazione: json['dataPubblicazione'] ?? '',
    );
  }
}

class Candidatura {
  final String id;
  final String annuncioId;
  final String nome;
  final String cognome;
  final String email;
  final String nomeFileOriginale;
  final String fileSalvato;
  final String dataInvio;

  Candidatura({
    required this.id,
    required this.annuncioId,
    required this.nome,
    required this.cognome,
    required this.email,
    required this.nomeFileOriginale,
    required this.fileSalvato,
    required this.dataInvio,
  });

  factory Candidatura.fromJson(Map<String, dynamic> json) {
    return Candidatura(
      id: json['id'] ?? '',
      annuncioId: json['annuncioId'] ?? '',
      nome: json['nome'] ?? '',
      cognome: json['cognome'] ?? '',
      email: json['email'] ?? '',
      nomeFileOriginale: json['nomeFileOriginale'] ?? '',
      fileSalvato: json['fileSalvato'] ?? '',
      dataInvio: json['dataInvio'] ?? '',
    );
  }
}
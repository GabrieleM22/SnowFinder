import 'package:image_picker/image_picker.dart';

class Mountain {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final int snowLevelCm;

  // foto locali selezionate quindi no persistenti
  List<XFile> photos = [];

  // foto salvate su Firebase (URL persistenti)
  List<Map<String, dynamic>> firebasePhotos = []; // salva foto salvate su Firebase con autore

  Mountain({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.snowLevelCm,
  });
}

final List<Mountain> initialMountains = [
  Mountain(id: "DOLOMITI SUPERSKI", name: "Dolomiti superski", latitude: 46.538, longitude: 11.76, snowLevelCm: 1),
  Mountain(id: "VIALATTEA", name: "Vialattea ski", latitude: 44.973, longitude: 6.89, snowLevelCm: 1),
  Mountain(id: "MADONNA DI CAMPIGLIO", name: "Madonna di Campiglio", latitude: 46.228, longitude: 10.832,snowLevelCm: 1),
  Mountain(id: "VAL GARDENA", name : "Val Gardena", latitude : 46.562, longitude : 11.716,snowLevelCm: 1),
  Mountain(id: "KRONPLATZ", name : "Kronplatz ski", latitude : 46.76, longitude : 11.932,snowLevelCm: 1),
  Mountain(id: "ALTA BADIA", name : "Alta Badia ski", latitude : 46.58, longitude : 11.87,snowLevelCm: 1),
  Mountain(id: "MONTEROSA", name : "Monte Rosa ski", latitude : 45.853, longitude : 7.796,snowLevelCm: 1),
  Mountain(id: "CORTINA", name : "Cortina d'Ampezzo", latitude : 46.54, longitude : 12.135,snowLevelCm: 1),
  Mountain(id:  "LIVIGNO", name : "Livigno", latitude : 46.535, longitude : 10.143,snowLevelCm: 1 ),
  Mountain(id:  "CERVINIA", name : "Cervinia", latitude : 45.936, longitude : 7.63,snowLevelCm: 1),
  Mountain(id: "SESTRIERE", name : "Sestriere", latitude : 44.954, longitude :  6.878,snowLevelCm: 1),
  Mountain(id:  "COURMAYEUR", name : "Courmayeur", latitude : 45.791, longitude : 6.968,snowLevelCm: 1),
  Mountain(id:  "BORMIO", name : "Bormio", latitude : 46.467, longitude : 10.367,snowLevelCm: 1),
  Mountain(id:  "SAN MARTINO", name : "San Martino di Castrozza", latitude : 46.258, longitude : 11.796,snowLevelCm: 1),
  Mountain(id:  "OBEREGEN", name : "Obereggen-Latemar", latitude : 46.383, longitude :  11.503,snowLevelCm: 1),
  Mountain(id:  "VAL DI FASSA", name : "Val di Fassa ", latitude : 46.43, longitude : 11.681,snowLevelCm: 1),
  Mountain(id:  "VAL DI FIEMME", name : "Val di Fiemme", latitude : 46.3, longitude : 11.45,snowLevelCm: 1),
  Mountain(id:  "PIANCAVALLO", name : "Piancavallo", latitude : 46.104, longitude : 12.515,snowLevelCm: 1),
  Mountain(id:  "FOLGARIA", name : "Folgaria ski", latitude : 45.902, longitude : 11.176,snowLevelCm: 1),
  Mountain(id:  "PASSO DEL TONALE ", name : "Passo del Tonale-Ponte di Legno", latitude : 46.257, longitude : 10.586,snowLevelCm: 1),
  Mountain(id:  "CIMONE", name : "Monte Cimone", latitude : 44.208, longitude : 10.667,snowLevelCm: 1),
  Mountain(id:  "ABETONE", name : "Abetone", latitude : 44.143, longitude : 10.633,snowLevelCm: 1),
  Mountain(id: "ROCCARASO", name : "Roccaraso", latitude : 41.817, longitude : 14.083,snowLevelCm: 1),
  Mountain(id:  "CAMPOFELICE", name : "Campo Felice", latitude : 42.2, longitude : 13.4,snowLevelCm: 1),
  Mountain(id:  "CAMPO IMPERATORE ", name : "Campo Imperatore", latitude : 42.442 , longitude : 13.588,snowLevelCm: 1),
  Mountain(id:  "ETNA NORD", name : "Etna Nord ski", latitude : 37.821, longitude : 14.99,snowLevelCm: 1),
  Mountain(id:  "ETNA SUD", name : "Etna Sud ski", latitude : 37.698, longitude : 14.999,snowLevelCm: 1),
  Mountain(id:  "ALPE CERMIS", name : "Alpe Cermis", latitude : 46.29, longitude : 11.454,snowLevelCm: 1),
  Mountain(id:  "ARABBA/MARMOLADA", name : "Arabba-Marmolada", latitude : 46.49, longitude: 11.873,snowLevelCm: 1),
  Mountain(id:  "VALCHIAVENNA", name : "SkiArea Valchiavenna", latitude : 46.454, longitude : 9.346,snowLevelCm: 1),
  Mountain(id:  "PRALI", name : "Prali", latitude : 45.047, longitude : 7.038,snowLevelCm: 1),
  Mountain(id:  "FRABOSA", name : "Frabosa ski", latitude : 44.244, longitude : 7.781,snowLevelCm: 1),
  Mountain(id:  "LIMONE", name : "Limone ski", latitude : 44.201, longitude : 7.578,snowLevelCm: 1),
  Mountain(id:  "TARVISIO -", name : "Tarvisio ski", latitude : 46.508, longitude : 13.586,snowLevelCm: 1),
  Mountain(id:  "RIVISONDOLI", name :"Rivisindoli", latitude : 41.866, longitude : 14.09,snowLevelCm: 1),
  Mountain(id:  "PESCASSEROLI", name : "Pescasseroli", latitude :  41.8, longitude : 13.783,snowLevelCm: 1),
  Mountain(id:  "OVINDOLI", name : "Ovindoli", latitude : 42.139, longitude : 13.518,snowLevelCm: 1),
  Mountain(id:  "MONTE AMIATA", name : "Monte Amiata ", latitude : 42.886, longitude : 11.615,snowLevelCm: 1),
  Mountain(id:  "PILA", name :"Pila", latitude : 45.728, longitude :  7.317,snowLevelCm: 1),
  Mountain(id:  "MONTE TERMINILLO", name : "Monte Terminillo", latitude : 42.483, longitude : 13.000,snowLevelCm: 1),
  Mountain(id:  "PASSO DELLO STELVIO", name : "Passo dello Stelvio", latitude : 46.5286, longitude : 10.453,snowLevelCm: 1),
  Mountain(id:  "SAN BERNARDO", name : "Espace San Bernardo (La Thuile–LaRosière)", latitude : 45.6288, longitude : 6.8479,snowLevelCm: 1),
  Mountain(id:  "PRATO NEVOSO", name: "Prato Nevoso", latitude : 44.2546, longitude : 7.7846,snowLevelCm: 1),
  Mountain(id:  "VERMIGLIO", name : "Vermiglio", latitude : 46.300, longitude : 10.683,snowLevelCm: 1),
  Mountain(id: "PRESENA", name : "Ghiacciao Presena", latitude : 46.2376, longitude : 10.58062,snowLevelCm: 1),
  Mountain(id:  "PADOLA", name : "Padola", latitude : 46.6066, longitude : 12.4807,snowLevelCm: 1)
];

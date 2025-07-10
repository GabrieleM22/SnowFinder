import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../utils/permissions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:snowfinder_flutter/mountains.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class WeatherInfo {
  final double temp;
  final double? snow1h;
  final double? rain1h;
  final String desc;
  final DateTime time;

  WeatherInfo({
    required this.temp,
    this.snow1h,
    this.rain1h,
    required this.desc,
    required this.time,
  });
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  late GoogleMapController _mapController;
  final TextEditingController _searchController = TextEditingController();
  final Set<Marker> _markers = {};
  File? _personalImage;
  List<Mountain> mountains = initialMountains;

  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(42.8333, 12.8333),
    zoom: 5.8,
  );

  @override
  void initState() {
    super.initState();
    _setMountainMarkers(context);
  }

  Future<WeatherInfo> _fetchWeather(Mountain m) async {
    const apiKey = 'e161a827a51c8f73b0830328aa0db881';
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=${m.latitude}&lon=${m.longitude}&appid=$apiKey&units=metric&lang=it';

    final resp = await http.get(Uri.parse(url));
    if (resp.statusCode != 200) throw Exception('Errore meteo');

    final data = json.decode(resp.body);
    return WeatherInfo(
      temp: (data['main']['temp'] as num).toDouble(),
      snow1h: (data['snow']?['1h'] as num?)?.toDouble(),
      rain1h: (data['rain']?['1h'] as num?)?.toDouble(),
      desc: data['weather'][0]['description'],
      time: DateTime.fromMillisecondsSinceEpoch((data['dt'] as int) * 1000),
    );
  }

  Future<void> _setMountainMarkers(BuildContext context) async {
    _markers.clear();
    final snapshot = await FirebaseFirestore.instance.collection('mountains').get();

    for (final m in mountains) {
      final docList = snapshot.docs.where((d) => d.id == m.id);

      if (docList.isNotEmpty) {
        final doc = docList.first;
        final data = doc.data();
        if (data.containsKey('photos')) {
          m.firebasePhotos = List<Map<String, dynamic>>.from(data['photos'] ?? []);

        }
      }

      _markers.add(
        Marker(
          markerId: MarkerId(m.name),
          position: LatLng(m.latitude, m.longitude),
          infoWindow: InfoWindow(
            title: m.name,
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (_) => _buildMountainBottomSheet(context, m),
              );
            },
          ),
        ),
      );
    }

    if (mounted) setState(() {});
  }

  Widget _buildMountainBottomSheet(BuildContext context, Mountain m) {
    return FutureBuilder<WeatherInfo>(
      future: _fetchWeather(m),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final weather = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(m.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('🌡️ Temperatura: ${weather.temp.toStringAsFixed(1)}°C'),
                Text('☁️ Condizioni: ${weather.desc}'),
                Text('🕒 Aggiornato alle: ${TimeOfDay.fromDateTime(weather.time).format(context)}'),
                if (weather.snow1h != null)
                  Text('❄️ Neve ultima ora: ${weather.snow1h!.toStringAsFixed(1)} cm')
                else
                  const Text('❄️ Nessuna nevicata recente'),
                if (weather.rain1h != null)
                  Text('🌧️ Pioggia ultima ora: ${weather.rain1h!.toStringAsFixed(1)} mm'),

                const SizedBox(height: 16),

                if (m.firebasePhotos.isNotEmpty) ...[
                  const Text('📷 Foto caricate:'),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 160,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: m.firebasePhotos.length,
                      itemBuilder: (context, index) {
                        final reversedIndex = m.firebasePhotos.length - 1 - index;
                        final photo = m.firebasePhotos[reversedIndex];

                        final author = photo['author'] ?? '';
                        final timestampStr = photo['timestamp'] ?? '';
                        final timestamp = DateTime.tryParse(timestampStr);
                        final formattedDate = timestamp != null
                            ? '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}'
                            : '';

                        final photoUrl = photo['url'] ?? '';

                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              if (photoUrl.isEmpty) return;
                              showDialog(
                                context: context,
                                builder: (_) => Dialog(
                                  insetPadding: const EdgeInsets.all(16),
                                  child: InteractiveViewer(
                                    child: Image.network(photoUrl),
                                  ),
                                ),
                              );
                            },
                            onLongPress: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text("Rimuovi foto"),
                                  content: const Text("Sei sicuro di voler eliminare questa foto?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text("Annulla"),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text("Elimina"),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm != true) return;

                              final mountainDoc = FirebaseFirestore.instance.collection('mountains').doc(m.id);
                              final photoUrl = photo['url'];

                              try {
                                // lista dal doc
                                final docSnap = await mountainDoc.get();
                                final current = List<Map<String, dynamic>>.from(docSnap.data()?['photos'] ?? []);

                                // Filtra la foto da eliminare
                                final updated = current.where((p) => p['url'] != photoUrl).toList();

                                // Aggiorna Firestore
                                await mountainDoc.update({'photos': updated});
                                print("✅ FIRESTORE UPDATE SUCCESS");

                                //  da qui elimina da Firebase Storage
                                try {
                                  final uri = Uri.parse(photoUrl);
                                  final fullPath = uri.pathSegments.skip(1).join('/');
                                  final ref = FirebaseStorage.instance.ref().child(fullPath);
                                  await ref.delete();
                                  print("✅ STORAGE DELETE SUCCESS");
                                } catch (e) {
                                  print("❌ STORAGE DELETE FAILED: $e");
                                }

                                //  Aggiorna subito la UI locale e forza il rebuild del bottom sheet
                                if (mounted) {
                                  Navigator.pop(context); // chiudi il bottomsheet corrente
                                  setState(() {
                                    m.firebasePhotos = updated;
                                  });
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                    ),
                                    builder: (_) => _buildMountainBottomSheet(context, m),
                                  );
                                }
                              } catch (e) {
                                print("❌ ERRORE eliminazione: $e");
                              }
                            },


                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    photoUrl,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    author,
                                    style: const TextStyle(fontSize: 10),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (formattedDate.isNotEmpty)
                                  SizedBox(
                                    width: 100,
                                    child: Text(
                                      formattedDate,
                                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },

                    ),
                  ),
                  const SizedBox(height: 16),
                ],



                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      await requestImagePermissions();
                      final picked = await _picker.pickImage(source: ImageSource.gallery);
                      if (picked == null) return;

                      final fileBytes = await picked.readAsBytes();
                      final fileName = '${m.name}_${DateTime.now().millisecondsSinceEpoch}.jpg';
                      final ref = FirebaseStorage.instance.ref().child('mountain_photos/$fileName');

                      await ref.putData(fileBytes);
                      final downloadUrl = await ref.getDownloadURL();
                      final author = FirebaseAuth.instance.currentUser?.displayName ?? 'Anonimo';

                      final newPhoto = {
                        'url': downloadUrl,
                        'author': author,
                        'timestamp': DateTime.now().toIso8601String(),
                      };

                      final mountainDoc = FirebaseFirestore.instance.collection('mountains').doc(m.id);

                      await mountainDoc.set({
                        'photos': FieldValue.arrayUnion([newPhoto])
                      }, SetOptions(merge: true));

                      final updatedDoc = await mountainDoc.get();
                      final updatedPhotos = List<Map<String, dynamic>>.from(updatedDoc.data()?['photos'] ?? []);

                      setState(() => m.firebasePhotos = updatedPhotos);

                      if (!mounted) return;
                      Navigator.pop(context);
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (_) => _buildMountainBottomSheet(context, m),
                      );
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Errore nel caricamento immagine')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text('Carica foto'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    if (_markers.isEmpty) _setMountainMarkers(context);

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: _initialCameraPosition,
                  onMapCreated: (controller) => _mapController = controller,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: _markers,
                ),
                Positioned(
                  top: 60,
                  left: 20,
                  right: 20,
                  child: _buildSearchBar(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(30),
      child: TypeAheadField<String>(
        suggestionsCallback: (pattern) async {
          if (pattern.trim().length < 2) return [];
          return mountains
              .where((m) => m.name.toLowerCase().contains(pattern.toLowerCase()))
              .map((m) => m.name)
              .toList();
        },
        itemBuilder: (context, suggestion) {
          return ListTile(title: Text(suggestion));
        },
        onSuggestionSelected: (suggestion) {
          _searchController.text = suggestion;
          final selected = mountains.firstWhere(
                  (m) => m.name.toLowerCase() == suggestion.toLowerCase());
          _mapController.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(selected.latitude, selected.longitude),
              14,
            ),
          );
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) => _buildMountainBottomSheet(context, selected),
          );
        },
        textFieldConfiguration: TextFieldConfiguration(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Cerca località',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
          ),
        ),
      ),
    );
  }
}

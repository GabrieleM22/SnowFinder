import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../mountains.dart';

class MountainDetailScreen extends StatefulWidget {
  final Mountain mountain;

  const MountainDetailScreen({super.key, required this.mountain});

  @override
  State<MountainDetailScreen> createState() => _MountainDetailScreenState();
}

class _MountainDetailScreenState extends State<MountainDetailScreen> {
  String weatherDescription = 'Caricamento meteo...';

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    const apiKey = 'e161a827a51c8f73b0830328aa0db881';
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=${widget.mountain.latitude}&lon=${widget.mountain.longitude}&appid=$apiKey&lang=it&units=metric';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final desc = data['weather'][0]['description'];
      setState(() {
        weatherDescription = desc;
      });
    } else {
      setState(() {
        weatherDescription = 'Errore nel recupero meteo';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('BUILDING DETAIL FOR ${widget.mountain.name}');
    final m = widget.mountain;

    return Scaffold(
      appBar: AppBar(title: Text(m.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Meteo attuale:', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text(weatherDescription, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: implementa caricamento foto
              },
              child: const Text('Carica foto delle condizioni'),
            ),
          ],
        ),
      ),
    );
  }
}

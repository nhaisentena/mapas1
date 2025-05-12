import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/location_viewmodel.dart';
import 'views/map_view.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => LocationViewModel()..startLocationUpdates(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mapa OSM',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue.shade900,
          primary: Colors.blue.shade800,
          secondary: Colors.blue.shade300,
          brightness: Brightness.light,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Localización en el mapa'),
        ),
        body: const MapView(),
      ),
    );
  }
}

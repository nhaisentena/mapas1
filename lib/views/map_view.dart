import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:geocoding/geocoding.dart';

import '../viewmodels/location_viewmodel.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  final Color azulOscuro = const Color(0xFF0D47A1);
  final Color azulClaro = const Color(0xFF64B5F6);

  @override
  void initState() {
    super.initState();
    final viewModel = Provider.of<LocationViewModel>(context, listen: false);
    viewModel.startLocationUpdates();
  }

  Future<void> _searchAndMoveMap(String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final first = locations.first;
        final latLng = LatLng(first.latitude, first.longitude);
        _mapController.move(latLng, 16);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Endereço não encontrado: $address'),
          backgroundColor: azulOscuro,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<LocationViewModel>(
        builder: (context, viewModel, child) {
          final location = viewModel.location;

          if (location == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentLatLng = LatLng(location.latitude, location.longitude);

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _mapController.move(currentLatLng, _mapController.camera.zoom);
          });

          return Column(
            children: [
              Container(
                color: azulOscuro,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Buscar endereço...',
                          hintStyle: TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: azulClaro,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onSubmitted: _searchAndMoveMap,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
                      onPressed: () => _searchAndMoveMap(_searchController.text),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: currentLatLng,
                    initialZoom: 16,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'br.edu.ifsul.flutter_mapas_osm',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: currentLatLng,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

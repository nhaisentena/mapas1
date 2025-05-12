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

  void _searchLocation(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        _mapController.move(LatLng(loc.latitude, loc.longitude), 16);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dirección no encontrada.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar dirección...',
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => _searchLocation(_searchController.text),
              ),
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: Consumer<LocationViewModel>(
            builder: (context, viewModel, child) {
              final location = viewModel.location;

              if (location == null) {
                return const Center(child: CircularProgressIndicator());
              }

              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: LatLng(location.latitude, location.longitude),
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
                        point: LatLng(location.latitude, location.longitude),
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
              );
            },
          ),
        ),
      ],
    );
  }
}

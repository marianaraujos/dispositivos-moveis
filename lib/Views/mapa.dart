import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:recicla_the/Data/banco.dart';
import 'dart:ui' as ui;

class Mapa extends StatefulWidget {
  const Mapa({super.key, required this.id});
  final String id;

  @override
  State<Mapa> createState() => _MapaState();
}

class _MapaState extends State<Mapa> {
  Set<Marker> _marcadores = {};
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;

  late GoogleMapController mapController;
  final LatLng _center = const LatLng(-5.08917, -42.80194);

  // FUNÇÃO PARA REDIMENSIONAR O ASSET
  Future<BitmapDescriptor> _bitmapFromAsset(String path, int width) async {
    final ByteData data = await rootBundle.load(path);
    final Uint8List bytes = data.buffer.asUint8List();

    final ui.Codec codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: width,
    );
    final ui.FrameInfo fi = await codec.getNextFrame();

    final ByteData? resized = await fi.image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    return BitmapDescriptor.bytes(resized!.buffer.asUint8List());
  }

  // CARREGAR O ÍCONE PERSONALIZADO
  Future<void> _addCustomIcon() async {
    markerIcon = await _bitmapFromAsset("assets/images/recycle.png", 50);
    setState(() {});
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // CARREGAR MARCADORES
  Future<void> _carregaMarcadoresContato() async {
    Set<Marker> marcadorLocal = {};
    DataSnapshot contatos = await Banco.recuperaContatosDoUsuario(widget.id);
    int quantidade = contatos.children.length;

    for (int i = 0; i < quantidade; i++) {
      DataSnapshot contato = contatos.child(i.toString());
      if (contato.exists) {
        String idMarcador = contato.child('nome').value as String;
        double? latitude = contato.child('latitude').exists
            ? contato.child('latitude').value as double
            : null;
        double? longitude = contato.child('longitude').exists
            ? contato.child('longitude').value as double
            : null;
        String telefone = contato.child('telefone').value as String;

        if (telefone.isEmpty) {
          telefone = 'Telefone não cadastrado';
        }

        if (latitude != null && longitude != null) {
          marcadorLocal.add(
            Marker(
              markerId: MarkerId(idMarcador),
              position: LatLng(latitude, longitude),
              infoWindow: InfoWindow(title: idMarcador, snippet: telefone),
              icon: markerIcon, // Ícone já redimensionado
            ),
          );
        }
      }
    }

    setState(() {
      _marcadores = marcadorLocal;
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.ff
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  // GARANTE QUE ÍCONE É CARREGADO ANTES DOS MARCADORES
  Future<void> _inicializar() async {
    await _addCustomIcon();
    await _carregaMarcadoresContato();
  }

  @override
  void initState() {
    super.initState();
    _inicializar();
    _determinePosition();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      zoomGesturesEnabled: true,
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(target: _center, zoom: 7.0),
      markers: _marcadores,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
    );
  }
}

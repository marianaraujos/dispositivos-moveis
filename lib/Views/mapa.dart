import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:recicla_the/Data/banco.dart';
import 'dart:ui' as ui;
import 'package:url_launcher/url_launcher.dart';

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

  // Localização inicial temporária (será substituída pela real)
  final LatLng _center = const LatLng(-5.08917, -42.80194);

  // Variável para posição do usuário
  LatLng? _currentUserPosition;

  // REDIMENSIONAR ASSETS
  Future<BitmapDescriptor> _bitmapFromAsset(String path, int width) async {
    final ByteData data = await rootBundle.load(path);
    final Uint8List bytes = data.buffer.asUint8List();

    final ui.Codec codec =
        await ui.instantiateImageCodec(bytes, targetWidth: width);
    final ui.FrameInfo fi = await codec.getNextFrame();

    final ByteData? resized =
        await fi.image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.bytes(resized!.buffer.asUint8List());
  }

  // ÍCONE PERSONALIZADO
  Future<void> _addCustomIcon() async {
    markerIcon = await _bitmapFromAsset("assets/images/reciclathe.png", 60);
    setState(() {});
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
        double? latitude =
            contato.child('latitude').exists ? contato.child('latitude').value as double : null;
        double? longitude =
            contato.child('longitude').exists ? contato.child('longitude').value as double : null;
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
              icon: markerIcon,
              onTap: () {
                _abrirBottomSheet(
                  nome: idMarcador,
                  telefone: telefone,
                  posicao: LatLng(latitude, longitude),
                );
              },
            ),
          );
        }
      }
    }

    setState(() {
      _marcadores = marcadorLocal;
    });
  }

  // OBTER POSIÇÃO DO USUÁRIO E CENTRALIZAR NO MAPA
  Future<void> _getUserPositionAndCenterMap() async {
    try {
      Position position = await Geolocator.getCurrentPosition();

      _currentUserPosition = LatLng(position.latitude, position.longitude);

      // Move câmera quando o mapa já estiver carregado
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(_currentUserPosition!, 16),
      );
    } catch (e) {
      print("Erro ao encontrar localização: $e");
    }
  }

  // PERMISSÕES DE LOCALIZAÇÃO
  Future<void> _requestLocationPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
  }

  // ABRIR BOTTOM SHEET
  void _abrirBottomSheet({
    required String nome,
    required String telefone,
    required LatLng posicao,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.35,
          minChildSize: 0.25,
          maxChildSize: 0.55,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      nome,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 10),
                    Text("Telefone: $telefone",
                        style: const TextStyle(fontSize: 17)),

                    const SizedBox(height: 25),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _ligarOuWhatsApp(telefone);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.all(14),
                            ),
                            child: const Text("Entrar em contato"),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _abrirGoogleMaps(posicao);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.all(14),
                            ),
                            child: const Text("Iniciar rota"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ABRIR CONTATO
  void _ligarOuWhatsApp(String telefone) async {
    final Uri uri = Uri.parse("tel:$telefone");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  // ABRIR GOOGLE MAPS
  void _abrirGoogleMaps(LatLng posicao) async {
    final url =
        "https://www.google.com/maps/dir/?api=1&destination=${posicao.latitude},${posicao.longitude}&travelmode=driving";

    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // INICIALIZAÇÃO
  Future<void> _inicializar() async {
    await _requestLocationPermissions();
    await _addCustomIcon();
    await _carregaMarcadoresContato();
  }

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

 
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;

    // Assim que o mapa carregar → centraliza no usuário
    _getUserPositionAndCenterMap();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      zoomGesturesEnabled: true,
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: _center, // Posição temporária
        zoom: 5,
      ),
      markers: _marcadores,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
    );
  }
}

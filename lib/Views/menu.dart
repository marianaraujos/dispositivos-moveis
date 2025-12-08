import 'package:flutter/material.dart';
import 'package:recicla_the/Models/estabelecimento.dart';

// Importação das telas reais



import 'package:recicla_the/Views/cadastro.dart';
import 'package:recicla_the/Views/mapa.dart';
import 'package:recicla_the/Views/meus_contatos.dart';

class Menu extends StatefulWidget {
  final Estabelecimento estabelecimento;

  const Menu({super.key, required this.estabelecimento});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      _boasVindasPage(),
      Mapa(id: widget.estabelecimento.id),
      Cadastro(),
      MeusContatos(id: widget.estabelecimento.id),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("ReciclaTHE"),
      ),

      body: pages[_selectedIndex],

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (value) {
          setState(() {
            _selectedIndex = value;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: "Início",
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            label: "Mapa",
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            label: "Cadastrar",
          ),
          NavigationDestination(
            icon: Icon(Icons.business_outlined),
            label: "Estabelecimentos",
          )
        ],
      ),
    );
  }

  //
  // 1. TELA DE BOAS-VINDAS
  //
  Widget _boasVindasPage() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            "Bem-vindo ao ReciclaTHE!",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            "Gerencie seus pontos de coleta, cadastre novos locais\n"
            "e visualize tudo no mapa.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.all(15.0),
            child: SizedBox(
              height: 320,
              child: Image.asset(
                'assets/images/reciclathe.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

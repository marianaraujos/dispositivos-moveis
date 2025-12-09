import 'package:flutter/material.dart';
import 'package:recicla_the/Models/estabelecimento.dart';

// Importação das telas reais

import 'package:recicla_the/Views/cadastro_contato.dart';
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
      CadastroContato(id: widget.estabelecimento.id),
      MeusContatos(id: widget.estabelecimento.id),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("ReciclaTHE"),
        centerTitle: true,
        backgroundColor: Colors.green[300],
        elevation: 4,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          icon: Icon(Icons.logout),
        ),
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w600,
          fontStyle: FontStyle.italic,
          color: Colors.brown[800],
          decoration: TextDecoration.underline,
          decorationStyle: TextDecorationStyle.wavy,
          decorationColor: Colors.green,
          letterSpacing: 1.1,
        ),
      ),

      body: pages[_selectedIndex],

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (value) {
          setState(() {
            _selectedIndex = value;
          });
        },

        indicatorColor: Colors.green,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: "Início",
          ),
          NavigationDestination(icon: Icon(Icons.map_outlined), label: "Mapa"),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            label: "Cadastrar",
          ),
          NavigationDestination(
            icon: Icon(Icons.business_outlined),
            label: "Locais",
          ),
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
          const SizedBox(height: 25),

          Text(
            "Bem-vindo ao ReciclaTHE!",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.green,
            ),
          ),

          const SizedBox(height: 18),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Encontre pontos de coleta, cadastre novos locais e visualize tudo no mapa.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                height: 1.4,
                color: Colors.grey.shade700,
              ),
            ),
          ),

          const SizedBox(height: 25),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.green.shade50,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/reciclathe.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

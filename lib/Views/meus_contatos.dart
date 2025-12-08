import 'package:recicla_the/Models/contato.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../Data/banco.dart';
import '../Util/extrair_parametros.dart';

class MeusContatos extends StatefulWidget {
  const MeusContatos({super.key, required this.id});
  final String id;

  @override
  State<MeusContatos> createState() => _MeusContatosState();
}

class _MeusContatosState extends State<MeusContatos> {
  List<Contato> _listaContatos = [];

  void _carregarContatos() async {
    List<Contato> listaContatos = [];
    DataSnapshot contatos =
        await Banco.recuperaContatosDoUsuario(widget.id);

    for (var contato in contatos.children) {
      String nome = contato.child('nome').value as String;
      double? latitude = contato.child('latitude').exists
          ? contato.child('latitude').value as double
          : null;
      double? longitude = contato.child('longitude').exists
          ? contato.child('longitude').value as double
          : null;
      String telefone = contato.child('telefone').value as String;

      if (telefone.isEmpty) {
        telefone = "Telefone não cadastrado";
      }

      Contato ctt = Contato(
        nome,
        latitude: latitude,
        longitude: longitude,
        telefone: telefone,
      );

      ctt.id = contato.key;
      listaContatos.add(ctt);
    }

    setState(() {
      _listaContatos = listaContatos;
    });
  }

  @override
  void initState() {
    super.initState();
    _carregarContatos();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView.builder(
        itemCount: _listaContatos.length,
        itemBuilder: (BuildContext ctx, int i) {
          var contato = _listaContatos[i];
          return Card(
            child: ListTile(
              key: Key(i.toString()),
              title: Text(contato.nome),
              subtitle: Text(contato.telefone as String),
              trailing: const Icon(Icons.edit),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  "/editarContato",
                  arguments: ExtrairParametros(
                    id: widget.id,
                    idContato: contato.id!,
                    contato: contato,
                  ),
                ).then((_) {
                  setState(() {
                    _carregarContatos();
                  });
                });
              },
            ),
          );
        },
      ),
    );
  }
}

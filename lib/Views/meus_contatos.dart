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
  bool _carregando = true;
  String? _erro;

  void _carregarContatos() async {
    try {
      setState(() {
        _carregando = true;
        _erro = null;
      });

      List<Contato> listaContatos = [];
      DataSnapshot contatos = await Banco.recuperaContatosDoUsuario(widget.id);

      for (var contato in contatos.children) {
        String nome = contato.child('nome').value?.toString() ?? "Sem nome";
        double? latitude = contato.child('latitude').exists
            ? (contato.child('latitude').value as num).toDouble()
            : null;
        double? longitude = contato.child('longitude').exists
            ? (contato.child('longitude').value as num).toDouble()
            : null;
        String telefone = contato.child('telefone').value?.toString() ?? "Telefone não cadastrado";

        if (telefone.isEmpty) telefone = "Telefone não cadastrado";

        Contato ctt = Contato(
          nome,
          latitude: latitude,
          longitude: longitude,
          telefone: telefone,
        );
        ctt.id = contato.key ?? '';
        listaContatos.add(ctt);
      }

      setState(() {
        _listaContatos = listaContatos;
        _carregando = false;
      });
    } catch (e) {
      setState(() {
        _erro = "Erro ao carregar contatos: $e";
        _carregando = false;
      });
      
    }
  }

  @override
  void initState() {
    super.initState();
    _carregarContatos();
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_erro != null) {
      return Center(child: Text(_erro!));
    }

    if (_listaContatos.isEmpty) {
      return const Center(child: Text("Nenhum contato encontrado."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _listaContatos.length,
      itemBuilder: (BuildContext ctx, int i) {
        var contato = _listaContatos[i];
        return Card(
          child: ListTile(
            key: Key(i.toString()),
            title: Text(contato.nome),
            subtitle: Text(contato.telefone ?? "Telefone não cadastrado"),
            trailing: const Icon(Icons.edit, color: Colors.green),
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
                _carregarContatos();
              });
            },
          ),
        );
      },
    );
  }
}

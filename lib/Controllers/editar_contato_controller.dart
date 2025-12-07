import 'package:recicla_the/Data/banco.dart';

import '../Models/contato.dart';

class EditarContatoController{
  final String id;
  final String idContato;
  final Contato contato;

  const EditarContatoController({required this.id, required this.idContato, required this.contato});

  Future<bool> editarContato() async{
    var contatos = await Banco.db2("$id/contatos/$idContato").get();
    var contatoEditado = contatos.ref;

    return contatoEditado.update({
      'nome': contato.nome,
      'telefone': contato.telefone,
      'longitude': contato.longitude,
      'latitude': contato.latitude
    }).
    then((_) =>  true)
    .catchError((_) =>  false);   

  }

  Future<void> excluirContato() async{
    var contatos = await Banco.db2("$id/contatos/$idContato").get();
    var contatoEditado = contatos.ref;
    await contatoEditado.remove();
  }
  
}
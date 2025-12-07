import '../Data/banco.dart';
import '../Models/contato.dart';

class ContatoCadastroController{
  Contato contato;
  String id;

  ContatoCadastroController(this.id,this.contato);

  Future<bool> cadastrarNovoContato() async{
    final contatos = await Banco.recuperaContatosDoUsuario(id);    
    var key = contatos.children.length;    
    var db = await Banco.db2("$id/contatos/$key").get();
    while(db.exists){
      key += 1;
      db = await Banco.db2("$id/contatos/$key").get();
    }
    final newRef = db.ref;

    final novoContato = {
      "nome": contato.nome,
      "telefone": contato.telefone,
      "latitude": contato.latitude, 
      "longitude": contato.longitude
    };
    

    return newRef.set(novoContato)
                  .then((_) => true)
                  .catchError((_) => false);
  }
    
}
import 'package:firebase_database/firebase_database.dart';

class Banco{

  static DatabaseReference db(){
    return FirebaseDatabase.instance.ref("estabelecimentos");
  }

  static DatabaseReference db2(String path){
    return FirebaseDatabase.instance.ref("estabelecimentos/$path");
  }

  static Future<DataSnapshot> recuperaContatosDoUsuario(String id) async{
     var tabelaContatos =  await db2(id).get();
     return tabelaContatos.child('contatos');
  }
}
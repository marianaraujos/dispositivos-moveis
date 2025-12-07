import 'package:firebase_database/firebase_database.dart';
import 'package:recicla_the/Models/estabelecimento.dart';

import '../Data/banco.dart';



class LoginController{
  String login;
  String senha;

  LoginController(this.login,this.senha);

  Future<Estabelecimento?> retornaUsuarioCadastrado() async{  
      
    if(login.isEmpty || senha.isEmpty){
      return null;
    }    
    
    final tabelaEstabelecimentos =  await Banco.db().get();

    //Caso não exista usários no banco, então retorna uma pessoa com id vazio
    if(tabelaEstabelecimentos.children.isEmpty){
      return null;
    }

    bool existeUsuario = false;
    late DataSnapshot user;
    
    //Itera sobre os usuários, e verifica se existe o login digitado
    for(var usuario in tabelaEstabelecimentos.children){
      if(usuario.child('login').value == login){   
        existeUsuario = true;
        user = usuario;
        break;
      }
    }    

    //se não existir o login, então retorna uma pessoa com id vazio
    if(!existeUsuario){
      return null;
    }   

    //o login existe, mas senha digitada está errada
    if(user.child('senha').value != senha){
      return null;
    }

    Estabelecimento estabelecimento = Estabelecimento(
      id: user.key as String,
      login: login,
      senha: senha,
    );   

    if(user.child('latitude').exists){
      estabelecimento.latitude = user.child('latitude').value as double?;
    }
    if(user.child('longitude').exists){
      estabelecimento.longitude = user.child('longitude').value as double?;
    }
    

    return estabelecimento;
  }
}
class Estabelecimento{ 
  String id;
  String login;
  String senha;
  double? latitude;
  double? longitude;
  List<Estabelecimento> contatos = [];

  Estabelecimento({this.id = "", this.login="", this.senha = "", this.latitude = 0.0, this.longitude = 0.0});
}
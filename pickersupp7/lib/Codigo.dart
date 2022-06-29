class Codigo {
  final id_Auditoria;
  final Tipo_captura;
  final codigo_barra;
  final fecha_captura;
  final desc;
  final razon_falla;
  final sincro;
  final tipo_pallet;  //listo todas las variables que pertenecerán a mi objeto
  final Estado_pallets;
  final cantidad;

  Codigo({required this.id_Auditoria,required this.Tipo_captura,required this.codigo_barra, //se inicializan las variables
    required this.fecha_captura,required this.desc,required this.razon_falla,required this.sincro,
    required this.tipo_pallet ,required this.Estado_pallets,required this.cantidad}); //sino, dara error al momento de la declaracion de arriba

  Map<String, dynamic> toJson(){ //se convierte a "MAP" para que una vez pase a la base de datos se haga como
    return{                     //"""recorrible"""
           'id_Auditoria': id_Auditoria,
           'Tipo_captura': Tipo_captura,
           'codigo_barra': codigo_barra, //en definitivas, es como una lista con los elementos que recien inicializamos.
           'fecha_captura': fecha_captura,
           'desc': desc,
           'razon_falla': razon_falla,
           'sincro': sincro,
           'tipo_pallet': tipo_pallet,
           'Estado_pallets': Estado_pallets,
           'cantidad': cantidad,
    };
  }
}

class User {
  String name;
  int age;
  User(this.name, this.age);
  Map toJson() => {
    'name': name,
    'age': age,
  };
}


class Persona {
  final cookie;
  final usuario;
  final pass;

  //listo todas las variables que pertenecerán a mi objeto

  Persona(
      {required this.cookie, required this.usuario, //se inicializan las variables
        required this.pass}); //sino, dara error al momento de la declaracion de arriba

  Map<String, dynamic> toMap() {
    //se convierte a "MAP" para que una vez pase a la base de datos se haga como
    return { //"""recorrible"""
    'cookie': cookie,
    'usuario' : usuario,
    'pass' : pass,
    };
  }
}
class Guid {
  final guid;

  //listo todas las variables que pertenecerán a mi objeto

  Guid(
      {required this.guid}); //sino, dara error al momento de la declaracion de arriba

  Map<String, dynamic> toMap() {
    //se convierte a "MAP" para que una vez pase a la base de datos se haga como
    return { //"""recorrible"""
      'guid_id': guid
    };
  }
}

class Album {
  final int userId;
  final int id;
  final String title;

  const Album({
    required this.userId,
    required this.id,
    required this.title,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
    );
  }
}

class Usuario {
  final user;
  final pass;

  const Usuario({
    required this.user,
    required this.pass,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      user: json['userId'],
      pass: json['id'],
    );
  }
}





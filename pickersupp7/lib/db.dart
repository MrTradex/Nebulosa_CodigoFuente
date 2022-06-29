import 'dart:async';
import 'package:pickersupp/Codigo.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';

class DB {

  static Future<Database> _openDB() async {

    return openDatabase(join(await getDatabasesPath(),'Codigos.db'),
        onCreate: (db, version) async {
          await db.execute(
              "CREATE TABLE codigos (Id_base_datos INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,id_Auditoria VARCHAR(10), Tipo_captura INT, codigo_barra TEXT, fecha_captura DATETIME, desc VARCHAR(30), razon_falla VARCHAR (50), sincro INT, tipo_pallet TEXT, Estado_pallets TEXT, cantidad TEXT)"
          );
          await db.execute("CREATE TABLE usuarios (cookie VARCHAR(50), usuario VARCHAR(30), pass VARCHAR(30))");
          await db.execute("CREATE TABLE guid (guid_id VARCHAR(100))");
          await db.execute("CREATE TABLE errores (error VARCHAR(100))");
          await db.execute("CREATE TABLE api (direccion_api VARCHAR(100))");
          await db.execute("CREATE TABLE IF NOT EXISTS ultimo (estado VARCHAR(40))");
          await db.execute("CREATE TABLE auditoria (id_auditoria INT, estado INT, fecha_inicio DATETIME, fecha_cierre DATETIME, detalle_auditoria VARCHAR(100), cantidad_pallets INT)");
        }, version: 4);
  }

  static Future<Future<int>> insert(Codigo codigo) async {
    Database database = await _openDB();
    return database.insert("codigos", codigo.toJson(),

    );
  }


  static insert_error(String error) async {
    Database database = await _openDB();
    await database.rawQuery("INSERT INTO errores (error) VALUES ('$error')");

  }
  static Mostrar_errores() async {
    Database database = await _openDB();
    final List<Map<String, dynamic>> codigosMap = await database.rawQuery("SELECT * FROM errores");

    return codigosMap.toList();
  }

  static insertar_api(String API)async {
    Database database = await _openDB();
    database.execute("INSERT INTO api (direccion_api) VALUES ('$API')");

  }
  static OBTENER_TODO() async {
    Database database = await _openDB();
    final List<Map<String, dynamic>> codigosMap = await database.rawQuery("SELECT * FROM codigos");

    return codigosMap.toList();
  }
  //----------------------Auditoria---------------------------------------
  static Obtener_estado_auditoria() async {
    Database database = await _openDB();
    final List<Map<String, dynamic>> estado = await database.rawQuery("SELECT (estado) FROM auditoria");
    List verificadora = estado.toList();
    int resultado_estado_auditoria = 0;
    if(verificadora.length > 1){
      resultado_estado_auditoria = 1;
    }else{
      resultado_estado_auditoria = 0;
    }

    return resultado_estado_auditoria;
  }
  static Obtener_campos_anteriores_auditoria() async {
    Database database = await _openDB();
    final List<Map<String, dynamic>> codigosMap = await database.rawQuery("SELECT * FROM auditoria");

    List lista_campos_anteriores = codigosMap.toList();
    return lista_campos_anteriores;
  }

  static insertar_Auditoria(String fecha_inicio,String fecha_termino,String cantidad_pallets,String detalle) async {
    Database database = await _openDB();
    final List<Map<String, dynamic>> codigosMap = await database.rawQuery("INSERT INTO auditoria (id_auditoria,estado,fecha_inicio,fecha_cierre,detalle_auditoria,cantidad_pallets) VALUES (1,1,'$fecha_inicio','$fecha_termino','$detalle','$cantidad_pallets')");

    return codigosMap.toList();
    //(id_auditoria INT, estado INT, fecha_inicio DATETIME, fecha_cierre DATETIME, detalle_auditoria VARCHAR(100), cantidad_pallets INT)"
  }

  static Eliminar_Auditoria() async {
    Database database = await _openDB();
    await database.rawQuery("DELETE FROM auditoria");
    print("Eliminó correctamente el ultimo auditoria registrada");

  }
  //----------------------Auditoria---------------------------------------
  //---------------------Comandos Auditoria-------------------------------
  static Obtener_idAuditoria() async {
    Database database = await _openDB();
    final List<Map<String, dynamic>> codigosMap = await database.rawQuery("SELECT id_auditoria from auditoria ");
    List lista = codigosMap.toList();
    return lista[0];
  }
  //---------------------Comandos Auditoria-------------------------------

  static insertar_estado(String estado_actual) async {
    Database database = await _openDB();
    final List<Map<String, dynamic>> codigosMap = await database.rawQuery("INSERT INTO ultimo (estado) VALUES ('$estado_actual')");

    return codigosMap.toList();
  }


  static obtener_estado() async {
    Database database = await _openDB();
    final List<Map<String, dynamic>> codigosMap = await database.rawQuery("SELECT * FROM ultimo");

    return codigosMap.toList();
  }

  static Eliminar_estado() async {
    Database database = await _openDB();
    await database.rawQuery("DELETE FROM ultimo");
    print("Eliminó correctamente el ultimo estado registrado");

  }
  static Future<int> sacar_api() async {
    Database database = await _openDB();
    final List<Map<String, dynamic>> codigosMap = await database.rawQuery("SELECT * FROM api");
    int verificador = 0;
    if (codigosMap.length < 1){
      print("no tiene ninguna api registrada, ferozo default");
      verificador = 0;
    }else{
      verificador = 1;
    }

    return verificador;
  }
  static Cambiar_api(String API) async {
    Database database = await _openDB();
    await database.rawQuery("DELETE FROM api");
    await database.execute("INSERT INTO api (direccion_api) VALUES ('$API')");
  }


  static Future<int> Mostrar_experimento_guid(Guid_recibido) async {
    Database database = await _openDB();
    int Confirmacion = 0;
    final List<Map<String, dynamic>> codigosMap = await database.rawQuery("SELECT * FROM guid WHERE guid_id = '$Guid_recibido'");
    List lista = codigosMap.toList();
    if(lista.length > 1){
      print("codigo repetido");
      Confirmacion = 1;
    }else{
    }
    print("validando desde la bd...");


    return Confirmacion;
  }

  static Future<int> Resetear_BD() async {
    Database database = await _openDB();
    //deleteDatabase("Codigos.db");
    database.execute("drop table codigos");
    database.execute("CREATE TABLE codigos (Id_base_datos INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, Tipo_captura INT, codigo_barra TEXT, fecha_captura DATETIME, desc VARCHAR(30), razon_falla VARCHAR (50), sincro INT, tipo_pallet TEXT, Estado_pallets TEXT, cantidad TEXT)");

    int Confirmacion = 1;
    return Confirmacion;
  }


  static Future<int> Cambiar_sincro_recibida(codigos_recibidos,codigos_recibidos_rechazados,codigos_estados_rechazados_Detalle) async { //lo que recibo: codigo, estado pero solo ingresados.
    // [77993839, ingresado] , rechazados: id, detalle
    Database database = await _openDB();
    final List<Map<String, dynamic>> codigosMap = await database.rawQuery("SELECT * FROM codigos where sincro = 0");

    for(int x = 0; x < codigos_recibidos.length;x++ ) {
          String temp = codigos_recibidos[x];
          database.execute("UPDATE codigos SET sincro = 1 WHERE Id_base_datos = '$temp'");
    }
    print("codigos rechazados:");
    print(codigos_recibidos_rechazados);
    for(int x = 0; x < codigos_recibidos_rechazados.length;x++ ) {
      String temp = codigos_recibidos_rechazados[x];
      String temp_desc = codigos_estados_rechazados_Detalle[x];
      if(temp_desc == "01-Codigo_repetido"){
        database.execute("UPDATE codigos SET sincro = 1 WHERE Id_base_datos = '$temp'");
      }if(temp_desc == "02-Sin_turno"){
        database.execute("UPDATE codigos SET desc = '$temp_desc' WHERE Id_base_datos = '$temp'");
      }if(temp_desc == "03-Rechazado_doble_ingreso"){
        database.execute("UPDATE codigos SET sincro = 1 WHERE Id_base_datos = '$temp'");
      }if(temp_desc == "04-Paquete_envio_duplicado"){
        database.execute("UPDATE codigos SET desc = '$temp_desc' WHERE Id_base_datos = '$temp'");
      }if(temp_desc == "05-Error_formato_fecha"){
        database.execute("UPDATE codigos SET desc = '$temp_desc' WHERE Id_base_datos = '$temp'");
      }if(temp_desc == "06-Error_Sql_api_interno"){
        database.execute("UPDATE codigos SET desc = '$temp_desc' WHERE Id_base_datos = '$temp'");
      }if(temp_desc == "99-No_es_posible_determinar_confirguracion"){
        database.execute("UPDATE codigos SET desc = '$temp_desc' WHERE Id_base_datos = '$temp'");
      }
    }

    int confirmar = 0;
    return confirmar;
  }

  static Future<Future<int>> insert_usuario(Persona persona) async {
    Database database = await _openDB();
    print("Lo datos que entraron a la bd fueron: ");
    print("pero del ingreso de una persona eso si");
    print(persona.cookie);
    print(persona.usuario);
    print(persona.pass);

    return database.insert("usuarios", persona.toMap(),

    );

  }

  static Future<List<Codigo>> Mostrar_experimento() async {
    Database database = await _openDB();
    final List<Map<String, dynamic>> codigosMap = await database.query("codigos");
    List listita = codigosMap.toList();
    //print(listita[listita.length -1]);

    return List.generate(codigosMap.length,
            (i) => Codigo(
                id_Auditoria: codigosMap[i]['id_Auditoria'],
            Tipo_captura: codigosMap[i]['Tipo_captura'],
            codigo_barra: codigosMap[i]['codigo_barra'],
            fecha_captura: codigosMap[i]['fecha_captura'],
            desc: codigosMap[i]['desc'],
            razon_falla: codigosMap[i]['razon_falla'],
            sincro: codigosMap[i]['sincro'],
            tipo_pallet: codigosMap[i]['tipo_pallet'],
            Estado_pallets: codigosMap[i]['Estado_pallets'],
            cantidad: codigosMap[i]['cantidad']
        ));
  }

  static Future<List<Codigo>> Mostrar_experimento_sincro() async {
    Database database = await _openDB();
    final List<Map<String, dynamic>> codigosMap = await database.rawQuery("SELECT * FROM codigos where sincro = 0");
    //print(listita[listita.length -1]);
    List<Codigo> listita = [];
    List<Codigo> lista_enviable_no_sincronizados = [];
    List<Codigo> lista_enviable_sincronizados = [];
    listita =  List.generate(codigosMap.length,
            (i) => Codigo(
                id_Auditoria: codigosMap[i]['id_Auditoria'],
            Tipo_captura: codigosMap[i]['id_campo'],
            codigo_barra: codigosMap[i]['codigo'],
            fecha_captura: codigosMap[i]['fecha'],
            desc: codigosMap[i]['desc'],
            razon_falla: codigosMap[i]['razon_falla'],
            sincro: codigosMap[i]['sincro'],
            tipo_pallet: codigosMap[i]['tipo_pallet'],   //Hice una lista que me guarde los sincronizados por si acaso.
            Estado_pallets: codigosMap[i]['Estado_pallets'],
            cantidad: codigosMap[i]['cantidad']
        ));

    for(int x = 0; x< listita.length;x++){
      if(listita[x].sincro == 0){
        lista_enviable_no_sincronizados.add(listita[x]);
      }else{
        lista_enviable_sincronizados.add(listita[x]);
      }
    }
    return lista_enviable_no_sincronizados;
  }
  static Future<List<Map<String, dynamic>>> Mostrar_experimento_sincronizados() async {
    Database database = await _openDB();
    final List<Map<String, dynamic>> codigosMap = await database.rawQuery("SELECT * FROM codigos where sincro = 1");
    //print(listita[listita.length -1]); sincro = 1 para cuando la api me devuelva los no sincronizados.

    return codigosMap;
  }

  static Future<List<Map<String, dynamic>>> Mostrar_experimento_uff() async {
    Database database = await _openDB();
    final List<Map<String, dynamic>> codigosMap = await database.rawQuery("SELECT * FROM codigos where sincro = 0");
    //print(listita[listita.length -1]);
    print("Trabajando desde la BD");


    return codigosMap.toList();
  }

  static Future<List<Map<String, dynamic>>> Mostrar_experimento_TODOS() async {
    Database database = await _openDB();
    final List<Map<String, dynamic>> codigosMap = await database.rawQuery("SELECT * FROM codigos");
    //print(listita[listita.length -1]);
    print("Trabajando desde la BD");


    return codigosMap.toList();
  }
  static Future<List> Data_graficos() async {
    Database database = await _openDB();
    final List<Map<String, dynamic>> codigosMap1 = await database.rawQuery("SELECT * FROM codigos WHERE Estado_pallets=1");
    final List<Map<String, dynamic>> codigosMap2 = await database.rawQuery("SELECT * FROM codigos WHERE Estado_pallets=2");
    final List<Map<String, dynamic>> codigosMap3 = await database.rawQuery("SELECT * FROM codigos WHERE Estado_pallets=3");
    final List<Map<String, dynamic>> codigosMap4 = await database.rawQuery("SELECT * FROM codigos WHERE Estado_pallets=4");
    final List<Map<String, dynamic>> codigosMap5 = await database.rawQuery("SELECT * FROM codigos WHERE Estado_pallets=5");
    //print(listita[listita.length -1]);
    print("Obteniendo datos...");
    List lista_de_largos = [codigosMap1.length,codigosMap2.length,codigosMap3.length,codigosMap4.length,codigosMap5.length];

    print(lista_de_largos.length);
    return lista_de_largos;
  }


  static Future<int> Mostrar_experimento_falta_sincronizar() async {
    Database database = await _openDB();
    final List<Map<String, dynamic>> codigosMap = await database.rawQuery("SELECT * FROM codigos where sincro = 0");
    //print(listita[listita.length -1]);
    print("Trabajando desde la BD");


    return codigosMap.toList().length;
  }

  static Future<List<Persona>> Mostrar_experimento_user() async {
    Database database = await _openDB();
    final List<Map<String, dynamic>> usuariosmap = await database.query("usuarios");
    List listita = usuariosmap.toList();
    //print(listita[listita.length -1]);

    return List.generate(usuariosmap.length,
            (i) => Persona(
            cookie: usuariosmap[i]['cookie'],
            usuario: usuariosmap[i]['usuario'],
            pass: usuariosmap[i]['pass']
        ));
  }
  static Future<Future<int>> delete(Persona persona) async {
    Database database = await _openDB();

    return database.delete("usuarios", where: "usuario = ?", whereArgs: [persona.usuario]);
  }

}












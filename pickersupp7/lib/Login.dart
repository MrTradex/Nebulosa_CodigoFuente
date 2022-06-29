import 'dart:async';
import 'dart:io';
import 'package:dart_ping/dart_ping.dart';
import 'package:flutter/material.dart';
import 'package:pickersupp/Seleccionar_categoria_Default.dart';
import 'package:pickersupp/main.dart';
import 'package:sqflite/sqflite.dart';
import 'package:pickersupp/db.dart';
import 'package:pickersupp/Codigo.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pickersupp/Log.dart';
import 'package:pickersupp/Prueba_Auditoria_1.dart';
import 'package:geolocator/geolocator.dart';

String valor_coordenadas_longitud = "";
String valor_coordenadas_latitud = "";
List locacion_oficina = [];
int Verificador_localizacion = 0;
List Informe_errores = [];
List json_tipo_pallets = [];
List json_tipo_pallets_id = [];
List json_estado_pallets = [];
List json_estado_pallets_id = [];
String Http_prueba = "Cargando...";
String URL = "";
String tiempo_sincro = "";
String id_empresa = "";
String id_sucursal = "";
int verificador_modo_sin_internet = 0;
var valor_locacion = "";
class SecondRoute extends StatefulWidget {
  const SecondRoute({Key? key}) : super(key: key);

  @override
  State<SecondRoute> createState() => _SecondRouteState();
}

class _SecondRouteState extends State<SecondRoute> {
  late Future<String> respuesta_http;
  final usuario_ingresado = TextEditingController();
  final contrasena_ingresada = TextEditingController();
  final textcontrololer_url = TextEditingController();
  int verificador_usuario = 0;
  void initState() {
    Inicializar_direccion_api();
    location_variable();
    Verificador_nuevo_usuario();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    int verificador = 0;
    final ButtonStyle style =
    ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: ListView(
          children: [
            Container(
              height: 300,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('images/login_background.jpg'),
                      fit: BoxFit.fill
                  )
              ),

              child: Stack(
                  children:<Widget> [
                    Positioned(
                      child: Container(
                        child: Center(
                          child: Text("Nebulosa Scanner" + "\n"+ "V1.1", style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
                          //child: Text(valor_locacion.toString(), style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    TextButton(
                      child: Text("Cambiar API", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      onPressed:(){
                        showDialog(
                            context: context,
                            builder: (BuildContext context){
                              return AlertDialog(
                                title: Text("Credenciales utilizadas"),
                                content: TextField(
                                  controller: textcontrololer_url,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: 'Ingrese otra dirección de API',
                                  ),
                                ),
                                actions: [
                                  ElevatedButton(
                                      onPressed: (){
                                        setState(() {
                                          URL = textcontrololer_url.text;
                                        });
                                        Navigator.pop(context);
                                      },
                                      child: Text("Cambiar"))
                                ],
                              );

                        });
                      },
                    )
                  ]
              ),
            ),
            Container(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: usuario_ingresado,
                    decoration: InputDecoration(
                      labelText: 'Nombre de usuario',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(
                        Icons.supervised_user_circle_sharp,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8.0),

                  TextFormField(
                    controller: contrasena_ingresada,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(
                        Icons.lock,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Colors.blue,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        textStyle: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
                    onPressed: () async {
                      if(verificador_modo_sin_internet == 1){
                        List usuario_del_capturador = await DB.Mostrar_experimento_user();
                        print(usuario_del_capturador);
                        //no tiene internet
                        if(usuario_del_capturador.length >= 1){ //si hay alguien registrado en el capturador
                          if(usuario_ingresado.text == usuario_del_capturador[0].usuario && contrasena_ingresada.text == usuario_del_capturador[0].pass){
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                    'Bienvenid@ nuevamente!'),
                              ),
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => Seleccionar_categoria()),
                            );
                          }else{
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                    'Credenciales incorrectas!'),
                              ),
                            );
                          }
                        }else{
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                  'No se pude verificar su identidad en modo offline!'),
                            ),
                          );
                        }
                      }

                      if(verificador_modo_sin_internet == 0 && verificador_usuario == 0 ){
                        await Post(usuario_ingresado.text, contrasena_ingresada.text);
                        Cargar_caracteristicas();
                        var json_decodeado = json.decode(Http_prueba);
                        tiempo_sincro = json_decodeado["Configuraciones"][0]["M_segundos_act_sinc_Configuracion_C"];
                        id_empresa = json_decodeado["Configuraciones"][0]["id_empresa_Configuracion_C"].toString();
                        id_sucursal = json_decodeado["Configuraciones"][0]["id_Sucursal_Contador"].toString();
                        var api_nueva = json_decodeado["Configuraciones"][0]["Servidor_S_C_I"].toString();
                        await DB.insertar_api(api_nueva);
                        DB.insert_usuario(Persona(cookie: json_decodeado["Configuraciones"][0]["Serie_S_C_I"], usuario: json_decodeado["Configuraciones"][0]["Usuario_S_C_I"], pass: json_decodeado["Configuraciones"][0]["Clave_S_C_I"]));
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Seleccionar_categoria()));
                      }
                    },
                    child: const Text('Ingresar'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8.0),
            //Container(
              //child: Text(Http_prueba)
            //)
          ],//todo lo que quieras arriba
        ),
      ),
      floatingActionButton: FloatingActionButton(
      onPressed:() async {
      },
        tooltip: "",
        child: const Icon(Icons.add_photo_alternate_outlined),
        )

      );
  }


    Future<Position> _determinePosition() async {
      bool serviceEnabled;
      LocationPermission permission;

      // Test if location services are enabled.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled don't continue
        // accessing the position and request users of the
        // App to enable the location services.
        return Future.error('Location services are disabled.');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions are denied, next time you could try
          // requesting permissions again (this is also where
          // Android's shouldShowRequestPermissionRationale
          // returned true. According to Android guidelines
          // your App should show an explanatory UI now.
          return Future.error('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, handle appropriately.
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }

      // When we reach here, permissions are granted and we can
      // continue accessing the position of the device.
      return await Geolocator.getCurrentPosition();
    }


    //print("LOCALIZACION? : ");
    //print(_locationData);

  Inicializar_direccion_api(){
    setState(() {
      URL = "http://164.77.174.74/api/";
    });
  }
  Notificador_no_internet(){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
            'No posee conexion a internet!'),
      ),
    );
    verificador_modo_sin_internet = 1;
  }
  Cargar_caracteristicas(){
    var contenido_Caracteristicas = json.decode(Http_prueba);
    final length = contenido_Caracteristicas["Configuraciones1"].length;
    final length2 = contenido_Caracteristicas["Configuraciones2"].length;

    for(int x = 0; x < length; x++){
      json_tipo_pallets.add(contenido_Caracteristicas["Configuraciones1"][x]["Codigo_t_pallets"].toString());
      json_tipo_pallets_id.add(contenido_Caracteristicas["Configuraciones1"][x]["Id_t_pallets"].toString());
      print(contenido_Caracteristicas["Configuraciones1"][x]["Id_t_pallets"].toString());
    }
    for(int x = 0; x < length2; x++){
      json_estado_pallets.add(contenido_Caracteristicas["Configuraciones2"][x]["Nombre_cshe"].toString());
      json_estado_pallets_id.add(contenido_Caracteristicas["Configuraciones2"][x]["id_cshe"].toString());
      print(contenido_Caracteristicas["Configuraciones2"][x]["id_cshe"].toString());
    }
  }
  location_variable() {
    const oneSec = Duration(seconds:10);
    Timer.periodic(oneSec, (Timer t) => funcion_posicion());
  }
  funcion_posicion() async {
    var valor = await _determinePosition();
    valor_coordenadas_longitud = valor.longitude.toString();
    valor_coordenadas_latitud = valor.latitude.toString();
    //print("-------------------------");
    //      print("Longitud: : ");
    //      print(valor_coordenadas_longitud);
    //      print("Latitud: : ");
    //      print(valor_coordenadas_latitud);
    //      print("-------------------------");
  }
  Verificador_nuevo_usuario() async {
    List<Persona> auxPersona = await DB.Mostrar_experimento_user();
    if(auxPersona.length < 1){
      verificador_usuario = 0;
    }else{
      verificador_usuario = 1;
    }
    String estado_de_la_red = await Post("", "");
    print("el estado de la red es: ");
    print(estado_de_la_red);
    if(estado_de_la_red == "200"){
      print("conexion con servidor exitosa y funcionando,ademas de internet claro");
    }
    if(estado_de_la_red == "400"){
      print("no hay conexion a internet");
    }
    //Verificaciones de estado completadas--------------------------------------

    if(verificador_usuario == 1 && estado_de_la_red == "200"){
      await Post(auxPersona[0].usuario, auxPersona[0].pass);
      Cargar_caracteristicas();
      var json_decodeado = json.decode(Http_prueba);
      tiempo_sincro = json_decodeado["Configuraciones"][0]["M_segundos_act_sinc_Configuracion_C"];
      id_empresa = json_decodeado["Configuraciones"][0]["id_empresa_Configuracion_C"].toString();
      id_sucursal = json_decodeado["Configuraciones"][0]["id_Sucursal_Contador"].toString();

      int api_disponible = await DB.sacar_api();
      if(api_disponible == 0){
        URL = "http://164.77.174.74/api/";
        //URL = "http://sd-1894661-h00004.ferozo.net/api/";
        //await DB.insertar_api("http://sd-1894661-h00004.ferozo.net/api/");
        await DB.insertar_api("http://164.77.174.74/api/");
      }

      //URL = api_nueva[0]["direccion_api"].toString();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Seleccionar_categoria()), //si la persona esta registrada en la base de datos local y tiene internet
      );
    }
     if(verificador_usuario == 1 && estado_de_la_red == "400") {
       verificador_modo_sin_internet = 1;
       Navigator.pushReplacement(
         context,
         MaterialPageRoute(builder: (context) => Seleccionar_categoria()),//si la persona esta registrada pero no tiene internet
       );
     }
    //if(verificador_usuario == 0 && estado_de_la_red == "200"){
    //       print("El usuario es totalmente nuevo, porque no hay nada en la base de datos"); //El usuario no esta registrado, pero tiene net
    //       await Post("", "");
    //     } tendria que hacerse con el boton por huevos.

    if(verificador_usuario == 0 && estado_de_la_red == 400 || estado_de_la_red == 404){
      verificador_modo_sin_internet = 1;
      print("no esta ni registrado ni tiene internet.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Usted no se encuentra registrado ni tiene internet'),
        ),
      );
    }
  }


  Future<String> Post(String user,String pass) async {
    try{
      var jsonenviable = "[" +jsonEncode(<String, String>{
        'Usuario': user,
        'Pass': pass,
      }) + "]";
      print("lo de abajo es el print de la funcion");
      print(jsonenviable);

      final response = await http
          .post(Uri.parse(URL+"SessionCapturadores"),
          body: jsonenviable,
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json"
          }
      );

      //print(response.body);
      Http_prueba = response.body;
      print(Http_prueba);
      var URL_de_json = json.decode(Http_prueba);
      //if(user != "" && pass != ""){
      //         URL = URL_de_json["Configuraciones"][0]["Servidor_S_C_I"];
      //         print(URL_de_json["Configuraciones"][0]["Servidor_S_C_I"]);
      //         print("Nuevo valor de URL: $URL");
      //       }
      return response.statusCode.toString();

    }on SocketException{
      //esto es cuando no tiene conexion a internet para entrar en la aplicacion.
      return 400.toString();
    }
  }
}









import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:pickersupp/AuditoriaG.dart';
import 'package:pickersupp/Graficos.dart';
import 'package:pickersupp/Listado_trabajadores.dart';
import 'package:pickersupp/main.dart';
import 'package:pickersupp/db.dart';
import 'package:pickersupp/Codigo.dart';
import 'package:pickersupp/Login.dart';
import 'package:http/http.dart' as http;
import 'package:restart_app/restart_app.dart';
import 'Calidad_Curva.dart';
import 'package:pickersupp/Trazabilidad.dart';
import 'package:uuid/uuid.dart';
import 'Calidad_Fin.dart';
List nose = [];
String ultimo_registro = "";
int largo_codigo_escaneado = 9;
String opcion_escogida = "Seleccione un modo";
int conexion_error = 0;
int conexion_ok = 0;
int verificador_estoy_aqui_iniciado = 0;
int verificador_enviar_bloque_iniciado = 0;
String Guid = "";
String turno_actual = "";
int verificador_turno_continua = 0;
var data_graficos;
class Seleccionar_categoria extends StatefulWidget {
  const Seleccionar_categoria({Key? key}) : super(key: key);

  @override
  State<Seleccionar_categoria> createState() => _Seleccionar_categoriaState();
}

class _Seleccionar_categoriaState extends State<Seleccionar_categoria> {
  var Lista_de_modos = [
    "Auditoria",
    "Reparacion",
    "Calidad Fin",
    "Calidad Curva",
    "Trazabilidad",
    //"Inventario Maderas"
  ];
  var titulo_appbar = "Selecciona Modo";
  final textcontrololer_largo_codigo = TextEditingController();

  @override
  void initState() {
    Future.delayed(
      Duration(),
          () => SystemChannels.textInput.invokeMethod('TextInput.hide'),
    );
    Revisar_ultimo_estado();
    //Obtener_valores();
    Estoy_aqui(); //este cuidado
    Enviar_Bloque(); //este cuidado
    Internet_restablecido();
    super.initState();
  }

  String bienvenido = "Bienvenid@!";
  String bienvenido2 = "";
  double prueba1 = 0.0;
  double prueba2 = 0.0;
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Selecciona Modo"),
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context){
                        return AlertDialog(
                          title: Text("Codigo de barras configuración"),
                          content: TextField(
                            controller: textcontrololer_largo_codigo,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Ingrese la cantidad del codigo de barras',
                            ),
                          ),
                          actions: [
                            ElevatedButton(
                                onPressed: (){
                                  textcontrololer_largo_codigo.text = textcontrololer_largo_codigo.text;
                                  largo_codigo_escaneado = int.parse(textcontrololer_largo_codigo.text);
                                  Navigator.pop(context);
                                },
                                child: Text("Aceptar"))
                          ],
                        );

                      });
                },
                child: Icon(
                  Icons.list_alt,
                  size: 26.0,
                ),
              )
          ),
        ],
        backgroundColor: Colors.black,

      ),
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('images/windows-g018a98fad_1920.jpg'),
                fit: BoxFit.fill
            )
        ),
        child: ListView(
          children: [
            const SizedBox(height: 135),

            Center(
              child: Text(bienvenido,
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
            ),
            Center(
              child: Text(bienvenido2,
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 30),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 70, vertical: 8),
              decoration: BoxDecoration(color: Colors.black54,
                  borderRadius: BorderRadius.circular(30)),

              child: DropdownButton(
                items: Lista_de_modos.map((String a) { //vista1
                  return DropdownMenuItem(
                      value: a,
                      child: Text(a));
                }).toList(),
                onChanged: (_value) =>
                {
                  setState(() {
                    opcion_escogida = _value.toString();
                  })
                },
                hint: Text(
                    opcion_escogida, style: TextStyle(color: Colors.white)),
                iconEnabledColor: Colors.green,
                icon: Icon(Icons.arrow_downward_sharp),
              ),
            ),

            const SizedBox(height: 70),

            Container(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 8),
                child: ElevatedButton(
                  onPressed: () {
                    if (opcion_escogida == "Seleccione un modo") {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                              'Porfavor, seleccione un modo'),
                        ),
                      );
                    }
                    if (opcion_escogida == "Reparacion") {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MyHomePage(
                                title: "Sistema Base")),
                      );
                    }
                    if (opcion_escogida == "Auditoria") {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Calidad_Curva()),
                      );
                    }
                    if (opcion_escogida == "Trazabilidad") {
                      Navigator.push(context,
                        MaterialPageRoute(builder: (context) => trazabilidad()),
                      );
                    }
                    if (opcion_escogida == "Calidad Curva") {
                      Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Auditoria()),
                      );
                    }
                    if (opcion_escogida == "Calidad Fin") {
                      Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Calidad_Fin()),
                      );
                    }
                    if (opcion_escogida == "Listado Trabajadores") {
                      Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Listado_trabajadores_Log()),
                      );
                    }
                  },
                  child: Text("Continuar"),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.black,
                      padding: EdgeInsets.symmetric(
                          horizontal: 30, vertical: 10),
                      textStyle: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                )
            ),
          ],
        ),
      ),
    );
  }

  Post_estoy_aqui() async {
    final consola_date = DateTime.now().toString().substring(0, 19);
    String cookie_pasa = "";
    String fecha_pasa = "";
    List lista_json_estoy_aqui = [];
    List List_to_json = [];
    List <Persona> Serie_usuario = await DB
        .Mostrar_experimento_user();
    List <Codigo> ultimo_objeto = await DB
        .Mostrar_experimento();
    int falta_sincronizar_Cantidad = await DB
        .Mostrar_experimento_falta_sincronizar();

    String puertos_com = "no hay puertos";
    String Tipo_dispositivo = "Scanner_android_Beta";
    String Funcion_actual = titulo_appbar;

    Serie_usuario.isEmpty ? cookie_pasa = "Sin cookie" : cookie_pasa = Serie_usuario[0].cookie;
    ultimo_objeto.isEmpty ? fecha_pasa = consola_date : fecha_pasa = ultimo_objeto.last.fecha_captura;

    lista_json_estoy_aqui.add(cookie_pasa);
    lista_json_estoy_aqui.add(puertos_com);
    lista_json_estoy_aqui.add(fecha_pasa);
    lista_json_estoy_aqui.add(Tipo_dispositivo);
    lista_json_estoy_aqui.add(Funcion_actual);
    lista_json_estoy_aqui.add(falta_sincronizar_Cantidad);

    List contenido = lista_json_estoy_aqui;

    var json_interno = {
      "Serie": contenido[0],
      "Puertos_com": contenido[1],
      "Ultima_lectura": contenido[2],
      "Tipo_dipositivo": contenido[3],
      "Funcion_actual": contenido[4],
      "pendientes_sincronizacion": contenido[5],
      "latitud": valor_coordenadas_latitud,
      "longitud": valor_coordenadas_longitud,
      "Hora_actual": consola_date
    };

    List_to_json = [json_interno];

    nose = [];
    var json_nose = {
      'Informa_conexion': List_to_json,
      'respaldo_base_datos': nose
    };

    var msg = json.encode(json_nose);
    print("------------------------------");
    print("Estoy Aqui!");
    print("------------------------------");
    //print(msg);
    try {
    final response = await http
        .post(
        Uri.parse(URL+"MantenedorConexion"),
        body: msg,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json"
        }
    );
    if(response.statusCode == 200){
      print("200");
    }else{
      ultima_sincronizacion_fallida = "Error en servidor";
      await DB.insert_error("Servidor rechaza estoy_aqui $consola_date");
      print("servidor muerto compa");
    }
    respuesta_de_bd_estoyaqui = response.body;
    var json_respuesta_de_bd_contenido = json.decode(respuesta_de_bd_estoyaqui);
    print(json_respuesta_de_bd_contenido);

    if (json_respuesta_de_bd_contenido[0]["Reiniciar_sistema"] == "2") {
      var api_nueva = json_respuesta_de_bd_contenido[0]["Servidor_S_C_I"];
      await DB.Cambiar_api(api_nueva);
      Restart.restartApp(webOrigin: 'MyHomePage(title: "Reiniciando...")');
    }else{
      print("No hay reseteo hardcore");
    }
    if (json_respuesta_de_bd_contenido[0]["Reiniciar_sistema"] == "1") {
      print("iniciando reseteo");
      List resultado = await DB.obtener_estado();
      print(resultado);
      if(resultado.isEmpty) {
        print("entro al condicional");
        await DB.insertar_estado("Reparacion");
        Restart.restartApp(webOrigin: 'MyHomePage(title: "Reiniciando...")');
      }
    }else{
      print("Ninguna instruccion adicional");
    }
    if(json_respuesta_de_bd_contenido[0]["Solicitar_bd_local"] == "1"){
      nose = await DB.OBTENER_TODO();
    }else{
      nose = [];
    }

  }on SocketException{
      await DB.insert_error("Error desconocido, Socket_Estoyaqui $consola_date");
      return  Internet_restablecido();
    }
   on Exception{
      return Internet_restablecido();
   }
  }
  //los dos post con su respectivo verificador de internet
  Future<String> Post_bloque(bloque_datos_enviable) async {
    try {
      final response = await http
          .post(Uri.parse(
          URL+"SincronizadorApp2"), //
          body: bloque_datos_enviable,
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json"
          }
      );

      respuesta_de_bd = response.body;
      if (response.statusCode == 200) {
        print("EL envio del bloque fue exitoso!");
      } else{
        ultima_sincronizacion_fallida = "Error en servidor";
        print("servidor muerto");
      }
      return response.body;
    }on SocketException{

  return  Internet_restablecido();
    }
     on Exception{
      return Internet_restablecido();
    }
  }
  Internet_restablecido() {
    print("Algo falló");
  }

  Revisar_ultimo_estado() async {
    List estado = await DB
        .obtener_estado();

    if(estado.isNotEmpty){
      ultimo_registro = estado.last["estado"].toString();
      Navigator.push(context, MaterialPageRoute(builder: (context) => const MyHomePage(
          title: "Sistema Base")));
      await DB.
      Eliminar_estado();
    }else{
      print("No se habia quedado en ningun lugar");
    }
  }
  Recuperar_Datos() async {
    List<Persona> usuario_actual = await DB.Mostrar_experimento_user();
    Recuperar_informacion(usuario_actual[0].usuario, usuario_actual[0].pass);
  }
  Future<String> Recuperar_informacion(String user,String pass) async {
    try{
      var jsonenviable = "[" +jsonEncode(<String, String>{
        'Usuario': user,
        'Pass': pass,
      }) + "]";
      final response = await http
          .post(Uri.parse(URL+"SessionCapturadores"),
          body: jsonenviable,
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json"
          }
      );

      Http_prueba = response.body;
      if(response.statusCode == 200){
        var json_decodeado = json.decode(Http_prueba);
        tiempo_sincro = json_decodeado["Configuraciones"][0]["M_segundos_act_sinc_Configuracion_C"];
        id_empresa = json_decodeado["Configuraciones"][0]["id_empresa_Configuracion_C"].toString();
        id_sucursal = json_decodeado["Configuraciones"][0]["id_Sucursal_Contador"].toString();
        verificador_modo_sin_internet = 0;
      }else{
        ultima_sincronizacion_fallida = "Error en servidor";
      }
      return response.body;

    }on SocketException{
      //esto es cuando no tiene conexion a internet para entrar en la aplicacion.
      print("Intentando volver a conectar...");
      return Internet_restablecido();
    }on Exception{
      return Internet_restablecido();
    }
  }
  Enviar_Bloque() {
    if(verificador_modo_sin_internet == 0){
      if(verificador_enviar_bloque_iniciado == 0){
        if(tiempo_sincro == ""){
          print("El usuario no ha sido reconocido, pero se pondra un tiempo default");
          tiempo_sincro = "3000";
        }
        var tiempo_recibido = int.parse(tiempo_sincro);
        tiempo_recibido = tiempo_recibido * 25; //tiempo recibido 6000
        var oneSec = Duration(milliseconds: tiempo_recibido); //tengo que sacar el tiempo de la sincronizacion
        print("tiempo estimado por cada sincronizacion: $tiempo_recibido ");
        final bloque_envio_tiempo = Timer.periodic(oneSec, (Timer t) => Enviar_no_Sincronizados());
      }else{
        print("Ya habia entrado compa");
      }
      }else{
        print("Modo sin internet, por lo cual no se puede enviar bloque");
      }
  }
//  Contar(List elements){
//     var map = Map();
//
//     elements.forEach((element) {
//       if(!map.containsKey(element)) {
//         map[element] = 1;
//       } else {
//         map[element] +=1;
//       }
//     });
//
//     return map;
//   }
//   Obtener_valores() async {
//     lista_contenido = await DB.Data_graficos(); //el tiene que recibir lenght's de los distintos tipos de pallets que tiene
//     //definitivamente se podria hacer de manera responsiva, viendo la cantidad de elementos que me carga desde la lista de pallets
//     //dinamica, pero claro, eso seria para más adelante, por el momento solo me importa la planta de alla
//     //List lista_contenido_lengths = [lista_contenido.count];
//     data_graficos = Contar(lista_contenido); //esto me devolverá
//   }

  Enviar_no_Sincronizados() async {
    // Post de envio del bloque.
    List prueba_funcion = await DB.
    Mostrar_experimento_uff();
    var json_usuario = json.decode(Http_prueba);
    String usuario_cookie = json_usuario["Configuraciones"][0]["Serie_S_C_I"];
    var Guid = Uuid().v1();
    String prueba_guid = Guid;
    var encabezado_credenciales = {
      'Serie': usuario_cookie,
      'Guid_envio': prueba_guid
    };
    List encabezado = [encabezado_credenciales];
    var json_bloque = {
      'Data_encabezado':encabezado,
      'Data_tabla':prueba_funcion
    };

    var msg = json.encode(json_bloque);
    await Post_bloque(msg);

    var json_de_la_bd = json.decode(respuesta_de_bd);
    final largo = json_de_la_bd["Data_tabla"].length;

    List codigos_estados = [];
    List codigos_estados_rechazados = [];
    List codigos_estados_rechazados_Detalle = [];
    print("validando estado del paquete: ");

    //if(json_de_la_bd["Estado_consulta"][0]["id_turno"] != "0"){ //con esto confirmamos que logramos enviar paquetes.
    //       print("tenemos un turno!");
    //       if(turno_actual != ""){
    //
    //         if(json_de_la_bd["Estado_consulta"][0]["id_turno"] != turno_actual){
    //             print("Significa que es un turno diferente");
    //             lista_contenido = [];
    //             print("aqui tendria que reiniciar el grafico");
    //             //hacer una lista que se llene de datos ingresados 001 pal grafico. con esos datos, llenar otra lista.
    //           //esa otra lista eso si, tendria los datos hasta que turno cambie.
    //         }else{
    //           print("todavia estamos en el mismo turno");
    //           verificador_turno_continua = 1;
    //         }
    //       }
    //
    //       turno_actual = json_de_la_bd["Estado_consulta"][0]["id_turno"];
    //     }else{
    //       turno_actual = "0";
    //       print("no fue posible obtener un turno de ninguna manera");
    //     }

    if(json_de_la_bd["Estado_consulta"][0]["Estado"] == "OK"){
      ultima_sincronizacion = DateTime.now().toString().substring(0,19);
      conexion_ok = 1;
      for(int x = 0; x < largo ; x++ ){
        if(json_de_la_bd["Data_tabla"][x]["Estado"] == "00-Ingresado"){
          codigos_estados.add(json_de_la_bd["Data_tabla"][x]["Id_base_datos"].toString());
          if(verificador_turno_continua == 1){
            lista_contenido.add(json_de_la_bd["Data_tabla"][x]["Estado_pallets"].toString());
            //que me agregue los estadoooos, de esa manera, despues solo cuento cuantas veces se repite en la lista jsdnjsdnsd
          }
        }
        else if(json_de_la_bd["Data_tabla"][x]["Estado"] == "01-Codigo_repetido"){
          codigos_estados_rechazados.add(json_de_la_bd["Data_tabla"][x]["Id_base_datos"].toString());
          codigos_estados_rechazados_Detalle.add(json_de_la_bd["Data_tabla"][x]["Estado"].toString());
        }
        else if(json_de_la_bd["Data_tabla"][x]["Estado"] == "02-Sin_turno"){
          codigos_estados_rechazados.add(json_de_la_bd["Data_tabla"][x]["Id_base_datos"].toString());
          codigos_estados_rechazados_Detalle.add(json_de_la_bd["Data_tabla"][x]["Estado"].toString());
        }
        else if(json_de_la_bd["Data_tabla"][x]["Estado"] == "03-Rechazado_doble_ingreso"){
          codigos_estados_rechazados.add(json_de_la_bd["Data_tabla"][x]["Id_base_datos"].toString());
          codigos_estados_rechazados_Detalle.add(json_de_la_bd["Data_tabla"][x]["Estado"].toString());
        }
        else if(json_de_la_bd["Data_tabla"][x]["Estado"] == "04-Paquete_envio_duplicado"){
          codigos_estados_rechazados.add(json_de_la_bd["Data_tabla"][x]["Id_base_datos"].toString());
          codigos_estados_rechazados_Detalle.add(json_de_la_bd["Data_tabla"][x]["Estado"].toString());
        }
        else if(json_de_la_bd["Data_tabla"][x]["Estado"] == "05-Error_formato_fecha"){
          codigos_estados_rechazados.add(json_de_la_bd["Data_tabla"][x]["Id_base_datos"].toString());
          codigos_estados_rechazados_Detalle.add(json_de_la_bd["Data_tabla"][x]["Estado"].toString());
        }
        else if(json_de_la_bd["Data_tabla"][x]["Estado"] == "06-Error_Sql_api_interno"){
          codigos_estados_rechazados.add(json_de_la_bd["Data_tabla"][x]["Id_base_datos"].toString());
          codigos_estados_rechazados_Detalle.add(json_de_la_bd["Data_tabla"][x]["Estado"].toString());
        }
        else if(json_de_la_bd["Data_tabla"][x]["Estado"] == "99-No_es_posible_determinar_confirguracion"){
          codigos_estados_rechazados.add(json_de_la_bd["Data_tabla"][x]["Id_base_datos"].toString());
          codigos_estados_rechazados_Detalle.add(json_de_la_bd["Data_tabla"][x]["Estado"].toString());
        }
      }
      int sincroscero = await DB.
      Mostrar_experimento_falta_sincronizar();

      if(sincroscero == 0){
        var consola_date = DateTime.now().toString().substring(0,19);
        await DB.insert_error("Error: No hay datos para sincronizar $consola_date");
      }else{
        await DB.Cambiar_sincro_recibida(codigos_estados,codigos_estados_rechazados,codigos_estados_rechazados_Detalle);
      }
    }else if(json_de_la_bd["Estado_consulta"][0]["Estado"] == "Error"){
      ultima_sincrnizacion_fallida_razon = json_de_la_bd["Estado_consulta"][0]["Estado"];
      var consola_date = DateTime.now().toString().substring(0,19);
      await DB.insert_error("Servidor rechaza paquete $ultima_sincrnizacion_fallida_razon $consola_date");
      conexion_error = 1;
      ultima_sincronizacion_fallida = DateTime.now().toString().substring(0,19);
    }
  }

  Estoy_aqui() {
    if(verificador_modo_sin_internet == 0){
      if (verificador_estoy_aqui_iniciado == 0) {
        var contenido = json.decode(Http_prueba);
        verificador_estoy_aqui_iniciado = 1;
        const oneSec = Duration(seconds: 30); //tiempo_por_sincro_sec
        final Estoy_aqui_tiempo = Timer.periodic(oneSec, (Timer t) => Post_estoy_aqui());
      } else {
        print("Estoy aqui ya se encuentra en marcha!");
      }
    }else{
      print("modo sin conexion, estoy aqui desactivado");
    }
  }
}

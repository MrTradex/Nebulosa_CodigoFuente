import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart'hide Intent;
import 'package:flutter/material.dart' hide Intent;
import 'package:pickersupp/AuditoriaG.dart';
import 'package:pickersupp/Calidad_Fin.dart';
import 'package:pickersupp/Listado_trabajadores.dart';
import 'package:pickersupp/Seleccionar_categoria_Default.dart';
import 'package:pickersupp/Trazabilidad.dart';
import 'package:pickersupp/db.dart';
import 'package:pickersupp/Codigo.dart';
import 'package:pickersupp/Login.dart';
import 'package:pickersupp/Log.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'Calidad_Curva.dart';
import 'Graficos.dart';
import 'Log_errores.dart';


String ultima_caida_wifi = "";
String ultima_caida_api = "";
String ultima_sincronizacion= "";
String ultima_sincronizacion_fallida = "";
String ultima_sincrnizacion_fallida_razon = "";
String Modo_lectura_pistola = "Pantalla";
bool pregunta_lectura = false;

String Http_prueba_cookie = "";
String respuesta_de_bd = "";
String respuesta_de_bd_estoyaqui = "";
IconData iconData = Icons.check;
Color Color_estado_paquete = Colors.grey;
Color Color_api = Colors.white;
Color Color_wifi = Colors.white;
int multiple = 0;


void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Sistema Base',
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
        ),
        home: const SecondRoute()
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();

}

class _MyHomePageState extends State<MyHomePage> {
  List<Codigo> lista_objetos_codigos = [];
  List<Persona> objeto_usuario = [];
  @override
  void initState() {
    Future.delayed(
      Duration(),
          () => SystemChannels.textInput.invokeMethod('TextInput.hide'),
    );
    Cambiar_campo();
    Nombre_modulo();
    Usuario_Detectado();
    Dato_adicional();
    cargaCodigos();
    Actualizar_tabla();
    super.initState();

  }
  //Variables abiertas en el codigo.
  //-----------------------------------------------------------
  //listado de opciones que aparecen en las causas

  var paso = 0;
  var recuperado = 0;
  String cantidad_seleccionada = "1";
  int verificador_cambia_opcion_manual = 0;
  //listado de las opiones escogidas.
  int verificador_de_campo = 1;
  int verificador_de_color = 1;
  //variables cambiantes en MORADOS (CTRL + F = MORADO)
  Color btn_colorverde = Colors.white;
  Color btn_colorrojo = Colors.white; //Colores de los botones --> Controladores
  int verificador_no_manual = 0;
  bool codigo_compuesto = false;
  //----------------------------------------------
  var titulo_appbar = "Seleccione una opción";
  final textcontroller_cambiar_usuario_url = TextEditingController();
  final textcontroller_resetear_BD = TextEditingController();
  final textcontrollercodigo_lote = TextEditingController();
  final textcontrollercodigo = TextEditingController();
  final padding = EdgeInsets.symmetric(horizontal: 20);
  final bool value = false;
  final focus = FocusNode();
  //---------------------------------------------
  String texto_codigo = "";
  String texto_id_campo = "12";
  List _listaTipos = []; // tipos de pallets (cambiable cuando se conecte a la api)
  List _listaTipos_2 = [];
  String vista = "Seleccione Estado de pallet";
  String vista2 = "Seleccione Tipo de pallet";
  String vista_tipo = "";
  String vista_estado = "";


  //-----------------------------------------------------------

  Table _tabla(){
    setState(() {
    });
    if(lista_objetos_codigos.length < 3){
      return Table(
          defaultColumnWidth: FixedColumnWidth(100.0),
          border: TableBorder.all(
              color: Colors.black,
              style: BorderStyle.solid,
              width: 2),
          children: [
            TableRow(children: [
              Column(
                  children: [
                    Text("Codigo", style: TextStyle(fontSize: 20.0))
                  ]),
              Column(children: [
                Text('T° Pallet', style: TextStyle(fontSize: 20.0))
              ]),
              Column(
                  children: [
                    Text('Fecha', style: TextStyle(fontSize: 20.0))
                  ]),

            ]),
          ] //final del children que agrega
      );
    }else{
      return Table(
          defaultColumnWidth: FixedColumnWidth(100.0),
          border: TableBorder.all(
              color: Colors.black,
              style: BorderStyle.solid,
              width: 2),
          children: [
            TableRow(children: [
              Column(
                  children: [
                    Text("Codigo", style: TextStyle(fontSize: 20.0))
                  ]),
              Column(children: [
                Text('T° Pallet', style: TextStyle(fontSize: 20.0))
              ]),
              Column(
                  children: [
                    Text('Fecha', style: TextStyle(fontSize: 20.0))
                  ]),

            ]),
            TableRow(children: [
              Column(
                  children: [Text(lista_objetos_codigos.last.codigo_barra)]),
              //la ida era poner el ultimo id registrado aca.
              Column(
                  children: [Text(lista_objetos_codigos.last.tipo_pallet)]),
              Column(children: [Text(lista_objetos_codigos.last.fecha_captura)]),
            ]),

            TableRow(children: [
              Column(
                  children: [Text(lista_objetos_codigos[lista_objetos_codigos.length-2].codigo_barra)]),
              //la ida era poner el ultimo id registrado aca.
              Column(
                  children: [Text(lista_objetos_codigos[lista_objetos_codigos.length-2].tipo_pallet)]),
              Column(children: [Text(lista_objetos_codigos[lista_objetos_codigos.length-2].fecha_captura)]),
            ]),

            TableRow(children: [
              Column(
                  children: [Text(lista_objetos_codigos[lista_objetos_codigos.length-3].codigo_barra)]),
              //la ida era poner el ultimo id registrado aca.
              Column(
                  children: [Text(lista_objetos_codigos[lista_objetos_codigos.length-3].tipo_pallet)]),
              Column(children: [Text(lista_objetos_codigos[lista_objetos_codigos.length-3].fecha_captura)]),
            ]),

          ] //final del children que agrega
      );
    }

  }

  Notificador_no_internet(){
    verificador_modo_sin_internet = 1;
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
            'Esperando conexion, para enviar datos...'),
      ),
    );
  }

  Internet_restablecido() async {
    //verificar cada 30 segundos
    try {
      final result = await InternetAddress.lookup('example.com');
      print(result);
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        sleep(Duration(seconds:3));
        const oneSec = Duration(seconds: 10);
        final restablecer_internet = Timer.periodic(oneSec, (Timer t) => Recuperar_Datos());
        print("Entró en internet_restablecido");
      }
    } on SocketException catch (_) {
      print("Se cayo el internet");
      setState(() {
        Color_wifi = Colors.red;
        Color_api = Colors.yellow;
      });
    }

  }
  Preguntar_modo_lectura(){
    const tiempo = Duration(minutes: 30);
    final pregunta_lectura = Timer.periodic(tiempo, (Timer t) =>  aux1());
  }
  aux1(){
    pregunta_lectura = false;
  }

  Recuperar_Datos() async {
    setState(() {
      Color_wifi = Colors.green;
    });
    List<Persona> usuario_actual = await DB.Mostrar_experimento_user();
    Recuperar_informacion(usuario_actual[0].usuario, usuario_actual[0].pass);

  }
  Future Recuperar_informacion(String user,String pass) async {
    print("estoy entrando en la funcion de recuperar informacion");
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
      print("El HTTP PRUEBA");
      print(Http_prueba);
      if(response.statusCode == 404) { //server responde bien
        setState(() {
          Color_wifi = Colors.red;
          ultima_caida_wifi = DateTime.now().toString().substring(0,19);
          sleep(Duration(seconds:3));
        });
        recuperado = 1;
      }
      if(response.statusCode == 200) { //server responde bien
        setState(() {
          Color_api = Colors.green;
          sleep(Duration(seconds:3));
        });
        recuperado = 1;
      }else{
        recuperado = 0;
        setState(() {
          Color_api = Colors.red;
          ultima_caida_api = DateTime.now().toString().substring(0,19);
          sleep(Duration(seconds:3));
        });
        paso = 0;
      }
      if(conexion_error == 1){
        setState(() {
          iconData = Icons.cancel;
          Color_estado_paquete = Colors.red;
          sleep(Duration(seconds:3));
          conexion_error = 0;
        });
      }
      if(conexion_ok == 1){
        setState(() {
          iconData = Icons.check;
          Color_estado_paquete = Colors.green;
          sleep(Duration(seconds:3));
          conexion_ok = 0;
        });
      }

      if(recuperado == 1 && paso != 1){
        var json_decodeado = json.decode(Http_prueba);
        tiempo_sincro = json_decodeado["Configuraciones"][0]["M_segundos_act_sinc_Configuracion_C"];
        id_empresa = json_decodeado["Configuraciones"][0]["id_empresa_Configuracion_C"].toString();
        id_sucursal = json_decodeado["Configuraciones"][0]["id_Sucursal_Contador"].toString();
        verificador_modo_sin_internet = 0;
        setState(() {
          Usuario_Detectado();
          Dato_adicional();
        });
        paso = 1;
      }
      return response.body;

    }on SocketException{
      //esto es cuando no tiene conexion a internet para entrar en la aplicacion.
      print("Intentando volver a conectar...");
      setState(() {
        Color_wifi = Colors.yellow;
        Color_api = Colors.yellow;
      });
      return Internet_restablecido();
    }
  }

  Actualizar_tabla() {
    const oneSec = Duration(minutes: 60);
    Timer.periodic(oneSec, (Timer t) => cargaCodigos());
  }

  Future<void> _borrar() async {
    texto_codigo = textcontrollercodigo.text.toString();
    textcontrollercodigo.clear();
    Future.delayed(const Duration(), () => SystemChannels.textInput.invokeMethod('TextInput.hide'));
    int verificador_capa8 = 0;
    if(verificador_cambia_opcion_manual == 0){
      if(opcion_escogida == "Reparacion"){
        texto_id_campo = "12";
        titulo_appbar = "Reparacion";

      }
    }

    if(vista == "Seleccione Estado de pallet" && vista2 != "Seleccione Tipo de pallet"){
      var consola_date = DateTime.now().toString().substring(0,19);
      await DB.insert_error("Error: $texto_codigo no selecciono estado de pallet $consola_date");

      verificador_capa8 = 1;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Falta seleccionar el Estado del pallet'),
        ),
      );
    }
    if(vista2 == "Seleccione Tipo de pallet" && vista != "Seleccione Estado de pallet"){
      var consola_date = DateTime.now().toString().substring(0,19);
      await DB.
      insert_error("Error: $texto_codigo no selecciono tipo de pallet $consola_date");

      verificador_capa8 = 1;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Falta seleccionar el Tipo de pallet'),
        ),
      );
    }

    if(vista == "Seleccione Estado de pallet" && vista2 == "Seleccione Tipo de pallet"){
      var consola_date = DateTime.now().toString().substring(0,19);
      //Informe_errores.add("Pallet: $texto_codigo Error = No seleccionó ni estado ni tipo de pallet $consola_date");
      verificador_capa8 = 1;
      await DB.insert_error("Error: $texto_codigo no selecciono estado ni tipo $consola_date");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Falta seleccionar el Estado del pallet y el tipo de pallet'),
        ),
      );
    }

    List codigos_para_ingresar = [];
    multiple = 0;
    if(texto_codigo.length>largo_codigo_escaneado){
      if(texto_codigo.contains("-") || texto_codigo.contains("/")){
        multiple = 1;
        codigo_compuesto = true;
        List division = texto_codigo.split("-");
        String finaldesarme = division.join("/");
        codigos_para_ingresar = finaldesarme.split("/");
        codigos_para_ingresar = codigos_para_ingresar.sublist(0,codigos_para_ingresar.length-1);
      }else{
        if(texto_codigo.length> largo_codigo_escaneado){ //texto_codigo.length  == largo_barras * 2
          for(int x = 0; x< texto_codigo.length; x++){
            if(x == 0 ||x == largo_codigo_escaneado || x == largo_codigo_escaneado*2 || x == largo_codigo_escaneado*3 ||x == largo_codigo_escaneado*4){
              codigos_para_ingresar.add(texto_codigo.substring(x,x+largo_codigo_escaneado));
            }
          }
        }else{
          print("esto es un error");
        }
      }
      for(int x = 0; x< codigos_para_ingresar.length;x++){
        if(codigos_para_ingresar[x] == ""){
          codigos_para_ingresar[x] = "AP";
        }
      }
      if(codigo_compuesto == true){
        print("identificamos un codigo compuesto");
      }else{
        print("no he identificado nada");
      }
      cargaCodigos();
      for(int ci = 0; ci <= codigos_para_ingresar.length-1;ci++){
        for (int x = 0; x < lista_objetos_codigos.length; x++){
          if (codigos_para_ingresar[ci].toString() == lista_objetos_codigos[x].codigo_barra.toString()) {
            if (texto_id_campo.toString() == lista_objetos_codigos[x].Tipo_captura.toString()) {
              verificador_de_color = 0;
            }else{
              print("noup"); //Todo joya
              textcontrollercodigo.clear();
            }
          }
        }
        if(codigos_para_ingresar[ci].toString().length > 6 && codigo_compuesto == false){ //le puse 4 nomas para que solo ingresen los codigos.
          _showReportDialog(codigos_para_ingresar[ci],"este no es un compuesto");
          textcontrollercodigo.clear();
        }
        if(codigos_para_ingresar[ci].toString().length > 6 && codigo_compuesto == true){
          _showReportDialog(codigos_para_ingresar[ci],codigos_para_ingresar[ci+1]);
        }
      }//fin for
      textcontrollercodigo.clear();

    }

    if(texto_codigo.length.toString() == largo_codigo_escaneado.toString()){
      codigo_compuesto = false;
      if(verificador_capa8 == 0) {
        cargaCodigos();
        setState(() {
          for (int x = 0; x < lista_objetos_codigos.length; x++) {
            if (texto_codigo.toString() == lista_objetos_codigos[x].codigo_barra.toString()) {
              if (texto_id_campo.toString() == lista_objetos_codigos[x].Tipo_captura.toString()) {
                verificador_de_color = 0;
              }else{
                print("noup"); //si esta repetido pero la seccion es diatinta, agregalo.
              }
            }
          }
          print("hasta aqui tambien llegó bien");
          _showReportDialog(texto_codigo.toString(),"nah,todo bien");
          //MORADO
          final consola_date = DateTime.now().toString().substring(0,19);
          textcontrollercodigo.clear();
        });
      }
    }
    textcontrollercodigo.clear();
  }
  Cambiar_campo(){
    setState(() {
      titulo_appbar = "Reparacion";
    });
  }
  cargaCodigos() async {
    print("Actualizando...");
    List<Codigo> auxAnimal = await DB.
    Mostrar_experimento();
    List<Persona> auxPersona = await DB.
    Mostrar_experimento_user();
    setState(() {
      titulo_appbar = opcion_escogida;
      lista_objetos_codigos = auxAnimal;
      objeto_usuario = auxPersona;
      _listaTipos_2 = json_tipo_pallets;
       _listaTipos = json_estado_pallets;
    });

  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(), () => SystemChannels.textInput.invokeMethod('TextInput.hide'));
    return Scaffold(
      appBar: AppBar(
        title: Text("Reparacion"),
        centerTitle: false,
        titleSpacing: 0.0,
        actions: <Widget>[
          IconButton(icon: Icon(iconData, color: Color_estado_paquete), onPressed: () async {

          }),
          IconButton(icon: Icon(Icons.wifi, color: Color_wifi,), onPressed: () async {

          }),
          
          IconButton(icon: Icon(Icons.electrical_services, color: Color_api), onPressed: () async {
            int falta_sincronizar_Cantidad = await DB
                .Mostrar_experimento_falta_sincronizar();
            String informacion = falta_sincronizar_Cantidad.toString();
            Enviar_no_Sincronizados();
            final act = CupertinoActionSheet(
                title: Text('Informacion de Errores'),
                message: Text('INTERNET: $ultima_caida_wifi'+'\n'+
                    'API: $ultima_caida_api'+'\n'+
                    'SINCRONIZACION: $ultima_sincronizacion '+'\n'+
                    'ERROR SINCRONIZACION: $ultima_sincronizacion_fallida' +'\n'+
                    'RAZON ERROR: $ultima_sincrnizacion_fallida_razon'),
                actions: <Widget>[
                  CupertinoActionSheetAction(
                    child: Text("Faltan sincronizar: $informacion"),
                    onPressed: () {},
                  )
                ],
                cancelButton: CupertinoActionSheetAction(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop("Cancel");
                  },
                ));

            showCupertinoModalPopup(context: context, builder: (BuildContext context) => act);
          }),
        ],
        backgroundColor: Colors.black,

      ),

      drawer: Drawer(
        child: Material(
          color: Colors.black87,
          child: ListView(
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text(Usuario_Detectado()),
                accountEmail: Text(Dato_adicional()),
                currentAccountPicture: GestureDetector(
                  child: CircleAvatar(
                    backgroundImage: AssetImage('images/barcode_scanner.png'),
                  ),
                ),
                decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: AssetImage('images/background.png'),
                    )
                ),
              ),
              const SizedBox(height: 10),
              buildMenuItem(
                  text: 'Calidad Curva',
                  icon: Icons.assignment_turned_in_rounded,
                  onClicked: () => selectedItem(context,1)
              ),
              const SizedBox(height: 5),
              buildMenuItem(
                  text: 'Calidad fin',
                  icon: Icons.assignment_turned_in_outlined,
                  onClicked: () => selectedItem(context,2)
              ),
              const SizedBox(height: 5),
              buildMenuItem(
                  text: 'Auditoria',
                  icon: Icons.zoom_in,
                  onClicked: () => selectedItem(context,3)
              ),
              const SizedBox(height: 5),
              buildMenuItem(
                  text: 'Reparación',
                  icon: Icons.home_repair_service,
                  onClicked: () => selectedItem(context,4)
              ),
              const SizedBox(height: 5),
              buildMenuItem(
                  text: 'Trazabilidad',
                  icon: Icons.graphic_eq,
                  onClicked: () => selectedItem(context,5)
              ),
              const SizedBox(height: 5),
              buildMenuItem(
                  text: 'Inventario de Maderas',
                  icon: Icons.inventory,
                  onClicked: () => selectedItem(context,6)
              ),
              const SizedBox(height: 5),
              Divider(color: Colors.white70),
              const SizedBox(height: 5),

              const SizedBox(height: 5),
              buildMenuItem(
                  text: 'Log de Escaneos',
                  icon: Icons.looks,
                  onClicked: () => selectedItem(context,7)
              ),

              buildMenuItem(
                  text: 'Cambiar usuario',
                  icon: Icons.supervised_user_circle_rounded,
                  onClicked: () => selectedItem(context,8)
              ),
              buildMenuItem(
                  text: 'Reiniciar BD',
                  icon: Icons.refresh,
                  onClicked: () => selectedItem(context,9)
              ),
              buildMenuItem(
                  text: 'Listado de Trabajadores',
                  icon: Icons.format_align_justify,
                  onClicked: () => selectedItem(context,10)
              ),
              buildMenuItem(
                  text: 'Cambiar Modo de lectura',
                  icon: Icons.youtube_searched_for,
                  onClicked: () => selectedItem(context,11)
              ),
              buildMenuItem(
                  text: 'Log de errores',
                  icon: Icons.error,
                  onClicked: () => selectedItem(context,12)
              ),
            ],
          ),
        ),
      ),

      body: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: Colors.black12),

          child: ListView(
            children: [
              const SizedBox(height: 5),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(color: Colors.white60, borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    DropdownButton<String>(
                      items: _listaTipos.map((data) {
                        return DropdownMenuItem<String>(
                          value: data.toString(),
                          child: Text(
                            data,
                          ),
                        );
                      }).toList(),
                      onChanged: (_value)=> {
                        setState((){
                          FocusScope.of(context).requestFocus(focus);
                          vista = _value.toString();
                        })
                      },
                      hint: Text(vista),
                      iconEnabledColor: Colors.green,
                      icon: Icon(Icons.arrow_downward_sharp),
                    ),
                    Spacer(),
                    ElevatedButton(
                      child: const Text('Lote'),
                      onPressed: () => Escanear_lote(),
                      style: ElevatedButton.styleFrom(
                          primary: Colors.grey,
                          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          textStyle: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Container(
                padding: EdgeInsets.symmetric(horizontal: 45, vertical: 8),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(10)),

                child: Row(
                  mainAxisSize:MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(   //SEMAFORO
                      onPressed: () {},
                      child: Icon(Icons.check_circle_sharp, color: Colors.black45),
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(20),
                        primary: btn_colorverde, // <-- Button color
                        onPrimary: Colors.red, // <-- Splash color
                      ),
                    ),

                    ElevatedButton(
                      onPressed: () {},
                      child: Icon(Icons.cancel, color: Colors.black45),
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(20),
                        primary: btn_colorrojo, // <-- Button color
                        onPrimary: Colors.red, // <-- Splash color
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Container(
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                child: DropdownButton<String>(
                  items: _listaTipos_2.map((data) {
                    return DropdownMenuItem<String>(
                      value: data.toString(),
                      child: Text(
                        data,
                      ),
                    );
                  }).toList(),
                  onChanged: (_value)=> {
                    setState((){
                      FocusScope.of(context).requestFocus(focus);
                      vista2 = _value.toString();
                    })
                  },
                  hint: Text(vista2),
                  iconEnabledColor: Colors.green,
                  icon: Icon(Icons.arrow_downward_sharp),
                ),
              ),
              //const SizedBox(height: 50),
              //Divider(color: Colors.black87),
              const SizedBox(height: 10),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                child: TextField(
                  focusNode: focus,
                  autofocus: true,
                  onEditingComplete: _borrar,
                  controller: textcontrollercodigo,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Codigo Barra',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                  child: _tabla()
              ),
            ],
          )
      ),
    );
  }

  Escanear_lote(){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text("Ingrese cantidad de Pallets a escanear"),
            content: TextField(
              controller: textcontrollercodigo_lote,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Ingrese cantidad',
              ),
            ),
            actions: [
              ElevatedButton(
                  onPressed: (){
                    cantidad_seleccionada = textcontrollercodigo_lote.text;
                    Navigator.pop(context);
                    textcontrollercodigo_lote.clear();
                  },
                  child: Text("Aceptar"))
            ],
          );

        });
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

  cambio_variable(String Estado_pallet_detectado){
      if(codigo_compuesto){
        print(codigo_compuesto);
        int index_de_tipo = json_tipo_pallets.indexOf(vista2);
        int index_de_estado = json_estado_pallets.indexOf(Estado_pallet_detectado);
        vista_estado = json_estado_pallets_id[index_de_estado];
        vista_tipo = json_tipo_pallets_id[index_de_tipo];
        print("Entro en el else del codigo compuesto: $index_de_estado");
        print(json_estado_pallets.indexOf(vista));
      }else{
        int index_de_tipo = json_tipo_pallets.indexOf(vista2);
        int index_de_estado = json_estado_pallets.indexOf(vista);
        vista_estado = json_estado_pallets_id[index_de_estado];
        vista_tipo = json_tipo_pallets_id[index_de_tipo];
        print("Entro en el else del codigo compuesto: $index_de_estado");
        print(json_estado_pallets.indexOf(vista));
      }
  }

  Usuario_Detectado(){
    if(verificador_modo_sin_internet == 1){
      return "Usuario_offline";
    }else{
      var json_usuario = json.decode(Http_prueba);
      return json_usuario["Configuraciones"][0]["NombreEqupo_S_C_I"];
    }
  }
  Dato_adicional(){
    if(verificador_modo_sin_internet == 1){
      return "Modo offline activado";
    }else{
      var json_usuario = json.decode(Http_prueba);
      return json_usuario["Configuraciones"][0]["Serie_S_C_I"];
    }
  }
//  Obtener_valores() async {
//     lista_contenido = await DB.Data_graficos();
//   }


  //WIDGET SHOWDIALOG
  _showReportDialog(String codigo_recibido_pallet_M, String Estado_pallet_detectado) {
    print("VERIFICADOR COLOR DENTRO DEL SHOWREPORT");//si es compuesto, devolvera el codigo y su estado, si no... solo el codigo
    print(verificador_de_color);
    final consola_date = DateTime.now().toString().substring(0,19);
    //REPARACION
    if (verificador_de_color != 1) { //el codigo esta repetido
      print("No ingresado!");
      textcontrollercodigo.clear();

    }else{
      print("ingresado correctamente!!");
    }

    if (verificador_de_color == 1) {
      setState(() {
        btn_colorverde = Colors.green;
        btn_colorrojo = Colors.white;
      });
    }
    if (verificador_de_color != 1) {
      setState(() {
        btn_colorrojo = Colors.red;
        btn_colorverde = Colors.white;
        //aqui mostrar el snackbar
      });
    }
    if (verificador_de_color == 1) { //decision
      cambio_variable(Estado_pallet_detectado);
      print("------------------");
      print("Insertamos esto en codigo: $codigo_recibido_pallet_M");
      print("Insertamos esto en Estado: $Estado_pallet_detectado");
      textcontrollercodigo.clear();
      print("------------------");
      textcontrollercodigo.clear();


      DB.insert(Codigo(
          Tipo_captura: 12,
          codigo_barra: codigo_recibido_pallet_M,
          fecha_captura: consola_date,
          desc: 0,
          razon_falla: "0",
          sincro: 0,
          tipo_pallet: vista_tipo,
          Estado_pallets: vista_estado,
          cantidad: cantidad_seleccionada
        )
      );
      cargaCodigos();
      //Obtener_valores();
      textcontrollercodigo.clear();
    }
    verificador_no_manual = 0;
    verificador_de_color = 1;
    verificador_de_campo = 1;
    cantidad_seleccionada = "1";
    }


  Widget buildMenuItem({
    required String text,
    required IconData icon,
    VoidCallback? onClicked,
  }){
    final color = Colors.white;
    final hoverColor = Colors.white70;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(text, style: TextStyle(color: color)),
      hoverColor: hoverColor,
      onTap: onClicked,
    );
  }

  Future<void> selectedItem(BuildContext context, int index) async {
    switch (index){

      case 1:
      //lo que pasa si presionan el botón de auditoria
      //texto_id_campo = "1";
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Auditoria()));
        break;
      case 2:
      //lo que pasa si presionan el botón de calidad fin
      //texto_id_campo = "2";
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Calidad_Fin()));
        break;
      case 3:
      //lo que pasa si presionan el botón calidad curva
      //texto_id_campo = "3";
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Calidad_Curva()));
        break;
      case 4:
      //lo que pasa si presionan el botón reparacion
      //texto_id_campo = "4";
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyHomePage(title: "Sistema Principal")),
        );
        break;
      case 5:
      //lo que pasa si presionan el botón trazabilidad
      //texto_id_campo = "5";
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => trazabilidad()));
        break;
      case 6:
      //lo que pasa si presionan el botón Inventario maderas
      //texto_id_campo = "6";
        Navigator.pop(context);
        break;
      case 7:
      //esto es el log
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Log_registros()),
        );
        break;
      case 8:
      //lo que pasa si presionan el botón Inventario maderas
      //texto_id_campo = "7";
        //Navigator.pop(context);
        print("Hemos cambiado de usuario");
        showDialog(
            context: context,
            builder: (BuildContext context){
              return AlertDialog(
                title: Text("¿Cambiar usuario?"),
                content: TextField(
                  controller: textcontroller_cambiar_usuario_url,
                  decoration: const InputDecoration(
                    hintText: 'Ingrese pass para cambiar de usuario',
                  ),
                ),
                actions: [
                  ElevatedButton(
                      onPressed: (){
                        if(textcontroller_cambiar_usuario_url.text == "123456"){
                          if(objeto_usuario.isEmpty){
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const SecondRoute()),
                            );
                          }else{
                            DB.delete(Persona(
                              cookie: objeto_usuario[0].cookie,
                              pass: objeto_usuario[0].pass,
                              usuario: objeto_usuario[0].usuario,
                            )
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const SecondRoute()),
                            );
                          }
                        }else{
                          print("noup, no es la pass");
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                  'Contraseña incorrecta, vuelva a intentar!'),
                            ),
                          );
                        }
                      },
                      child: Text("Confirmar")),
                  ElevatedButton(
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      child: Text("Volver"))
                ],
              );

            });
        break;
      case 9:
        showDialog(
            context: context,
            builder: (BuildContext context){
              return AlertDialog(
                title: Text("¿Cambiar usuario?"),
                content: TextField(
                  controller: textcontroller_resetear_BD,
                  decoration: const InputDecoration(
                    hintText: 'Ingrese pass para reiniciar bd',
                  ),
                ),
                actions: [
                  ElevatedButton(
                      onPressed: () async {
                        if(textcontroller_resetear_BD.text == "vaciar"){
                          Navigator.pop(context);
                          await DB.Resetear_BD();
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Seleccionar_categoria()));
                        }else{
                          print("noup, no es la pass");
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                  'Contraseña incorrecta, vuelva a intentar!'),
                            ),
                          );
                        }
                      },
                      child: Text("Confirmar")),
                  ElevatedButton(
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      child: Text("Volver"))
                ],
              );

            });
        break;
      case 10:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Listado_trabajadores_Log()));
        break;

      case 11:
        pregunta_lectura == false;
        if(Modo_lectura_pistola == "Pantalla"){
          Modo_lectura_pistola = "Pallet";
        }else{
          Modo_lectura_pistola = "Pantalla";
        }
        showDialog(
            context: context,
            builder: (BuildContext context)
            {
              return AlertDialog(
                title: Text("Se ha cambiado el modo lectura!"),
                content: Text(
                    "Modo actual: $Modo_lectura_pistola"
                ),
                actions: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Entendido")),
                ],
              );

            });
        break;
      case 12:
        Navigator.push(context, MaterialPageRoute(builder: (context) => Log_registro_errores()));
    }
  }

  Nombre_modulo(){
    setState(() {
      titulo_appbar = "Reparación";
    });
  }

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
      }
      return response.body;
    }on SocketException{

      return  Internet_restablecido();
    }
  }
}







import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pickersupp/Seleccionar_categoria_Default.dart';
import 'package:pickersupp/Trazabilidad.dart';
import 'package:pickersupp/main.dart';
import 'package:sqflite/sqflite.dart';
import 'package:pickersupp/db.dart';
import 'package:pickersupp/Codigo.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pickersupp/Log.dart';
import 'package:pickersupp/Prueba_Auditoria_1.dart';

import 'AuditoriaG.dart';
import 'Calidad_Fin.dart';
import 'Graficos.dart';
import 'Login.dart';
int verificador_fallas_obtenidas = 0;
bool _checkbox = false;
List<String> reportList = [];
List<String> reportList_id = [];
List lista_formato_de_id_de_fallas = [];

class Auditoria extends StatefulWidget {
  const Auditoria({Key? key}) : super(key: key);

  @override
  State<Auditoria> createState() => _AuditoriaState();
}

class _AuditoriaState extends State<Auditoria> {
//Init state me permite ejecutar algo apenas llegue a la pestaña. o algo, de manera continua. como un timer.
  @override
  void initState() {
    Future.delayed(
      Duration(),
          () => SystemChannels.textInput.invokeMethod('TextInput.hide'),
    );
    Cambiar_campo();
    Nombre_modulo();
    cargaCodigos();
    Usuario_Detectado();
    Dato_adicional();
    Obtener_usuario();
    Obtener_fallas();
    super.initState();
  }
  //"items" es una lista default que estoy usando. cuando la api se encuentre disponible, simplemente pondré la que tiene las causas
  //VARIABLES UTILIZADAS
  var modo_especial = 0;
  String vista_trabajador = "Seleccione Encargado";
  String usuario_cookie = "";
  String vista_tipo = "";
  String vista_estado = "";
  final List<String> _selectedItems = [];
  final List<String> items = ["Causa 1", "Causa 2", "Causa 3", "Causa 4", "Causa 5", "Causa 6"];
  List<String> selectedReportList = [];
  String texto_id_campo = "10";
  String texto_codigo = "";
  Color btn_colorverde = Colors.white; //colores del samaforo
  Color btn_colorrojo = Colors.white;
  int verificador_de_color = 1;
  String vista2= "Seleccione Tipo de pallet";
  final textcontroller_cambiar_usuario_url = TextEditingController();
  final textcontroller_resetear_BD = TextEditingController();
  final textcontrollercodigo = TextEditingController();
  final focus_input_text = FocusNode();
  List<Codigo> lista_objetos_codigos = [];
  List<Persona> objeto_usuario = [];
  List _lista_Trabajadores = ["JORDAN ISAAC ZAPATA CORREA", "OTRO TRABAJADOR", "OTRO TRABAJADOR"];
  List _listaTipos = ["1", "2", "3"];
  List lista_codigos_tablas = [];
  String titulo_appbar = "";

  @override
  Widget build(BuildContext context){
    return Scaffold(   //Suele retornarse un scaffold como si fuese un ejecutable, realmente es la base de la pagina.
      appBar: AppBar( //esto es la barra superior que aparece en la pagina. en el log que muestra, no hay uno de estos porque no me sirve.
        title: Text("Calidad Curva"), //con jerarquia, podemos colocar varibles a algunos atributos del widget
        backgroundColor: Colors.black,
      ),
      body: Container( //el body es la estructura principal de la "base" por lo cual, sera lo principal donde se trabajará
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5), //ajustes de como se posociona en la pantalla.
        decoration: BoxDecoration(color: Colors.black12), //me permite cambiar el color de fondo del container, que justamente es todo

        child: ListView( //dentro del container, puse un listview. este me permite crear una columna ajustable al tamaño de lo que coloques dentro.
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              decoration: BoxDecoration(color: Colors.white60, borderRadius: BorderRadius.circular(10)),
              child: DropdownButton<String>(
                items: _lista_Trabajadores.map((data) {
                  return DropdownMenuItem<String>(
                    value: data.toString(),
                    child: Text(
                      data,
                    ),
                  );
                }).toList(),
                onChanged: (_value)=> {
                  setState((){
                    FocusScope.of(context).requestFocus(focus_input_text);
                    vista_trabajador = _value.toString();
                    Future.delayed(
                      Duration(),
                          () => SystemChannels.textInput.invokeMethod('TextInput.hide'),
                    );
                  })
                },
                hint: Text(vista_trabajador),
                iconEnabledColor: Colors.green,
                icon: Icon(Icons.arrow_downward_sharp),
              ),
            ),
            SizedBox(height: 20),
            Container(
              child: Semaforo(),
            ),
            const SizedBox(height: 20),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: TextField(
                focusNode: focus_input_text,
                autofocus: true,
                onEditingComplete: _Empezar_Auditoria,
                controller: textcontrollercodigo,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Codigo Barra',
                ),
              ),
            ),
         const SizedBox(height: 25.0),
        Container(
          child: ElevatedButton(   //SEMAFORO
            onPressed: () {
              _checkbox = true;
                _Empezar_Auditoria();
            },
            child: Text("NR"),
            style: ElevatedButton.styleFrom(
              shape: CircleBorder(),
              padding: EdgeInsets.all(20),
              primary: Colors.white60, // <-- Button color
              onPrimary: Colors.red, // <-- Splash color
            ),
          ),
        ),
            SizedBox(height: 20),

      Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: Colors.white60, borderRadius: BorderRadius.circular(10)),
        child: DropdownButton<String>(
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
              FocusScope.of(context).requestFocus(focus_input_text);
              vista2 = _value.toString();
              Future.delayed(
                Duration(),
                    () => SystemChannels.textInput.invokeMethod('TextInput.hide'),
              );
            })
          },
          hint: Text(vista2),
          iconEnabledColor: Colors.green,
          icon: Icon(Icons.arrow_downward_sharp),
        ),
            )
          ],
        ),
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
              ],
            ),
          ),
        ),
    floatingActionButton: FloatingActionButton(
           onPressed:() async {
             List inprimirlista  = await DB.Mostrar_experimento_TODOS();
             print(inprimirlista);
               },
             ),
    );
  }
  //Funciones para ejecutar ----------------------------------------------------------- Funciones-----------------
  NR(){
    return Row(
      children: [
        Checkbox(
          value: _checkbox,
          onChanged: (value) {
            setState(() {
              if(_checkbox == true){
                _checkbox = false;
              }else{
                _checkbox = true;
              }

            });
          },
        ),
        Text('NR'),
      ],
    );
  }

  Obtener_fallas() async {

    if(verificador_fallas_obtenidas == 0){
      await Get_fallas(usuario_cookie);
    }else{
      print("Fallas ya obtenidas");
    }
    verificador_fallas_obtenidas = 1;
  }
  Obtener_usuario(){
    var json_usuario = json.decode(Http_prueba);
    usuario_cookie = json_usuario["Configuraciones"][0]["Serie_S_C_I"];
  }
  cambio_variable(){
    int index_de_tipo = json_tipo_pallets.indexOf(vista2);
    vista_tipo = json_tipo_pallets_id[index_de_tipo];
  }
  _Empezar_Auditoria(){

    Future.delayed(
      Duration(),
          () => SystemChannels.textInput.invokeMethod('TextInput.hide'),
    );
    cargaCodigos();
    int verificador_capa8 = 0;
    //Verificadores

    if(vista2 == "Seleccione Tipo de pallet"){
      verificador_capa8 = 1;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Falta seleccionar el Tipo de pallet'),
        ),
      );
    }

    if(vista_trabajador == "Seleccione Encargado"){
      verificador_capa8 = 1;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Falta seleccionar el encargado de la calidad!'),
        ),
      );
    }
    if(vista_trabajador == "Seleccione Encargado" && vista2 == "Seleccione Tipo de pallet"){
      verificador_capa8 = 1;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Falta seleccionar el encargado de la calidad y el tipo de pallet!!'),
        ),
      );
    }
    print("Pasó correctamente por los verificadores");
    print("He escaneado un codigo");

    //Filtro para repetidos
    print("valor del verificador del capa 8");
    print(verificador_capa8);
    var modo_especial = 1; //MODO ESPECIAL
    if(verificador_capa8 == 0) {
      cargaCodigos();
      if(modo_especial == 1){
        texto_codigo = textcontrollercodigo.text.toString();
        List division = texto_codigo.split("-");
        print("Esta fue la division: ");
        print(division);

        String finaldesarme = division.join("/");
        print("Resultado final de la division del codigo: ");
        print(finaldesarme);
        List codigos_para_ingresar = finaldesarme.split("/");
        print("Lista de codigos procesados: ");
        print(codigos_para_ingresar);
      }
      setState(() {
        print("Entró a la funcion");
        texto_codigo = textcontrollercodigo.text.toString();
        final now = DateTime.now();
        //--------------Teclado de condiciones para desc,obs-----------------------
        //-------------------
        texto_codigo = textcontrollercodigo.text.toString();
        if(_checkbox == true){
          setState(() {
            texto_codigo = "NR";
          });
        }
        for (int x = 0; x < lista_objetos_codigos.length; x++) {
          if (texto_codigo.toString() == lista_objetos_codigos[x].codigo_barra.toString()) {
            if (texto_id_campo.toString() == lista_objetos_codigos[x].Tipo_captura.toString()) {
              verificador_de_color = 0;
              if(texto_codigo.toString() == "NR"){
                verificador_de_color = 1;
              }
            }else{
            }
          }//si no esta repetido, agregalo.
        }
        //--------------------
        print("saliendo de los verificadores el valor del color quedo en 1");
        textcontrollercodigo.clear();
        _showReportDialog();
        print(texto_id_campo);
        //MORADO

        //-------------------------------------------------------------------------

      });
    }


    //Termino de programa
    textcontrollercodigo.clear();
  } //Termino de inicio de Scaneo

  // Obtener las fallas de la DB
  Future<String> Get_fallas(String cookie) async { //await Get_fallas(json_prueba[0]["Serie_S_C_I"]);
    http.Response response = await http.get(
        Uri.parse(URL+"ConfiguracionesCapturadores?opcion=Opciones_Fallas"),
        headers: {'Cookie':'session_nebulosa_web='+cookie}
    );

    print("que es esto: ");
    //print(response.body);
    Http_prueba_cookie = response.body;

    //------------Area de Pruebas------------- VAR = Http_prueba
    var json_extraido = json.decode(Http_prueba_cookie);
    print("el valor del json el con solo decode es: ");

    //print(json_extraido[0]["opciones_falla"]);
    //    var stores = json.decode(response.body);
    //     print("el largo que me salio de lo de arriba es: ");
    //     print(json_extraido["opciones_falla"]);
    final largo = json_extraido["opciones_falla"].length;
    for(int x = 0; x < largo; x++){
      //print(json_extraido["opciones_falla"][x]["Resumen"]);
      reportList.add(json_extraido["opciones_falla"][x]["Resumen"].toString());
      reportList_id.add(json_extraido["opciones_falla"][x]["Id_CSCConf"].toString());
    }
    print("Lista de id's");
    print(reportList_id);
    print("Lista de fallas");
    print(reportList);


    return response.body;
  }
  Obtener_valores() async {
    lista_contenido = await DB.Data_graficos();

  }
  Morado(){
    Future.delayed(
      Duration(),
          () => SystemChannels.textInput.invokeMethod('TextInput.hide'),
    );
    cargaCodigos();
    int verificador_capa8 = 0;
    //Verificadores

    if(vista2 == "Seleccione Tipo de pallet"){
      verificador_capa8 = 1;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Falta seleccionar el Tipo de pallet'),
        ),
      );
    }

    if(vista_trabajador == "Seleccione Encargado"){
      verificador_capa8 = 1;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Falta seleccionar el encargado de la calidad!'),
        ),
      );
    }
    if(vista_trabajador == "Seleccione Encargado" && vista2 == "Seleccione Tipo de pallet"){
      verificador_capa8 = 1;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Falta seleccionar el encargado de la calidad y el tipo de pallet!!'),
        ),
      );
    }
     //MODO ESPECIAL
    if(verificador_capa8 == 0) {
      cargaCodigos();
      texto_codigo = textcontrollercodigo.text.toString(); //seteando var escaneada
      //--------------------------------------------------
      if(texto_codigo.contains("-")){
        modo_especial = 1;
        texto_codigo = textcontrollercodigo.text.toString();
        List division = texto_codigo.split("-");
        String finaldesarme = division.join("/");
        List codigos_para_ingresar = finaldesarme.split("/");
        print("Lista de codigos procesados: ");
        print(codigos_para_ingresar); //lista con este formato: [890001,RU,890002,AR...] [Codigo,Estado]
      }

      //--------------------------------------------------

      setState(() {
        texto_codigo = textcontrollercodigo.text.toString();
        final now = DateTime.now();
        texto_codigo = textcontrollercodigo.text.toString();
        if(_checkbox == true){
          setState(() {
            texto_codigo = "NR";
          });
        }
        for (int x = 0; x < lista_objetos_codigos.length; x++) {
          if (texto_codigo.toString() == lista_objetos_codigos[x].codigo_barra.toString()) {
            if (texto_id_campo.toString() == lista_objetos_codigos[x].Tipo_captura.toString()) {
              verificador_de_color = 0;
              if(texto_codigo.toString() == "NR"){
                verificador_de_color = 1;
              }
            }else{
            }
          }//si no esta repetido, agregalo.
        }
        //--------------------
        textcontrollercodigo.clear();
        _showReportDialog();
        //MORADO

        //-------------------------------------------------------------------------

      });
    }


    //Termino de programa
    textcontrollercodigo.clear();
  }
  Nombre_modulo(){
    setState(() {
      titulo_appbar = "Auditoria";
    });
  }
  //PARA LAS CAUSAS -------------------------------------
  _showReportDialog() async {
    List<String> lista_utilizada = [];
    List<String> lista_emergencia = ["esta es una palabra bastante larga","esta palabra tambien es super larga","y esta es incluso mas largo que la anterior1","y esta es incluso mas largo que la anterior2","y esta es incluso mas largo que la anterior3","y esta es incluso mas largo que la anterior","y esta es incluso mas largo que la anterior5","y esta es incluso mas largo que la anterior6","y esta es incluso mas largo que la anterior7","y esta es incluso mas largo que la anterior8","y esta es incluso mas largo que la anterior9","y esta es incluso mas largo que la anterior10","y esta es incluso mas largo que la anterior11","y esta es incluso mas largo que la anterior12","y esta es incluso mas largo que la anterior13","y esta es incluso mas largo que la anterior14","y esta es incluso mas largo que la anterior15","y esta es incluso mas largo que la anterior16"];
    if (verificador_modo_sin_internet == 1) {
      List lista_utilizada = lista_emergencia;
    }else{
      lista_utilizada = reportList;
    }
    print("Entro a la funcion de showreport");
    final consola_date = DateTime.now().toString().substring(0, 19);
    //Auditoria
    await showDialog(
      barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          //Here we will build the content of the dialog
          return MultiSelect(items: reportList);
        }
    );

    if (verificador_de_color == 1 && lista_traspasable.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Codigo Ingresado Correctamente!'),
        ),
      );
    }
    if (verificador_de_color == 1 && lista_traspasable.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'El pallet no ha sido ingresado.'),
        ),
      );
    }


    if (verificador_de_color != 1) { //el codigo esta repetido
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Codigo repetido!'),
        ),
      );
    }

    print("la lista de causas que paso es: ");
    var string_fallas = lista_formato_de_id_de_fallas.join(",");
    //var string_fallas_id = _selectedItems.join(",");
    print(string_fallas);

    //VERIFICAR POR ACA QUE ONDA CON LOS DATOS REPETIDOS
    if (verificador_de_color == 1 && lista_traspasable.isNotEmpty) {
      print("Este estaba nuevo");
      print("Verificador color 1 ");
      setState(() {
        btn_colorverde = Colors.green;
        btn_colorrojo = Colors.white;
        //aqui igual un snackbar
      });
    }
    if (verificador_de_color != 1 && lista_traspasable.isNotEmpty) {
      setState(() {
        print("Verificador color 2 ");
        btn_colorrojo = Colors.red;
        btn_colorverde = Colors.white;
        //aqui mostrar el snackbar
      });
    }
    if (verificador_de_color == 1) { //decision
      print("Buena prueba!");
      cambio_variable();
      if(_checkbox == true){
        texto_codigo = "NR";
      }
      if(lista_traspasable.isNotEmpty){
        DB.insert(Codigo(
          id_Auditoria: "No Auditoria",
          Tipo_captura: "10",
          codigo_barra: texto_codigo,
          fecha_captura: consola_date,
          desc: "0",
          razon_falla: string_fallas,
          sincro: 0,
          tipo_pallet: vista_tipo,
          Estado_pallets: "0",
          cantidad: 1,
          )
        );
      }
      cargaCodigos();
      Obtener_valores();
    }
    vista_trabajador = "Seleccione Encargado";
    vista2 = "Seleccione Tipo de pallet";
    verificador_de_color = 1;
    print("Antes de reiniciarlo");
    print(lista_traspasable);
    print(lista_De_id_fallas);
    //------------------
    lista_formato_de_id_de_fallas = [];
    for(int x = 0; x < lista_De_id_fallas.length; x++){
      lista_formato_de_id_de_fallas.add("-"+lista_De_id_fallas[x]);
    }
    print("la lista aceptada seria asi: ");
    //print(lista_formato_de_id_de_fallas);
    //-----------------
    print("Despues de reiniciarlo");
    lista_traspasable = []; //reiniciando_escogidos choosen wan
    lista_De_id_fallas = [];
    print(lista_traspasable);
    Future.delayed(
      Duration(),
          () => SystemChannels.textInput.invokeMethod('TextInput.hide'),
    );
  }   //PARA LAS CAUSAS -------------------------------------
  Usuario_Detectado(){
    if(verificador_modo_sin_internet == 1){
      return "Usuario_offline";
    }else{
      var json_usuario = json.decode(Http_prueba);
      //print(Http_prueba);
      json_usuario["Configuraciones"][0]["NombreEqupo_S_C_I"];
      return json_usuario["Configuraciones"][0]["NombreEqupo_S_C_I"];
      print(Http_prueba);
    }
  }
  Cambiar_campo(){
    setState(() {
      titulo_appbar = "Auditoria";
    });
  }
  Dato_adicional(){
    if(verificador_modo_sin_internet == 1){
      return "Modo offline activado";
    }else{
      var json_usuario = json.decode(Http_prueba);
      return json_usuario["Configuraciones"][0]["Serie_S_C_I"];
    }
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
    }
  }
    cargaCodigos() async {
      print("Actualizando...");
      List<Codigo> auxAnimal = await DB.Mostrar_experimento();
      List<Persona> auxPersona = await DB.Mostrar_experimento_user();
      setState(() {
        titulo_appbar = opcion_escogida;
        lista_objetos_codigos = auxAnimal;
        objeto_usuario = auxPersona;
        _listaTipos = json_tipo_pallets; //lista extraida desde otro lugar, es lo que tengo que hacer con los trabajdores.
        //_listaTipos = json_estado_pallets; //TRANSFORMACION
        print(json_tipo_pallets);


      });

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
  Mostrar_lista_escogidos(){
    print("Mostrando los valores de la lista seleccionados: ");
    print(lista_traspasable);
  }
  Semaforo(){
    return Container(

      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 8),
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
          )

        ],
      ),
    );
  }
} //fin del programa

//Causas Nueva



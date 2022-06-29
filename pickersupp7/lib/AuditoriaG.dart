import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:pickersupp/Seleccionar_categoria_Default.dart';
import 'package:pickersupp/Trazabilidad.dart';
import 'package:sqflite/sqflite.dart';
import 'package:pickersupp/db.dart';
import 'package:pickersupp/Codigo.dart';
import 'package:pickersupp/Login.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:pickersupp/Log.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'Auditar_codigos.dart';
import 'Calidad_Curva.dart';
import 'Calidad_Fin.dart';
import 'Listado_trabajadores.dart';
import 'Log_errores.dart';
import 'main.dart';
int continuar_auditoria = 0;
class Calidad_Curva extends StatefulWidget {
  const Calidad_Curva({Key? key}) : super(key: key);

  @override
  State<Calidad_Curva> createState() => _Calidad_CurvaState();
}

class _Calidad_CurvaState extends State<Calidad_Curva> {
  bool alternar_visibilidad = true;
  String cant = "0";
  String Hora_actual = "";
  List _listabush = [];
  String vista2 = "Estado";
  final textcontroller_cambiar_usuario_url = TextEditingController();
  final textcontroller_resetear_BD = TextEditingController();
  final textcontrollercodigo_lote = TextEditingController();
  final textcontrollercodigo = TextEditingController();

  TextEditingController detalle_escrito = TextEditingController();
  TextEditingController textcontroller_cant_pallet = TextEditingController();
  TextEditingController dateinput = TextEditingController();
  final focus_input_text = FocusNode();
  String vista_zona_auditoria = "Zona";
  List _lista_zona_auditoria = [
    "Reparacion",
    "Inspeccion linea 1",
    "Inspeccion linea 2",
    "Lavado"
  ];
  List<Codigo> lista_objetos_codigos = [];
  List<Persona> objeto_usuario = [];

  void initState() {
    dateinput.text = "";
    cargaCodigos();
    Verificar_Existencia_auditoria();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        title: Text("Auditoria"),
        backgroundColor: Colors.black,
        actions: <Widget>[
          IconButton(icon: Icon(Icons.arrow_forward, color: Colors.white), onPressed: () async {
            int resultado = await DB.Obtener_estado_auditoria();
            if(resultado == 1){
              print("habia una auditoria activa!");
            }else{
              print("No, no habia ninguna auditoria activa!");
            }
            int pasa = 1;
            print("Enviando...");
            int verificacion = Verificar_capa8();
            if(verificacion == 1){
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                      'Seleccione una fecha porfavor!'),
                ),
              );
            }else{
              pasa = 0;
            }
            if(verificacion == 2){
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                      'Seleccione una cantidad adecuada!'),
                ),
              );
            }else{
              pasa = 0;
            }
            if(verificacion == 3){
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                      'Complete detalle!'),
                ),
              );
            }else{
              pasa = 0;
            }
            if(pasa != 0){
              print("Todo bien con los capa 8");
              //seguir codeando aqui
            }else{
              print("No, no va a pasar esto. Esta imcompleto.");
            }
            if(verificacion == 0){
              print("Creando Auditoria...");
              print("Esto es lo que insertaria: "+Hora_actual+ " "+dateinput.text+ " " +cant+ " "+ detalle_escrito.text);
              DB.insertar_Auditoria(Hora_actual, dateinput.text, cant, detalle_escrito.text);
            }
          }),
        ],
      ),

      body: Container(
          child: ListView(
            children: [
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    decoration: BoxDecoration(color: Colors.white,
                        borderRadius: BorderRadius.circular(15)),
                    child: DropdownButton<String>(
                      items: _lista_zona_auditoria.map((data) {
                        return DropdownMenuItem<String>(
                          value: data.toString(),
                          child: Text(
                            data,
                          ),
                        );
                      }).toList(),
                      onChanged: (_value) =>
                      {
                        setState(() {
                          FocusScope.of(context).requestFocus(focus_input_text);
                          vista_zona_auditoria = _value.toString();
                          Future.delayed(
                            Duration(),
                                () =>
                                SystemChannels.textInput.invokeMethod(
                                    'TextInput.hide'),
                          );
                        })
                      },
                      hint: Text(vista_zona_auditoria),
                      iconEnabledColor: Colors.green,
                      icon: Icon(Icons.arrow_downward_sharp),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Container(
                //    final consola_date = DateTime.now().toString().substring(0,19); Text(Hora_actual.toString())
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      child: Text("Inicio", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                      child: Text(Hora_actual.toString()),
                    ),
                    Container(
                      child: ElevatedButton(
                        child: Text("Actualizar"),
                        onPressed: (){
                          setState(() {
                            Hora_actual = DateTime.now().toString().substring(0,19);
                          });
                        },
                        style: ElevatedButton.styleFrom(
                            primary: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
SizedBox(height: 10),
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                  child:Center(
                      child:TextField(
                        controller: dateinput, //editing controller of this TextField
                        decoration: InputDecoration(
                            icon: Icon(Icons.calendar_today), //icon of text field
                            labelText: "Ingrese hora de termino" //label text of field
                        ),
                        readOnly: true,  //set it true, so that user will not able to edit text
                        onTap: () async {
                          TimeOfDay _time = TimeOfDay(hour: 7, minute: 15);
                          final TimeOfDay? newTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay(hour: 7, minute: 15),
                            initialEntryMode: TimePickerEntryMode.input,
                          );

                          //-----------
                          //-----------

                          if (newTime != null) {
                            setState(() {
                              _time = newTime;
                              dateinput.text = _time.hour.toString() +":"+_time.minute.toString();
                            });
                          }else{
                            print("Fecha no ha sido ingresada!");
                          }
                        },
                      )
                  )
              ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Center(
                    child: ElevatedButton(
                      child: Text("Cantidad"),
                      onPressed: (){
                        Escanear_lote();
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.black,
                      ),
                    ),
                  ),
                  Container(
                    child: Text("Cantidad Ingresada: $cant", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  Card(
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.all(7.0),
                        child: TextField(
                          controller: detalle_escrito,
                          maxLines: 7, //or null
                        ),
                      ),
                  )
                ],
              )
            ],
          )
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
    );
  }
  Verificar_capa8(){
    int todobien = 1;
    if(dateinput.text != "" && cant != "0" && detalle_escrito.text != ""){
      todobien = 1;
      return 0;
    }
    if(dateinput.text == ""){
      todobien = 0;
      return 1;
    }
    if(cant == "0"){
      todobien = 0;
      return 2;
    }
    if(detalle_escrito.text == ""){
      todobien = 0;
      return 3;
    }


  }

  //inicio de funciones
  Mostrar_floating() async {
    print("entro al mostrar");
    setState(() {
      alternar_visibilidad = true;
    });
  }

  Verificar_Existencia_auditoria() async {
    print("Desplegando notificacion que existe alguna o algo asi...");
    var consultar_estado_auditoria = await DB.Obtener_estado_auditoria();
    if (consultar_estado_auditoria == 1) {
      print(
          "fue detectada una auditoria activa, por lo cual se desplegará la notificacion");
      Cuadro_dialogo_existe_auditoria();
    } else {
      print(

          "No existe ninguna auditoria momentanea, por lo cual no pasa nada"
      );
    }
  }
  //Cargar_campos_anteriores
  Esconder_floating() async {
    print("entro al esconder");
    setState(() {
      alternar_visibilidad = false;
    });
  }


  cargaCodigos() async {
    print("Actualizando...");
    List<Codigo> auxAnimal = await DB.
    Mostrar_experimento();
    List<Persona> auxPersona = await DB.
    Mostrar_experimento_user();
    setState(() {
      lista_objetos_codigos = auxAnimal;
      objeto_usuario = auxPersona;
      _listabush = json_estado_pallets;
      Hora_actual = DateTime.now().toString().substring(0,19);
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

  Escanear_lote(){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text("Ingrese la cantidad de pallets"),
            content: Container(
              child: TextField(
              controller: textcontroller_cant_pallet,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Ingrese cantidad',
              ),
            )
            ),
            actions: [
              ElevatedButton(
                  onPressed: (){
                    setState(() {
                      cant = textcontroller_cant_pallet.text;
                    });
                    Navigator.pop(context);
                    textcontroller_cant_pallet.clear();
                  },
                  child: Text("Aceptar")),

              ElevatedButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text("Salir"))
            ],
          );

        });
  }


  //Cuadro de dialogo
  Cuadro_dialogo_existe_auditoria() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Auditoria activa detectada. ¿Desea continuar esta?"),
            actions: [
              ElevatedButton(
                  onPressed: () async {
                    continuar_auditoria = 1;
                    int imprimir_auditoria = await DB.Obtener_estado_auditoria();
                    print(imprimir_auditoria);
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => auditar_codigos()));
                  },
                  child: Text("Si")),
              ElevatedButton(
                  onPressed: () async {
                    continuar_auditoria = 0;
                    await DB.Eliminar_Auditoria();
                    Navigator.pop(context);
                  },
                  child: Text("No"))
            ],
          );
        });
  }
}




import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:pickersupp/AuditoriaG.dart';
import 'package:pickersupp/Calidad_Curva.dart';
import 'package:pickersupp/Seleccionar_categoria_Default.dart';
import 'package:pickersupp/Trazabilidad_Registros.dart';
import 'package:sqflite/sqflite.dart';
import 'package:pickersupp/db.dart';
import 'package:pickersupp/Codigo.dart';
import 'package:pickersupp/Login.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:pickersupp/Log.dart';
import 'package:http/http.dart' as http;

import 'Calidad_Fin.dart';
import 'main.dart';

String boton_seleccionado = "";
String Codigo_trazabilidad = "";
class trazabilidad extends StatefulWidget {
  const trazabilidad({Key? key}) : super(key: key);

  @override
  State<trazabilidad> createState() => _trazabilidadState();
}

class _trazabilidadState extends State<trazabilidad> {
  int verificador_tipo_data_solicitado = 0;
  int verificador_existencia = 0;
  List<Codigo> lista_objetos_codigos = [];
  List<Persona> objeto_usuario = [];
  @override
  void initState() {
    Future.delayed(
      Duration(),
          () => SystemChannels.textInput.invokeMethod('TextInput.hide'),
    );
    Nombre_modulo();
    Dato_adicional();
    Usuario_Detectado();
    super.initState();
  }

  String respuesta_trazabilidad = "";
  final textcontrollercodigo = TextEditingController();
  final focus_input_text = FocusNode();
  String titulo_appbar = "";

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titulo_appbar)),
      backgroundColor: Colors.black87,
      body: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('images/windows-g018a98fad_1920.jpg'),
                  fit: BoxFit.fill
              )
          ),
          child: ListView(
            children: [
              Center(
                child: Text("Modo Seleccionado", style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold)),
              ),
              Center(
                child: Text(boton_seleccionado, style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
              ),

              const SizedBox(height: 100),
              Center(
                child: TextField(
                  focusNode: focus_input_text,
                  autofocus: true,
                  onEditingComplete: Empezar_trazabilidad,
                  controller: textcontrollercodigo,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Codigo Barra',
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    boton_seleccionado = "Unico";
                    verificador_tipo_data_solicitado = 1;
                  });
                },
                child: Text("Unico"),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    boton_seleccionado = "Data";
                    verificador_tipo_data_solicitado = 1;
                  });
                },
                child: Text("Data"),
              ),
            ],
          )
      ),
      drawer: Drawer(
        child: Material(
          color: Color.fromRGBO(111, 108, 102, 1),
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
                      image: AssetImage('images/business.jpg'),
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
                  text: 'Modulo Disponible',
                  icon: Icons.add,
                  onClicked: () => selectedItem(context,9)
              ),
            ],
          ),
        ),
      ),
    );
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
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Calidad_Curva()));
        break;
      case 2:
      //lo que pasa si presionan el botón de calidad fin
      //texto_id_campo = "2";
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Calidad_Fin()));
        break;
      case 3:
      //lo que pasa si presionan el botón calidad curva
      //texto_id_campo = "3";
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Auditoria()));
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
        Navigator.pop(context);
        print("Hemos cambiado de usuario");
        if(objeto_usuario.isEmpty){
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SecondRoute()),
          );
        }else {
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
        break;
      case 9:
        break;
    }
  }
  Nombre_modulo() {
    setState(() {
      titulo_appbar = "Trazabilidad";
    });
  }
  Usuario_Detectado(){
    if(verificador_modo_sin_internet == 1){
      return "Usuario_offline";
    }else{
      var json_usuario = json.decode(Http_prueba);
      print(Http_prueba);
      json_usuario["Configuraciones"][0]["NombreEqupo_S_C_I"];
      return json_usuario["Configuraciones"][0]["NombreEqupo_S_C_I"];
      print(Http_prueba);
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

  Empezar_trazabilidad() async {
    lista_registros_trazabilidad.clear();
    textcontrollercodigo.clear();
    if (boton_seleccionado == "") {
      verificador_tipo_data_solicitado = 0;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Porfavor, seleccione uno de los modos "Unico" o "Data"'),
        ),
      );
    }
    if (verificador_tipo_data_solicitado == 1) {
      Codigo_trazabilidad = textcontrollercodigo.text;
      Future.delayed(
        Duration(),
            () => SystemChannels.textInput.invokeMethod('TextInput.hide'),
      );
      Navigator.push(context, MaterialPageRoute(builder: (context) => Trazabilidad_Registros()));
    }
  }
}

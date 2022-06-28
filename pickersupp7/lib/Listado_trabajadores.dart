import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:pickersupp/Ayuda.dart';
import 'package:pickersupp/AuditoriaG.dart';
import 'package:pickersupp/Calidad_Fin.dart';
import 'package:pickersupp/Seleccionar_categoria_Default.dart';
import 'package:pickersupp/Trazabilidad.dart';
import 'package:sqflite/sqflite.dart';
import 'package:pickersupp/db.dart';
import 'package:pickersupp/Codigo.dart';
import 'package:pickersupp/Login.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:pickersupp/Log.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'Calidad_Curva.dart';
import 'package:restart_app/restart_app.dart';

import 'Graficos.dart';



class Listado_trabajadores_Log extends StatefulWidget {
  const Listado_trabajadores_Log({Key? key}) : super(key: key);

  @override
  State<Listado_trabajadores_Log> createState() => _Listado_trabajadores_LogState();
}

class _Listado_trabajadores_LogState extends State<Listado_trabajadores_Log> {

  @override
  void initState() {
    cargaCodigos();
    //inicializar_variables();
    super.initState();
  }


  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Listado de Trabajadores"),
        backgroundColor: Colors.black87,
      ),

      body: Container(
        child: Text("Bienvenido a listado de trabajadores"),
      ),

      //body: ListView.builder(
      //         itemCount: lista_objetos_codigos_entero.length,
      //         itemBuilder: (context, index) {
      //           return ListTile(
      //             title: Text(lista_objetos_codigos_entero[index].codigo_barra +" | "+" ("+lista_objetos_codigos_entero[index].fecha_captura+") " +" | "+lista_objetos_codigos_entero[index].tipo_pallet),
      //           );
      //         },
      //       ),

    );
  }
}
cargaCodigos(){
  print("Entramos a la lista de trabajadores");
}

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

import 'Calidad_Curva.dart';
import 'Calidad_Fin.dart';
import 'Listado_trabajadores.dart';
import 'Log_errores.dart';
import 'main.dart';


class auditar_codigos extends StatefulWidget {
  const auditar_codigos({Key? key}) : super(key: key);

  @override
  State<auditar_codigos> createState() => _auditar_codigosState();
}

class _auditar_codigosState extends State<auditar_codigos> {
  int cantidad_actual = 0;
  String vista2 = "Estado";
  List _listabush = [];
  final textcontrollercodigo = TextEditingController();
  final focus = FocusNode();
  void initState() {
    cargaCodigos();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        title: Text("Realizando Auditoria..."),
        backgroundColor: Colors.black,
      ),
      body: ListView(
        children: [
          SizedBox(height: 15),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: DropdownButton<String>(
              items: _listabush.map((data) {
                return DropdownMenuItem<String>(
                  value: data.toString(),
                  child: Text(
                    data,
                  ),
                );
              }).toList(),
              onChanged: (_value)=> {
                setState((){
                  vista2 = _value.toString();
                })
              },
              hint: Text(vista2),
              iconEnabledColor: Colors.green,
              icon: Icon(Icons.arrow_downward_sharp),
            ),
          ),
          SizedBox(height: 15),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: TextField(
              focusNode: focus,
              autofocus: true,
              onEditingComplete: _ingresarPallet(),
              controller: textcontrollercodigo,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Codigo Barra',
              ),
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text("Cantidad Pallets Auditados actualmente", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold))
            ],
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 45, vertical: 8),
            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(10)),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize:MainAxisSize.min,
              children: [
                Text(cantidad_actual.toString(), style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
  _ingresarPallet(){
    FocusScope.of(context).requestFocus(focus);
    Future.delayed(
      Duration(),
          () => SystemChannels.textInput.invokeMethod('TextInput.hide'),
    );

    setState(() {
      cantidad_actual++;
    });

    textcontrollercodigo.clear();

  }
  cargaCodigos() async {
    print("Actualizando...");
    List<Codigo> auxAnimal = await DB.
    Mostrar_experimento();
    List<Persona> auxPersona = await DB.
    Mostrar_experimento_user();
    setState(() {
      _listabush = json_estado_pallets;
    });

  }
}


import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:pickersupp/db.dart';
import 'package:pickersupp/Codigo.dart';
import 'package:pickersupp/Login.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:loading_animations/loading_animations.dart';

class Log_registros extends StatefulWidget {
  const Log_registros({Key? key}) : super(key: key);


  @override
  State<Log_registros> createState() => _Log_registrosState();
}

class _Log_registrosState extends State<Log_registros> {
  List<Codigo> lista_objetos_codigos_entero = [];
  //List<Persona> objeto_usuario_entero;
  int index = 0;


  @override
  void initState() {
    cargaCodigos();
    //inicializar_variables();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView.builder(
        reverse: true,
        itemCount: lista_objetos_codigos_entero.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(lista_objetos_codigos_entero[index].codigo_barra +" | "+" ("+lista_objetos_codigos_entero[index].fecha_captura+") " +" | "+lista_objetos_codigos_entero[index].tipo_pallet),
          );
        },
      ),
    );
  }
  cargaCodigos() async {
    List<Codigo> auxAnimal = await DB.Mostrar_experimento();

    setState(() {
      lista_objetos_codigos_entero = auxAnimal;
    });

  }

  Future<void> inicializar_variables() async {
    final objeto_usuario = await DB.Mostrar_experimento_user(); //inicializar
    print("el usuario y los contenidos de la tabla han sido debidamente obtenidos.");
    if(objeto_usuario.length < 1){
      print("El usuario no existe");
    }else{
      print("Datos del usuario encargado del dispositivo: ");
      print(objeto_usuario[0].cookie);
      print(objeto_usuario[0].usuario);
      print(objeto_usuario[0].pass);
      lista_objetos_codigos_entero = await DB.Mostrar_experimento();
      lista_objetos_codigos_entero.reversed;
    }
  }

  TableRow tabla_responsiva(int index){
    return TableRow(children: [
      Column(children: [Text(lista_objetos_codigos_entero[lista_objetos_codigos_entero.length - index].codigo_barra)]),
      Column(children: [Text(lista_objetos_codigos_entero[lista_objetos_codigos_entero.length - index].tipo_pallet)]),
      Column(children: [Text(lista_objetos_codigos_entero[lista_objetos_codigos_entero.length - index].fecha_captura)]),
    ]);
  }

}













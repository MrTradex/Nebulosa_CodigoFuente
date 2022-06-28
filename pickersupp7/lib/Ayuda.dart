import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:pickersupp/AuditoriaG.dart';
import 'package:pickersupp/Calidad_Fin.dart';
import 'package:pickersupp/Seleccionar_categoria_Default.dart';
import 'package:pickersupp/Trazabilidad.dart';
import 'package:pickersupp/main.dart';
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

class Ayuda extends StatefulWidget {
  const Ayuda({Key? key}) : super(key: key);

  @override
  State<Ayuda> createState() => _AyudaState();
}

class _AyudaState extends State<Ayuda> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Center(
            child: Text("Manual de Usuario"),
        ),
      ),

      body: PageView(
        children: [
          Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('images/geometric-g9d2c6b826_1920.jpg'),
                    fit: BoxFit.fill
                )
            ),
            child: Center(
              child: ListView(
                children: [
                  SizedBox(height: 120),
                  Center(
                    child: Text("Bienvenid@!", style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Text("Este es un instructivo de ayuda para el Scanner Nebulosa ", style: TextStyle(color: Colors.white, fontSize: 15)),
                  ),

                  SizedBox(height: 40),
                  Center(
                    child: Text("Para continuar, deslice hacia la izquierda", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('images/AYUDA1.jpg'),
                    fit: BoxFit.scaleDown
                )
            ),
            child: Center(
              child: ListView(
                children: [
                  SizedBox(height: 320),
                  ElevatedButton(
                      onPressed: (){
                        showModalBottomSheet<void>(
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              height: 1000,
                              color: Colors.black,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text('Lote: \nEsta opcion permite al usuario ingresar una cantidad para escanear. Por ejemplo, usted desea escanear un lote de 30 pallets, Por lo cual, '
                                        'debe presionar la opcion e indicar la cantidad, escanear. De esa forma, habrá ingresado la cantidad exitosamente.\n'
                                        '\nSemáforo:\nEste se pondra verde en cuanto el pallet haya sido ingresado exitosamente. De lo contrario, se pondrá rojo.', style: TextStyle(color: Colors.white, fontSize: 13)),
                                    ElevatedButton(
                                      child: const Text('Volver'),
                                      onPressed: () => Navigator.pop(context),
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.white60, // <-- Button color
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }, child: Icon(Icons.help, color: Colors.white60),
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(25),
                      primary: Colors.green, // <-- Button color
                      onPrimary: Colors.white60, // <-- Splash color
                    ),
                  ),
                ],
              )
            ),


          ),
          Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('images/geometric-g9d2c6b826_1920.jpg'),
                    fit: BoxFit.fill
                )
            ),
            child: ListView(
              children: [
                SizedBox(height: 120),
                Center(
                  child: Text("Fin instructivo Scanner Nebulosa!", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                ),
                SizedBox(height: 20),

                ElevatedButton(
                    onPressed: (){
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Seleccionar_categoria()));
                    },
                    child: Text("Salir de Ayuda")
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
int continuar_auditoria = 0;
int Cargar_variables_automaticamente = 0;
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
                ],
              ),
              SizedBox(height: 5),
              Container(

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
                        padding: EdgeInsets.all(8.0),
                        child: TextField(
                          
                          onTap: Esconder_floating(),
                          onEditingComplete: Mostrar_floating(),
                          controller: detalle_escrito,
                          maxLines: 8, //or null
                          decoration: InputDecoration.collapsed(hintText: "Detalle"),
                        ),
                      )
                  )
                ],
              )
            ],
          )
      ),
      floatingActionButton: new Visibility(
        visible: alternar_visibilidad,
        child: new FloatingActionButton(
          onPressed:() async {
            print("Creando Auditoria...");
            print("Esto es lo que insertaria: "+ Hora_actual+ " "+dateinput.text+ " " +cant+ " "+ detalle_escrito.text);
            //DB.insertar_Auditoria(Hora_actual, dateinput.text, cant, detalle_escrito.text);
          },
          backgroundColor: Colors.black,
          child: const Icon(Icons.arrow_forward),
        ),
      ),
    );
  }

  //inicio de funciones
  Mostrar_floating(){
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
      Cargar_variables_automaticamente = 1;
      Rellenar_campos();
    } else {
      print(
          "No existe ninguna auditoria momentanea, por lo cual se creará otra"
      );
      Cargar_variables_automaticamente = 0;
      Rellenar_campos();
    }
  }
  //Cargar_campos_anteriores
  Esconder_floating(){
    print("entro al esconder");
    setState(() {
      alternar_visibilidad = false;
    });
  }
  Rellenar_campos(){
    //aqui tendrian que rellenarse los campos automaticamente, dependiendo de la variable que cambio en la parte de arriba
    if(Cargar_variables_automaticamente == 1){
      //empezar a rellenar campos por nombres, ez
    }else{
      print("es totalmente nuevo, no hay nada que cargar");
    }
  }
  cargaCodigos() async {
    print("Actualizando...");
    List<Codigo> auxAnimal = await DB.
    Mostrar_experimento();
    List<Persona> auxPersona = await DB.
    Mostrar_experimento_user();
    setState(() {
      _listabush = json_estado_pallets;
      Hora_actual = DateTime.now().toString().substring(0,19);
    });

  }
  Escanear_lote(){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text("Ingrese la cantidad de pallets"),
            content: TextField(
              controller: textcontroller_cant_pallet,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Ingrese cantidad',
              ),
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
            title: Text("¿Continuar con Auditoria?"),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    continuar_auditoria = 1;
                  },
                  child: Text("Si")),
              ElevatedButton(
                  onPressed: () {
                    continuar_auditoria = 0;
                  },
                  child: Text("No"))
            ],
          );
        });
  }
}




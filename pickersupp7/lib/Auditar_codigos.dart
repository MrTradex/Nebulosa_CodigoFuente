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
  String vista_estado = "";
  int verificador_de_campo = 1;
  int verificador_de_color = 1;
  List<Codigo> lista_objetos_codigos = [];
  List<Persona> objeto_usuario = [];
  Color btn_colorverde = Colors.white;
  Color btn_colorrojo = Colors.white;
  bool codigo_compuesto = false;
  var titulo_appbar = "Seleccione una opción";
  String texto_id_campo = "4";
  String texto_codigo = "";
  String cantidad_seleccionada = "1";
  int cantidad_actual = 0;
  String vista2 = "Seleccione Tipo de pallet";
  String vista = "Seleccione Estado de pallet";
  String vista_tipo = "";
  List _listaTipos_2 = [];
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
          SizedBox(height: 10),
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
                  vista = _value.toString();
                })
              },
              hint: Text(vista),
              iconEnabledColor: Colors.green,
              icon: Icon(Icons.arrow_downward_sharp),
            ),
          ),
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
          SizedBox(height: 20),
          ElevatedButton(
            child: Text("Terminar Auditoria"),
            onPressed: (){
//RESOLVER DUDA DE ANGEL PRIMERO.
            },
          )
        ],
      ),
    );
  }
  _ingresarPallet() async {
    FocusScope.of(context).requestFocus(focus);
    Future.delayed(
      Duration(),
          () => SystemChannels.textInput.invokeMethod('TextInput.hide'),
    );

    setState(() {
      cantidad_actual++;
    });

    texto_codigo = textcontrollercodigo.text.toString();
    textcontrollercodigo.clear();
    Future.delayed(const Duration(), () => SystemChannels.textInput.invokeMethod('TextInput.hide'));
    int verificador_capa8 = 0;

    if(opcion_escogida == "Auditoria"){
      texto_id_campo = "12";
      titulo_appbar = "Auditoria";

    }

    if(vista == "Seleccione Estado de pallet"){
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
  cargaCodigos() async {
    print("Actualizando...");
    List<Codigo> auxAnimal = await DB.
    Mostrar_experimento();
    List<Persona> auxPersona = await DB.
    Mostrar_experimento_user();
    setState(() {
      _listabush = json_estado_pallets;
      titulo_appbar = opcion_escogida;
      lista_objetos_codigos = auxAnimal;
      _listaTipos_2 = json_tipo_pallets;
      objeto_usuario = auxPersona;
    });

  }

  _showReportDialog(String codigo_recibido_pallet_M, String Estado_pallet_detectado) async {
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

      String Obtener_auditoria = await DB.Obtener_idAuditoria();
      DB.insert(Codigo(
          id_Auditoria: Obtener_auditoria.toString(),
          Tipo_captura: 4,
          codigo_barra: codigo_recibido_pallet_M,
          fecha_captura: consola_date,
          desc: 0,
          razon_falla: "0",
          sincro: 0,
          tipo_pallet: vista_tipo,
          Estado_pallets: vista_estado,
          cantidad: "1"
      )
      );
      cargaCodigos();
      //Obtener_valores();
      textcontrollercodigo.clear();
    }
    verificador_de_color = 1;
    verificador_de_campo = 1;
    cantidad_seleccionada = "1";
  }
}


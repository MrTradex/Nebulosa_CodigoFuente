import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pickersupp/Trazabilidad.dart';
import 'package:pickersupp/Login.dart';
import 'package:http/http.dart' as http;

List lista_registros_trazabilidad = [];
String respuesta_registros = "";

class Trazabilidad_Registros extends StatefulWidget {
  const Trazabilidad_Registros({Key? key}) : super(key: key);

  @override
  State<Trazabilidad_Registros> createState() => _Trazabilidad_RegistrosState();
}

class _Trazabilidad_RegistrosState extends State<Trazabilidad_Registros> {

  //List<Persona> objeto_usuario_entero;
  int index = 0;

  @override
  void initState() {
    Empezar_busqueda();
    //inicializar_variables();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView.builder(
        itemCount: lista_registros_trazabilidad.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(lista_registros_trazabilidad[index].toString()),
          );
        },
      ),
    );
  }

  Empezar_busqueda() async {
    var valor = await Post(boton_seleccionado,Codigo_trazabilidad, "Capturador_androd");
  }

  Future<String> Post(String Unico,String Codigo_consulta, String Tipo_dispositivo) async {
    //id_empresa = "1";
    //id_sucursal="1";
    print("datos que pasaron respecto al id empresa y sucursal: ");
    print(id_empresa);
    print(id_sucursal);
    var jsonenviable = "[" +jsonEncode(<String, String>{
      'Id_empresa':id_empresa,
      'Id_sucursal':id_sucursal,
      'Funcionalidad':Unico,
      'Codigo_consulta':Codigo_consulta,
      'Tipo_dispositivo':Tipo_dispositivo
    }) + "]";
    print("lo de abajo es el print de la funcion");
    print(jsonenviable);

    final response = await http
        .post(Uri.parse("http://sd-1894661-h00004.ferozo.net/api/Trazabilidad"), //192.168.0.78:44332
        body: jsonenviable,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json"
        }
    );
    print("llego aca?");


    print("Respuesta de Trazabilidad: ");
    json.decode(response.body);
    respuesta_registros = response.body;
    var contenido_json = json.decode(respuesta_registros);
    print("el largo del response es de: ");
    print(response.body.length);
    final length = contenido_json.length;

    setState(() {
      for(int x = 0; x < length; x++){
        lista_registros_trazabilidad.add("ID: "+contenido_json[x]["id_Contador"].toString());
        lista_registros_trazabilidad.add("Nombre Equipo: "+contenido_json[x]["NombreEqupo_S_C_I"]);
        lista_registros_trazabilidad.add("Tipo: "+contenido_json[x]["Tipo_S_C_I"]);
        lista_registros_trazabilidad.add("Codigo de barra: "+contenido_json[x]["Codigo_barra_Contador"]);
        lista_registros_trazabilidad.add("ID de turno activo: "+contenido_json[x]["ID_tuno_Activo_Contador"].toString());
        lista_registros_trazabilidad.add("Detalle turno: "+contenido_json[x]["Detalle_turnos_conf"]);
        lista_registros_trazabilidad.add("Fecha Inicio: "+contenido_json[x]["Fecha_inicio_contador"].toString());
        lista_registros_trazabilidad.add("Fecha Termino"+contenido_json[x]["Fecha_termino_contador"].toString());
        lista_registros_trazabilidad.add("Estado de Turno: "+contenido_json[x]["Estado_Turno_contador"].toString());
        lista_registros_trazabilidad.add("Detalle de Captura: "+contenido_json[x]["Detalle_Captura"]);
        lista_registros_trazabilidad.add("Tam_Codigo: "+contenido_json[x]["Tam_codigo_Configuracion_C"].toString());
        lista_registros_trazabilidad.add("Identificador_planta: "+contenido_json[x]["Identificador_planta_Contador"].toString());
        lista_registros_trazabilidad.add("Fallas: "+contenido_json[x]["Fallas"]);
        lista_registros_trazabilidad.add("--------------- Siguiente Registro ---------------");
      }
    });
    return response.body;

  }
}

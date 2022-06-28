
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pickersupp/Login.dart';

import 'db.dart';


class Log_registro_errores extends StatefulWidget {
  const Log_registro_errores({Key? key}) : super(key: key);

  @override
  State<Log_registro_errores> createState() => _Log_registro_erroresState();
}

class _Log_registro_erroresState extends State<Log_registro_errores> {
  //List<Persona> objeto_usuario_entero;



  @override
  void initState() {
    Cargar_lista_errores();
    //inicializar_variables();
    super.initState();
  }
  List searchedNames = [];
  String searchString = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Registro de errores Scanner"),
      ),
        body: Column(
          children: [
            TextField(
              // calls the _searchChanged on textChange
              onChanged: (search) => _searchChanged(search),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: searchedNames.length,
                itemBuilder: (context, index) => Container(
                  padding: EdgeInsets.all(5),
                  child: Text(searchedNames[index]),
                ),
              ),
            ),
          ],
        ),
    );
  }
  void _searchChanged(String searchText) {
    if (searchText != null && searchText.isNotEmpty) {
      setState(() {
        searchedNames =
            List.from(Informe_errores.where((name) => name.contains(searchText)));
      });
    }
    else {
      setState(() {
        searchedNames =
            List.from(Informe_errores);
      });
    }
  }
  Cargar_lista_errores() async {
    List Informe_errores = await DB.Mostrar_errores();
    //Informe_errores = ["Error12-32-1231","Error12-32-1232","Error12-32-1233","4","1"];
    searchedNames.addAll(Informe_errores);
  }
}



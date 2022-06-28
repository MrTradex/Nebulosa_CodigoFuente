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
import 'package:syncfusion_flutter_charts/charts.dart';
List lista_contenido = [];
List lista_grafica = ["1","2","3","4","5"];
class graficos extends StatefulWidget {
  const graficos({Key? key}) : super(key: key);

  @override
  State<graficos> createState() => _graficosState();
}

class _graficosState extends State<graficos> {
  late List<GDPData> _chartData;

  @override
  void initState(){
    _chartData = getChartData();
    super.initState();
  }
  int data_buenos = 0;
  int data_sucio = 0;
  int data_humedo = 0;
  int data_premium = 0;
  int data_por_pintar = 0;

  String vista = "Seleccione turno";

  @override
  Widget build(BuildContext context) {
    return SafeArea(child:
    Scaffold(
      body: ListView(
        children: [
          SfCircularChart(
            title: ChartTitle(text: "Cantidad de Estados de pallets Scaneados: "),
            legend: Legend(
                isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
            series: <CircularSeries>[
              PieSeries<GDPData, String>(
                  dataSource: _chartData,
                  xValueMapper: (GDPData data,_) => data.Estado_pallet,
                  yValueMapper: (GDPData data,_) => data.cantidad,
                  dataLabelSettings: DataLabelSettings(isVisible: true)
                )
              ],
            ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 70, vertical: 5),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: DropdownButton<String>(
              items: lista_grafica.map((data) {
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
                  if(vista == "5"){
                    print("Bueno, ahora tendriamos que estar viendo el turno numero 5");
                    print(turno_actual);
                  }
                })
              },
              hint: Text(vista),
              iconEnabledColor: Colors.green,
              icon: Icon(Icons.arrow_downward_sharp),
            ),
            ),
          ],
        ),
      ),
    );
  }
  List<GDPData> getChartData(){
      print("valor de lo que esta adentro: ");
      print(data_buenos);
     List<GDPData> chartData =[
      GDPData("Bueno", lista_contenido[0]),
      GDPData("Sucio", lista_contenido[1]),
      GDPData("Humedo", lista_contenido[2]),
      GDPData("Premium", lista_contenido[3]),
      GDPData("Por pintar", lista_contenido[4])
    ];
    return chartData;
  }

}

class GDPData{
  GDPData(this.Estado_pallet,this.cantidad);
  final String Estado_pallet;
  final int cantidad;
}

import 'package:flutter/material.dart';
import 'package:pickersupp/Calidad_Curva.dart';

List lista_traspasable = [];
List lista_De_id_fallas = [];
// Multi Select widget
// This widget is reusable
class MultiSelect extends StatefulWidget {
  final List<String> items;
  const MultiSelect({Key? key, required this.items}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MultiSelectState();
}

class _MultiSelectState extends State<MultiSelect> {
  // this variable holds the selected items
  final List<String> _selectedItems = [];

// This function is triggered when a checkbox is checked or unchecked
  void _itemChange(String itemValue, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedItems.add(itemValue);
      } else {
        _selectedItems.remove(itemValue);
      }
    });
  }

  // this function is called when the Cancel button is pressed
  void _cancel() {
    Navigator.pop(context);
  }

// this function is called when the Submit button is tapped
  void _submit() {
    print("los items seleccionados: ");
    print(_selectedItems);
    lista_traspasable = _selectedItems;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Seleccione las fallas del Pallet'),
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.items
              .map((item) => CheckboxListTile(
            value: _selectedItems.contains(item),
            title: Text(item),
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (isChecked) => _itemChange(item, isChecked!),
          ))
              .toList(),
        ),
      ),
      actions: [
        ElevatedButton(
          child: const Text('Ingresar'),
          onPressed: (){
            if(_selectedItems.isEmpty){
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                      'Debe seleccionar alguna opcion para continuar!'),
                ),
              );
            }else{
              _submit();
              lista_De_id_fallas = reportList_id;
              Navigator.pop(context);
            }
            //reportList.clear();
            //reportList_id.clear();
          },
        ),
        ElevatedButton(
          child: const Text('Cancelar'),
          onPressed: _cancel,
        ),
      ],
    );
  }
}

// Implement a multi select on the Home screen
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> _selectedItems = [];

  void _showMultiSelect() async {
    // a list of selectable items
    // these items can be hard-coded or dynamically fetched from a database/API
    final List<String> _items = [
      'Flutter',
      'Node.js',
      'React Native',
      'Java',
      'Docker',
      'MySQL'
    ];

    final List<String>? results = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MultiSelect(items: _items);
      },
    );

    // Update UI
    if (results != null) {
      setState(() {
        _selectedItems = results;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KindaCode.com'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // use this button to open the multi-select dialog
            ElevatedButton(
              child: const Text('Select Your Favorite Topics'),
              onPressed: _showMultiSelect,
            ),
            const Divider(
              height: 30,
            ),
            // display selected items
            Wrap(
              children: _selectedItems
                  .map((e) => Chip(
                label: Text(e),
              ))
                  .toList(),
            )
          ],
        ),
      ),
    );
  }
}
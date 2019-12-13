import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?format=json&key=a6fb3734";

void main() async {
  runApp(MaterialApp(
      home: Home(),
));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body)["results"]["currencies"];
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double dolar, euro;
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  void _clearAll(){
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  void _realChanged(String text) {
    if(text.isEmpty){
      _clearAll();
      return;
    }
    double real = double.parse(text);
    dolarController.text = (real * dolar).toStringAsFixed(2);
    euroController.text = (real * euro).toStringAsFixed(2);

  }

  void _dolarChanged(String text) {
    if(text.isEmpty){
      _clearAll();
      return;
    }
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = ((dolar * this.dolar) / euro).toStringAsFixed(2);

  }

  void _euroChanged(String text) {
    if(text.isEmpty){
      _clearAll();
      return;
    }
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = ((euro * this.euro) / dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        backgroundColor: Colors.black45,
        title: Text("\$ Conversor \$"),
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                  child: Text("Carregando dados...",
                      style: TextStyle(color: Colors.black, fontSize: 25),
                      textAlign: TextAlign.center));
              break;
            default:
              if (snapshot.hasError) {
                return Center(
                    child: Text("Erro ao Carregar os Dados :(",
                        style: TextStyle(color: Colors.black, fontSize: 25),
                        textAlign: TextAlign.center));
              } else {
                dolar = snapshot.data["USD"]["buy"];
                euro = snapshot.data["EUR"]["buy"];
                return SingleChildScrollView(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(
                        Icons.monetization_on,
                        size: 150,
                        color: Colors.black45,
                      ),
                      buildTextField(
                        "Reais",
                        "R\$",
                        realController,
                        _realChanged,
                      ),
                      Divider(),
                      buildTextField(
                          "Dólares", "\$", dolarController, _dolarChanged),
                      Divider(),
                      buildTextField(
                          "Euros", "€", euroController, _euroChanged),
                    ],
                  ),
                );
              }
              break;
          }
        },
      ),
    );
  }
}

Widget buildTextField(String label, String prefix,
    TextEditingController controller, Function change) {
  return TextField(
    controller: controller,
    onChanged: change,
    keyboardType: TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.black45, fontSize: 30),
      border: OutlineInputBorder(),
      prefixText: prefix,
    ),
    style: TextStyle(color: Colors.black45, fontSize: 30),
  );
}

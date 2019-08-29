import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CEP APP',
      theme: ThemeData(

        primarySwatch: Colors.red,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget{

  MyHomePageState createState() => new MyHomePageState();
  // MyHomePageState createState() { return new MyHomePageState(); }

}

class MyHomePageState extends State<MyHomePage>{

  String cep;
  final _formKey = new GlobalKey<FormState>();
  var data;
  int status = 0;
  /*
  Status Http:
    200 (OK);
    201 (Created);
    202 (Accepted);
    204 (No Content).
  */

  void submit() async{
    if(_formKey.currentState.validate()){
      setState(() {
        status = 1;
      });
      _formKey.currentState.save();
    }
    final response =
        await http.get('http://api.postmon.com.br/v1/cep/$cep');
    if(response.statusCode == 200)
      setState(() {
        status = 2;
        data = json.decode(response.body);
      });
    else
      setState(() {
        status = 3;
      });
  }

  Widget responseWidget() => status == 0 ? SizedBox()
      : status == 1 ?
        Center(
          child: CircularProgressIndicator(),
        )
      : status == 2 ?
        Center(
          child: Column(
             children: <Widget>[
                Icon(Icons.home),
            data['logradouro'] != null
            ? Text(data['logradouro'],
              style:
                TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w200),
            )
            : Text(data['ciadade'],
              style:
              TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w200),
            ),
               Text(data['bairro'] + ' - ' + data['cidade'],
                 style:
                 TextStyle(
                     fontSize: 25,
                     fontWeight: FontWeight.w200),
               ),
              ],
            ),
          )
        : Center(
          child: Column(
              children: <Widget>[
            Icon(Icons.close),
            Text("Erro no cep!"),
            ],
          ),
        );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Buscador de CEP"),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: TextFormField(
                validator: (inputText){
                  if(inputText.isEmpty)
                    return "Digite algo!";
                  if(inputText.length < 8)
                    return "Digite um cep válido!";
                  return null;
                },
                onSaved: (inputText){
                  cep = inputText;
                },
                maxLength: 8,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Digite seu cep",
                ),
              ),
            ),
          ),
          Center(
            child: FlatButton(
              child: Text("Buscar"),
              onPressed: () => this.submit(),
            ),
          ),
          SizedBox(
            height: 50,
          ),
          responseWidget(),
        ],
      ),
    );
  }
}
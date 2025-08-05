import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Define the webhook URL
  static const String webhookUrl = "https://hook.eu2.make.com/9x1mm72cbt99ib6iylutk22kmyv6avru";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sentence Beautify Application',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _inputController = TextEditingController();
  TextEditingController _outputController = TextEditingController();

  Future<String> sendToWebhook(String inputText) async {
    try {
      final response = await http.post(
        Uri.parse(MyApp.webhookUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'input': inputText,
        }),
      );
      if (response.statusCode == 200) {
        return response.body;
      } else {
        return 'Error: ${response.statusCode}';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  void showOutput() async {
    String inputText = _inputController.text.trim();
    String outputText = await sendToWebhook(inputText);
    setState(() {
      _outputController.text = outputText;
    });
  }

  void copyToClipboard() {
    String outputText = _outputController.text.trim();
    Clipboard.setData(ClipboardData(text: outputText));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Copied to Clipboard'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sentence Beautify Application'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _inputController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Enter your text',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: showOutput,
                child: Text('Submit'),
              ),
              SizedBox(height: 20.0),
              Text(
                'Output:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10.0),
              TextField(
                controller: _outputController,
                maxLines: 5,
                readOnly: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: copyToClipboard,
                child: Text('Copy Output'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }
}

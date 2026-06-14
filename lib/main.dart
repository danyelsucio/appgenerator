import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Up Generator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String contenidoArchivo = '';
  String nombreArchivo = 'Ningún archivo seleccionado';

  Future<void> importarArchivo() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'docx', 'json'],
        initialDirectory: '/storage/emulated/0/Documents', // Carpeta Documentos
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        String contenido = await file.readAsString();
        setState(() {
          contenidoArchivo = contenido;
          nombreArchivo = result.files.single.name;
        });
      }
    } catch (e) {
      setState(() {
        contenidoArchivo = 'Error al leer archivo: $e';
      });
    }
  }

  List<TextSpan> resaltarVariables(String texto) {
    List<TextSpan> spans = [];
    RegExp exp = RegExp(r'\{\{.*?\}\}');
    int ultimoIndex = 0;

    for (RegExpMatch match in exp.allMatches(texto)) {
      if (match.start > ultimoIndex) {
        spans.add(TextSpan(
          text: texto.substring(ultimoIndex, match.start),
          style: const TextStyle(color: Colors.white70),
        ));
      }
      spans.add(TextSpan(
        text: texto.substring(match.start, match.end),
        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      ));
      ultimoIndex = match.end;
    }

    if (ultimoIndex < texto.length) {
      spans.add(TextSpan(
        text: texto.substring(ultimoIndex),
        style: const TextStyle(color: Colors.white70),
      ));
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.red,
        centerTitle: true,
        title: const Text(
          'up generator',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 1, child: Text('Opción 1')),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.grey[900],
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.red),
              child: Text('Menú', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.file_open, color: Colors.white),
              title: const Text('Importar archivo', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context); // Cierra el drawer
                importarArchivo(); // Abre selector de archivos
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white),
              title: const Text('Ajustes', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Archivo: $nombreArchivo',
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: SelectableText.rich(
                  TextSpan(children: resaltarVariables(contenidoArchivo)),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

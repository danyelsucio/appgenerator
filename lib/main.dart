import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
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
  final TextEditingController _controller = TextEditingController();
  String textoSeleccionado = '';
  int inicioSel = 0;
  int finSel = 0;

  List<String> listaFundamentos = [
    'Artículo 217 del CNPP',
    'Artículo 251 del CNPP',
    'Artículo 16 Constitucional',
    'Artículo 20 Constitucional',
  ];
  List<String> fundamentosElegidos = [];

  @override
  void initState() {
    super.initState();
    _controller.text = '''REGISTRO DE ACTIVIDAD MINISTERIAL.- En la Ciudad de México, siendo las {{HORA}} del día {{FECHA}} de 2026 dos mil veintiséis, con fundamento en {{FUNDAMENTOS}}, la Licenciada Adrianayeli Hernández Hernández...''';
  }

  List<TextSpan> resaltarVariables(String texto) {
    List<TextSpan> spans = [];
    RegExp exp = RegExp(r'\{\{.*?\}\}');
    int ultimoIndex = 0;
    for (RegExpMatch match in exp.allMatches(texto)) {
      if (match.start > ultimoIndex) {
        spans.add(TextSpan(text: texto.substring(ultimoIndex, match.start)));
      }
      spans.add(TextSpan(
        text: texto.substring(match.start, match.end),
        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      ));
      ultimoIndex = match.end;
    }
    if (ultimoIndex < texto.length) {
      spans.add(TextSpan(text: texto.substring(ultimoIndex)));
    }
    return spans;
  }

  void mostrarMenuOpciones() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.calendar_today, color: Colors.white),
            title: const Text('Fecha', style: TextStyle(color: Colors.white)),
            onTap: () async {
              Navigator.pop(context);
              DateTime? fecha = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (fecha!= null) {
                reemplazarTextoSeleccionado('${fecha.day}/${fecha.month}/${fecha.year}');
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.document_scanner, color: Colors.white),
            title: const Text('Escanear', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => ScannerPage(onTextoExtraido: reemplazarTextoSeleccionado),
              ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.gavel, color: Colors.white),
            title: const Text('Fundamento', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              mostrarDialogoFundamentos();
            },
          ),
        ],
      ),
    );
  }

  void mostrarDialogoFundamentos() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Selecciona Fundamentos', style: TextStyle(color: Colors.white)),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: listaFundamentos.map((fundamento) {
                return CheckboxListTile(
                  title: Text(fundamento, style: const TextStyle(color: Colors.white, fontSize: 14)),
                  value: fundamentosElegidos.contains(fundamento),
                  onChanged: (val) {
                    setDialogState(() {
                      if (val == true) {
                        fundamentosElegidos.add(fundamento);
                      } else {
                        fundamentosElegidos.remove(fundamento);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                reemplazarTextoSeleccionado(fundamentosElegidos.join(', '));
                fundamentosElegidos.clear();
              },
              child: const Text('ACEPTAR', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  void reemplazarTextoSeleccionado(String nuevoTexto) {
    if (textoSeleccionado.isNotEmpty) {
      String texto = _controller.text;
      _controller.text = texto.replaceRange(inicioSel, finSel, nuevoTexto);
      setState(() {
        textoSeleccionado = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.red,
        centerTitle: true,
        title: const Text('up generator', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          if (textoSeleccionado.contains('{{'))
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onPressed: mostrarMenuOpciones,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Pega tu machote aquí...',
                  hintStyle: TextStyle(color: Colors.white38),
                ),
                onChanged: (val) => setState(() {}),
                onTap: () {
                  final selection = _controller.selection;
                  if (selection.start!= selection.end) {
                    setState(() {
                      inicioSel = selection.start;
                      finSel = selection.end;
                      textoSeleccionado = _controller.text.substring(inicioSel, finSel);
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText.rich(
                TextSpan(children: resaltarVariables(_controller.text)),
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScannerPage extends StatefulWidget {
  final Function(String) onTextoExtraido;
  const ScannerPage({super.key, required this.onTextoExtraido});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  String textoReconocido = '';
  bool escaneando = false;

  Future<void> escanearImagen() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return;

    setState(() => escaneando = true);
    final inputImage = InputImage.fromFilePath(image.path);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
    await textRecognizer.close();

    setState(() {
      textoReconocido = recognizedText.text;
      escaneando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text('Escáner OCR', style: TextStyle(color: Colors.white)),
        actions: [
          if (textoReconocido.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                widget.onTextoExtraido(textoReconocido);
                Navigator.pop(context);
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: escaneando? null : escanearImagen,
              icon: const Icon(Icons.camera_alt),
              label: Text(escaneando? 'Escaneando...' : 'Tomar Foto'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: SelectableText(
                  textoReconocido.isEmpty? 'Toma una foto para extraer texto' : textoReconocido,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

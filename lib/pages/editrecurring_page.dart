import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EditRecurringPage extends StatefulWidget {
  static const String routeName = '/edit_recurring';
  final Map<String, dynamic> task;

  const EditRecurringPage({Key? key, required this.task}) : super(key: key);

  @override
  _EditRecurringPageState createState() => _EditRecurringPageState();
}

class _EditRecurringPageState extends State<EditRecurringPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late int _priority;
  String _selectedPriorityTxt = "";

  @override
  void initState() {
    super.initState();

    // Inicializar valores predeterminados
    _titleController = TextEditingController(text: widget.task['Title']);
    _descriptionController =
        TextEditingController(text: widget.task['Description']);
    _priority = widget.task['Priority'] ?? 0;
    _selectedPriorityTxt = _getPriorityText(_priority);
  }

  Future<bool> _updateTask() async {
    if (_formKey.currentState!.validate()) {
      int recurringId = widget.task['Recurring']['RecurringID'];
      String title = _titleController.text;
      String description = _descriptionController.text;
      int priority = _priority;

      final url = Uri.parse(
          'https://focusnet-task-service-194080380757.southamerica-west1.run.app/recurring/recurring/update/$recurringId');

      final response = await http.put(
        url,
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "Title": title,
          "Description": description,
          "Priority": priority,
        }),
      );

      if (response.statusCode == 200) {
        print("Rutina actualizada con éxito: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rutina actualizada con éxito.')),
        );
        return true; // Éxito
      } else {
        print("Error al actualizar la Rutina: ${response.statusCode}");
        return false; // Falla
      }
    }
    return false; // Si la validación falla
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SafeArea(
            child: Stack(
              children: [
                // Título centrado
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  color: const Color(0xFF882ACB),
                  child: Center(
                    child: Text(
                      "Editar rutina",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Botón de retroceso alineado a la izquierda
                Positioned(
                  left: 10, // Ajusta la posición izquierda
                  top: 10, // Ajusta la posición superior
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
              child: Form(
                  key: _formKey,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                            child: Column(
                          children: [
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Nombre de la actividad",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              controller: _titleController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      width: 3.0, color: Color(0xFF882ACB)),
                                ),
                                filled: true,
                                fillColor: Colors.purple.shade50,
                              ),
                              validator: (value) => value!.isEmpty
                                  ? 'El título no puede estar vacío'
                                  : null,
                            ),
                            const SizedBox(height: 20),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Descripción",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 15),
                            TextField(
                              controller: _descriptionController,
                              maxLines: 4,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Color.fromRGBO(204, 8, 8, 1),
                                    width: 5.0,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.purple.shade50,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Nivel de priorización
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Nivel de Priorización",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildPriorityButton(
                                    "Baja", Colors.amber.shade700),
                                _buildPriorityButton(
                                    "Media", Colors.deepOrange),
                                _buildPriorityButton(
                                    "Alta", Colors.red.shade800),
                              ],
                            ),

                            const SizedBox(height: 50),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  width: 160,
                                  height: 42,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color.fromRGBO(182, 15, 15, 1),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                      size: 20.0,
                                    ),
                                    label: Text(
                                      "Descartar",
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.white),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 160,
                                  height: 42,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color.fromRGBO(41, 190, 128, 1),
                                    ),
                                    onPressed: () async {
                                      bool success = await _updateTask();
                                      if (success) {
                                        Future.delayed(Duration(seconds: 1),
                                            () {
                                          Navigator.pop(context);
                                        });
                                      }
                                    },
                                    icon: Icon(
                                      Icons.update,
                                      color: Colors.white,
                                      size: 20.0,
                                    ),
                                    label: Text(
                                      "Actualizar",
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.white),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ))
                      ])),
            ),
          ),
        ],
      ),
    );
  }

  String _getPriorityText(int? priority) {
    switch (priority) {
      case 0:
        return "Baja";
      case 1:
        return "Media";
      case 2:
        return "Alta";
      default:
        return "No definida";
    }
  }

  Widget _buildPriorityButton(String text, Color color) {
    return Container(
      width: 110,
      height: 45,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedPriorityTxt = text;
            switch (text) {
              case "Baja":
                _priority = 0;
                break;
              case "Media":
                _priority = 1;
                break;
              case "Alta":
                _priority = 2;
                break;
              default:
                _priority = -1;
            }
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              _selectedPriorityTxt == text ? color : color.withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(text,
            style: const TextStyle(color: Colors.white, fontSize: 17.0)),
      ),
    );
  }
}

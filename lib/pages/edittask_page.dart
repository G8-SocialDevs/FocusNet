import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class EditTaskPage extends StatefulWidget {
  static const String routeName = '/edit_task';
  final Map<String, dynamic> task;

  const EditTaskPage({Key? key, required this.task}) : super(key: key);

  @override
  _EditTaskPageState createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  Map<int, Map<String, dynamic>> calendarData = {};
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late int _priority;
  String _selectedPriorityTxt = "";
  late bool _recurringStart;
  late TextEditingController _dateController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;

  // Variables de fecha
  late int calendarID_start;
  late int calendarID_end;
  late int year;
  late int month;
  late int day;
  late int hour_start;
  late int minute_start;
  late int hour_end;
  late int minute_end;

  @override
  void initState() {
    super.initState();

    // Inicializar valores predeterminados
    calendarID_start = widget.task['StartTimestampID'] ?? -1;
    calendarID_end = widget.task['EndTimeStampID'] ?? -1;
    _titleController = TextEditingController(text: widget.task['Title']);
    _descriptionController =
        TextEditingController(text: widget.task['Description']);
    _priority = widget.task['Priority'] ?? 0;
    _recurringStart = widget.task['RecurringStart'] ?? false;
    _selectedPriorityTxt = _getPriorityText(_priority);

    // Valores predeterminados en caso de que fetchCalendarData() tarde
    year = 2099;
    month = 12;
    day = 30;
    hour_start = 23;
    minute_start = 59;
    hour_end = 23;
    minute_end = 59;

    _dateController = TextEditingController(
        text:
            "${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/${year.toString().padLeft(2, '0')}");
    _startTimeController = TextEditingController(
        text:
            "${hour_start.toString().padLeft(2, '0')}:${minute_start.toString().padLeft(2, '0')}");
    _endTimeController = TextEditingController(
        text:
            "${hour_end.toString().padLeft(2, '0')}:${minute_end.toString().padLeft(2, '0')}");

    fetchCalendarDataAndUpdate();
  }

// Función para obtener los datos y actualizar el estado
  Future<void> fetchCalendarDataAndUpdate() async {
    await fetchCalendarData(); // Esperar a que los datos sean obtenidos

    // Actualizar los valores si `calendarData` ya está disponible
    if (calendarData.containsKey(calendarID_start)) {
      setState(() {
        year = calendarData[calendarID_start]?['Year'] ?? 2099;
        month = calendarData[calendarID_start]?['Month'] ?? 12;
        day = calendarData[calendarID_start]?['Day'] ?? 30;
        hour_start = calendarData[calendarID_start]?['Hour'] ?? 23;
        minute_start = calendarData[calendarID_start]?['Minute'] ?? 59;
        hour_end = calendarData[calendarID_end]?['Hour'] ?? 23;
        minute_end = calendarData[calendarID_end]?['Minute'] ?? 59;

        _dateController.text =
            "${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/${year.toString().padLeft(2, '0')}";
        _startTimeController.text =
            "${hour_start.toString().padLeft(2, '0')}:${minute_start.toString().padLeft(2, '0')}";
        _endTimeController.text =
            "${hour_end.toString().padLeft(2, '0')}:${minute_end.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<bool> _updateTask() async {
    if (_formKey.currentState!.validate()) {
      int taskid = widget.task['TaskID'];
      String title = _titleController.text;
      String description = _descriptionController.text;
      int priority = _priority;
      String startTimestamp =
          _formatToISO8601(_dateController.text, _startTimeController.text);
      String endTimestamp =
          _formatToISO8601(_dateController.text, _endTimeController.text);

      final url = Uri.parse(
          'https://focusnet-task-service-194080380757.southamerica-west1.run.app/task/update');

      final response = await http.put(
        url,
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "TaskID": taskid,
          "Title": title,
          "Description": description,
          "Priority": priority,
          "RecurringStart": false,
          "StartTimestamp": startTimestamp,
          "EndTimestamp": endTimestamp,
        }),
      );

      if (response.statusCode == 200) {
        print("Tarea actualizada con éxito: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Actividad actualizada con éxito.')),
        );
        return true; // Éxito
      } else {
        print("Error al actualizar la tarea: ${response.statusCode}");
        return false; // Falla
      }
    }
    return false; // Si la validación falla
  }

  /// Obtiene la información del calendario desde el endpoint calendar/get_calendar
  Future<void> fetchCalendarData() async {
    try {
      final response = await http.get(Uri.parse(
          'https://focusnet-task-service-194080380757.southamerica-west1.run.app/calendar/get_calendar'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          calendarData = {for (var item in data) item['CalendarID']: item};
        });
      } else {
        throw Exception('Error al cargar datos del calendario');
      }
    } catch (e) {
      print('Error al obtener datos del calendario: $e');
    }
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void _selectTime(TextEditingController controller) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.format(context);
      });
    }
  }

  String _formatToISO8601(String date, String time) {
    // Convertir la fecha de dd/MM/yyyy a DateTime
    List<String> dateParts = date.split('/');
    int day = int.parse(dateParts[0]);
    int month = int.parse(dateParts[1]);
    int year = int.parse(dateParts[2]);

    // Convertir la hora de formato 12h a 24h
    TimeOfDay parsedTime = TimeOfDayFormat(context, time);
    DateTime dateTime =
        DateTime(year, month, day, parsedTime.hour, parsedTime.minute);

    // Convertir a UTC y formatear en ISO 8601
    return DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(dateTime.toUtc());
  }

  TimeOfDay TimeOfDayFormat(BuildContext context, String time) {
    print("Valor de 'time' antes de parsear: '$time'");

    time = time.replaceAll(RegExp(r'\s+'), ' ').trim();

    try {
      final parts = time.split(':'); // Solo divide en horas y minutos
      if (parts.length != 2) {
        throw FormatException("Formato de hora incorrecto");
      }

      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      print("Error al parsear la hora: '$time'");
      rethrow;
    }
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
                      "Editar actividad",
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
                            const SizedBox(height: 20),

                            // Fecha
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Fecha",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 15),
                            TextField(
                              controller: _dateController,
                              readOnly: true,
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.calendar_today),
                                  onPressed: _selectDate,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF882ACB)),
                                ),
                                filled: true,
                                fillColor: Colors.purple.shade50,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Hora inicio y fin
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          "Hora de Inicio",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      TextField(
                                        controller: _startTimeController,
                                        readOnly: true,
                                        decoration: InputDecoration(
                                          hintText: "HH:MM",
                                          suffixIcon: IconButton(
                                            icon: const Icon(Icons.access_time),
                                            onPressed: () => _selectTime(
                                                _startTimeController),
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: const BorderSide(
                                                color: Color(0xFF882ACB)),
                                          ),
                                          filled: true,
                                          fillColor: Colors.purple.shade50,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          "Hora de fin",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      TextField(
                                        controller: _endTimeController,
                                        readOnly: true,
                                        decoration: InputDecoration(
                                          hintText: "HH:MM",
                                          suffixIcon: IconButton(
                                            icon: const Icon(Icons.access_time),
                                            onPressed: () =>
                                                _selectTime(_endTimeController),
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: const BorderSide(
                                                color: Color(0xFF882ACB)),
                                          ),
                                          filled: true,
                                          fillColor: Colors.purple.shade50,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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

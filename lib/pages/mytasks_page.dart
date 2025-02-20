import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:focusnet/pages/task_page.dart';

class MytasksPage extends StatefulWidget {
  static const String routeName = '/mytasks';
  final int userId;

  const MytasksPage({super.key, required this.userId});

  @override
  _MytasksPageState createState() => _MytasksPageState();
}

class _MytasksPageState extends State<MytasksPage> {
  List<Map<String, dynamic>> tasks = [];
  Map<int, Map<String, dynamic>> calendarData = {};
  String searchQuery = "";
  int? selectedPriority;

  @override
  void initState() {
    super.initState();
    fetchTasks();
    fetchCalendarData();
  }

  /// Obtiene las tareas del endpoint task/get_tasks
  Future<void> fetchTasks() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://focusnet-task-service-194080380757.southamerica-west1.run.app/task/list_user_tasks/${widget.userId}'),
        headers: {'accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        List<Map<String, dynamic>> loadedTasks =
            List<Map<String, dynamic>>.from(json.decode(response.body));
        setState(() {
          tasks = loadedTasks;
        });
      } else {
        throw Exception('Error al cargar las tareas');
      }
    } catch (e) {
      print('Error al obtener tareas: $e');
    }
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

  /// Ordena todas las tareas primero por día y mes, luego por la hora.
  List<Map<String, dynamic>> getSortedTasks() {
    return tasks.toList()
      ..sort((a, b) {
        int calendarA = a['StartTimestampID'] ?? -1;
        int calendarB = b['StartTimestampID'] ?? -1;

        int yearA = calendarData[calendarA]?['Year'] ?? 9999;
        int monthA = calendarData[calendarA]?['Month'] ?? 12;
        int dayA = calendarData[calendarA]?['Day'] ?? 31;
        int hourA = calendarData[calendarA]?['Hour'] ?? 23;
        int minuteA = calendarData[calendarA]?['Minute'] ?? 59;

        int yearB = calendarData[calendarB]?['Year'] ?? 9999;
        int monthB = calendarData[calendarB]?['Month'] ?? 12;
        int dayB = calendarData[calendarB]?['Day'] ?? 31;
        int hourB = calendarData[calendarB]?['Hour'] ?? 23;
        int minuteB = calendarData[calendarB]?['Minute'] ?? 59;

        // Comparar primero por fecha (año, mes, día)
        int dateComparison = DateTime(yearA, monthA, dayA)
            .compareTo(DateTime(yearB, monthB, dayB));

        if (dateComparison != 0)
          return dateComparison; // Si no son iguales, ordenar por fecha

        // Si la fecha es la misma, comparar por hora y minuto
        return (hourA * 60 + minuteA).compareTo(hourB * 60 + minuteB);
      });
  }

  List<Map<String, dynamic>> getFilteredTasks() {
    return getSortedTasks().where((task) {
      final titleMatch =
          task['Title'].toLowerCase().contains(searchQuery.toLowerCase());
      final priorityMatch =
          selectedPriority == null || task['Priority'] == selectedPriority;
      return titleMatch && priorityMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SafeArea(
          child: Stack(
            children: [
              // Título centrado
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                color: Color(0xFF882ACB),
                child: const Center(
                  child: Text(
                    "Mis actividades",
                    style: TextStyle(
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Buscar actividad...",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 10), // Ajusta según necesites
                    child: Text(
                      "Filtrar por prioridad:",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  SizedBox(width: 25),
                  DropdownButton<int?>(
                    hint: Text(
                      "Filtrar por prioridad",
                      style: TextStyle(fontSize: 15),
                    ),
                    value: selectedPriority,
                    items: [
                      DropdownMenuItem(
                          value: null,
                          child: Text("Todas", style: TextStyle(fontSize: 16))),
                      DropdownMenuItem(
                          value: 0,
                          child: Text("Baja", style: TextStyle(fontSize: 16))),
                      DropdownMenuItem(
                          value: 1,
                          child: Text("Media", style: TextStyle(fontSize: 16))),
                      DropdownMenuItem(
                          value: 2,
                          child: Text("Alta", style: TextStyle(fontSize: 16))),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedPriority = value;
                      });
                    },
                  ),
                ],
              )
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: getFilteredTasks().length,
            itemBuilder: (context, index) {
              return buildTaskCard(getFilteredTasks()[index]);
            },
          ),
        )
      ]),
    );
  }

  /// Construye la tarjeta de cada tarea
  Widget buildTaskCard(Map<String, dynamic> task) {
    int calendarID = task['StartTimestampID'] ?? -1;
    int hour = calendarData[calendarID]?['Hour'] ?? 23;
    int minute = calendarData[calendarID]?['Minute'] ?? 59;
    int month = calendarData[calendarID]?['Month'] ?? 12;
    int day = calendarData[calendarID]?['Day'] ?? 30;

    // Definir el color según la prioridad de la tarea
    Color containerColor;
    switch (task['Priority']) {
      case 0:
        containerColor = Colors.amber.shade700; // Prioridad 0 -> Amarillo
        break;
      case 1:
        containerColor = Colors.deepOrange; // Prioridad 1 -> Naranja
        break;
      case 2:
        containerColor = Colors.red.shade800; // Prioridad 2 -> Rojo
        break;
      default:
        containerColor = const Color.fromARGB(
            255, 66, 148, 241); // Si no tiene prioridad, blanco
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskPage(task: task),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Container(
          decoration: BoxDecoration(
            color:
                containerColor, // Establecer el color de fondo según la prioridad
            borderRadius: BorderRadius.circular(
                12), // Bordes redondeados con un radio de 16
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white), // Texto blanco
                ), // Ícono de actividad
                Text(
                  task['Title'] ?? 'Sin título',
                  style: TextStyle(
                      fontSize: 18, color: Colors.white), // Texto blanco
                ),
                Text(
                  "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white), // Texto blanco
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

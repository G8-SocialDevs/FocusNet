import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  static const String routeName = '/calendar';
  final int userId;

  const CalendarPage({super.key, required this.userId});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  List<Map<String, dynamic>> tasks = [];
  Map<int, Map<String, dynamic>> calendarData = {};
  DateTime selectedDate = DateTime.now();
  CalendarFormat calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    fetchTasks();
    fetchCalendarData();
  }

  /// Obtiene las tareas del endpoint task/get_tasks
  Future<void> fetchTasks() async {
    try {
      final response = await http.get(Uri.parse(
          'https://focusnet-task-service-194080380757.southamerica-west1.run.app/task/get_tasks'));
      if (response.statusCode == 200) {
        setState(() {
          tasks = List<Map<String, dynamic>>.from(json.decode(response.body));
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

  /// Filtra y ordena las tareas por la fecha seleccionada
  List<Map<String, dynamic>> getFilteredTasks() {
    return tasks.where((task) {
      int? calendarID = task['StartTimestampID'];
      if (calendarID != null && calendarData.containsKey(calendarID)) {
        DateTime taskDate = DateTime(
          calendarData[calendarID]!['Year'],
          calendarData[calendarID]!['Month'],
          calendarData[calendarID]!['Day'],
        );
        return isSameDay(taskDate, selectedDate);
      }
      return false;
    }).toList()
      ..sort((a, b) {
        int calendarA = a['StartTimestampID'] ?? -1;
        int calendarB = b['StartTimestampID'] ?? -1;

        int hourA = calendarData[calendarA]?['Hour'] ?? 23;
        int minuteA = calendarData[calendarA]?['Minute'] ?? 59;
        int hourB = calendarData[calendarB]?['Hour'] ?? 23;
        int minuteB = calendarData[calendarB]?['Minute'] ?? 59;

        return (hourA * 60 + minuteA).compareTo(hourB * 60 + minuteB);
      });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredTasks = getFilteredTasks();

    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
              color: const Color(0xFF882ACB),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, // Alinea los elementos
                children: [
                  const Text(
                    "Calendario de actividades",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: () {
                      fetchTasks();
                      fetchCalendarData();
                    },
                  ),
                ],
              ),
            ),
          ),

          /// Calendario para seleccionar fecha
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16.0),
            child: TableCalendar(
              focusedDay: selectedDate,
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              calendarFormat: calendarFormat,
              selectedDayPredicate: (day) => isSameDay(selectedDate, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  selectedDate = selectedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  calendarFormat = format;
                });
              },
              headerStyle: HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                titleTextStyle: const TextStyle(
                  color: Colors.white, // Color del texto del encabezado
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                formatButtonTextStyle: const TextStyle(
                    color:
                        Colors.white), // Texto del botón de formato en blanco
                leftChevronIcon: const Icon(Icons.chevron_left,
                    color: Colors.white), // Flecha izquierda en blanco
                rightChevronIcon: const Icon(Icons.chevron_right,
                    color: Colors.white), // Flecha derecha en blanco
                formatButtonDecoration: BoxDecoration(
                  color: Colors.transparent, // Hace que el botón no tenga fondo
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color:
                          Colors.white), // Borde blanco si quieres resaltarlo
                ),
                decoration: BoxDecoration(
                  color: const Color(
                      0xFF1E3A8A), // Cambia el fondo del encabezado a rosado
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: const Color.fromRGBO(
                      183, 127, 224, 0.7), // Color de fondo para hoy
                  shape: BoxShape.circle, // Mantiene la forma redonda
                ),
                selectedDecoration: BoxDecoration(
                  color: Color(
                      0xFF882ACB), // Color sólido para la fecha seleccionada
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color:
                      Colors.white, // Texto de la fecha seleccionada en blanco
                ),
              ),
            ),
          ),

          /// Lista de tareas
          Expanded(
            child: filteredTasks.isEmpty
                ? const Center(child: Text('No hay tareas para esta fecha'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      return buildTaskCard(filteredTasks[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Construye la tarjeta de cada tarea
  Widget buildTaskCard(Map<String, dynamic> task) {
    int calendarID = task['StartTimestampID'] ?? -1;
    int hour = calendarData[calendarID]?['Hour'] ?? 23;
    int minute = calendarData[calendarID]?['Minute'] ?? 59;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.event, color: Colors.blue), // Ícono de actividad
            Text(task['Title'] ?? 'Sin título', style: TextStyle(fontSize: 18)),
            Text(
              "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

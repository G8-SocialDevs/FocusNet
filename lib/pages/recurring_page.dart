import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:focusnet/pages/editrecurring_page.dart';

class RecurringPage extends StatefulWidget {
  static const String routeName = '/recurring';
  final Map<String, dynamic> task;
  const RecurringPage({Key? key, required this.task}) : super(key: key);

  @override
  _RecurringPageState createState() => _RecurringPageState();
}

class _RecurringPageState extends State<RecurringPage> {
  Map<int, Map<String, dynamic>> calendarData = {};

  @override
  void initState() {
    super.initState();
    fetchCalendarData();
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

  Future<bool> deleteRecurring() async {
    int recurringId = widget.task['RecurringID'];
    final url = Uri.parse(
        'https://focusnet-task-service-194080380757.southamerica-west1.run.app/recurring/recurring/delete/$recurringId');

    try {
      final response = await http.delete(url, headers: {
        'accept': 'application/json',
      });

      if (response.statusCode == 200) {
        print("Rutina eliminada correctamente.");
        return true;
      } else {
        print("Error al eliminar la Rutina: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error de conexión: $e");
      return false;
    }
  }

  void _confirmDeleteRecurring(BuildContext context, Function onDelete) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmar eliminación"),
          content: Text("¿Estás seguro de que deseas eliminar esta rutina?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar diálogo
              },
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Cerrar diálogo
                bool success = await deleteRecurring();
                if (success) {
                  onDelete(); // Refrescar la lista después de eliminar
                }
              },
              child: Text("Eliminar", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int calendarID_start = widget.task['StartTimestampID'] ?? -1;
    int hour_start = calendarData[calendarID_start]?['Hour'] ?? 23;
    int minute_start = calendarData[calendarID_start]?['Minute'] ?? 59;

    int calendarID_end = widget.task['EndTimeStampID'] ?? -1;
    int hour_end = calendarData[calendarID_end]?['Hour'] ?? 23;
    int minute_end = calendarData[calendarID_end]?['Minute'] ?? 59;

    int year = calendarData[calendarID_start]?['Year'] ?? 2099;
    int month = calendarData[calendarID_start]?['Month'] ?? 12;
    int day = calendarData[calendarID_start]?['Day'] ?? 30;

    String date =
        "${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/${year.toString().padLeft(2, '0')}";
    String start_time =
        "${hour_start.toString().padLeft(2, '0')}:${minute_start.toString().padLeft(2, '0')}";
    String end_time =
        "${hour_end.toString().padLeft(2, '0')}:${minute_end.toString().padLeft(2, '0')}";

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
                      widget.task['Title'] ?? 'Detalles del Hábito',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  left: 10,
                  top: 10,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("Descripción"),
                _buildReadOnlyField(
                    widget.task['Description'] ?? 'Sin descripción'),
                const SizedBox(height: 20),
                _buildSectionTitle("Nivel de prioridad"),
                _buildPriorityButton(widget.task['Priority']),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _buildTimeField("Hora inicio", start_time)),
                    SizedBox(width: 10),
                    Expanded(child: _buildTimeField("Hora fin", end_time)),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSectionTitle("Amigos Invitados"),
                _buildInvitedFriends(widget.task['Friends'] ?? []),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: 150,
                      height: 42,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(182, 15, 15, 1),
                        ),
                        onPressed: () {
                          _confirmDeleteRecurring(context, () {
                            setState(() {
                              Navigator.pop(context);
                            });
                          });
                        },
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 20.0,
                        ),
                        label: const Text(
                          "Eliminar",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                    Container(
                      width: 150,
                      height: 42,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromRGBO(26, 151, 208, 1),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditRecurringPage(task: widget.task),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20.0,
                        ),
                        label: const Text(
                          "Editar",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 1, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildReadOnlyField(String text, {IconData? icon}) {
    return TextField(
      readOnly: true,
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey[200],
        suffixIcon: icon != null ? Icon(icon) : null,
      ),
      controller: TextEditingController(text: text),
    );
  }

  Widget _buildPriorityButton(int priority) {
    String priorityText = _getPriorityText(priority);
    Color priorityColor = priority == 0
        ? Colors.amber.shade700
        : priority == 1
            ? Colors.deepOrange
            : priority == 2
                ? Colors.red.shade800
                : const Color.fromARGB(255, 66, 148, 241);
    return Container(
      width: 150,
      height: 45,
      decoration: BoxDecoration(
        color: priorityColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          priorityText,
          style: const TextStyle(
              color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
        ),
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

  Widget _buildTimeField(String label, String time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        _buildReadOnlyField(time, icon: Icons.access_time),
      ],
    );
  }

  Widget _buildInvitedFriends(List<dynamic> friends) {
    if (friends.isEmpty) {
      return const Text(
        "No hay amigos invitados para esta actividad.",
        style: TextStyle(fontSize: 16),
      );
    }
    return Column(
      children: friends.map((friend) {
        return Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            Text(friend),
          ],
        );
      }).toList(),
    );
  }
}

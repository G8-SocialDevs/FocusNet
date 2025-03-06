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
  List<String> invitedFriends = [];

  @override
  void initState() {
    super.initState();
    fetchCalendarData();
    fetchInvitedFriends();
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
    int recurringId = widget.task['Recurring']['RecurringID'];
    print(widget.task['TaskID'].toString());
    print(recurringId.toString());
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

  Future<Map<String, dynamic>> fetchUserProfile(int userID) async {
    final response = await http.get(
      Uri.parse(
          'https://focusnet-user-auth-service-194080380757.southamerica-west1.run.app/profiles/obtain_profile/$userID'),
      headers: {'accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener los datos del usuario');
    }
  }

  Future<void> fetchInvitedFriends() async {
    List<dynamic> attendees = widget.task['attendees'];
    List<String> fetchedFriends = [];

    for (var attendee in attendees) {
      int userID = attendee['UserID'];
      try {
        Map<String, dynamic> userProfile = await fetchUserProfile(userID);
        String fullName =
            '${userProfile["FirstName"]} ${userProfile["LastName"]}';
        fetchedFriends.add(fullName);
      } catch (e) {
        print('Error al obtener usuario $userID: $e');
      }
    }

    setState(() {
      invitedFriends = fetchedFriends;
    });
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
                _buildFrequency(widget.task['Recurring']['Frequency'] ?? "",
                    widget.task['Recurring']['DayNameFrequency'] ?? ""),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _buildTimeField("Hora inicio", start_time)),
                    SizedBox(width: 10),
                    Expanded(child: _buildTimeField("Hora fin", end_time)),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSectionTitle("Compañeros de rutina"),
                _buildInvitedFriends(invitedFriends),
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
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        _buildReadOnlyField(time, icon: Icons.access_time),
      ],
    );
  }

  Widget _buildInvitedFriends(List<dynamic> friends) {
    if (friends.isEmpty) {
      return const Text(
        "No tienes amigos con la misma actividad.",
        style: TextStyle(fontSize: 16),
      );
    }
    return Column(
      children: friends.map((friend) {
        return Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              friend,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 40),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildFrequency(String freq, String days) {
    String frequency = freq.trim();
    String dayNameFrequency = days.trim();

    List<String> daysLabels = ["Lu", "Ma", "Mi", "Ju", "Vi", "Sa", "Do"];
    List<String> activeDays = dayNameFrequency.split(',');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (frequency
            .isNotEmpty) // Si la frecuencia es diaria, semanal o mensual
          RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 18, color: Colors.black),
              children: [
                TextSpan(
                  text: "Frecuencia: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: frequency,
                ),
              ],
            ),
          )
        else if (dayNameFrequency.isNotEmpty) // Si tiene días específicos
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Frecuencia en días",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: daysLabels.map((label) {
                  bool isSelected =
                      activeDays.map((day) => day.trim()).contains(label);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color:
                            isSelected ? Color(0xFF882ACB) : Colors.transparent,
                        border: Border.all(
                            color:
                                isSelected ? Color(0xFF882ACB) : Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        label,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          )
      ],
    );
  }
}

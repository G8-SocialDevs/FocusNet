import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RecurringInvitationPage extends StatefulWidget {
  static const String routeName = '/recurringinvitation';
  final int userId;
  final int invitationId;
  final int taskId;
  final bool isFromR;

  const RecurringInvitationPage(
      {Key? key,
      required this.userId,
      required this.invitationId,
      required this.taskId,
      required this.isFromR})
      : super(key: key);

  @override
  _RecurringInvitationPageState createState() =>
      _RecurringInvitationPageState();
}

class _RecurringInvitationPageState extends State<RecurringInvitationPage> {
  Map<int, Map<String, dynamic>> calendarData = {};
  List<String> invitedFriends = [];
  Map<String, dynamic> task = {};

  @override
  void initState() {
    super.initState();
    fetchCalendarData();
    fetchTask().then((_) => fetchInvitedFriends());
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

  Future<void> fetchTask() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://focusnet-task-service-194080380757.southamerica-west1.run.app/task/search_task/?task_id=${widget.taskId}&user_id=${widget.userId}'),
        headers: {'accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> loadedTask =
            Map<String, dynamic>.from(json.decode(response.body));
        setState(() {
          task = loadedTask;
        });
      } else {
        throw Exception('Error al carga las tarea');
      }
    } catch (e) {
      print('Error al obtener tarea: $e');
    }
  }

  Future<Map<String, dynamic>> fetchUserProfile(int userID) async {
    final response = await http.get(
      Uri.parse(
          'https://focusnet-user-auth-service-194080380757.southamerica-west1.run.app/profiles/obtain_profile/$userID'),
      headers: {'accept': 'application/json'},
    );

    print('Response (${response.statusCode}): ${response.body}'); // Debug

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener los datos del usuario');
    }
  }

  Future<void> fetchInvitedFriends() async {
    List<dynamic> attendees = task['attendees'];
    List<String> fetchedFriends = [];

    for (var attendee in attendees) {
      int? userID = attendee['UserID'];
      if (userID == null) {
        print('Error: userID es null en un attendee.');
        continue;
      }

      try {
        Map<String, dynamic> userProfile = await fetchUserProfile(userID);

        String firstName = userProfile["FirstName"] ?? "Desconocido";
        String lastName = userProfile["LastName"] ?? "";

        String fullName = "$firstName $lastName".trim();
        fetchedFriends.add(fullName);
      } catch (e) {
        print('Error al obtener usuario $userID: $e');
      }
    }

    setState(() {
      invitedFriends = fetchedFriends;
    });

    print('Invitados cargados: $invitedFriends');
  }

  Future<bool> _respondToInvitation(
      BuildContext context, int invitationID, String status) async {
    final url = Uri.parse(
        'https://focusnet-task-service-194080380757.southamerica-west1.run.app/invitations/invitation/respond/$invitationID');

    final response = await http.put(
      url,
      headers: {
        'accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'Status': status}),
    );

    if (response.statusCode == 200) {
      print("Respuesta exitosa: ${response.body}");

      // Definir el mensaje según el estado
      String message = status == "Aceptada"
          ? "Invitación aceptada con éxito."
          : "Invitación rechazada con éxito.";

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }

      return true; // Éxito
    } else {
      print("Error en la solicitud: ${response.statusCode} - ${response.body}");
      return false; // Falla
    }
  }

  Future<bool> deleteInvitation(BuildContext context, int invitationID) async {
    final url = Uri.parse(
        'https://focusnet-task-service-194080380757.southamerica-west1.run.app/invitations/invitation/delete/$invitationID');

    try {
      final response = await http.delete(url, headers: {
        'accept': 'application/json',
      });
      if (response.statusCode == 200) {
        print("Invitación eliminada correctamente.");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Invitación eliminada correctamente")),
          );
        }
        return true;
      } else {
        print("Error al eliminar la invitación: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error de conexión: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    int calendarID_start = task['StartTimestampID'] ?? -1;
    int hour_start = calendarData[calendarID_start]?['Hour'] ?? 23;
    int minute_start = calendarData[calendarID_start]?['Minute'] ?? 59;

    int calendarID_end = task['EndTimeStampID'] ?? -1;
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
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                    task['Title'] ?? 'Detalles de la Tarea',
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Descripción"),
              _buildReadOnlyField(task['Description'] ?? 'Sin descripción'),
              const SizedBox(height: 20),
              _buildSectionTitle("Nivel de prioridad"),
              _buildPriorityButton(task['Priority'] ?? 0),
              const SizedBox(height: 20),
              _buildFrequency(task['Recurring']?['Frequency'] ?? "",
                  task['Recurring']?['DayNameFrequency'] ?? ""),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _buildTimeField("Hora inicio", start_time)),
                  SizedBox(width: 10),
                  Expanded(child: _buildTimeField("Hora fin", end_time)),
                ],
              ),
              const SizedBox(height: 20),
              _buildSectionTitle("Participantes de la actividad"),
              _buildInvitedFriends(invitedFriends),
              const SizedBox(height: 20),
              Column(
                children: [
                  if (widget.isFromR)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: 150,
                          height: 42,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromRGBO(182, 15, 15, 1),
                            ),
                            onPressed: () async {
                              bool success = await _respondToInvitation(
                                  context, widget.invitationId, "Rechazada");
                              if (success) {
                                Future.delayed(Duration(seconds: 1), () {
                                  Navigator.pop(context);
                                });
                              }
                            },
                            icon: const Icon(
                              Icons.cancel,
                              color: Colors.white,
                              size: 20.0,
                            ),
                            label: const Text(
                              "Rechazar",
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ),
                        Container(
                          width: 150,
                          height: 42,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            onPressed: () async {
                              bool success = await _respondToInvitation(
                                  context, widget.invitationId, "Aceptada");
                              if (success) {
                                Future.delayed(Duration(seconds: 1), () {
                                  Navigator.pop(context);
                                });
                              }
                            },
                            icon: const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 20.0,
                            ),
                            label: const Text(
                              "Aceptar",
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        )
                      ],
                    )
                  else
                    Center(
                      child: Container(
                        width: 150,
                        height: 42,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromRGBO(182, 15, 15, 1),
                          ),
                          onPressed: () async {
                            bool success = await deleteInvitation(
                                context, widget.invitationId);
                            if (success) {
                              Future.delayed(Duration(seconds: 1), () {
                                Navigator.pop(context);
                              });
                            }
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
                    )
                ],
              )
            ],
          ),
        ),
      ]),
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

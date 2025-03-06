import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:focusnet/pages/taskinvitation_page.dart';
import 'package:focusnet/pages/recurringinvitation_page.dart';

class MyinvitationsPage extends StatefulWidget {
  static const String routeName = '/myinvitations';
  final int userId;

  const MyinvitationsPage({super.key, required this.userId});

  @override
  _MyinvitationsPageState createState() => _MyinvitationsPageState();
}

class _MyinvitationsPageState extends State<MyinvitationsPage> {
  int selectedIndex = 0; // 0: Recibidos, 1: Enviados
  List<Map<String, dynamic>> invitationsR = [];
  List<Map<String, dynamic>> invitationsS = [];
  List<Map<String, dynamic>> tasks = [];
  Map<int, Map<String, dynamic>> calendarData = {};

  @override
  void initState() {
    super.initState();
    fetchInvitationsR();
    fetchInvitationsS();
    fetchTasks();
    fetchCalendarData();
  }

  /// Obtiene las tareas del endpoint task/get_tasks
  Future<void> fetchTasks() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://focusnet-task-service-194080380757.southamerica-west1.run.app/task/get_tasks'),
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

  /// Obtiene las invitaciones recibidas con estado "Pendiente"
  Future<void> fetchInvitationsR() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://focusnet-task-service-194080380757.southamerica-west1.run.app/invitations/invitation/list/${widget.userId}'),
        headers: {'accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> loadedInvitationsR =
            List<Map<String, dynamic>>.from(json.decode(response.body));

        // Filtrar solo aquellas con Status "Pendiente"
        List<Map<String, dynamic>> filteredInvitationsR = loadedInvitationsR
            .where((invitation) => invitation['Status'] == 'Pendiente')
            .toList();

        setState(() {
          invitationsR = filteredInvitationsR;
        });
      } else {
        throw Exception('Error al cargar las invitaciones recibidas');
      }
    } catch (e) {
      print('Error al obtener invitaciones recibidas: $e');
    }
  }

  /// Obtiene las invitaciones enviadas con estado "Pendiente"
  Future<void> fetchInvitationsS() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://focusnet-task-service-194080380757.southamerica-west1.run.app/invitations/invitation/list_prop/${widget.userId}'),
        headers: {'accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> loadedInvitationsS =
            List<Map<String, dynamic>>.from(json.decode(response.body));

        // Filtrar solo aquellas con Status "Pendiente"
        List<Map<String, dynamic>> filteredInvitationsS = loadedInvitationsS
            .where((invitation) => invitation['Status'] == 'Pendiente')
            .toList();

        setState(() {
          invitationsS = filteredInvitationsS;
        });
      } else {
        throw Exception('Error al cargar las invitaciones enviadas');
      }
    } catch (e) {
      print('Error al obtener invitaciones enviadas: $e');
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
                color: Color(0xFF882ACB),
                child: const Center(
                  child: Text(
                    "Mis invitaciones",
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
        // MenuBar con "Recibidos" y "Enviados"
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildMenuItem("Recibidas", 0),
            _buildMenuItem("Enviadas", 1),
          ],
        ),
        // Contenido dinámico según la opción seleccionada
        Expanded(
          child: selectedIndex == 0
              ? InvitationsList(
                  tasks: tasks,
                  calendarData: calendarData,
                  invitations: invitationsR,
                  isFromR: true)
              : InvitationsList(
                  tasks: tasks,
                  calendarData: calendarData,
                  invitations: invitationsS,
                  isFromR: false),
        ),
      ],
    ));
  }

  Widget _buildMenuItem(String title, int index) {
    bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isSelected ? Color(0xFF882ACB) : Colors.black,
            ),
          ),
          SizedBox(height: 4),
          Container(
            width: 80,
            height: 3,
            color: isSelected ? Color(0xFF882ACB) : Colors.transparent,
          ),
        ],
      ),
    );
  }
}

class InvitationsList extends StatelessWidget {
  final List<Map<String, dynamic>> invitations;
  final List<Map<String, dynamic>> tasks;
  final Map<int, Map<String, dynamic>> calendarData;
  final bool isFromR;

  const InvitationsList(
      {required this.tasks,
      required this.calendarData,
      required this.invitations,
      required this.isFromR,
      Key? key})
      : super(key: key);

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
    return invitations.isEmpty
        ? Center(
            child: Text(
              "No has recibido invitaciones",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: invitations.length,
            itemBuilder: (context, index) {
              return FutureBuilder<Map<String, dynamic>>(
                future: fetchUserProfile(isFromR
                    ? invitations[index]['CreatorID']
                    : invitations[index]['GuestID']),
                builder: (context, snapshot) {
                  final userProfile = snapshot.data ?? {};
                  String invitationText = isFromR
                      ? 'por ${userProfile['FirstName'] ?? 'Nombre'} ${userProfile['LastName'] ?? 'Apellido'}'
                      : 'para ${userProfile['FirstName'] ?? 'Nombre'} ${userProfile['LastName'] ?? 'Apellido'}';

                  return buildInvitationCard(
                      context, invitations[index], invitationText);
                },
              );
            },
          );
  }

  /// Construye la tarjeta de cada invitación recibida
  Widget buildInvitationCard(BuildContext context,
      Map<String, dynamic> invitation, String invitationText) {
    Color containerColor = Color(0xFFFFF9C4);
    int recurringTaskID = 0;

    // Buscar la tarea correspondiente a la invitación
    Map<String, dynamic>? task;
    if (invitation['TaskID'] != null && invitation['RecurringID'] == null) {
      task = tasks.firstWhere(
        (task) => task['TaskID'] == invitation['TaskID'],
        orElse: () => {},
      );
    } else if (invitation['TaskID'] == null &&
        invitation['RecurringID'] != null) {
      task = tasks.firstWhere(
        (task) => task['RecurringID'] == invitation['RecurringID'],
        orElse: () => {},
      );
      recurringTaskID = task['TaskID'] ?? 0;
    } else {
      task = {};
    }

    int calendarID = task['StartTimestampID'] ?? -1;
    int hour = calendarData[calendarID]?['Hour'] ?? 23;
    int minute = calendarData[calendarID]?['Minute'] ?? 59;
    int month = calendarData[calendarID]?['Month'] ?? 12;
    int day = calendarData[calendarID]?['Day'] ?? 30;

    String taskTitle = task.isNotEmpty
        ? task['Title'] ?? 'Título no disponible'
        : 'Tarea no encontrada';

    String recurrenceInfo = "";
    if (task.isNotEmpty && task['RecurringStart'] == true) {
      if (task['recurring'] != null) {
        if (task['recurring']['Frequency'] != null &&
            task['recurring']['Frequency'].toString().isNotEmpty) {
          recurrenceInfo = task['recurring']['Frequency'];
        } else if (task['recurring']['DayNameFrequency'] != null) {
          recurrenceInfo = task['recurring']['DayNameFrequency'];
        } else {
          recurrenceInfo = "Sin frecuencia";
        }
      } else {
        recurrenceInfo = "Sin frecuencia";
      }
    }
    print(recurrenceInfo);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => (task?['RecurringStart'] ?? false)
                ? RecurringInvitationPage(
                    userId: task?['CreatorID'] ?? 0,
                    invitationId: invitation['InvitationID'],
                    taskId: recurringTaskID ?? 0,
                    isFromR: isFromR,
                  )
                : TaskInvitationPage(
                    userId: task?['CreatorID'] ?? 0,
                    invitationId: invitation['InvitationID'],
                    taskId: task?['TaskID'] ?? 0,
                    isFromR: isFromR,
                  ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Container(
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 60,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (recurrenceInfo == "")
                        Text(
                          "${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF0D47A1),
                            shadows: [
                              Shadow(
                                offset: Offset(1, 1),
                                blurRadius: 2,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        )
                      else
                        Text(
                          recurrenceInfo,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF0D47A1),
                            shadows: [
                              Shadow(
                                offset: Offset(1, 1),
                                blurRadius: 2,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      Text(
                        "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF0D47A1),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Sección de Actividad
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        taskTitle,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        invitationText,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),

                // Botones
                isFromR
                    ? Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check_circle,
                                color: Colors.green),
                            iconSize: 33,
                            onPressed: () async {
                              bool success = await _respondToInvitation(context,
                                  invitation['InvitationID'], "Aceptada");
                              if (success) {
                                Future.delayed(Duration(seconds: 1), () {
                                  Navigator.pop(context);
                                });
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            iconSize: 33,
                            onPressed: () async {
                              bool success = await _respondToInvitation(context,
                                  invitation['InvitationID'], "Rechazada");
                              if (success) {
                                Future.delayed(Duration(seconds: 1), () {
                                  Navigator.pop(context);
                                });
                              }
                            },
                          ),
                        ],
                      )
                    : IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        iconSize: 33,
                        onPressed: () async {
                          bool success = await deleteInvitation(
                              context, invitation['InvitationID']);
                          if (success) {
                            Future.delayed(Duration(seconds: 1), () {
                              Navigator.pop(context);
                            });
                          }
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

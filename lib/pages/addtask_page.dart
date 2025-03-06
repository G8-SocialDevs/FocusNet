import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:numberpicker/numberpicker.dart';

class AddtaskPage extends StatefulWidget {
  static const String routename = '/addtask';
  final int userId;

  const AddtaskPage({super.key, required this.userId});

  @override
  _AddtaskPageState createState() => _AddtaskPageState();
}

class _AddtaskPageState extends State<AddtaskPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  int _selectedPriorityNum = 0;
  String? selectedFrequency;
  List<String> _selectedDaysLabels = [];
  int selectedOccurrences = 10;

  String _selectedPriorityTxt = "Media";
  bool repeatActivity = false;
  List<bool> selectedDays = [false, false, false, false, false, false, false];
  final List<String> daysLabels = ['Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sa', 'Do'];

  List<Map<String, dynamic>> contacts = [];
  List<String> friends = [];
  List<bool> invitedFriends = [];

  @override
  void initState() {
    super.initState();
    fetchContacts();
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

//Traer la lista de contactos
  Future<void> fetchContacts() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://focusnet-user-auth-service-194080380757.southamerica-west1.run.app/contacts/list_contacts/${widget.userId}'),
        headers: {'accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        List<Map<String, dynamic>> loadedContacts =
            List<Map<String, dynamic>>.from(json.decode(response.body));
        setState(() {
          contacts = loadedContacts;
          extractFriendNames();
        });
      } else {
        throw Exception('Error al cargar las tareas');
      }
    } catch (e) {
      print('Error al obtener tareas: $e');
    }
  }

  void extractFriendNames() {
    setState(() {
      friends = contacts
          .map((contact) =>
              "${contact['user']['FirstName']} ${contact['user']['LastName']}")
          .toList();
      invitedFriends = List.filled(friends.length, false);
    });
  }

  Future<bool> _addtask() async {
    if (_formKey.currentState!.validate()) {
      String title = _titleController.text;
      String description = _descriptionController.text;
      int priority = _selectedPriorityNum;
      String startTimestamp =
          _formatToISO8601(_dateController.text, _startTimeController.text);
      String endTimestamp =
          _formatToISO8601(_dateController.text, _endTimeController.text);
      String dayNameFrequency = _selectedDaysLabels.join(", ");
      String frequency = selectedFrequency ?? "";
      int ocurrences = selectedOccurrences;
      // Filtrar los UserIDs de los contactos seleccionados
      List<int> guestIDs = [];
      for (int i = 0; i < contacts.length; i++) {
        if (invitedFriends[i]) {
          guestIDs.add(contacts[i]['user']['UserID']);
        }
      }

      final url = Uri.parse(
          'https://focusnet-task-service-194080380757.southamerica-west1.run.app/task/task/create_task');

      final Map<String, dynamic> requestBody = {
        "Title": title,
        "Description": description,
        "Priority": priority,
        "CreatorID": widget.userId,
        "StartTimestamp": startTimestamp,
        "EndTimestamp": endTimestamp,
        "RecurringStart": repeatActivity,
        "Frequency": frequency,
        "DayNameFrequency": dayNameFrequency,
        "Occurrences": ocurrences,
        "GuestIDs": guestIDs,
      };

      final response = await http.post(
        url,
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print("Enviando JSON: ${jsonEncode(requestBody)}");

      if (response.statusCode == 200) {
        print("Tarea creada con éxito: ${response.body}");
        if (repeatActivity) {
          _recurring();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registro exitoso de la actividad: $title')),
        );
        return true; // Éxito
      } else {
        print("Error al crear la tarea: ${response.statusCode}");
        return false; // Falla
      }
    }
    return false; // Si la validación falla
  }

  Future<void> _recurring() async {
    String title = _titleController.text;
    String description = _descriptionController.text;
    int priority = _selectedPriorityNum;

    String frequency = selectedFrequency ?? "";
    String dayNameFrequency = _selectedDaysLabels.join(", ");

    final url = Uri.parse(
        'https://focusnet-task-service-194080380757.southamerica-west1.run.app/recurring/set_recurring/${widget.userId}');

    final Map<String, dynamic> requestBody = {
      "Title": title,
      "Description": description,
      "Priority": priority,
      "Frequency": frequency,
      "DayNameFrequency": dayNameFrequency,
    };

    final response = await http.post(
      url,
      headers: {
        'accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );
    if (response.statusCode == 200) {
      print("Recurrencia establecida con éxito: ${response.body}");
    } else {
      print("Error al establecer la recurrencia: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título fijo con fondo morado
          SafeArea(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15),
              color: Color(0xFF882ACB),
              child: const Center(
                child: Text(
                  "Crear actividad",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
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
                          // Nombre de la actividad
                          const SizedBox(height: 20),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Nombre de la actividad",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              hintText: "Nombre de la actividad",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    width: 3.0, color: Color(0xFF882ACB)),
                              ),
                              filled: true,
                              fillColor: Colors.purple.shade50,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Nota
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
                              hintText: "Descripción",
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
                              _buildPriorityButton("Media", Colors.deepOrange),
                              _buildPriorityButton("Alta", Colors.red.shade800),
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
                              hintText: "DD/MM/YY",
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.calendar_today),
                                onPressed: _selectDate,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Color(0xFF882ACB)),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                          onPressed: () =>
                                              _selectTime(_startTimeController),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                          const SizedBox(height: 20),

                          //Repetir actividad
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Repetir actividad",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              Switch(
                                value: repeatActivity,
                                onChanged: (value) {
                                  setState(() {
                                    // Si repeatActivity es false, limpiar los valores
                                    repeatActivity = value;
                                    if (!repeatActivity) {
                                      _selectedDaysLabels.clear();
                                      selectedDays =
                                          List.generate(7, (_) => false);
                                      selectedFrequency = null;
                                    }
                                  });
                                },
                                activeColor: Color(0xFF882ACB),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          Visibility(
                            visible: repeatActivity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    "Seleccione una frecuencia o los días específicos.",
                                    style: TextStyle(
                                      fontSize: 16,
                                    )),
                                SizedBox(height: 15),
                                //Frecuencia periodica
                                Text("Frecuencia periódica",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                SizedBox(height: 10),
                                DropdownButtonFormField<String>(
                                  value: selectedFrequency,
                                  hint: Text("Seleccione una frecuencia"),
                                  items: ['diaria', 'semanal', 'mensual']
                                      .map((String value) => DropdownMenuItem(
                                            value: value,
                                            child: Text(value),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedFrequency = value!;

                                      // Si se selecciona una frecuencia, deshabilitar los días seleccionados
                                      _selectedDaysLabels.clear();
                                      selectedDays =
                                          List.generate(7, (_) => false);
                                    });
                                  },
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    filled: true,
                                    fillColor: Colors.purple.shade50,
                                  ),
                                  style: TextStyle(
                                      fontSize: 17, color: Colors.black),
                                ),
                                const SizedBox(height: 20),

                                //Dias
                                Text("Frecuencia en días",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 15),
                                ToggleButtons(
                                  children: daysLabels
                                      .map((label) => Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8),
                                            child: Text(label),
                                          ))
                                      .toList(),
                                  isSelected: selectedDays,
                                  onPressed: (index) {
                                    setState(() {
                                      // Si se selecciona un día, resetear el dropdown
                                      selectedFrequency = null;

                                      // Alternar selección
                                      selectedDays[index] =
                                          !selectedDays[index];

                                      // Actualizar lista de días seleccionados
                                      if (selectedDays[index]) {
                                        _selectedDaysLabels
                                            .add(daysLabels[index]);
                                      } else {
                                        _selectedDaysLabels
                                            .remove(daysLabels[index]);
                                      }
                                    });
                                  },
                                  selectedColor: Colors.white,
                                  fillColor: Color(0xFF882ACB),
                                  borderRadius: BorderRadius.circular(20),
                                ),

                                SizedBox(height: 20),
                                Text("Número de repeticiones",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                SizedBox(height: 15),
                                Center(
                                  child: NumberPicker(
                                    value: selectedOccurrences,
                                    minValue: 1,
                                    maxValue: 20,
                                    step: 1,
                                    itemHeight: 50,
                                    axis: Axis
                                        .horizontal, // Puedes cambiar a Axis.vertical si lo prefieres
                                    selectedTextStyle: TextStyle(
                                      fontSize:
                                          24, // Tamaño del número seleccionado
                                      fontWeight: FontWeight.bold,
                                      color: Colors
                                          .purple, // Color morado al número central
                                    ),
                                    textStyle: TextStyle(
                                      fontSize:
                                          18, // Tamaño de los números no seleccionados
                                      color: Colors
                                          .grey, // Color gris para los números de los lados
                                    ),
                                    onChanged: (value) => setState(
                                        () => selectedOccurrences = value),
                                  ),
                                ),

                                SizedBox(height: 20),
                              ],
                            ),
                          ),

                          //Invitaciones
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Amigo(s) a invitar",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                          ),

                          const SizedBox(height: 15),
                          Column(
                            children: List.generate(friends.length, (index) {
                              return CheckboxListTile(
                                title: Text(friends[index]),
                                value: invitedFriends[index],
                                onChanged: (bool? value) {
                                  setState(() {
                                    invitedFriends[index] = value!;
                                  });
                                },
                                activeColor: Color(0xFF882ACB),
                              );
                            }),
                          ),
                          SizedBox(height: 20),

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
                                  onPressed: () {
                                    _titleController.clear();
                                    _descriptionController.clear();
                                    _dateController.clear();
                                    _startTimeController.clear();
                                    _endTimeController.clear();
                                    _selectedPriorityTxt = "Media";
                                    repeatActivity = false;
                                    _selectedDaysLabels.clear();
                                    selectedDays =
                                        List.generate(7, (_) => false);
                                    selectedFrequency = null;
                                    invitedFriends = List.generate(
                                        invitedFriends.length, (_) => false);
                                    selectedOccurrences = 10;
                                    setState(() {});
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
                                width: 150,
                                height: 42,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromRGBO(41, 190, 128, 1),
                                  ),
                                  onPressed: () async {
                                    bool success = await _addtask();
                                    if (success) {
                                      _titleController.clear();
                                      _descriptionController.clear();
                                      _dateController.clear();
                                      _startTimeController.clear();
                                      _endTimeController.clear();
                                      _selectedPriorityTxt = "Media";
                                      repeatActivity = false;
                                      _selectedDaysLabels.clear();
                                      selectedDays =
                                          List.generate(7, (_) => false);
                                      selectedFrequency = null;
                                      invitedFriends = List.generate(
                                          invitedFriends.length, (_) => false);
                                      selectedOccurrences = 10;
                                      setState(() {});
                                    }
                                  },
                                  icon: Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 20.0,
                                  ),
                                  label: Text(
                                    "Crear",
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white),
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
              ),
            ),
          ),
        ],
      ),
    );
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
                _selectedPriorityNum = 0;
                break;
              case "Media":
                _selectedPriorityNum = 1;
                break;
              case "Alta":
                _selectedPriorityNum = 2;
                break;
              default:
                _selectedPriorityNum = -1;
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

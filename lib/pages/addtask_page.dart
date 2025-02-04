import 'package:flutter/material.dart';

import 'package:focusnet/pages/login_page.dart';

class AddtaskPage extends StatefulWidget {
  static const String routename = '/addtask';

  const AddtaskPage({super.key});

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
  bool repeatActivity = false;
  String selectedFrequency = 'diaria';
  List<bool> selectedDays = [false, false, false, false, false, false, false];
  List<bool> invitedFriends = [false, false, false];

  final List<String> daysLabels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
  final List<String> friends = ['Amigo 1', 'Amigo 2', 'Amigo 3'];

  String _selectedPriority = "Media";

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

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      String title = _titleController.text;

      // Aca va el código para el registro dele
      /*
      User? user = await _authService.registerWithEmailPassword(email, password);
      if (user != null) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error en el registro')),
        );
      }
      */

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registro exitoso de la actividad: $title')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título fijo con fondo morado
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
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
                              style: TextStyle(fontSize: 18),
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
                              "Nota",
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                          const SizedBox(height: 15),

                          TextField(
                            controller: _descriptionController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: "Nota",
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
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildPriorityButton("Baja", Colors.yellow),
                              _buildPriorityButton("Media", Colors.orange),
                              _buildPriorityButton("Alta", Colors.red),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Fecha
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Fecha",
                              style: TextStyle(fontSize: 18),
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
                                        style: TextStyle(fontSize: 18),
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
                                        style: TextStyle(fontSize: 18),
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
                                  style: TextStyle(fontSize: 18)),
                              Switch(
                                value: repeatActivity,
                                onChanged: (value) {
                                  setState(() {
                                    repeatActivity = value;
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
                                //Frecuencia periodica
                                Text("Frecuencia periódica",
                                    style: TextStyle(fontSize: 18)),
                                SizedBox(height: 10),
                                DropdownButtonFormField<String>(
                                  value: selectedFrequency,
                                  items: ['diaria', 'semanal', 'mensual']
                                      .map((String value) => DropdownMenuItem(
                                            value: value,
                                            child: Text(value),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedFrequency = value!;
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
                                    style: TextStyle(fontSize: 18)),
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
                                      selectedDays[index] =
                                          !selectedDays[index];
                                    });
                                  },
                                  selectedColor: Colors.white,
                                  fillColor: Color(0xFF882ACB),
                                  borderRadius: BorderRadius.circular(20),
                                ),

                                SizedBox(height: 20),
                              ],
                            ),
                          ),

                          //Invitaciones
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Amigo(s) a invitar",
                                style: TextStyle(fontSize: 18)),
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
                          SizedBox(height: 16),

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
                                    Navigator.pushReplacementNamed(
                                        context, '/login');
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
                                  onPressed: () {},
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
            _selectedPriority = text;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              _selectedPriority == text ? color : color.withOpacity(0.6),
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

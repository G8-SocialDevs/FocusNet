import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CalendarPage extends StatefulWidget {
  static const String routeName = '/calendar';
  final int userId;

  const CalendarPage({super.key, required this.userId});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  List<Map<String, dynamic>> tasks = [];

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    try {
      final response = await http.get(Uri.parse(
          'https://focusnet-task-service-194080380757.southamerica-west1.run.app/task/get_tasks'));
      if (response.statusCode == 200) {
        setState(() {
          tasks = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        throw Exception('Error al cargar los datos');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  DataRow buildTaskItem(Map<String, dynamic> task) {
    return DataRow(cells: [
      DataCell(Text(task['CreatorID'].toString())),
      DataCell(Text(task['TaskID'].toString())),
      DataCell(Text(task['Title'])),
      DataCell(Text(task['Priority'].toString())),
      DataCell(Text(task['EndTimeStampID'].toString())),
      DataCell(Text(task['RecurringStart'].toString())),
      DataCell(Text(task['RecurringID']?.toString() ?? 'N/A')),
      DataCell(Text(task['Description'] ?? 'N/A')),
      DataCell(Text(task['StartTimestampID'].toString())),
      DataCell(Text(task['MinutesDuration'].toString())),
      DataCell(Text(task['CreationDate'])),
      DataCell(Text(task['recurring']?.toString() ?? 'N/A')),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchTasks,
          ),
        ],
      ),
      body: tasks.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Creador ID')),
                    DataColumn(label: Text('Task ID')),
                    DataColumn(label: Text('Título')),
                    DataColumn(label: Text('Prioridad')),
                    DataColumn(label: Text('EndTimeStampID')),
                    DataColumn(label: Text('Recurring Start')),
                    DataColumn(label: Text('Recurring ID')),
                    DataColumn(label: Text('Descripción')),
                    DataColumn(label: Text('StartTimestampID')),
                    DataColumn(label: Text('Duración (min)')),
                    DataColumn(label: Text('Fecha de Creación')),
                    DataColumn(label: Text('Recurring')),
                  ],
                  rows: tasks.map((task) => buildTaskItem(task)).toList(),
                ),
              ),
            ),
    );
  }
}

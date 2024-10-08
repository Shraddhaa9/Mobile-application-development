import 'package:flutter/material.dart';

class WeatherDetailsPage extends StatelessWidget {
  final Map<String, dynamic> weatherDetails;

  const WeatherDetailsPage({Key? key, required this.weatherDetails})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather Details',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade300, Colors.deepPurple.shade800],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildDetailsTable(weatherDetails),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsTable(Map<String, dynamic> details) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1), // Keys get less space
        1: FlexColumnWidth(2), // Values get more space
      },
      border: TableBorder.all(
          color: Colors.black, width: 1, style: BorderStyle.solid),
      children: details.entries.map((entry) {
        // Check if the value is a Map, if so, generate a nested table
        Widget valueWidget = entry.value is Map<String, dynamic>
            ? _buildNestedTable(
                entry.value) // Recursive call to build nested table
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  entry.value.toString(),
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                ),
              );

        return TableRow(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                entry.key,
                style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
                textAlign: TextAlign.left,
              ),
            ),
            valueWidget,
          ],
        );
      }).toList(),
    );
  }

  Widget _buildNestedTable(Map<String, dynamic> nestedData) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1), // Nested Keys
          1: FlexColumnWidth(2), // Nested Values
        },
        children: nestedData.entries
            .map((subEntry) => TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        subEntry.key,
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        subEntry.value.toString(),
                        style:
                            const TextStyle(color: Colors.black, fontSize: 12),
                      ),
                    ),
                  ],
                ))
            .toList(),
      ),
    );
  }
}

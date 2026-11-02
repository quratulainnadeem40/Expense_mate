import 'package:flutter/material.dart';
import '../model/report_model.dart';

class ReportCard extends StatelessWidget {
  final ReportModel report;

  const ReportCard({Key? key, required this.report}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: ListTile(
        title: Text(report.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${report.description}\nDate: ${report.date}"),
        isThreeLine: true,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Details screen logic
        },
      ),
    );
  }
}
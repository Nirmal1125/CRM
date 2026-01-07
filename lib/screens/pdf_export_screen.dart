import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfExportScreen extends StatefulWidget {
  const PdfExportScreen({Key? key}) : super(key: key);

  @override
  State<PdfExportScreen> createState() => _PdfExportScreenState();
}

class _PdfExportScreenState extends State<PdfExportScreen> {
  DateTime? startDate;
  DateTime? endDate;

  // ================= DATE PICKER =================

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (picked == null) return;

    if (!isStart && startDate != null && picked.isBefore(startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date cannot be before start date')),
      );
      return;
    }

    setState(() {
      if (isStart) {
        startDate = picked;
      } else {
        endDate = picked;
      }
    });
  }

  // ================= FIRESTORE FETCH =================

  Future<List<Map<String, dynamic>>> _fetchCollection(
    String collection,
    String dateField,
  ) async {
    Query query = FirebaseFirestore.instance.collection(collection);

    if (startDate != null) {
      query = query.where(
        dateField,
        isGreaterThanOrEqualTo: Timestamp.fromDate(startDate!),
      );
    }

    if (endDate != null) {
      query = query.where(
        dateField,
        isLessThanOrEqualTo:
            Timestamp.fromDate(endDate!.add(const Duration(days: 1))),
      );
    }

    final snap = await query.get();
    return snap.docs
        .map((d) => d.data() as Map<String, dynamic>)
        .toList();
  }

  // ================= BUILD PDF =================

  Future<Uint8List> _buildPdf() async {
    final pdf = pw.Document();

    final customers = await _fetchCollection('customers', 'createdAt');
    final leads = await _fetchCollection('leads', 'createdAt');
    final tasks = await _fetchCollection('tasks', 'dueDate');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (_) => [
          _pdfHeader(),

          if (customers.isNotEmpty)
            _summarySection(customers, leads, tasks),

          if (customers.isNotEmpty) ...[
            _sectionTitle('Customers'),
            _customerTable(customers),
          ],

          if (leads.isNotEmpty) ...[
            _sectionTitle('Leads'),
            _leadTable(leads),
          ],

          if (tasks.isNotEmpty) ...[
            _sectionTitle('Tasks'),
            _taskTable(tasks),
          ],
        ],
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: pw.TextStyle(fontSize: 10),
          ),
        ),
      ),
    );

    return pdf.save();
  }

  // ================= PDF WIDGETS =================

  pw.Widget _pdfHeader() => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'CRM System Report',
            style:
                pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            'Period: '
            '${startDate != null ? DateFormat('dd MMM yyyy').format(startDate!) : 'All'}'
            ' - '
            '${endDate != null ? DateFormat('dd MMM yyyy').format(endDate!) : 'All'}',
            style: pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 20),
        ],
      );

  pw.Widget _sectionTitle(String title) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 12),
        child: pw.Text(
          title,
          style:
              pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
      );

  pw.Widget _summarySection(
    List customers,
    List leads,
    List tasks,
  ) {
    final won = leads.where((l) => l['status'] == 'Won').length;
    final lost = leads.where((l) => l['status'] == 'Lost').length;

    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      margin: const pw.EdgeInsets.only(bottom: 20),
      decoration: pw.BoxDecoration(border: pw.Border.all()),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('CRM Summary',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Text('Total Customers: ${customers.length}'),
          pw.Text('Total Leads: ${leads.length}'),
          pw.Text('Won Leads: $won'),
          pw.Text('Lost Leads: $lost'),
          pw.Text('Total Tasks: ${tasks.length}'),
        ],
      ),
    );
  }

  pw.Widget _customerTable(List customers) {
    return pw.Table.fromTextArray(
      headers: ['Name', 'Email', 'Phone', 'City', 'Status'],
      data: customers
          .map((c) => [
                c['name'] ?? '',
                c['email'] ?? '',
                c['phone'] ?? '',
                c['city'] ?? '',
                c['status'] ?? '',
              ])
          .toList(),
    );
  }

  pw.Widget _leadTable(List leads) {
    return pw.Table.fromTextArray(
      headers: ['Name', 'Company', 'Email', 'Status'],
      data: leads
          .map((l) => [
                l['name'] ?? '',
                l['company'] ?? '',
                l['email'] ?? '',
                l['status'] ?? '',
              ])
          .toList(),
    );
  }

  pw.Widget _taskTable(List tasks) {
    return pw.Table.fromTextArray(
      headers: ['Title', 'Status', 'Priority', 'Due Date'],
      data: tasks.map((t) {
        final due = t['dueDate'] is Timestamp
            ? DateFormat('dd MMM yyyy')
                .format((t['dueDate'] as Timestamp).toDate())
            : '';
        return [
          t['title'] ?? '',
          t['status'] ?? '',
          t['priority'] ?? '',
          due,
        ];
      }).toList(),
    );
  }

  // ================= ACTIONS =================

  Future<void> _previewPdf() async {
    final pdfData = await _buildPdf();
    await Printing.layoutPdf(onLayout: (format) async => pdfData);
  }

  Future<void> _downloadPdf() async {
  final pdfData = await _buildPdf();

  late Directory directory;

  if (Platform.isAndroid) {
    // ✅ ANDROID → Public Downloads folder
    directory = Directory('/storage/emulated/0/Download');
  } else if (Platform.isIOS) {
    // ❗ iOS does NOT allow access to Downloads
    directory = await getApplicationDocumentsDirectory();
  } else {
    // ✅ Desktop (Windows / macOS / Linux)
    directory = await getDownloadsDirectory() ??
        await getApplicationDocumentsDirectory();
  }

  final fileName =
      'CRM_Report_${DateTime.now().millisecondsSinceEpoch}.pdf';
  final file = File('${directory.path}/$fileName');

  await file.writeAsBytes(pdfData);

  // ✅ Success message
  if (!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        Platform.isIOS
            ? 'PDF saved inside app documents'
            : 'PDF saved to Downloads',
      ),
      action: SnackBarAction(
        label: 'Open',
        onPressed: () => Printing.sharePdf(
          bytes: pdfData,
          filename: fileName,
        ),
      ),
    ),
  );
}


  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 700;

    return Scaffold(
      appBar: AppBar(title: const Text('Export CRM Report')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Date Range Filter',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        isWide
                            ? Row(children: _dateButtons())
                            : Column(children: _dateButtons()),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.visibility),
                  label: const Text('Preview PDF'),
                  onPressed: _previewPdf,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.download),
                  label: const Text('Download PDF'),
                  onPressed: _downloadPdf,
                ),
                TextButton(
                  onPressed: () =>
                      setState(() => {startDate = null, endDate = null}),
                  child: const Text('Clear Date Filter'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _dateButtons() => [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _pickDate(true),
            child: Text(
              startDate == null
                  ? 'Start Date'
                  : DateFormat('dd MMM yyyy').format(startDate!),
            ),
          ),
        ),
        const SizedBox(width: 12, height: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: () => _pickDate(false),
            child: Text(
              endDate == null
                  ? 'End Date'
                  : DateFormat('dd MMM yyyy').format(endDate!),
            ),
          ),
        ),
      ];
}

import 'dart:convert';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:http/http.dart' as http;

enum ExportType {
  json(label: "JSON"),
  dot(label: "DOT"),
  pdf(label: "PDF"),
  image(label: "Imagen");

  final String label;

  const ExportType({required this.label});
}

class ExportService {
  final bool _isWeb = kIsWeb;

  Future<void> exportJson(String json, String name) async {
    await FileSaver.instance.saveFile(
      name: '$name.json',
      mimeType: MimeType.json,
      bytes: Uint8List.fromList(utf8.encode(json)),
    );
  }

  Future<void> exportAsDot(String dot, String name) async {
    await FileSaver.instance.saveFile(
      name: '$name.dot',
      mimeType: MimeType.text,
      bytes: Uint8List.fromList(dot.codeUnits),
    );
  }

  Future<void> exportAsPDF(String dot, String name) async {
    final svg = await _downloadImage(dot);

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.letter,
        orientation: pw.PageOrientation.landscape,
        build: (context) {
          final svgImage = pw.SvgImage(
            svg: svg,
            fit: pw.BoxFit.contain,
            height: PdfPageFormat.letter.height,
            width: PdfPageFormat.letter.width,
          );
          return pw.Expanded(child: svgImage);
        },
      ),
    );

    await FileSaver.instance.saveFile(
      name: '$name.pdf',
      mimeType: MimeType.pdf,
      bytes: await pdf.save(),
    );
  }

  Future<void> exportAsImage(String dot, String name) async {
    final bytes = await _downloadImage(dot);

    await FileSaver.instance.saveFile(
      name: '$name.svg',
      mimeType: MimeType.other,
      bytes: Uint8List.fromList(bytes.codeUnits),
    );
  }

  Future<String> _downloadImage(String dot) async {
    final response = await http.get(
      Uri.parse(
        'https://quickchart.io/graphviz?graph=${Uri.encodeComponent(dot)}&format=svg&engine=dot',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load image');
    }

    return response.body;
  }
}

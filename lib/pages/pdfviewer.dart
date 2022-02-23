import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter/material.dart';
class PdfViewer1 extends StatefulWidget {
  String url;

  PdfViewer1({required this.url});

  @override
  _PdfViewer1State createState() => _PdfViewer1State();
}

class _PdfViewer1State extends State<PdfViewer1> {

  @override
  Widget build(BuildContext context) {
    print(widget.url);
    return Scaffold(
      appBar: AppBar(
        title: Text('Pdf'),
      ),
      body: Center(child: SfPdfViewer.network(widget.url)),
    );
  }
}

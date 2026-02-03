import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../models/order.dart';

class InvoiceService {
  static Future<void> generateInvoice(OrderModel order) async {
    final pdf = pw.Document();


    final fontData = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [


                pw.Text(
                  'INVOICE',
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),

                pw.SizedBox(height: 20),


                pw.Text('Order ID: ${order.orderId}',
                    style: pw.TextStyle(font: ttf, fontSize: 14)),
                pw.Text('Customer ID: ${order.customerId}',
                    style: pw.TextStyle(font: ttf, fontSize: 14)),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Total Amount: ₹ ${order.totalAmount.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),

                pw.SizedBox(height: 20),
                pw.Divider(),


                pw.Text(
                  'Products',
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),

                pw.SizedBox(height: 10),

                pw.Column(
                  children: order.items.map((item) {
                    final itemTotal = item.price * item.quantity;
                    return pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 4),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            '${item.name} x${item.quantity}',
                            style: pw.TextStyle(font: ttf, fontSize: 14),
                          ),
                          pw.Text(
                            '₹ ${itemTotal.toStringAsFixed(2)}',
                            style: pw.TextStyle(font: ttf, fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),

                pw.Divider(),
                pw.SizedBox(height: 12),


                pw.Text(
                  'Thank you for your purchase!',
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 14,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );


    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/invoice_${order.orderId}.pdf');
    await file.writeAsBytes(await pdf.save());


    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Invoice for Order ${order.orderId}',
    );
  }
}
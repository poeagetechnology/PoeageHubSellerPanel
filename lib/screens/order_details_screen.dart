import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/order.dart';
import '../providers/order_provider.dart';
import '../services/invoice_service.dart';

class OrderDetailsScreen extends ConsumerStatefulWidget {
  static const routeName = '/order-details';

  final OrderModel order;

  const OrderDetailsScreen({
    super.key,
    required this.order,
  });

  @override
  ConsumerState<OrderDetailsScreen> createState() =>
      _OrderDetailsScreenState();
}

class _OrderDetailsScreenState
    extends ConsumerState<OrderDetailsScreen> {
  late String selectedStatus;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.order.status;
  }

  Future<Map<String, String>> _fetchCustomerDetails() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.order.customerId)
        .get();

    if (!doc.exists) {
      return {
        'name': 'Unknown Customer',
        'address': 'Address not available',
      };
    }

    final data = doc.data()!;
    return {
      'name': data['name'] ?? 'Unnamed Customer',
      'address': data['address'] ?? 'Address not available',
    };
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    return Scaffold(
      appBar: AppBar(
        title: Text('Order ${order.orderId}'),
      ),
      body: FutureBuilder<Map<String, String>>(
        future: _fetchCustomerDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final customerName = snapshot.data?['name'] ?? 'Unknown';
          final customerAddress =
              snapshot.data?['address'] ?? 'Not available';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                _infoRow('Order ID', order.orderId),
                _infoRow('Seller ID', order.sellerId),
                _infoRow('Customer ID', order.customerId),
                _infoRow('Customer Name', customerName),
                _infoRow('Customer Address', customerAddress),
                _infoRow('Status', order.status.toUpperCase()),
                _infoRow(
                  'Total Amount',
                  '₹${order.totalAmount.toStringAsFixed(2)}',
                ),

                const SizedBox(height: 24),


                const Text(
                  'Items',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Divider(),

                if (order.items.isEmpty)
                  const Text('No items found')
                else
                  Column(
                    children: order.items.map((item) {
                      final subtotal =
                          item.price * item.quantity;

                      return Card(
                        margin:
                        const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 6),


                              Text(
                                'Product ID: ${item.productId}',
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey),
                              ),

                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      'Qty: ${item.quantity}'),
                                  Text(
                                      '₹${item.price.toStringAsFixed(2)}'),
                                ],
                              ),
                              const Divider(),
                              Align(
                                alignment:
                                Alignment.centerRight,
                                child: Text(
                                  'Subtotal: ₹${subtotal.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontWeight:
                                      FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                const SizedBox(height: 24),

                if (order.status != 'cancelled' &&
                    order.status != 'delivered') ...[
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Update Order Status',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'pending',
                          child: Text('Pending')),
                      DropdownMenuItem(
                          value: 'processing',
                          child: Text('Processing')),
                      DropdownMenuItem(
                          value: 'shipped',
                          child: Text('Shipped')),
                      DropdownMenuItem(
                          value: 'delivered',
                          child: Text('Delivered')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedStatus = value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isUpdating
                          ? null
                          : () async {
                        setState(() => isUpdating = true);

                        await ref
                            .read(orderServiceProvider)
                            .updateOrderStatus(
                          order.docId,
                          selectedStatus,
                        );

                        setState(() => isUpdating = false);

                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Order status updated'),
                          ),
                        );

                        Navigator.pop(context);
                      },
                      child: isUpdating
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child:
                        CircularProgressIndicator(
                            strokeWidth: 2),
                      )
                          : const Text('Update Status'),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],


                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon:
                    const Icon(Icons.picture_as_pdf),
                    label:
                    const Text('Generate Invoice'),
                    onPressed: () async {
                      await InvoiceService
                          .generateInvoice(order);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(
                  fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
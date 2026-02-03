import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as p;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../models/order.dart';
import '../services/invoice_service.dart';
import 'order_details_screen.dart';

//test update for github
class OrderManagementScreen extends ConsumerStatefulWidget {
  static const routeName = '/order-management';

  const OrderManagementScreen({super.key});

  @override
  ConsumerState<OrderManagementScreen> createState() =>
      _OrderManagementScreenState();
}

class _OrderManagementScreenState
    extends ConsumerState<OrderManagementScreen> {
  String statusFilter = 'all';
  String searchQuery = '';
  DateTimeRange? dateRange;
  int rowsPerPage = 10;

  @override
  Widget build(BuildContext context) {
    final sellerId =
        p.Provider.of<AuthProvider>(context, listen: false)
            .currentSeller!
            .id;

    final ordersAsync = ref.watch(ordersStreamProvider(sellerId));

    return Scaffold(
      appBar: AppBar(title: const Text('Order Management')),
      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                DropdownButton<String>(
                  value: statusFilter,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All')),
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(value: 'processing', child: Text('Processing')),
                    DropdownMenuItem(value: 'shipped', child: Text('Shipped')),
                    DropdownMenuItem(value: 'delivered', child: Text('Delivered')),
                    DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                  ],
                  onChanged: (v) => setState(() => statusFilter = v!),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search Order ID',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (v) => setState(() => searchQuery = v),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.date_range),
                  onPressed: () async {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => dateRange = picked);
                    }
                  },
                ),
              ],
            ),
          ),


          Expanded(
            child: ordersAsync.when(
              loading: () =>
              const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(e.toString())),
              data: (orders) {
                final filtered = orders.where((o) {
                  final statusOk =
                      statusFilter == 'all' || o.status == statusFilter;

                  final searchOk = o.orderId
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase());

                  final dateOk = dateRange == null ||
                      (!o.createdAt.isBefore(dateRange!.start) &&
                          !o.createdAt.isAfter(dateRange!.end));

                  return statusOk && searchOk && dateOk;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No orders found'));
                }

                return PaginatedDataTable(
                  rowsPerPage: rowsPerPage,
                  columns: const [
                    DataColumn(label: Text('Order ID')),
                    DataColumn(label: Text('Customer')),
                    DataColumn(label: Text('Amount')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Action')),
                  ],
                  source: _OrderDataSource(context, ref, filtered),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderDataSource extends DataTableSource {
  final BuildContext context;
  final WidgetRef ref;
  final List<OrderModel> orders;

  _OrderDataSource(this.context, this.ref, this.orders);

  static const List<String> orderStatuses = [
    'pending',
    'processing',
    'shipped',
    'delivered',
    'cancelled',
  ];


  Future<String> _getCustomerName(String customerId) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(customerId)
        .get();

    if (!doc.exists) return 'Unknown';
    return doc.data()?['name'] ?? 'Unknown';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  DataRow getRow(int index) {
    final o = orders[index];

    final bool isFinalState =
        o.status == 'delivered' || o.status == 'cancelled';

    return DataRow(cells: [
      DataCell(Text(o.orderId)),


      DataCell(
        FutureBuilder<String>(
          future: _getCustomerName(o.customerId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading...');
            }
            return Text(snapshot.data ?? 'Unknown');
          },
        ),
      ),

      DataCell(Text('₹${o.totalAmount.toStringAsFixed(2)}')),


      DataCell(
        Chip(
          label: Text(o.status.toUpperCase()),
          backgroundColor: _statusColor(o.status).withOpacity(0.15),
          labelStyle: TextStyle(color: _statusColor(o.status)),
        ),
      ),

      DataCell(Text(o.createdAt.toString().split(' ')[0])),


      DataCell(
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) async {
            if (value == 'details') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OrderDetailsScreen(order: o),
                ),
              );
            }

            if (value == 'status') {
              _showStatusDialog(context, ref, o);
            }

            if (value == 'invoice') {
              await InvoiceService.generateInvoice(o);
            }

            if (value == 'cancel') {
              await ref
                  .read(orderServiceProvider)
                  .cancelOrder(o.docId);
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'details',
              child: Text('View Details'),
            ),

            if (!isFinalState)
              const PopupMenuItem(
                value: 'status',
                child: Text('Update Status'),
              ),

            const PopupMenuItem(
              value: 'invoice',
              child: Text('Generate Invoice'),
            ),

            if (!isFinalState)
              const PopupMenuItem(
                value: 'cancel',
                child: Text('Cancel Order'),
              ),
          ],
        ),
      ),
    ]);
  }

  void _showStatusDialog(
      BuildContext context, WidgetRef ref, OrderModel order) {
    String newStatus = order.status;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Update Order Status'),
          content: DropdownButton<String>(
            value: newStatus,
            items: orderStatuses
                .map(
                  (s) => DropdownMenuItem(
                value: s,
                child: Text(s.toUpperCase()),
              ),
            )
                .toList(),
            onChanged: (v) => setState(() => newStatus = v!),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () async {
                await ref
                    .read(orderServiceProvider)
                    .updateOrderStatus(order.docId, newStatus);
                Navigator.pop(context);
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  int get rowCount => orders.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
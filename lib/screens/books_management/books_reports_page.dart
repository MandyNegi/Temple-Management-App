import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:temple/utils/colors.dart';
import 'package:temple/widget/empty_state.dart';

class BooksReportsPage extends StatefulWidget {
  const BooksReportsPage({Key? key}) : super(key: key);

  @override
  State<BooksReportsPage> createState() => _BooksReportsPageState();
}

class _BooksReportsPageState extends State<BooksReportsPage> {
  String? _selectedMonth;

  String _monthKey(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.mainColor,
        elevation: 0,
        title: const Text('Sales Reports', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload),
            onPressed: () async {
              try {
                // Future implementation hooks
              } catch (e) {
                Get.snackbar('Export failed', e.toString());
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView( // 🧠 Added to prevent overflow layouts when records multiply
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('book_sales').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snapshot.data?.docs ?? [];

              // aggregate layout mappings
              final Map<String, Map<String, dynamic>> booksByMonth = {};
              final Map<String, Map<String, dynamic>> giftsByMonth = {};
              final Map<String, Map<String, Map<String, dynamic>>> booksByDay = {};
              final Map<String, Map<String, Map<String, dynamic>>> giftsByDay = {};

              for (var d in docs) {
                final data = d.data() as Map<String, dynamic>;
                DateTime date;
                try {
                  date = DateTime.parse(data['saleDate']);
                } catch (e) {
                  date = DateTime.now();
                }
                final monthKey = _monthKey(date);
                final dayKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                final type = (data['itemType'] ?? 'book').toString();
                final qty = (data['quantitySold'] ?? 0) as int;
                final price = (data['totalPrice'] ?? 0).toDouble();

                final targetMonth = type == 'gift' ? giftsByMonth : booksByMonth;
                final entry = targetMonth.putIfAbsent(monthKey, () => {'count': 0, 'sum': 0.0});
                entry['count'] = entry['count'] + qty;
                entry['sum'] = entry['sum'] + price;

                final targetDayMap = type == 'gift' ? giftsByDay : booksByDay;
                final dayMap = targetDayMap.putIfAbsent(monthKey, () => {});
                final dayEntry = dayMap.putIfAbsent(dayKey, () => {'count': 0, 'sum': 0.0});
                dayEntry['count'] = dayEntry['count'] + qty;
                dayEntry['sum'] = dayEntry['sum'] + price;
              }

              final months = <String>{}..addAll(booksByMonth.keys)..addAll(giftsByMonth.keys);
              final monthList = months.toList()..sort((a, b) => b.compareTo(a));
              if (_selectedMonth == null && monthList.isNotEmpty) _selectedMonth = monthList.first;
              if (monthList.isEmpty) {
                return const EmptyState(message: 'There are no recorded sales to report.', icon: Icons.insert_chart);
              }

              Widget buildMonthSummary(String title, Map<String, Map<String, dynamic>> map) {
                final keys = map.keys.toList()..sort((a, b) => b.compareTo(a));
                if (keys.isEmpty) return const EmptyState(message: 'No data for this section');
                return Column(
                  children: keys.map((k) {
                    final v = map[k]!;
                    return ListTile(
                      title: Text('$title — $k'),
                      subtitle: Text('Items sold: ${v['count']}  •  Total ₹${(v['sum'] as double).toStringAsFixed(2)}'),
                    );
                  }).toList(),
                );
              }

              Widget buildDayDetails(String month, Map<String, Map<String, Map<String, dynamic>>> dayMap) {
                final map = dayMap[month] ?? {};
                final keys = map.keys.toList()..sort((a, b) => b.compareTo(a));
                if (keys.isEmpty) return const EmptyState(message: 'No day-wise data for this month');
                return Column(
                  children: keys.map((d) {
                    final v = map[d]!;
                    return ListTile(
                      title: Text(d),
                      subtitle: Text('Items sold: ${v['count']}  •  Total ₹${(v['sum'] as double).toStringAsFixed(2)}'),
                    );
                  }).toList(),
                );
              }

              return Column(
                mainAxisSize: MainAxisSize.min, 
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (monthList.isNotEmpty) ...[
                    const Text('Select Month', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: _selectedMonth,
                      items: monthList.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                      onChanged: (v) => setState(() => _selectedMonth = v),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Text('Books Monthly Summary', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  buildMonthSummary('Books', booksByMonth),
                  const SizedBox(height: 16),
                  Text('Gift Items Monthly Summary', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  buildMonthSummary('Gifts', giftsByMonth),
                  const SizedBox(height: 16),
                  if (_selectedMonth != null) ...[
                    Text('Day-wise Books for $_selectedMonth', style: Theme.of(context).textTheme.bodyLarge),
                    buildDayDetails(_selectedMonth!, booksByDay),
                    const SizedBox(height: 12),
                    Text('Day-wise Gifts for $_selectedMonth', style: Theme.of(context).textTheme.bodyLarge),
                    buildDayDetails(_selectedMonth!, giftsByDay),
                  ]
                ],
              );
            }, // Closes builder function
          ), // Closes StreamBuilder
        ), // Closes Padding
      ), // Closes SingleChildScrollView
    ); // Closes Scaffold
  } // Closes Widget build
} // Closes Class _BooksReportsPageState

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:temple/models/sewa_management/program_model.dart';
import 'package:temple/utils/colors.dart';
import 'package:temple/utils/async_utils.dart';
import 'package:temple/utils/constant.dart';
import 'package:temple/widget/empty_state.dart';

class SewaProgramsPage extends StatefulWidget {
  const SewaProgramsPage({Key? key}) : super(key: key);

  @override
  State<SewaProgramsPage> createState() => _SewaProgramsPageState();
}

class _SewaProgramsPageState extends State<SewaProgramsPage> {
  final CollectionReference _programs = FirebaseFirestore.instance.collection('sewa_programs');

  void _showAddDialog() {
    final title = TextEditingController();
    final leader = TextEditingController();
    final manager = TextEditingController();
    final location = TextEditingController();
    DateTime scheduledAt = DateTime.now();

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Create Program'),
        content: SingleChildScrollView(
          child: Column(children: [
            TextField(controller: title, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: leader, decoration: const InputDecoration(labelText: 'Leader')),
            TextField(controller: manager, decoration: const InputDecoration(labelText: 'Manager')),
            TextField(controller: location, decoration: const InputDecoration(labelText: 'Location')),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: scheduledAt,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (picked != null) scheduledAt = picked;
              },
              child: const Text('Pick Date'),
            )
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final prog = SewaProgramModel(
                title: title.text,
                leader: leader.text,
                manager: manager.text,
                location: location.text,
                scheduledAt: scheduledAt,
              );
              try {
                debugPrint('SewaPrograms: attempting Firestore write to collection "sewa_programs"');
                await runWithTimeout(
                  _programs.add(prog.toJson()),
                  timeout: const Duration(seconds: 10),
                );
                debugPrint('SewaPrograms: Firestore write succeeded');
                if (!context.mounted) return;
                Navigator.pop(context);
              } catch (error) {
                if (!context.mounted) return;
                debugPrint('SewaPrograms: save failed: $error');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Unable to save program: $error')),
                );
              }
            },
            child: const Text('Create'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 0,
        title: const Text("Sewa Programs", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot>(
          stream: _programs.orderBy('scheduledAt', descending: true).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final docs = snapshot.data!.docs;
            if (docs.isEmpty) return const EmptyState(message: 'Create a program to get started', icon: Icons.event);
            
            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final d = docs[index];
                final prog = SewaProgramModel.fromJson(d.data() as Map<String, dynamic>, d.id);
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    title: Text(prog.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Leader: ${prog.leader} • Manager: ${prog.manager}'),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.orange, size: 16),
                    onTap: () {
                      Get.toNamed('/sewa-program-details-page', arguments: {'id': prog.id, 'title': prog.title});
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: _showAddDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

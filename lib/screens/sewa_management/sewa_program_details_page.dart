import 'package:cloud_firestore/cloud_firestore.dart' hide Constant;
import 'package:flutter/material.dart';
import 'package:temple/utils/colors.dart';
import 'package:temple/utils/constant.dart';
import 'package:temple/widget/confirm_dialog.dart';
import 'package:temple/widget/empty_state.dart';

class SewaProgramDetailsPage extends StatefulWidget {
  final String programId;
  final String programTitle;

  const SewaProgramDetailsPage({Key? key, required this.programId, required this.programTitle}) : super(key: key);

  @override
  State<SewaProgramDetailsPage> createState() => _SewaProgramDetailsPageState();
}

class _SewaProgramDetailsPageState extends State<SewaProgramDetailsPage> {
  CollectionReference get volunteersRef =>
      FirebaseFirestore.instance.collection('sewa_programs').doc(widget.programId).collection('volunteers');

  CollectionReference get assignmentsRef =>
      FirebaseFirestore.instance.collection('sewa_programs').doc(widget.programId).collection('assignments');

  void _showAddVolunteer() {
    final name = TextEditingController();
    final dept = TextEditingController();
    final phone = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Volunteer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: dept, decoration: const InputDecoration(labelText: 'Department')),
            TextField(controller: phone, decoration: const InputDecoration(labelText: 'Phone')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              volunteersRef.add({'name': name.text, 'department': dept.text, 'phone': phone.text});
              Navigator.pop(context);
            },
            child: const Text('Add'),
          )
        ],
      ),
    );
  }

  Future<void> _showAssignDialog() async {
    final snap = await volunteersRef.get();
    final vols = snap.docs
        .map((d) => {'id': d.id, ...Map<String, dynamic>.from(d.data() as Map<String, dynamic>)})
        .toList();

    if (vols.isEmpty) {
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('No volunteers'),
          content: const Text('Add volunteers before assigning.'),
          actions: [
            ElevatedButton(onPressed: () => Navigator.pop(c), child: const Text('OK')),
          ],
        ),
      );
      return;
    }

    if (!mounted) return;
    String? selectedId = vols.first['id'] as String?;
    final role = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Assign Volunteer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: selectedId,
              items: vols
                  .map((v) => DropdownMenuItem(value: v['id'] as String?, child: Text(v['name'] ?? '')))
                  .toList(),
              onChanged: (v) => selectedId = v,
              decoration: const InputDecoration(labelText: 'Volunteer'),
            ),
            TextField(controller: role, decoration: const InputDecoration(labelText: 'Role')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(c, true), child: const Text('Assign')),
        ],
      ),
    );

    if (ok != true || selectedId == null) return;

    final volunteerDoc = vols.firstWhere((v) => v['id'] == selectedId, orElse: () => {});
    await assignmentsRef.add({
      'volunteerId': selectedId,
      'volunteerName': volunteerDoc['name'] ?? '',
      'role': role.text,
      'assignedAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Constant.appBar(widget.programTitle),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Volunteers', style: Theme.of(context).textTheme.titleLarge),
                ElevatedButton.icon(
                  onPressed: _showAssignDialog,
                  icon: const Icon(Icons.assignment_ind),
                  label: const Text('Assign'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: volunteersRef.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) return const EmptyState(message: 'No volunteers yet', icon: Icons.group);
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final d = docs[index];
                      final data = d.data() as Map<String, dynamic>;
                      return ListTile(
                        title: Text(data['name'] ?? ''),
                        subtitle: Text('${data['department'] ?? ''} • ${data['phone'] ?? ''}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final ok = await showConfirmDialog(
                              context,
                              title: 'Delete Volunteer',
                              content: 'Remove ${data['name']}?',
                            );
                            if (ok == true) await volunteersRef.doc(d.id).delete();
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Assignments', style: Theme.of(context).textTheme.titleLarge),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: assignmentsRef.orderBy('assignedAt', descending: true).snapshots(),
                builder: (context, snap) {
                  if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                  final adocs = snap.data!.docs;
                  if (adocs.isEmpty) return const EmptyState(message: 'No assignments yet', icon: Icons.assignment);
                  return ListView.builder(
                    itemCount: adocs.length,
                    itemBuilder: (context, i) {
                      final a = adocs[i];
                      final d = a.data() as Map<String, dynamic>;
                      return ListTile(
                        title: Text(d['volunteerName'] ?? ''),
                        subtitle: Text('${d['role'] ?? ''} • ${d['assignedAt'] ?? ''}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_forever, color: Colors.red),
                          onPressed: () async {
                            final ok = await showConfirmDialog(
                              context,
                              title: 'Remove Assignment',
                              content: 'Remove assignment for ${d['volunteerName']}?',
                            );
                            if (ok == true) await assignmentsRef.doc(a.id).delete();
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.mainColor,
        onPressed: _showAddVolunteer,
        child: const Icon(Icons.person_add),
      ),
    );
  }
}

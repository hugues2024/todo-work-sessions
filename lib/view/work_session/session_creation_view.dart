// lib/view/work_session/session_creation_view.dart

import 'package:flutter/material.dart';
import '../../models/work_session.dart';
import '../../utils/colors.dart';
import '../../main.dart';

class SessionCreationView extends StatefulWidget {
  final WorkSession? session; // If provided, we are editing

  const SessionCreationView({super.key, this.session});

  @override
  State<SessionCreationView> createState() => _SessionCreationViewState();
}

class _SessionCreationViewState extends State<SessionCreationView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  int _workMinutes = 25;
  int _breakMinutes = 5;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.session?.title ?? "");
    _descController = TextEditingController(text: widget.session?.description ?? "");
    _workMinutes = widget.session?.workDurationMinutes ?? 25;
    _breakMinutes = widget.session?.breakDurationMinutes ?? 5;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final dataStore = BaseWidget.of(context).dataStore;
      
      if (widget.session != null) {
        // Edit existing
        widget.session!.title = _titleController.text;
        widget.session!.description = _descController.text;
        widget.session!.workDurationMinutes = _workMinutes;
        widget.session!.breakDurationMinutes = _breakMinutes;
        await widget.session!.save();
      } else {
        // Create new
        final newSession = WorkSession.create(
          title: _titleController.text,
          description: _descController.text,
          workDurationMinutes: _workMinutes,
          breakDurationMinutes: _breakMinutes,
        );
        await dataStore.addSession(session: newSession);
      }
      
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.session != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Session" : "New Focus Session"),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Session Name",
                  hintText: "e.g., Deep Work, Study, Coding",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 32),
              
              Text("Durations", style: Theme.of(context).textTheme.titleMedium),
              const Divider(),
              
              _buildDurationPicker(
                label: "Work Duration",
                value: _workMinutes,
                onChanged: (v) => setState(() => _workMinutes = v),
                color: MyColors.primaryColor,
              ),
              
              const SizedBox(height: 16),
              
              _buildDurationPicker(
                label: "Break Duration",
                value: _breakMinutes,
                onChanged: (v) => setState(() => _breakMinutes = v),
                color: Colors.green,
              ),
              
              const SizedBox(height: 48),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColors.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(isEdit ? "Update Session" : "Create Session", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDurationPicker({required String label, required int value, required ValueChanged<int> onChanged, required Color color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text("$value minutes", style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(
          value: value.toDouble(),
          min: 1,
          max: 120,
          activeColor: color,
          onChanged: (v) => onChanged(v.toInt()),
        ),
      ],
    );
  }
}

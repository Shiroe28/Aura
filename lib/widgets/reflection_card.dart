import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class ReflectionCard extends StatefulWidget {
  final String title;
  final String hint;
  final String? initialValue;
  final Function(String) onSave;

  const ReflectionCard({
    super.key,
    required this.title,
    required this.hint,
    this.initialValue,
    required this.onSave,
  });

  @override
  State<ReflectionCard> createState() => _ReflectionCardState();
}

class _ReflectionCardState extends State<ReflectionCard> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    widget.onSave(_controller.text.trim());
    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (_isEditing)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _controller.text = widget.initialValue ?? '';
                            _isEditing = false;
                          });
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: _save,
                        child: const Text('Save'),
                      ),
                    ],
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () {
                      setState(() {
                        _isEditing = true;
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (_isEditing)
              TextField(
                controller: _controller,
                maxLines: 3,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: widget.hint,
                  border: const OutlineInputBorder(),
                ),
              )
            else
              Text(
                _controller.text.isEmpty ? widget.hint : _controller.text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _controller.text.isEmpty
                          ? AppTheme.sage
                          : AppTheme.stoneGrey,
                      fontStyle: _controller.text.isEmpty
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/journal_provider.dart';
import '../../utils/app_theme.dart';

class JournalEditorScreen extends StatefulWidget {
  final String? entryId;

  const JournalEditorScreen({super.key, this.entryId});

  @override
  State<JournalEditorScreen> createState() => _JournalEditorScreenState();
}

class _JournalEditorScreenState extends State<JournalEditorScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagController = TextEditingController();
  final List<String> _tags = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.entryId != null) {
      _loadEntry();
    }
  }

  void _loadEntry() {
    final journalProvider = Provider.of<JournalProvider>(context, listen: false);
    final entry = journalProvider.entries.firstWhere(
      (e) => e.id == widget.entryId,
    );
    
    _titleController.text = entry.title;
    _contentController.text = entry.content;
    if (entry.tags != null) {
      _tags.addAll(entry.tags!);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _saveEntry() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a title')),
      );
      return;
    }

    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add some content')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final journalProvider = Provider.of<JournalProvider>(context, listen: false);
      
      if (widget.entryId != null) {
        await journalProvider.updateEntry(
          entryId: widget.entryId!,
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          tags: _tags.isNotEmpty ? _tags : null,
        );
      } else {
        await journalProvider.createEntry(
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          tags: _tags.isNotEmpty ? _tags : null,
        );
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _addTag() {
    if (_tagController.text.trim().isNotEmpty) {
      setState(() {
        _tags.add(_tagController.text.trim());
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: AppTheme.stoneGrey),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton.icon(
              onPressed: _saveEntry,
              icon: const Icon(Icons.check),
              label: const Text('Save'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.softBlue,
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title input
            TextField(
              controller: _titleController,
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    color: AppTheme.stoneGrey,
                    fontWeight: FontWeight.bold,
                  ),
              decoration: InputDecoration(
                hintText: 'Entry Title',
                hintStyle: TextStyle(
                  color: AppTheme.sage.withOpacity(0.5),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            
            const SizedBox(height: 8),
            
            // Date display
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: AppTheme.sage,
                ),
                const SizedBox(width: 6),
                Text(
                  DateTime.now().toString().split(' ')[0],
                  style: TextStyle(
                    color: AppTheme.sage,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            const Divider(),
            
            const SizedBox(height: 24),
            
            // Content input
            TextField(
              controller: _contentController,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: AppTheme.stoneGrey,
                    height: 1.6,
                  ),
              decoration: InputDecoration(
                hintText: 'Start writing your thoughts...',
                hintStyle: TextStyle(
                  color: AppTheme.sage.withOpacity(0.5),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
            
            const SizedBox(height: 32),
            
            // Tags section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.calmSand.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.label_outline,
                        size: 18,
                        color: AppTheme.softBlue,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tags',
                        style: TextStyle(
                          color: AppTheme.stoneGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Display tags
                  if (_tags.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _tags.map<Widget>((tag) {
                        return Chip(
                          label: Text('#$tag'),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () => _removeTag(tag),
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color: AppTheme.forestGreen,
                            fontWeight: FontWeight.w500,
                          ),
                          side: BorderSide(
                            color: AppTheme.sage.withOpacity(0.3),
                          ),
                        );
                      }).toList(),
                    ),
                  
                  const SizedBox(height: 12),
                  
                  // Add tag input
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _tagController,
                          decoration: InputDecoration(
                            hintText: 'Add a tag...',
                            hintStyle: TextStyle(
                              color: AppTheme.sage,
                              fontSize: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppTheme.sage.withOpacity(0.3),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppTheme.sage.withOpacity(0.3),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppTheme.softBlue,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          onSubmitted: (_) => _addTag(),
                          textCapitalization: TextCapitalization.words,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _addTag,
                        icon: Icon(Icons.add_circle, color: AppTheme.softBlue),
                        iconSize: 32,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/journal_provider.dart';
import '../../utils/app_theme.dart';
import 'journal_editor_screen.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<JournalProvider>(context, listen: false).loadEntries();
    });
  }

  void _navigateToEditor({String? entryId}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JournalEditorScreen(entryId: entryId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final journalProvider = Provider.of<JournalProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.calmSand,
      appBar: AppBar(
        title: const Text('Journal'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => journalProvider.loadEntries(),
        child: journalProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : journalProvider.entries.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: journalProvider.entries.length,
                    itemBuilder: (context, index) {
                      final entry = journalProvider.entries[index];
                      return _buildJournalCard(entry);
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToEditor(),
        icon: const Icon(Icons.add),
        label: const Text('New Entry'),
        backgroundColor: AppTheme.softBlue,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.book_outlined,
                size: 64,
                color: AppTheme.softBlue.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Start Your Journey',
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    color: AppTheme.stoneGrey,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Capture your thoughts, reflections,\nand memories in your personal journal',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: AppTheme.sage,
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _navigateToEditor(),
              icon: const Icon(Icons.edit),
              label: const Text('Write First Entry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.softBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJournalCard(entry) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('h:mm a');
    
    return GestureDetector(
      onTap: () => _navigateToEditor(entryId: entry.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with date and actions
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.softBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: AppTheme.softBlue,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          dateFormat.format(entry.createdAt),
                          style: TextStyle(
                            color: AppTheme.softBlue,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.more_vert,
                      color: AppTheme.sage,
                    ),
                    onPressed: () => _showOptionsMenu(entry),
                  ),
                ],
              ),
            ),
            
            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Text(
                entry.title,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: AppTheme.stoneGrey,
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            // Content preview
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Text(
                entry.content,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: AppTheme.sage,
                      height: 1.5,
                    ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            // Tags and time
            if (entry.tags != null && entry.tags!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: entry.tags!.take(3).map<Widget>((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.calmSand,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppTheme.sage.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        '#$tag',
                        style: TextStyle(
                          color: AppTheme.forestGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            
            // Footer with time
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.calmSand.withOpacity(0.5),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: AppTheme.sage,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    timeFormat.format(entry.createdAt),
                    style: TextStyle(
                      color: AppTheme.sage,
                      fontSize: 12,
                    ),
                  ),
                  if (entry.updatedAt.difference(entry.createdAt).inMinutes > 1) ...[
                    const SizedBox(width: 12),
                    Text(
                      '• Edited',
                      style: TextStyle(
                        color: AppTheme.sage,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsMenu(entry) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.sage.withOpacity(0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.edit, color: AppTheme.softBlue),
              title: const Text('Edit Entry'),
              onTap: () {
                Navigator.pop(context);
                _navigateToEditor(entryId: entry.id);
              },
            ),
            ListTile(
              leading: Icon(Icons.share, color: AppTheme.softBlue),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                // Implement share functionality
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Entry', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(entry);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this journal entry? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<JournalProvider>(context, listen: false)
                  .deleteEntry(entry.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

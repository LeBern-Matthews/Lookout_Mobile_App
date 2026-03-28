import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/checklist_provider.dart';
import '../components/appbar.dart';

class EssentialChecklistPage extends StatelessWidget {
  const EssentialChecklistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final checklist = context.watch<ChecklistProvider>();
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: CustomAppBar(title: "Essential Checklist"),
      body: Column(
        children: [
          // ── Progress header ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${checklist.checkedCount} of ${checklist.totalCount} complete",
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${(checklist.progress * 100).toInt()}%",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: checklist.colour,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: checklist.progress,
                    minHeight: 10,
                    backgroundColor: onSurface.withValues(alpha:  0.12),
                    valueColor: AlwaysStoppedAnimation(checklist.colour),
                  ),
                ),
              ],
            ),
          ),

          // ── Checklist ───────────────────────────────────────────────
          Expanded(
            child: !checklist.isLoaded
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: checklist.items.length,
                    itemBuilder: (context, index) {
                      final checked = checklist.isChecked[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 5.0),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          title: Text(
                            checklist.items[index],
                            style: TextStyle(
                              decoration: checked
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: checked
                                  ? onSurface.withValues(alpha: 0.4)
                                  : onSurface,
                            ),
                          ),
                          selected: checked,
                          trailing: Icon(
                            checked
                                ? Icons.check_box_rounded
                                : Icons.check_box_outline_blank_rounded,
                            color: checked ? checklist.colour : null,
                          ),
                          onTap: () =>
                              context.read<ChecklistProvider>().toggleItem(index),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
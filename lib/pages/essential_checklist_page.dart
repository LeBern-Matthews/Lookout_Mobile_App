import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/progress_provider.dart';

import 'package:flutter/services.dart' show rootBundle;

class EssentialChecklistPage extends StatefulWidget {
  const EssentialChecklistPage({super.key});

  @override
  State<EssentialChecklistPage> createState() => _EssentialChecklistPageState();
}

class _EssentialChecklistPageState extends State<EssentialChecklistPage>
    with AutomaticKeepAliveClientMixin {
  final List<String> _items = []; // List to store items from the text file
  final List<bool> _isChecked = []; // List to track checked states
  double progress = 0.0; // Progress value

  @override
  bool get wantKeepAlive => true; // Preserve state

  @override
  void initState() {
    super.initState();
    _loadItemsFromFile();
  }

  Future<void> _loadItemsFromFile() async {
    
    final String fileContent = await rootBundle.loadString('lib/assets/emergencyinfo.txt');
    final List<String> lines = fileContent.split('\n').map((line) => line.trim()).toList();

    setState(() {
      _items.addAll(lines);
      _isChecked.addAll(List.generate(lines.length, (index) => false));
    });
  }

  void __fillProgressBar() {
    setState(() {
      // Calculate progress based on the number of checked items
      final int checkedCount = _isChecked.where((isChecked) => isChecked).length;
      progress = _items.isNotEmpty ? checkedCount / _items.length : 0.0;
      Provider.of<ProgressProvider>(context, listen: false).setProgress(progress);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Essential Checklist"),
        centerTitle: false,
        backgroundColor:Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          // Progress indicator at the top
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              "${(progress * 100).toInt()}% Complete",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          // Expanded ListView for the checklist items
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(_items[index]),
                  leading: Icon(
                    _isChecked[index]
                        ? Icons.check_box_rounded
                        : Icons.check_box_outline_blank_rounded,
                  ),
                  onTap: () {
                    setState(() {
                      _isChecked[index] = !_isChecked[index];
                    });
                    __fillProgressBar();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
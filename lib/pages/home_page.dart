import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/progress_provider.dart';
//import 'package:test_project/essential_checklist_page.dart' as essential_checklist_page;
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Preserve state  

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final progress = context.watch<ProgressProvider>().progress;
    final currentColour=context.watch<ProgressProvider>().colour;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
        centerTitle: false,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          SizedBox(height: 60,),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
            //color: Colors.blue[100],
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: Colors.grey[300],
                  color: currentColour,
                ),
                const SizedBox(height: 20),
                Text(
                  "${(progress * 100).toInt()}% Complete", // Display progress percentage
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 100),
                const Text("Map",style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                Divider(
                  color: const Color.fromARGB(255, 188, 177, 177),
                  thickness: 1,
                ),
                
              ],
            ),
          ),
        ],
      ),
    );
  }
}
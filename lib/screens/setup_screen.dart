
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ahp_provider.dart';
import 'comparison_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final TextEditingController _critController = TextEditingController();
  final TextEditingController _altController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Default URL hook
    _urlController.text = "http://localhost:5000"; // Default
    // TODO: Fetch Gist logic can be triggered here or manually
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AhpProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Agro-AHP Pro Setup")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // API Config Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    const Text("Konfigurasi Server", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _urlController,
                      decoration: const InputDecoration(
                        labelText: "API Base URL (Python/Ngrok)",
                        border: OutlineInputBorder(),
                        hintText: "https://xxxx.ngrok-free.app"
                      ),
                      onChanged: (val) {
                          provider.setBaseUrl(val);
                      },
                    ),
                    TextButton(
                        onPressed: () {
                           provider.fetchConfig(); // Dummy call placeholder
                           ScaffoldMessenger.of(context).showSnackBar(
                               const SnackBar(content: Text("Gist Fetch Triggered (Mock)"))
                           );
                        },
                        child: const Text("Load from Gist")
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Criteria Section
            const Text("1. Kriteria (Minimal 4)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(child: TextField(controller: _critController, decoration: const InputDecoration(hintText: "Nama Kriteria"))),
                IconButton(icon: const Icon(Icons.add_circle, color: Colors.green), onPressed: () {
                  if (_critController.text.isNotEmpty) {
                    provider.addCriterion(_critController.text);
                    _critController.clear();
                  }
                }),
              ],
            ),
            Wrap(
              spacing: 8,
              children: provider.criteria.map((c) => Chip(
                label: Text(c),
                onDeleted: () => provider.removeCriterion(c),
              )).toList(),
            ),
            
            const SizedBox(height: 20),
            
            // Alternatives Section
            const Text("2. Alternatif Mesin", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(child: TextField(controller: _altController, decoration: const InputDecoration(hintText: "Nama Mesin/Alternatif"))),
                IconButton(icon: const Icon(Icons.add_circle, color: Colors.blue), onPressed: () {
                   if (_altController.text.isNotEmpty) {
                    provider.addAlternative(_altController.text);
                    _altController.clear();
                  }
                }),
              ],
            ),
             Wrap(
              spacing: 8,
              children: provider.alternatives.map((a) => Chip(
                label: Text(a),
                onDeleted: () => provider.removeAlternative(a),
                backgroundColor: Colors.blue.shade100,
              )).toList(),
            ),
            
            const SizedBox(height: 30),
            
            // Proceed Button
            ElevatedButton(
              onPressed: () {
                  provider.setBaseUrl(_urlController.text);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ComparisonScreen()));
              },
              child: const Text("Lanjut ke Perbandingan (AHP Analysis)"),
            )
          ],
        ),
      ),
    );
  }
}

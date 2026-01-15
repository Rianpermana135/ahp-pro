
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/ahp_provider.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AhpProvider>(context);
    final result = provider.result;

    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Hasil Analisis")),
        body: const Center(child: Text("Belum ada data hasil.")),
      );
    }

    final ranking = result['final_ranking'] as List;
    // Format: [{"name": "...", "score": 0.xx, "rank": 1}, ...]

    return Scaffold(
      appBar: AppBar(title: const Text("Hasil Rekomendasi")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Prioritas Pemeliharaan Mesin", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            
            // Chart Section
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 1.0, // Score is 0-1
                  barGroups: ranking.asMap().entries.map((entry) {
                    int idx = entry.key;
                    var item = entry.value;
                    return BarChartGroupData(
                      x: idx,
                      barRods: [
                        BarChartRodData(
                          toY: (item['score'] as num).toDouble(),
                          color: idx == 0 ? Colors.red : Colors.green, // Top 1 is highlighted
                          width: 20,
                          borderRadius: BorderRadius.circular(4),
                        )
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < ranking.length) {
                             // Show first 3 chars of name
                             return Padding(
                               padding: const EdgeInsets.only(top: 8),
                               child: Text(ranking[index]['name'].toString().substring(0, 3)),
                             );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),

            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 10),

            // List Details
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: ranking.length,
              itemBuilder: (context, index) {
                var item = ranking[index];
                return Card(
                  color: index == 0 ? Colors.red.shade50 : Colors.white,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: index == 0 ? Colors.red : Colors.green,
                      child: Text("#${item['rank']}", style: const TextStyle(color: Colors.white)),
                    ),
                    title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Text(
                      "${((item['score'] as num) * 100).toStringAsFixed(1)}%",
                       style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text("Mulai Ulang")
            )
          ],
        ),
      ),
    );
  }
}

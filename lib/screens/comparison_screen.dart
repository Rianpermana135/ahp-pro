
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ahp_provider.dart';
import '../widgets/comparison_slider.dart';
import 'result_screen.dart';

class ComparisonScreen extends StatefulWidget {
  const ComparisonScreen({super.key});

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {
  int _currentStep = 0; // 0 = Goal (Criteria comparisons), 1...N = Alt comparisons for each Criteria

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AhpProvider>(context);
    final totalSteps = 1 + provider.criteria.length; // 1 for Criteria, n for each criterion's alternatives

    // Determine what we are comparing
    String title = "";
    List<String> items = [];
    Function(int i, int j, double val) onUpdate;
    Function(int i, int j) getValue;

    if (_currentStep == 0) {
      title = "Perbandingan Antar Kriteria";
      items = provider.criteria;
      onUpdate = (i, j, val) {
        // Convert scale -9..9 to Saaty 1/9..9
        // If val < 0 (Left/i is stronger): Value = |val|.
        // If val > 0 (Right/j is stronger): Value = 1/|val|.
        // If val == 0: Value = 1.
        
        double saatyVal = 1.0;
        if (val < 0) {
             saatyVal = val.abs();
        } else if (val > 0) {
             saatyVal = 1.0 / val.abs();
        }
        
        provider.updateCriteriaComparison(i, j, saatyVal);
      };
      
      getValue = (i, j) {
          // Reverse logic: Retrieve Saaty value and convert to slider -9..9
          double? saaty = provider.criteriaComparisons["$i-$j"];
          if (saaty == null) return 0; // Default 0 (Center)
          
          if (saaty >= 1) {
              return -saaty; // Left is stronger (stored as >1) -> Slider negative
          } else {
              return (1.0/saaty); // Right is stronger (stored as <1) -> Slider positive
          }
      };
      
    } else {
      String criterionName = provider.criteria[_currentStep - 1];
      title = "Perbandingan Alternatif utk: $criterionName";
      items = provider.alternatives;
      
      onUpdate = (i, j, val) {
         double saatyVal = 1.0;
        if (val < 0) {
             saatyVal = val.abs();
        } else if (val > 0) {
             saatyVal = 1.0 / val.abs();
        }
        provider.updateAlternativeComparison(criterionName, i, j, saatyVal);
      };
      
      getValue = (i, j) {
           double? saaty = provider.alternativeComparisons[criterionName]?["$i-$j"];
           if (saaty == null) return 0;
           if (saaty >= 1) return -saaty;
           else return (1.0/saaty);
      };
    }

    // Generate pairs
    List<Widget> sliders = [];
    for (int i = 0; i < items.length; i++) {
        for (int j = i + 1; j < items.length; j++) {
            sliders.add(ComparisonSlider(
                labelLeft: items[i],
                labelRight: items[j],
                value: getValue(i, j).toDouble(),
                onChanged: (val) {
                    onUpdate(i, j, val);
                    setState(() {});
                }
            ));
        }
    }

    return Scaffold(
      appBar: AppBar(title: Text("Tahap ${_currentStep + 1} / $totalSteps")),
      body: Column(
        children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Expanded(
                child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: sliders,
                )
            ),
            Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                        if (_currentStep > 0)
                            ElevatedButton(onPressed: () => setState(() => _currentStep--), child: const Text("Kembali")),
                        const SizedBox(width: 10),
                        ElevatedButton(
                            onPressed: () {
                                if (_currentStep < totalSteps - 1) {
                                    setState(() => _currentStep++);
                                } else {
                                    // Finish
                                    provider.calculate().then((success) {
                                        if (success) {
                                             Navigator.push(context, MaterialPageRoute(builder: (_) => const ResultScreen()));
                                        } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text(provider.errorMessage ?? "Error"))
                                            );
                                        }
                                    });
                                }
                            },
                            child: Text(_currentStep < totalSteps - 1 ? "Lanjut" : "Hitung & Lihat Hasil")
                        )
                    ],
                )
            )
        ],
      ),
    );
  }
}

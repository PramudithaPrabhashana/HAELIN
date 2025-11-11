import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DiagnosisScreen extends StatefulWidget {
  const DiagnosisScreen({super.key});

  @override
  State<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen> {
  String selectedDisease = 'Dengue';
  bool isLoading = false;
  String? diagnosisResult;
  Color? resultColor;
  String? guideMessage;

  // ✅ Replace this with your actual FastAPI backend URL
  final String baseUrl = "http://localhost:8001/haelin-app";

  // Dengue symptoms
  Map<String, bool> dengueSymptoms = {
    'Fever': false,
    'Headache': false,
    'JointPain': false,
    'Bleeding': false,
  };

  // Chikungunya symptoms
  Map<String, bool> chikSymptoms = {
    'sex': false,
    'fever': false,
    'cold': false,
    'joint_pains': false,
    'myalgia': false,
    'headache': false,
    'fatigue': false,
    'vomitting': false,
    'arthritis': false,
    'Conjuctivitis': false,
    'Nausea': false,
    'Maculopapular_rash': false,
    'Eye_Pain': false,
    'Chills': false,
    'Swelling': false,
  };

  Map<String, bool> get currentSymptoms =>
      selectedDisease == "Dengue" ? dengueSymptoms : chikSymptoms;

  Future<void> diagnose() async {
    setState(() {
      isLoading = true;
      diagnosisResult = null;
    });

    try {
      final endpoint = selectedDisease == "Dengue"
          ? "$baseUrl/predict_dengue"
          : "$baseUrl/predict_chikun";

      final selectedSymptoms = currentSymptoms.map((key, value) =>
          MapEntry(key, value ? 1 : 0)); // convert bools to 0/1 for backend

      final response = await http.post(
        Uri.parse(endpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(selectedSymptoms),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prediction = data['prediction'];

        setState(() {
          if (prediction == 1) {
            diagnosisResult = "⚠️ You may be infected with $selectedDisease";
            resultColor = Colors.redAccent;
            guideMessage =
                "Please consult a doctor immediately and stay hydrated. Avoid self-medication.";
          } else {
            diagnosisResult =
                "✅ You are not likely infected with $selectedDisease";
            resultColor = Colors.green;
            guideMessage =
                "Maintain good hygiene and rest well. Monitor symptoms and seek help if they worsen.";
          }
        });
      } else {
        setState(() {
          diagnosisResult = "❌ Server error: ${response.statusCode}";
          resultColor = Colors.grey;
        });
      }
    } catch (e) {
      setState(() {
        diagnosisResult = "⚠️ Connection failed. Check your backend.";
        resultColor = Colors.orange;
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget symptomTile(String label, bool value, void Function(bool) onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          color: value ? Colors.blueAccent : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blueAccent),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: value ? Colors.white : Colors.black87,
                ),
              ),
            ),
            Icon(
              value ? Icons.check_circle : Icons.circle_outlined,
              color: value ? Colors.white : Colors.black45,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final symptoms = currentSymptoms;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FC),
      appBar: AppBar(
        title: const Text("Diagnosis Tool"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_hospital, color: Colors.blueAccent),
                const SizedBox(width: 10),
                Text(
                  "Health Diagnosis",
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.blueAccent.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Disease Dropdown
            DropdownButtonFormField<String>(
              value: selectedDisease,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.blue.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              dropdownColor: Colors.white,
              items: const [
                DropdownMenuItem(value: "Dengue", child: Text("Dengue")),
                DropdownMenuItem(
                    value: "Chikungunya", child: Text("Chikungunya")),
              ],
              onChanged: (value) => setState(() => selectedDisease = value!),
            ),

            const SizedBox(height: 25),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Select your symptoms",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.blueAccent.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Symptoms list
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: symptoms.entries.map((entry) {
                  return symptomTile(entry.key, entry.value, (v) {
                    setState(() => symptoms[entry.key] = v);
                  });
                }).toList(),
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: isLoading ? null : diagnose,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Submit",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
            ),

            const SizedBox(height: 25),

            if (diagnosisResult != null)
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: resultColor?.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: resultColor ?? Colors.grey, width: 2),
                ),
                child: Column(
                  children: [
                    Text(
                      diagnosisResult!,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: resultColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      guideMessage ?? "",
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

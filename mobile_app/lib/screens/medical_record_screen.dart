import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class MedicalHistoryScreen extends StatefulWidget {
  const MedicalHistoryScreen({super.key});

  @override
  State<MedicalHistoryScreen> createState() => _MedicalHistoryScreenState();
}

class _MedicalHistoryScreenState extends State<MedicalHistoryScreen> {
  final String baseUrl = "http://localhost:8080/haelin-app/medrec";
  bool isLoading = true;
  List<dynamic> records = [];

  @override
  void initState() {
    super.initState();
    fetchRecords();
  }

  Future<void> fetchRecords() async {
    setState(() => isLoading = true);
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          records = [];
          isLoading = false;
        });
        return;
      }

      String? idToken = await user.getIdToken();
      final response = await http.get(
        Uri.parse("$baseUrl/user"),
        headers: {"Authorization": "Bearer $idToken"},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          records = data;
        });
      } else {
        print("Failed to fetch records: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching records: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteRecord(String medID) async {
    try {
      final response = await http.delete(Uri.parse("$baseUrl/delete/$medID"));
      if (response.statusCode == 200) {
        setState(() {
          records.removeWhere((record) => record['medID'] == medID);
        });
      } else {
        print("Failed to delete record: ${response.statusCode}");
      }
    } catch (e) {
      print("Error deleting record: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Medical History"),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : records.isEmpty
              ? const Center(child: Text("No medical records found."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    final diagnosis = record['diagnosis'] ?? '';
                    final risk = record['riskStatus'] ?? '';
                    final date = record['date'] ?? '';
                    final medID = record['medID'] ?? '';
                    final symptoms = record['symptoms'] ?? {};

                    final bool isPositive =
                        diagnosis.toLowerCase() != "negative" &&
                        diagnosis.toLowerCase() != "none";

                    return Card(
                      color: isPositive
                          ? Colors.redAccent.withOpacity(0.3)
                          : Colors.greenAccent.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "ID: $medID",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  date,
                                  style: const TextStyle(color: Colors.black54),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Diagnosis: $diagnosis",
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Risk Status: $risk",
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Symptoms: ${symptoms.entries.map((e) => "${e.key}:${e.value}").join(", ")}",
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                ),
                                onPressed: () => deleteRecord(medID),
                                child: const Text("Delete"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

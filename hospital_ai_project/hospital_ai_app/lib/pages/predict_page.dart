import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class PredictPage extends StatefulWidget {
  const PredictPage({super.key});

  @override
  State<PredictPage> createState() => _PredictPageState();
}

class _PredictPageState extends State<PredictPage> {
  final _formKey = GlobalKey<FormState>();

  // Girdi değişkenleri
  final TextEditingController week = TextEditingController();
  final TextEditingController month = TextEditingController();
  final TextEditingController availableBeds = TextEditingController();
  final TextEditingController patientsRequest = TextEditingController();
  // ⛔️ REMOVED: final TextEditingController patientsAdmitted = TextEditingController();
  final TextEditingController patientsRefused = TextEditingController();
  final TextEditingController patientSatisfaction = TextEditingController();
  final TextEditingController staffMorale = TextEditingController();

  // ✅ ADDED: State for categorical dropdowns
  String? _selectedService;
  String? _selectedEvent;

  // ✅ ADDED: Options for your dropdowns
  // ⚠️ IMPORTANT: Change these to match your model's training data
  final List<String> _serviceOptions = [
    "emergency",
    "surgery",
    "general_medicine",
    "ICU",
  ];
  final List<String> _eventOptions = ["none", "flu", "donation", "strike"];

  double? prediction;
  bool isLoading = false;

  Future<void> getPrediction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => isLoading = true);

    try {
      // ✅ FIXED: All keys are now snake_case and match your Python DataFrame
      final Map<String, dynamic> data = {
        "week": int.parse(week.text),
        "month": int.parse(month.text),
        "available_beds": double.parse(availableBeds.text),
        "patients_request": double.parse(patientsRequest.text),
        // ⛔️ REMOVED: "patients_admitted"
        "patients_refused": double.parse(patientsRefused.text),
        "patient_satisfaction": double.parse(patientSatisfaction.text),
        "staff_morale": double.parse(staffMorale.text),
        // ✅ ADDED: New categorical data
        "service": _selectedService,
        "event": _selectedEvent,
      };

      final response = await http.post(
        Uri.parse(
          "https://nonimplicative-maudie-nondeclaratory.ngrok-free.dev/predict",
        ),
        headers: {"Content-Type": "application/json; charset=UTF-8"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        setState(() {
          prediction = result["predicted_occupancy"];
        });
      } else {
        throw Exception(
          "Server error (Code ${response.statusCode}): ${response.body}",
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Hata: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🏥 Hospital AI Predictor")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(week, "Hafta (1-52)"),
              _buildTextField(month, "Ay (1-12)"),

              // ✅ ADDED: Dropdown for "service"
              _buildDropdown(_serviceOptions, "Servis Seçin", (value) {
                setState(() => _selectedService = value);
              }),

              _buildTextField(availableBeds, "Boş Yatak Sayısı"),
              _buildTextField(patientsRequest, "Hasta Talebi"),
              // ⛔️ REMOVED: _buildTextField(patientsAdmitted, "Kabul Edilen Hasta"),
              _buildTextField(patientsRefused, "Reddedilen Hasta"),
              _buildTextField(patientSatisfaction, "Hasta Memnuniyeti (0-100)"),
              _buildTextField(staffMorale, "Personel Morali (0-100)"),

              // ✅ ADDED: Dropdown for "event"
              _buildDropdown(_eventOptions, "Özel Durum (Event) Seçin", (
                value,
              ) {
                setState(() => _selectedEvent = value);
              }),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : getPrediction,
                child:
                    isLoading
                        ? const CircularProgressIndicator()
                        : const Text("Tahmin Et"),
              ),
              const SizedBox(height: 20),
              if (prediction != null)
                Card(
                  color: Colors.indigo.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "🧠 Tahmini Doluluk: ${prediction!.toStringAsFixed(2)}%", // Assuming prediction is 0-100
                      // If prediction is 0-1, use:
                      // "🧠 Tahmini Doluluk: ${(prediction! * 100).toStringAsFixed(2)}%",
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        validator:
            (value) => value == null || value.isEmpty ? "Zorunlu alan" : null,
      ),
    );
  }

  // ✅ ADDED: Helper widget for dropdowns
  Widget _buildDropdown(
    List<String> items,
    String label,
    void Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) => value == null ? "Zorunlu alan" : null,
        items:
            items.map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

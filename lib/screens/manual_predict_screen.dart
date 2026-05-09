import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/prediction_results_view.dart';
import '../widgets/background_wrapper.dart';
import '../widgets/glass_card.dart';

class ManualPredictPage extends StatefulWidget {
  const ManualPredictPage({super.key});

  @override
  State<ManualPredictPage> createState() => _ManualPredictPageState();
}

class _ManualPredictPageState extends State<ManualPredictPage> {
  final _formKey = GlobalKey<FormState>();
  final controllers = {
    "N": TextEditingController(),
    "P": TextEditingController(),
    "K": TextEditingController(),
    "Temp": TextEditingController(),
    "Hum": TextEditingController(),
    "pH": TextEditingController(),
    "Rain": TextEditingController(),
  };

  List results = [];
  bool isLoading = false;

  Future<void> predict(bool isAdvanced) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    final Map<String, dynamic> requestBody = isAdvanced
        ? {
            "n": double.parse(controllers["N"]!.text),
            "p": double.parse(controllers["P"]!.text),
            "k": double.parse(controllers["K"]!.text),
            "ph": double.parse(controllers["pH"]!.text),
            "temperature": double.parse(controllers["Temp"]!.text),
            "humidity": double.parse(controllers["Hum"]!.text),
            "rainfall": double.parse(controllers["Rain"]!.text),
          }
        : {
            "temperature": double.parse(controllers["Temp"]!.text),
            "humidity": double.parse(controllers["Hum"]!.text),
            "rainfall": double.parse(controllers["Rain"]!.text),
          };

    final response = await ApiService.recommendCrop(
      isAdvanced: isAdvanced,
      data: requestBody,
    );

    if (mounted) {
      setState(() {
        results = response ?? [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Manual Prediction"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: BackgroundWrapper(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      GlassCard(
                        child: Column(
                          children: [
                            _inputField("Nitrogen (N) - mg/kg", controllers["N"]!),
                            _inputField("Phosphorus (P) - mg/kg", controllers["P"]!),
                            _inputField("Potassium (K) - mg/kg", controllers["K"]!),
                            _inputField("Temperature (°C)", controllers["Temp"]!, allowNegative: true),
                            _inputField("Humidity (%)", controllers["Hum"]!),
                            _inputField("pH Value", controllers["pH"]!),
                            _inputField("Rainfall (mm)", controllers["Rain"]!),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: isLoading ? null : () => predict(true),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 55), 
                          backgroundColor: Colors.greenAccent.shade700,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: const Text("Predict Crop", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      const SizedBox(height: 30),
                      PredictionResultsView(results: results, isLoading: isLoading),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField(String label, TextEditingController controller, {bool allowNegative = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: true, signed: allowNegative),
        decoration: InputDecoration(
          labelText: label, 
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.black26,
        ),
        validator: (v) {
          if (v == null || v.isEmpty) return "Required";
          final numValue = double.tryParse(v);
          if (numValue == null) return "Must be a valid number";
          if (!allowNegative && numValue < 0) return "Cannot be negative";
          return null;
        },
      ),
    );
  }
}

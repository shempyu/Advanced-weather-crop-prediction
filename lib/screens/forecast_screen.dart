import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/prediction_results_view.dart';
import '../widgets/background_wrapper.dart';
import '../widgets/glass_card.dart';

class ForecastScreen extends StatefulWidget {
  const ForecastScreen({super.key});

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  String? selectedDistrict;
  String? selectedMonth;
  String? selectedYear;

  Map<String, dynamic>? weatherData;
  List cropResults = [];
  List advancedCropResults = [];

  bool isWeatherLoading = false;
  bool isCropLoading = false;
  bool isAdvancedCropLoading = false;

  final _advancedSearchFormKey = GlobalKey<FormState>();

  final nCtrl = TextEditingController(text: "50");
  final pCtrl = TextEditingController(text: "50");
  final kCtrl = TextEditingController(text: "50");
  final phCtrl = TextEditingController(text: "6.5");

  late List<String> years;

  final months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  final districts = [
    'Bajali', 'Baksa', 'Barpeta', 'Bongaigaon', 'Cachar', 'Charaideo',
    'Chirang', 'Darrang', 'Dhemaji', 'Dhubri', 'Dibrugarh', 'Dima Hasao',
    'Goalpara', 'Golaghat', 'Hailakandi', 'Jorhat', 'Kamrup',
    'Kamrup Metropolitian', 'Karbi Anglong', 'Karimganj', 'Kokrajhar',
    'Lakhimpur', 'Majuli', 'Morigaon', 'Nagaon', 'Nalbari', 'Sivasagar',
    'Sonitpur', 'South Salmara - Mankachar', 'Tinsukia', 'Udalguri',
    'West Karbi Anglong',
  ];

  @override
  void initState() {
    super.initState();
    int currentYear = DateTime.now().year;
    years = List.generate(4, (i) => (currentYear + i).toString());
    selectedYear = years[0];
  }

  // ---------------- FETCH WEATHER ----------------
  Future<void> fetchWeather() async {
    if (selectedDistrict == null || selectedMonth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select year, month and district")),
      );
      return;
    }

    setState(() {
      isWeatherLoading = true;
      weatherData = null;
    });

    final response = await ApiService.fetchWeather(
      district: selectedDistrict!,
      year: int.tryParse(selectedYear!) ?? DateTime.now().year,
      month: selectedMonth!,
    );

    if (mounted) {
      setState(() {
        isWeatherLoading = false;
        if (response != null && !response.containsKey("error")) {
          weatherData = response;
        } else if (response != null && response.containsKey("error")) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['error'] ?? "Forecast Error")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Connection Failed")),
          );
        }
      });
    }
  }

  // ---------------- PREDICT CROP ----------------
  Future<void> predictCrop(bool isAdvanced) async {
    if (weatherData == null) return;
    
    if (isAdvanced) {
      if (!_advancedSearchFormKey.currentState!.validate()) return;
      setState(() => isAdvancedCropLoading = true);
    } else {
      setState(() => isCropLoading = true);
    }

    final Map<String, dynamic> requestBody = isAdvanced
        ? {
            "n": double.tryParse(nCtrl.text) ?? 50.0,
            "p": double.tryParse(pCtrl.text) ?? 50.0,
            "k": double.tryParse(kCtrl.text) ?? 50.0,
            "ph": double.tryParse(phCtrl.text) ?? 6.5,
            "temperature": weatherData!['temperature'],
            "humidity": weatherData!['humidity'],
            "rainfall": weatherData!['rainfall'],
          }
        : {
            "temperature": weatherData!['temperature'],
            "humidity": weatherData!['humidity'],
            "rainfall": weatherData!['rainfall'],
          };

    final response = await ApiService.recommendCrop(
      isAdvanced: isAdvanced,
      data: requestBody,
    );

    if (mounted) {
      setState(() {
        if (isAdvanced) {
          advancedCropResults = response ?? [];
          isAdvancedCropLoading = false;
        } else {
          cropResults = response ?? [];
          isCropLoading = false;
        }
      });
    }
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Assam Forecast Prediction"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: BackgroundWrapper(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildDropdowns(),
                    if (weatherData != null) ...[
                      const SizedBox(height: 20),
                      _buildWeatherCard(),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: isCropLoading ? null : () => predictCrop(false),
                        icon: const Icon(Icons.analytics),
                        label: const Text("Predict Crop", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 55),
                          backgroundColor: Colors.greenAccent.shade700,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      PredictionResultsView(
                        results: cropResults,
                        isLoading: isCropLoading,
                      ),
                      if (cropResults.isNotEmpty) ...[
                        const SizedBox(height: 30),
                        _buildAdvancedSearch(),
                        const SizedBox(height: 20),
                        if (advancedCropResults.isNotEmpty || isAdvancedCropLoading)
                          PredictionResultsView(
                            results: advancedCropResults,
                            isLoading: isAdvancedCropLoading,
                          ),
                      ],
                    ]
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- DROPDOWNS ----------------
  Widget _buildDropdowns() {
    return GlassCard(
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: selectedYear,
            decoration: InputDecoration(labelText: "Select Year", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), filled: true, fillColor: Colors.black26),
            items: years.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => selectedYear = v),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: selectedMonth,
            decoration: InputDecoration(labelText: "Select Month", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), filled: true, fillColor: Colors.black26),
            items: months.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => selectedMonth = v),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: selectedDistrict,
            decoration: InputDecoration(labelText: "Select District", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), filled: true, fillColor: Colors.black26),
            items: districts.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => selectedDistrict = v),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: isWeatherLoading ? null : fetchWeather,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 55),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: isWeatherLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                : const Text("Get Forecast", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  // ---------------- WEATHER CARD ----------------
  Widget _buildWeatherCard() {
    return GlassCard(
      color: Colors.blue.withOpacity(0.1),
      child: Column(
        children: [
          Text(
            "$selectedDistrict",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            "$selectedMonth $selectedYear",
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _weatherStat("🌡️ Temp", "${weatherData!['temperature']}°C"),
              _weatherStat("💧 Humidity", "${weatherData!['humidity']}%"),
              _weatherStat("🌧️ Rain", "${weatherData!['rainfall']}mm"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _weatherStat(String label, String val) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 5),
        Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
      ],
    );
  }

  // ---------------- ADVANCED SOIL INPUT ----------------
  Widget _buildAdvancedSearch() {
    return GlassCard(
      padding: EdgeInsets.zero,
      color: Colors.deepOrangeAccent.withOpacity(0.25),
      child: ExpansionTile(
        title: const Row(
          children: [
            Icon(Icons.tune, color: Colors.orangeAccent),
            SizedBox(width: 10),
            Text("Advanced Search (Edit Soil Data)", style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        iconColor: Colors.orangeAccent,
        collapsedIconColor: Colors.white,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _advancedSearchFormKey,
              child: Column(
                children: [
                  Wrap(
                    spacing: 15, runSpacing: 15,
                    alignment: WrapAlignment.center,
                    children: [
                      _smallInput("Nitrogen (N) - mg/kg", nCtrl),
                      _smallInput("Phosphorus (P) - mg/kg", pCtrl),
                      _smallInput("Potassium (K) - mg/kg", kCtrl),
                      _smallInput("pH Value", phCtrl),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: isAdvancedCropLoading ? null : () => predictCrop(true),
                    icon: const Icon(Icons.science),
                    label: const Text("Predict with Soil Data", style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50), 
                      backgroundColor: Colors.tealAccent.shade400,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _smallInput(String label, TextEditingController ctrl) {
    return SizedBox(
      width: 170,
      child: TextFormField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
        decoration: InputDecoration(
          labelText: label, 
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.black26,
        ),
        validator: (v) {
          if (v == null || v.isEmpty) return "Required";
          final numValue = double.tryParse(v);
          if (numValue == null) return "Invalid number";
          if (numValue < 0) return "No negative";
          return null;
        },
      ),
    );
  }
}

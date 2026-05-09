import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const AssamAgroApp());
}

class AssamAgroApp extends StatelessWidget {
  const AssamAgroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Assam Agro Predictor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: 'Roboto',
        colorSchemeSeed: Colors.greenAccent,
      ),
      home: const HomeScreen(),
    );
  }
}

// --- HOME SCREEN ---
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              "assets/bg.jpeg",
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(color: Colors.green.shade900),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.6)),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Assam Agro Portal",
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 40),
                _navButton(context, "🌱 Predict Crop", const ManualPredictPage()),
                _navButton(context, "🌤 See Forecast", const ForecastScreen()),
                _navButton(context, "📅 See Crop Calendar",
                    const Center(child: Text("Calendar coming soon"))),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _navButton(BuildContext context, String title, Widget page) {
    return Container(
      width: 300,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15))),
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => page)),
        child: Text(title, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}

// --- NEWS BOTTOM SHEET ---
class _NewsBottomSheet extends StatefulWidget {
  final String cropName;
  const _NewsBottomSheet({Key? key, required this.cropName}) : super(key: key);

  @override
  _NewsBottomSheetState createState() => _NewsBottomSheetState();
}

class _NewsBottomSheetState extends State<_NewsBottomSheet> {
  bool isLoading = true;
  Map<String, dynamic>? newsData;

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    try {
      debugPrint("Fetching news for crop: ${widget.cropName.toLowerCase()}");
      final response = await http.post(
        Uri.parse("http://10.53.3.78:5000/crop-news"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"crop": widget.cropName.toLowerCase()}),
      );
      
      debugPrint("News API Status Code: ${response.statusCode}");
      debugPrint("News API Response Body: ${response.body}");
      
      if (response.statusCode == 200) {
        setState(() {
          newsData = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("News API Error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(40.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (newsData == null || newsData!['results'] == null) {
      return const Padding(
        padding: EdgeInsets.all(40.0),
        child: Center(child: Text("Failed to load news or no connection.", style: TextStyle(color: Colors.white))),
      );
    }

    final results = newsData!['results'];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("News for ${widget.cropName.toUpperCase()}",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
            const SizedBox(height: 10),
            if (results['headline1'] != null && results['link1'] != null) ...[
              _sourceLink(results['headline1'], results['link1']),
              const Divider(color: Colors.white10),
            ],
            if (results['headline2'] != null && results['link2'] != null) ...[
              _sourceLink(results['headline2'], results['link2']),
              const Divider(color: Colors.white10),
            ],
            if (results['headline3'] != null && results['link3'] != null) ...[
              _sourceLink(results['headline3'], results['link3']),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sourceLink(String title, String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 15)),
          const SizedBox(height: 4),
          Text(url, style: const TextStyle(color: Colors.blue, fontSize: 13, decoration: TextDecoration.underline)),
        ],
      ),
    );
  }
}

// --- SHARED PREDICTION VIEW (With Top 5 and Related Data) ---
class PredictionResultsView extends StatelessWidget {
  final List results;
  final bool isLoading;

  const PredictionResultsView(
      {super.key, required this.results, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (results.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Text("Top Recommendations",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        // Top Card
        _buildTopCard(context, results[0]),
        const SizedBox(height: 15),
        // Top 2-5 Suggestions
        ...results
            .skip(1)
            .take(4)
            .map((item) => _buildMinorTile(context, item)),
      ],
    );
  }

  Widget _buildTopCard(BuildContext context, dynamic top) {
    String name = (top["crop"] ?? top["category"] ?? "Unknown").toString().toUpperCase();
    double conf = (top["confidence"] ?? 0.0).toDouble();
    if (conf <= 1.0 && conf > 0) conf *= 100;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.green, Colors.teal]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))]
      ),
      child: Row(
        children: [
          const Icon(Icons.stars, color: Colors.white, size: 40),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("BEST MATCH", style: TextStyle(fontSize: 12, letterSpacing: 1.2)),
                Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text("Probability Score: ${conf.toStringAsFixed(2)}%", style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white24, elevation: 0),
            onPressed: () => _showRelatedData(context, (top["crop"] ?? "Unknown").toString()),
            child: const Text("RELATED", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildMinorTile(BuildContext context, dynamic item) {
    String name = (item["crop"] ?? item["category"] ?? "Unknown");
    double conf = (item["confidence"] ?? 0.0).toDouble();
    if (conf <= 1.0 && conf > 0) conf *= 100;

    return Card(
      color: Colors.white.withOpacity(0.05),
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Probability Score: ${conf.toStringAsFixed(2)}%"),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueGrey.shade800,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          onPressed: () => _showRelatedData(context, name),
          child: const Text("RELATED", style: TextStyle(color: Colors.white, fontSize: 12)),
        ),
      ),
    );
  }

  void _showRelatedData(BuildContext context, String cropName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => _NewsBottomSheet(cropName: cropName),
    );
  }
}

// --- MANUAL PREDICT PAGE (Full 7 Inputs) ---
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

    try {
      final endpoint = isAdvanced ? "/recommend-advanced-crop" : "/recommend-basic-crop";
      
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

      final response = await http.post(
        Uri.parse("http://127.0.0.1:10000$endpoint"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() => results = data['recommended_crops'] ?? []);
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manual Prediction")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Wrap(
                spacing: 20, runSpacing: 10,
                children: [
                  _inputField("Nitrogen (N)", controllers["N"]!),
                  _inputField("Phosphorus (P)", controllers["P"]!),
                  _inputField("Potassium (K)", controllers["K"]!),
                  _inputField("Temperature", controllers["Temp"]!),
                  _inputField("Humidity", controllers["Hum"]!),
                  _inputField("pH Value", controllers["pH"]!),
                  _inputField("Rainfall", controllers["Rain"]!),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: isLoading ? null : () => predict(true),
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: Colors.green),
                child: const Text("Predict Crop"),
              ),
              const SizedBox(height: 20),
              PredictionResultsView(results: results, isLoading: isLoading),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField(String label, TextEditingController controller) {
    return SizedBox(
      width: 150,
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        validator: (v) => v!.isEmpty ? "Required" : null,
      ),
    );
  }
}

// --- FORECAST SCREEN ---
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

  bool isWeatherLoading = false;
  bool isCropLoading = false;

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

    try {
      final response = await http.post(
        Uri.parse("http://127.0.0.1:10000/predict-weather"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "district": selectedDistrict,
          "year": int.tryParse(selectedYear!) ?? DateTime.now().year,
          "month": selectedMonth
        }),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          weatherData = body;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(body['error'] ?? "Forecast Error")),
        );
      }
    } catch (e) {
      debugPrint("Forecast Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Connection Failed")),
      );
    } finally {
      setState(() {
        isWeatherLoading = false;
      });
    }
  }

  // ---------------- PREDICT CROP ----------------
  Future<void> predictCrop(bool isAdvanced) async {
    if (weatherData == null) return;
    setState(() => isCropLoading = true);

    try {
      final endpoint = isAdvanced ? "/recommend-advanced-crop" : "/recommend-basic-crop";
      
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

      final response = await http.post(
        Uri.parse("http://127.0.0.1:10000$endpoint"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          cropResults = data['recommended_crops'] ?? [];
        });
      }
    } catch (e) {
      debugPrint("Prediction Error: $e");
    } finally {
      setState(() => isCropLoading = false);
    }
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Assam Forecast Prediction")),
      body: SingleChildScrollView(
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
                label: const Text("Predict Crop"),
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              ),
              const SizedBox(height: 20),
              if (cropResults.isNotEmpty) ...[
                _buildAdvancedSearch(),
                const SizedBox(height: 20),
              ],
              PredictionResultsView(
                results: cropResults,
                isLoading: isCropLoading,
              ),
            ]
          ],
        ),
      ),
    );
  }

  // ---------------- DROPDOWNS ----------------
  Widget _buildDropdowns() {
    return Card(
      color: Colors.white.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedYear,
              decoration: const InputDecoration(labelText: "Select Year", border: OutlineInputBorder()),
              items: years.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => selectedYear = v),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedMonth,
              decoration: const InputDecoration(labelText: "Select Month", border: OutlineInputBorder()),
              items: months.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => selectedMonth = v),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedDistrict,
              decoration: const InputDecoration(labelText: "Select District", border: OutlineInputBorder()),
              items: districts.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => selectedDistrict = v),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isWeatherLoading ? null : fetchWeather,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: isWeatherLoading
                  ? const CircularProgressIndicator()
                  : const Text("Get Forecast"),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- WEATHER CARD ----------------
  Widget _buildWeatherCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.15),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(
            "$selectedDistrict",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "$selectedMonth $selectedYear",
            style: const TextStyle(fontSize: 16),
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
        Text(label),
        const SizedBox(height: 5),
        Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  // ---------------- ADVANCED SOIL INPUT ----------------
  Widget _buildAdvancedSearch() {
    return ExpansionTile(
      title: const Text("Advanced Search (Edit Soil Data)", style: TextStyle(color: Colors.greenAccent)),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Wrap(
                spacing: 10, runSpacing: 10,
                children: [
                  _smallInput("N", nCtrl),
                  _smallInput("P", pCtrl),
                  _smallInput("K", kCtrl),
                  _smallInput("pH", phCtrl),
                ],
              ),
              const SizedBox(height: 15),
              ElevatedButton.icon(
                onPressed: isCropLoading ? null : () => predictCrop(true),
                icon: const Icon(Icons.science),
                label: const Text("Predict with Soil Data"),
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: Colors.teal),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _smallInput(String label, TextEditingController ctrl) {
    return SizedBox(
      width: 80,
      child: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      ),
    );
  }
}

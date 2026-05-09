import 'package:flutter/material.dart';
import 'manual_predict_screen.dart';
import 'forecast_screen.dart';
import 'coming_soon_screen.dart';
import '../widgets/background_wrapper.dart';
import '../widgets/glass_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: BackgroundWrapper(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: GlassCard(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                      const ComingSoonScreen(title: "Crop Calendar\nComing Soon")),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navButton(BuildContext context, String title, Widget page) {
    return Container(
      width: 300,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.1),
            padding: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.white.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(15))),
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => page)),
        child: Text(title, style: const TextStyle(fontSize: 18, color: Colors.white)),
      ),
    );
  }
}

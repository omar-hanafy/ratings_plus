import 'package:flutter/material.dart';
import 'package:ratings_plus/ratings_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rating Bar Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        // Global theme for RatingBars
        extensions: const [
          RatingBarThemeData(itemSize: 40, glowColor: Colors.amber),
        ],
      ),
      home: const RatingBarDemo(),
    );
  }
}

class RatingBarDemo extends StatefulWidget {
  const RatingBarDemo({super.key});

  @override
  State<RatingBarDemo> createState() => _RatingBarDemoState();
}

class _RatingBarDemoState extends State<RatingBarDemo> {
  double _rating = 3.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rating Bar Plus Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader('Basic Usage'),
            const Text('Tap or drag to rate:'),
            const SizedBox(height: 8),
            Center(
              child: RatingBar(
                initialValue: 3,
                itemBuilder: (context, index) =>
                    const Icon(Icons.star, color: Colors.amber),
                onChanged: (rating) {
                  debugPrint('Rating updated: $rating');
                },
              ),
            ),

            _buildHeader('Fractional Rating (0.5 step)'),
            Center(
              child: RatingBar(
                initialValue: 2.5,
                step: 0.5,
                allowClear: true,
                itemBuilder: (context, index) =>
                    const Icon(Icons.star_rounded, color: Colors.blueAccent),
                onChanged: (rating) => setState(() => _rating = rating),
              ),
            ),
            Center(
              child: Text(
                'Value: $_rating',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),

            _buildHeader('Custom Shapes & Colors'),
            Center(
              child: RatingBar(
                initialValue: 3,
                itemCount: 5,
                itemBuilder: (context, index) {
                  switch (index) {
                    case 0:
                      return const Icon(
                        Icons.sentiment_very_dissatisfied,
                        color: Colors.red,
                      );
                    case 1:
                      return const Icon(
                        Icons.sentiment_dissatisfied,
                        color: Colors.redAccent,
                      );
                    case 2:
                      return const Icon(
                        Icons.sentiment_neutral,
                        color: Colors.amber,
                      );
                    case 3:
                      return const Icon(
                        Icons.sentiment_satisfied,
                        color: Colors.lightGreen,
                      );
                    case 4:
                      return const Icon(
                        Icons.sentiment_very_satisfied,
                        color: Colors.green,
                      );
                    default:
                      return const SizedBox();
                  }
                },
                onChanged: (rating) {},
              ),
            ),

            _buildHeader('Vertical Layout'),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(16),
                child: RatingBar(
                  initialValue: 3,
                  direction: Axis.vertical,
                  verticalDirection: VerticalDirection.up, // Grows upwards
                  itemCount: 5,
                  spacing: 4.0, // Space between items
                  itemBuilder: (context, index) => const Icon(
                    Icons.local_fire_department,
                    color: Colors.deepOrange,
                  ),
                  onChanged: (rating) {},
                ),
              ),
            ),

            _buildHeader('Read-only Indicator'),
            const Text('Displays a static value (e.g., average rating).'),
            const SizedBox(height: 8),
            Center(
              child: RatingBarIndicator(
                value: 4.3,
                itemCount: 5,
                itemSize: 30.0,
                itemBuilder: (context, index) =>
                    const Icon(Icons.star, color: Colors.amber),
              ),
            ),

            _buildHeader('Form Integration'),
            Form(
              autovalidateMode: AutovalidateMode.always,
              child: Column(
                children: [
                  RatingBar.form(
                    initialValue: 0,
                    minRating: 1,
                    validator: (value) {
                      if (value == null || value < 1) {
                        return 'Please select a rating';
                      }
                      return null;
                    },
                    itemBuilder: (context, _) =>
                        const Icon(Icons.star, color: Colors.purple),
                    onSaved: (value) {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

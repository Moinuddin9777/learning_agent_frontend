import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:learning_agent/theme.dart';
import 'package:learning_agent/views/response_screen.dart';
import 'package:learning_agent/widgets/api_key_validator.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

void main() {
  runApp(const LearningPathApp());
}

class LearningPathApp extends StatelessWidget {
  const LearningPathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Learning Path Generator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          secondary: const Color(0xFF03DAC6),
          tertiary: const Color(0xFFEFB8C8),
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 3,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Lottie Animation
                      Expanded(
                        flex: 2,
                        child: Lottie.network(
                          'https://lottie.host/6b230bbe-67a1-46e2-92d6-a1ff142ffc46/zf8l9mUsZ0.json', // Education/Learning animation
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Title and Description
                      Text(
                        'AI Learning Path Generator',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Create personalized learning paths tailored to your goals and preferences',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),
                      // Get Started Button
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MainScreen(
                                title: 'Generate Learning Path',
                              ),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Get Started',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Feature Cards
              Container(
                height: 180,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  children: [
                    _FeatureCard(
                      icon: Icons.person_outline,
                      title: 'Personalized',
                      description: 'Tailored to your learning style',
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    _FeatureCard(
                      icon: Icons.timeline,
                      title: 'Structured',
                      description: 'Clear milestones and progress tracking',
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    _FeatureCard(
                      icon: Icons.download,
                      title: 'Exportable',
                      description: 'Save and share your learning path',
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 4,
        shadowColor: color.withOpacity(0.4),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, required this.title});

  final String title;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String? apiKey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: switch (apiKey) {
        final providedKey? => LearningPathForm(apiKey: providedKey),
        _ => ApiKeyWidget(onSubmitted: (key) {
            setState(() => apiKey = key);
          }),
      },
    );
  }
}


class LearningPathForm extends StatefulWidget {
  const LearningPathForm({required this.apiKey, super.key});

  final String apiKey;

  @override
  State<LearningPathForm> createState() => _LearningPathFormState();
}

class _LearningPathFormState extends State<LearningPathForm> {
  late final GenerativeModel _model;
  late final ChatSession _chat;
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  // Form Controllers
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _topicController = TextEditingController();
  final _goalsController = TextEditingController();
  String _learningStyle = 'Visual';
  String _difficultyLevel = 'Beginner';

  final List<String> _learningStyles = [
    'Visual',
    'Auditory',
    'Reading/Writing',
    'Kinesthetic'
  ];
  final List<String> _difficultyLevels = ['Beginner', 'Intermediate', 'Advanced'];

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: widget.apiKey,
    );
    _chat = _model.startChat();
  }

  String _generatePrompt() {
    return '''
    Create a detailed, personalized learning path for a student with the following characteristics:

    Student Profile:
    - Name: ${_nameController.text}
    - Age: ${_ageController.text}
    - Topic of Interest: ${_topicController.text}
    - Learning Style: $_learningStyle
    - Current Level: $_difficultyLevel
    - Learning Goals: ${_goalsController.text}

    Please provide:
    1. A structured weekly learning plan
    2. Specific resources and materials
    3. Milestones and progress indicators
    4. Estimated time commitments
    5. Practice exercises and projects

    Format the response in Markdown with clear sections and bullet points.
    ''';
  }

  Future<void> _generateLearningPath() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final response = await _chat.sendMessage(
        Content.text(_generatePrompt()),
      );
      
      if (response.text == null) {
        _showError('Empty response received.');
        return;
      }

      // Show the response in a new screen
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ResponseScreen(response: response.text!),
          ),
        );
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: textFieldDecoration(context, 'Name'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ageController,
                decoration: textFieldDecoration(context, 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter your age' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _topicController,
                decoration: textFieldDecoration(context, 'Topic to Learn'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter a topic' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _learningStyle,
                decoration: textFieldDecoration(context, 'Learning Style'),
                items: _learningStyles
                    .map((style) => DropdownMenuItem(
                          value: style,
                          child: Text(style),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _learningStyle = value!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _difficultyLevel,
                decoration: textFieldDecoration(context, 'Difficulty Level'),
                items: _difficultyLevels
                    .map((level) => DropdownMenuItem(
                          value: level,
                          child: Text(level),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _difficultyLevel = value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _goalsController,
                decoration: textFieldDecoration(context, 'Learning Goals'),
                maxLines: 3,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter your goals' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _generateLearningPath,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Generate Learning Path'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _topicController.dispose();
    _goalsController.dispose();
    super.dispose();
  }
}

// class ResponseScreen extends StatelessWidget {
//   final String response;
//   const ResponseScreen({required this.response, super.key});
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Your Learning Path'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: MarkdownBody(
//             data: response,
//           ),
//         ),
//       ),
//     );
//   }
// }

// InputDecoration textFieldDecoration(BuildContext context, String hintText) =>
//     InputDecoration(
    //   contentPadding: const EdgeInsets.all(15),
    //   hintText: hintText,
    //   border: OutlineInputBorder(
    //     borderRadius: const BorderRadius.all(
    //       Radius.circular(14),
    //     ),
    //     borderSide: BorderSide(
    //       color: Theme.of(context).colorScheme.secondary,
    //     ),
    //   ),
    //   focusedBorder: OutlineInputBorder(
    //     borderRadius: const BorderRadius.all(
    //       Radius.circular(14),
    //     ),
    //     borderSide: BorderSide(
    //       color: Theme.of(context).colorScheme.secondary,
    //     ),
    //   ),
    // );
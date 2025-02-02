import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:learning_agent/views/response_screen.dart';

void main() {
  runApp(const LearningPathApp());
}

class LearningPathApp extends StatelessWidget {
  const LearningPathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Adaptive Learning Path Generator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color.fromARGB(255, 171, 222, 244),
        ),
        useMaterial3: true,
      ),
      home: const MainScreen(title: 'Learning Path Generator'),
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

class ApiKeyWidget extends StatelessWidget {
  ApiKeyWidget({required this.onSubmitted, super.key});

  final ValueChanged<String> onSubmitted;
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'To generate learning paths, you\'ll need a Gemini API key.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: textFieldDecoration(context, 'Enter your API key'),
                    controller: _textController,
                    onSubmitted: onSubmitted,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => onSubmitted(_textController.text),
                  child: const Text('Submit'),
                ),
              ],
            ),
          ],
        ),
      ),
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

InputDecoration textFieldDecoration(BuildContext context, String hintText) =>
    InputDecoration(
      contentPadding: const EdgeInsets.all(15),
      hintText: hintText,
      border: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(14),
        ),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(14),
        ),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mmse.dart';
import 'adl.dart';
import 'personal.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Form submission statuses
  bool isPersonalInfoSubmitted = false;
  bool isMMSESubmitted = false;
  bool isADLSubmitted = false;

  // Scores
  int mmseScore = 0;
  int adlScore = 0;

  @override
  void initState() {
    super.initState();
    _loadFormStatus();
  }

  Future<void> _loadFormStatus() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      isPersonalInfoSubmitted = prefs.getBool('personalInfoSubmitted') ?? false;
      isMMSESubmitted = prefs.getBool('mmseSubmitted') ?? false;
      isADLSubmitted = prefs.getBool('adlSubmitted') ?? false;

      mmseScore = prefs.getInt('mmseScore') ?? 0;
      adlScore = prefs.getInt('adlScore') ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Alzheimer's & Elderly Assessment")),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Personal Info Card
                _buildAssessmentCard(
                  context,
                  title: 'Personal Information',
                  description:
                      'Basic demographic information and Alzheimer\'s disease diagnosis status.',
                  points:
                      isPersonalInfoSubmitted ? 'Completed' : 'Not completed',
                  iconData: Icons.person,
                  color: Colors.orange,
                  statusIcon:
                      isPersonalInfoSubmitted
                          ? Icons.check_circle
                          : Icons.pending_outlined,
                  statusColor:
                      isPersonalInfoSubmitted ? Colors.green : Colors.grey,
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PersonalInfoForm(),
                      ),
                    );

                    if (result == true) {
                      _loadFormStatus();
                    }
                  },
                ),

                const SizedBox(height: 20),

                // MMSE Card
                _buildAssessmentCard(
                  context,
                  title: 'Mini-Mental State Examination (MMSE)',
                  description:
                      'A 30-point questionnaire used to measure cognitive impairment in clinical and research settings.',
                  points:
                      isMMSESubmitted
                          ? 'Score: $mmseScore/30'
                          : '30 points total',
                  iconData: Icons.psychology,
                  color: Colors.blue,
                  statusIcon:
                      isMMSESubmitted
                          ? Icons.check_circle
                          : Icons.pending_outlined,
                  statusColor: isMMSESubmitted ? Colors.green : Colors.grey,
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MMSEForm()),
                    );

                    if (result == true) {
                      _loadFormStatus();
                    }
                  },
                ),

                const SizedBox(height: 20),

                // ADL Card
                _buildAssessmentCard(
                  context,
                  title: 'Activities of Daily Living (ADL)',
                  description:
                      'Evaluates functional status and ability to perform everyday activities independently.',
                  points:
                      isADLSubmitted ? 'Score: $adlScore/6' : '6 points total',
                  iconData: Icons.accessibility_new,
                  color: Colors.green,
                  statusIcon:
                      isADLSubmitted
                          ? Icons.check_circle
                          : Icons.pending_outlined,
                  statusColor: isADLSubmitted ? Colors.green : Colors.grey,
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ADLForm()),
                    );

                    if (result == true) {
                      _loadFormStatus();
                    }
                  },
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAssessmentCard(
    BuildContext context, {
    required String title,
    required String description,
    required String points,
    required IconData iconData,
    required Color color,
    required VoidCallback onTap,
    required IconData statusIcon,
    required Color statusColor,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(iconData, color: color, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(statusIcon, color: statusColor, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              points,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(description, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    points.contains('Completed') || points.contains('Score')
                        ? 'View Assessment'
                        : 'Start Assessment',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

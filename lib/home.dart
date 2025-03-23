import 'audio.dart';
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
  bool isAudioSubmitted = false;

  // Scores
  int mmseScore = 0;
  int orientationTimeScore = 0;
  int orientationPlaceScore = 0;
  int registrationScore = 0;
  int attentionScore = 0;
  int recallScore = 0;
  int namingScore = 0;
  int repetitionScore = 0;
  int commandScore = 0;
  int readingScore = 0;
  int writingScore = 0;
  int copyingScore = 0;

  int adlScore = 0;
  bool bathingScore = false;
  bool dressingScore = false;
  bool toiletingScore = false;
  bool transferringScore = false;
  bool continenceScore = false;
  bool feedingScore = false;

  String patientName = '';
  String gender = '';
  DateTime? dob;
  DateTime? doRecording;
  String homeTown = '';
  String region = '';
  String currentCity = '';
  String duration = '';
  String birthPlace = '';
  bool adDiagnosis = false;

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
      isAudioSubmitted = prefs.getBool('audioSubmitted') ?? false;

      mmseScore = prefs.getInt('mmseScore') ?? 0;

      orientationTimeScore = prefs.getInt('orientationTimeScore') ?? 0;
      orientationPlaceScore = prefs.getInt('orientationPlaceScore') ?? 0;
      registrationScore = prefs.getInt('registrationScore') ?? 0;
      attentionScore = prefs.getInt('attentionScore') ?? 0;
      recallScore = prefs.getInt('recallScore') ?? 0;
      namingScore = prefs.getInt('namingScore') ?? 0;
      repetitionScore = prefs.getInt('repetitionScore') ?? 0;
      commandScore = prefs.getInt('commandScore') ?? 0;
      readingScore = prefs.getInt('readingScore') ?? 0;
      writingScore = prefs.getInt('writingScore') ?? 0;
      copyingScore = prefs.getInt('copyingScore') ?? 0;

      adlScore = prefs.getInt('adlScore') ?? 0;

      bathingScore = prefs.getBool('bathingScore') ?? false;
      dressingScore = prefs.getBool('dressingScore') ?? false;
      toiletingScore = prefs.getBool('toiletingScore') ?? false;
      transferringScore = prefs.getBool('transferringScore') ?? false;
      continenceScore = prefs.getBool('continenceScore') ?? false;
      feedingScore = prefs.getBool('feedingScore') ?? false;

      patientName = prefs.getString('name') ?? '';
      gender = prefs.getString('gender') ?? '';
      homeTown = prefs.getString('homeTown') ?? '';
      region = prefs.getString('region') ?? '';
      currentCity = prefs.getString('currentCity') ?? '';
      duration = prefs.getString('duration') ?? '';
      birthPlace = prefs.getString('birthPlace') ?? '';
      adDiagnosis = prefs.getBool('adDiagnosis') ?? false;

      // Load dates
      final dobString = prefs.getString('dob');
      if (dobString != null) {
        dob = DateTime.parse(dobString);
      }

      final doRecordingString = prefs.getString('doRecording');
      if (doRecordingString != null) {
        doRecording = DateTime.parse(doRecordingString);
      }
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

                // Audio Task Card
                _buildAssessmentCard(
                  context,
                  title: 'Cookie Theft Description Task',
                  description:
                      'Audio recording of patient describing the Cookie Theft picture to assess language and cognitive abilities.',
                  points: isAudioSubmitted ? 'Completed' : 'Not completed',
                  iconData: Icons.mic,
                  color: Colors.purple,
                  statusIcon:
                      isAudioSubmitted
                          ? Icons.check_circle
                          : Icons.pending_outlined,
                  statusColor: isAudioSubmitted ? Colors.green : Colors.grey,
                  onTap: () async {
                    if (!isPersonalInfoSubmitted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please complete the Personal Information form first',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AudioDescriptionTask(),
                      ),
                    );

                    if (result == true) {
                      _loadFormStatus();
                    }
                  },
                ),
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

import 'package:flutter/material.dart';

class MMSEForm extends StatefulWidget {
  const MMSEForm({Key? key}) : super(key: key);

  @override
  _MMSEFormState createState() => _MMSEFormState();
}

class _MMSEFormState extends State<MMSEForm> {
  // Initialize with default values to prevent null issues
  int totalScore = 0;
  
  // Section 1: Orientation
  int orientationTimeScore = 0;
  int orientationPlaceScore = 0;
  
  // Section 2: Registration
  int registrationScore = 0;
  
  // Section 3: Attention and Calculation
  int attentionScore = 0;
  
  // Section 4: Recall
  int recallScore = 0;
  
  // Section 5: Language
  int namingScore = 0;
  int repetitionScore = 0;
  int commandScore = 0;
  int readingScore = 0;
  int writingScore = 0;
  
  // Section 6: Copying
  int copyingScore = 0;

  @override
  void initState() {
    super.initState();
    // Calculate initial total score
    _updateTotalScore();
  }

  void _updateTotalScore() {
    setState(() {
      totalScore = orientationTimeScore + orientationPlaceScore + registrationScore + 
                  attentionScore + recallScore + namingScore + repetitionScore + 
                  commandScore + readingScore + writingScore + copyingScore;
    });
  }

  Widget _buildScoreSelector(int maxScore, int currentScore, Function(int) onChanged) {
    List<DropdownMenuItem<int>> items = [];
    for (int i = 0; i <= maxScore; i++) {
      items.add(DropdownMenuItem(
        value: i,
        child: Text('$i'),
      ));
    }
    
    return DropdownButton<int>(
      value: currentScore,
      items: items,
      onChanged: (int? value) {
        if (value != null) {
          onChanged(value);
          _updateTotalScore();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('MMSE Assessment'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total Score Display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Total MMSE Score',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '$totalScore/30',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Section 1: Orientation
              _buildSectionHeader('Section 1: Orientation'),
              _buildQuestionRow(
                'Year, month, day, date, time',
                5,
                orientationTimeScore,
                (value) => setState(() => orientationTimeScore = value),
              ),
              _buildQuestionRow(
                'Country, town, district, hospital, ward',
                5,
                orientationPlaceScore,
                (value) => setState(() => orientationPlaceScore = value),
              ),

              // Section 2: Registration
              _buildSectionHeader('Section 2: Registration'),
              _buildQuestionRow(
                'Examiner names 3 objects (e.g., apple, table, penny). '
                'Patient asked to repeat (1 point for each correct). '
                'THEN patient to learn the 3 names repeating until correct.',
                3,
                registrationScore,
                (value) => setState(() => registrationScore = value),
              ),

              // Section 3: Attention and Calculation
              _buildSectionHeader('Section 3: Attention and Calculation'),
              _buildQuestionRow(
                'Subtract 7 from 100, then repeat from result. '
                'Alternative: spell "WORLD" backwards - dlrow.',
                5,
                attentionScore,
                (value) => setState(() => attentionScore = value),
              ),

              // Section 4: Recall
              _buildSectionHeader('Section 4: Recall'),
              _buildQuestionRow(
                'Ask for names of 3 objects learned earlier.',
                3,
                recallScore,
                (value) => setState(() => recallScore = value),
              ),

              // Section 5: Language
              _buildSectionHeader('Section 5: Language'),
              _buildQuestionRow(
                'Name a pencil and watch.',
                2,
                namingScore,
                (value) => setState(() => namingScore = value),
              ),
              _buildQuestionRow(
                'Repeat "No ifs, ands, or buts".',
                1,
                repetitionScore,
                (value) => setState(() => repetitionScore = value),
              ),
              _buildQuestionRow(
                'Give a 3 stage command. Score 1 for each stage. '
                'E.g., "Place index finger of right hand on your nose and then on your left ear".',
                3,
                commandScore,
                (value) => setState(() => commandScore = value),
              ),
              _buildQuestionRow(
                'Ask patient to read and obey a written command on a piece of paper stating "Close your eyes".',
                1,
                readingScore,
                (value) => setState(() => readingScore = value),
              ),
              _buildQuestionRow(
                'Ask the patient to write a sentence. Score if it is sensible and has a subject and a verb.',
                1,
                writingScore,
                (value) => setState(() => writingScore = value),
              ),

              // Section 6: Copying
              _buildSectionHeader('Section 6: Copying'),
              _buildQuestionRow(
                'Ask the patient to copy a pair of intersecting pentagons.',
                1,
                copyingScore,
                (value) => setState(() => copyingScore = value),
              ),

              const SizedBox(height: 30),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Show result in a dialog
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('MMSE Assessment Result'),
                        content: Text('Total Score: $totalScore/30'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      'Submit Assessment',
                      style: TextStyle(fontSize: 18),
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

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8.0),
          color: Colors.grey.shade200,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildQuestionRow(String question, int maxScore, int currentScore, Function(int) onScoreChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(question),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Score: '),
                _buildScoreSelector(maxScore, currentScore, onScoreChanged),
                Text('/$maxScore'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

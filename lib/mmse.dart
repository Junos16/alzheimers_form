import 'package:flutter/material.dart';

class MMSEForm extends StatefulWidget {
  const MMSEForm({Key? key}) : super(key: key);

  @override
  _MMSEFormState createState() => _MMSEFormState();
}

class _MMSEFormState extends State<MMSEForm> {
  // Initialize with default values
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

  // Section totals
  int get orientationTotal => orientationTimeScore + orientationPlaceScore;
  int get languageTotal => namingScore + repetitionScore + commandScore + readingScore + writingScore;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Calculate initial total score
    _updateTotalScore();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
      body: SafeArea(
        child: Stack(
          children: [
            // Scrollable content
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                // App bar
                SliverAppBar(
                  title: const Text('MMSE Assessment'),
                  pinned: true,
                  floating: true,
                ),
                
                // Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 70), // Space for floating header
                        
                        // Section 1: Orientation
                        _buildSectionHeader('Section 1: Orientation', '$orientationTotal/10'),
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
                        _buildSectionHeader('Section 2: Registration', '$registrationScore/3'),
                        _buildQuestionRow(
                          'Examiner names 3 objects (e.g., apple, table, penny). '
                          'Patient asked to repeat (1 point for each correct).',
                          3,
                          registrationScore,
                          (value) => setState(() => registrationScore = value),
                        ),

                        // Section 3: Attention and Calculation
                        _buildSectionHeader('Section 3: Attention and Calculation', '$attentionScore/5'),
                        _buildQuestionRow(
                          'Subtract 7 from 100, then repeat from result. '
                          'Alternative: spell "WORLD" backwards - dlrow.',
                          5,
                          attentionScore,
                          (value) => setState(() => attentionScore = value),
                        ),

                        // Section 4: Recall
                        _buildSectionHeader('Section 4: Recall', '$recallScore/3'),
                        _buildQuestionRow(
                          'Ask for names of 3 objects learned earlier.',
                          3,
                          recallScore,
                          (value) => setState(() => recallScore = value),
                        ),

                        // Section 5: Language
                        _buildSectionHeader('Section 5: Language', '$languageTotal/8'),
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
                          'Give a 3 stage command. Score 1 for each stage.',
                          3,
                          commandScore,
                          (value) => setState(() => commandScore = value),
                        ),
                        _buildQuestionRow(
                          'Ask patient to read and obey "Close your eyes".',
                          1,
                          readingScore,
                          (value) => setState(() => readingScore = value),
                        ),
                        _buildQuestionRow(
                          'Ask the patient to write a sensible sentence.',
                          1,
                          writingScore,
                          (value) => setState(() => writingScore = value),
                        ),

                        // Section 6: Copying
                        _buildSectionHeader('Section 6: Copying', '$copyingScore/1'),
                        _buildQuestionRow(
                          'Ask the patient to copy intersecting pentagons.',
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
              ],
            ),
            
            // Floating score card
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Total MMSE Score: ',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '$totalScore/30',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String score) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                score,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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
            flex: 7, // Increased from 3 to 7 to fix overflow
            child: Text(question),
          ),
          Container(
            width: 100, // Fixed width to prevent overflow
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('Score: '),
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

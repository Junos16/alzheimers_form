import 'package:flutter/material.dart';

class ADLForm extends StatefulWidget {
  const ADLForm({Key? key}) : super(key: key);

  @override
  _ADLFormState createState() => _ADLFormState();
}

class _ADLFormState extends State<ADLForm> {
  // Initialize scores
  int totalScore = 0;

  // Individual scores
  bool bathingScore = false;
  bool dressingScore = false;
  bool toiletingScore = false;
  bool transferringScore = false;
  bool continenceScore = false;
  bool feedingScore = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _updateTotalScore();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _updateTotalScore() {
    setState(() {
      totalScore =
          (bathingScore ? 1 : 0) +
          (dressingScore ? 1 : 0) +
          (toiletingScore ? 1 : 0) +
          (transferringScore ? 1 : 0) +
          (continenceScore ? 1 : 0) +
          (feedingScore ? 1 : 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ADL Assessment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
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
                  title: const Text('ADL Assessment'),
                  pinned: true,
                  floating: true,
                  leading: Builder(
                    builder: (context) {
                      return IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.of(context).pop(),
                      );
                    },
                  ),
                ),

                // Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10), // Space for floating header
                        // Bathing
                        _buildADLItem(
                          title: 'Bathing',
                          description:
                              'Bathes self completely or needs help in bathing only a single part of the body such as the back, genital area or disabled extremity.',
                          negativeDescription:
                              'Need help with bathing more than one part of the body, getting in or out of the tub or shower. Requires total bathing.',
                          value: bathingScore,
                          onChanged: (value) {
                            setState(() {
                              bathingScore = value;
                              _updateTotalScore();
                            });
                          },
                        ),

                        // Dressing
                        _buildADLItem(
                          title: 'Dressing',
                          description:
                              'Get clothes from closets and drawers and puts on clothes and outer garments complete with fasteners. May have help tying shoes.',
                          negativeDescription:
                              'Needs help with dressing self or needs to be completely dressed.',
                          value: dressingScore,
                          onChanged: (value) {
                            setState(() {
                              dressingScore = value;
                              _updateTotalScore();
                            });
                          },
                        ),

                        // Toileting
                        _buildADLItem(
                          title: 'Toileting',
                          description:
                              'Goes to toilet, gets on and off, arranges clothes, cleans genital area without help.',
                          negativeDescription:
                              'Needs help transferring to the toilet, cleaning self or uses bedpan or commode.',
                          value: toiletingScore,
                          onChanged: (value) {
                            setState(() {
                              toiletingScore = value;
                              _updateTotalScore();
                            });
                          },
                        ),

                        // Transferring
                        _buildADLItem(
                          title: 'Transferring',
                          description:
                              'Moves in and out of bed or chair unassisted. Mechanical transfer aids are acceptable.',
                          negativeDescription:
                              'Needs help in moving from bed to chair or requires a complete transfer.',
                          value: transferringScore,
                          onChanged: (value) {
                            setState(() {
                              transferringScore = value;
                              _updateTotalScore();
                            });
                          },
                        ),

                        // Continence
                        _buildADLItem(
                          title: 'Continence',
                          description:
                              'Exercises complete self control over urination and defecation.',
                          negativeDescription:
                              'Is partially or totally incontinent of bowel or bladder.',
                          value: continenceScore,
                          onChanged: (value) {
                            setState(() {
                              continenceScore = value;
                              _updateTotalScore();
                            });
                          },
                        ),

                        // Feeding
                        _buildADLItem(
                          title: 'Feeding',
                          description:
                              'Gets food from plate into mouth without help. Preparation of food may be done by another person.',
                          negativeDescription:
                              'Needs partial or total help with feeding or requires parenteral feeding.',
                          value: feedingScore,
                          onChanged: (value) {
                            setState(() {
                              feedingScore = value;
                              _updateTotalScore();
                            });
                          },
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
                                builder:
                                    (context) => AlertDialog(
                                      title: const Text(
                                        'ADL Assessment Result',
                                      ),
                                      content: Text(
                                        'Total Score: $totalScore/6',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.of(context).pop(),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
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
                        'Total ADL Score: ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$totalScore/6',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
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

  Widget _buildADLItem({
    required String title,
    required String description,
    required String negativeDescription,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and checkbox
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(7),
                topRight: Radius.circular(7),
              ),
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
                // Modern checkbox icon
                InkWell(
                  onTap: () => onChanged(!value),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: value ? Colors.green : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: value ? Colors.green : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child:
                        value
                            ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 22,
                            )
                            : null,
                  ),
                ),
              ],
            ),
          ),

          // Description
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4, right: 8),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          '1',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Expanded(child: Text(description)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4, right: 8),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          '0',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Expanded(child: Text(negativeDescription)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

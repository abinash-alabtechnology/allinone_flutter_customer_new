
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:handy_allinone/util/images.dart';

import 'TripDetails.dart';


class FindingDriverContent extends StatefulWidget {
  const FindingDriverContent({Key? key}) : super(key: key);

  @override
  State<FindingDriverContent> createState() => _FindingDriverContentState();
}

class _FindingDriverContentState extends State<FindingDriverContent> {
  final List<String> headings = [
    "Looking for the best drivers for you",
    "Checking nearby availability",
    "Finding a clean and safe ride",
    "Matching with top-rated drivers",
  ];

  int currentIndex = 0;
  double progressValue = 0.0;
  Timer? _headingTimer;
  Timer? _progressTimer;
  int? _selectedTipAmount;
  @override
  void initState() {
    super.initState();
    _startHeadingAnimation();
    _startProgressAnimation();
  }

  void _startHeadingAnimation() {
    _headingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      setState(() {
        currentIndex = (currentIndex + 1) % headings.length;
      });
    });
  }

  void _startProgressAnimation() {
    const totalDuration = Duration(minutes: 1);
    const tick = Duration(milliseconds: 100);
    final totalTicks = totalDuration.inMilliseconds ~/ tick.inMilliseconds;

    int tickCount = 0;
    _progressTimer = Timer.periodic(tick, (timer) {
      tickCount++;
      setState(() {
        progressValue = tickCount / totalTicks;
      });

      if (tickCount >= totalTicks) {
        timer.cancel();
        _navigateToTripDetails();
      }
    });
  }
  void _navigateToTripDetails() {
    Navigator.pop(context); // Close the current bottom sheet

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showModalBottomSheet(
        context: context,
        isDismissible: false,          // ✅ Prevents tapping outside to dismiss
        enableDrag: false,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return NotificationListener<DraggableScrollableNotification>(
            onNotification: (notification) {
              if (notification.extent > 0.7) {
                Navigator.pop(context); // Close the sheet
              }
              return true;
            },
            child:  WillPopScope(
              onWillPop: () async => false,
              child: DraggableScrollableSheet(
                initialChildSize: 0.35,
                minChildSize: 0.25,
                maxChildSize: 0.8,
                expand: false,
                builder: (_, scrollController) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      children: [
                        const Center(
                          child: Text(
                            "Your ride is confirmed.",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: Image.asset("assets/image/Bookauto.png", width: 50),
                          title: const Text("TN12P9540", style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Ape City"),
                              Row(
                                children: [
                                  Text("Subu M  "),
                                  Icon(Icons.star, color: Colors.amber, size: 16),
                                  Text(" 4.7"),
                                ],
                              ),
                            ],
                          ),
                          trailing: const CircleAvatar(
                            radius: 24,
                            backgroundImage: AssetImage(Images.driverIcon),
                          ),
                        ),
                        const Divider(),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.call),
                              onPressed: () {
                                // Implement call logic
                              },
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Message your driver...',
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  suffixIcon: const Icon(Icons.send),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      );
    });
  }

  @override
  void dispose() {
    _headingTimer?.cancel();
    _progressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Text(
              headings[currentIndex],
              key: ValueKey(currentIndex),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LinearProgressIndicator(
              minHeight: 12,
              value: progressValue,
              backgroundColor: Colors.grey[300],
              valueColor:
               AlwaysStoppedAnimation<Color>( Theme.of(context)
                  .primaryColor),
            ),
          ),

          const SizedBox(height: 20),
          Image.asset('assets/image/delivery_tip.png', height: 80),

          const SizedBox(height: 12),
          const Text(
            'Choose to Add On - Entire amount goes to your driver',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 16),


          // ✅ Selectable Tip Buttons
          // Wrap(
          //   spacing: 10,
          //   children: [10, 20, 30, 40].map((amount) {
          //     final bool isSelected = _selectedTipAmount == amount;
          //     return ElevatedButton(
          //       style: ElevatedButton.styleFrom(
          //         backgroundColor: isSelected ? Colors.greenAccent : Colors.white,
          //         foregroundColor: isSelected ? Colors.white : Colors.black,
          //         elevation: isSelected ? 4 : 2,
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(10),
          //         ),
          //       ),
          //       onPressed: () {
          //         setState(() {
          //           if (_selectedTipAmount == amount) {
          //             _selectedTipAmount = null; // unselect
          //           } else {
          //             _selectedTipAmount = amount; // select
          //           }
          //         });
          //       },
          //       child: Text('₹$amount'),
          //     );
          //   }).toList(),
          // ),
          Wrap(
            spacing: 10,
            children: [10, 20, 30, 40].map((amount) {
              final bool isSelected = _selectedTipAmount == amount;
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ?  Theme.of(context)
                      .primaryColor : Colors.white,
                  foregroundColor: isSelected ? Colors.white : Colors.black,
                  elevation: isSelected ? 4 : 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  side: BorderSide(
                    color: isSelected ? Theme.of(context)
                        .primaryColor : Colors.grey.shade400,
                    width: 1,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    // Toggle the tip amount
                    if (_selectedTipAmount == amount) {
                      _selectedTipAmount = null;
                    } else {
                      _selectedTipAmount = amount;
                    }
                  });
                },
                child: Text('₹$amount'),
              );
            }).toList(),
          ),


          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  showTripDetailBottomSheet(context ,0,"");
                  // _navigateToTripDetails(); // manually skip
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Trip Details",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

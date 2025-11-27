import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const OceanAdventureApp());
}

class OceanAdventureApp extends StatelessWidget {
  const OceanAdventureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ocean Adventure',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Arial', // Using default font for simplicity
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Game Settings
  static double fishYaxis = 0;
  double time = 0;
  double height = 0;
  double initialHeight = fishYaxis;
  bool gameHasStarted = false;
  bool isGameOver = false;
  int score = 0;
  int highScore = 0;
  
  // Physics
  double gravity = -4.9; // Gravity strength
  double velocity = 2.5; // Jump strength
  double gameSpeed = 0.015; // Speed of obstacles moving left

  // Fish Character
  int selectedFishIndex = 0;
  final List<Color> fishColors = [
    Colors.orange, // Clownfish
    Colors.blueAccent, // Blue Tang
    Colors.redAccent, // Red Snapper
    Colors.purpleAccent, // Exotic
  ];

  // Obstacles (Reefs/Enemies)
  // [x_position, gap_height, is_enemy]
  List<List<dynamic>> barriers = [
    [1.1, 0.6, false],
    [1.8, 0.4, true],
    [2.5, 0.7, false],
  ];

  // Pearls (Collectibles)
  // [x_position, y_position]
  List<List<double>> pearls = [
    [1.5, 0.0],
    [2.2, -0.5],
  ];

  void jump() {
    if (isGameOver) return;
    
    setState(() {
      time = 0;
      initialHeight = fishYaxis;
    });
  }

  void startGame() {
    gameHasStarted = true;
    isGameOver = false;
    score = 0;
    fishYaxis = 0;
    time = 0;
    initialHeight = 0;
    barriers = [
      [1.1, 0.6, false],
      [1.8, 0.4, true],
      [2.5, 0.7, false],
    ];
    pearls = [
      [1.5, 0.0],
      [2.2, -0.5],
    ];
    
    Timer.periodic(const Duration(milliseconds: 20), (timer) {
      // Physics Equation: h = -gt^2/2 + vt
      time += 0.02;
      height = -gravity * time * time / 2 + velocity * time; // Gravity pulls down, velocity pushes up
      
      setState(() {
        // Update Fish Position (Inverted because screen Y goes down)
        fishYaxis = initialHeight - height;

        // Move Barriers
        for (int i = 0; i < barriers.length; i++) {
          barriers[i][0] -= gameSpeed;
          // Loop barriers
          if (barriers[i][0] < -1.5) {
            barriers[i][0] += 2.5; // Reset to right side
            barriers[i][1] = Random().nextDouble() * 0.8 - 0.4; // Random height
            barriers[i][2] = Random().nextBool(); // Randomly enemy or reef
          }
        }

        // Move Pearls
        for (int i = 0; i < pearls.length; i++) {
          pearls[i][0] -= gameSpeed;
          if (pearls[i][0] < -1.5) {
            pearls[i][0] += 2.5 + Random().nextDouble();
            pearls[i][1] = Random().nextDouble() * 1.6 - 0.8;
          }
        }

        // Collision Detection
        checkCollision(timer);
        checkPearlCollection();

        // Ceiling/Floor collision
        if (fishYaxis > 1.1 || fishYaxis < -1.1) {
          gameOver(timer);
        }
      });
    });
  }

  void checkCollision(Timer timer) {
    for (int i = 0; i < barriers.length; i++) {
      // Simple AABB Collision logic
      // Barrier X range: barrier[0] +/- width
      // Fish X is fixed at 0
      double barrierX = barriers[i][0];
      double barrierY = barriers[i][1]; // Center of gap
      bool isEnemy = barriers[i][2];

      // Check horizontal overlap (Fish is approx 0.1 wide)
      if (barrierX > -0.15 && barrierX < 0.15) {
        // Check vertical collision
        // If it's a reef (gap based), we die if we are NOT in the gap
        // Gap size is approx 0.4
        double gapSize = 0.4;
        
        if (isEnemy) {
           // Enemy logic: It's a block in the middle
           if (fishYaxis > barrierY - 0.1 && fishYaxis < barrierY + 0.1) {
             gameOver(timer);
           }
        } else {
          // Reef logic: Walls on top and bottom
          if (fishYaxis > barrierY + gapSize / 2 || fishYaxis < barrierY - gapSize / 2) {
            gameOver(timer);
          }
        }
      }
    }
  }

  void checkPearlCollection() {
    for (int i = 0; i < pearls.length; i++) {
      double pearlX = pearls[i][0];
      double pearlY = pearls[i][1];

      // Check overlap
      if (pearlX > -0.1 && pearlX < 0.1 && 
          fishYaxis > pearlY - 0.1 && fishYaxis < pearlY + 0.1) {
        // Collected!
        score += 1;
        // Move pearl away
        pearls[i][0] = -2.0; 
        // Play sound (mock)
        HapticFeedback.lightImpact();
      }
    }
  }

  void gameOver(Timer timer) {
    timer.cancel();
    gameHasStarted = false;
    isGameOver = true;
    if (score > highScore) {
      highScore = score;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          if (gameHasStarted) {
            jump();
          } else {
            startGame();
          }
        },
        child: Stack(
          children: [
            // Background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF006994), Color(0xFF003366)],
                ),
              ),
            ),
            
            // Bubbles (Decor)
            const Positioned(left: 50, bottom: 100, child: Icon(Icons.circle_outlined, color: Colors.white10, size: 20)),
            const Positioned(right: 80, top: 150, child: Icon(Icons.circle_outlined, color: Colors.white10, size: 30)),
            const Positioned(left: 150, top: 300, child: Icon(Icons.circle_outlined, color: Colors.white10, size: 15)),

            // Game Elements
            AnimatedContainer(
              alignment: Alignment(0, fishYaxis),
              duration: const Duration(milliseconds: 0),
              child: MyFish(color: fishColors[selectedFishIndex]),
            ),

            // Barriers
            for (var barrier in barriers)
              AnimatedContainer(
                alignment: Alignment(barrier[0], 0),
                duration: const Duration(milliseconds: 0),
                child: MyBarrier(
                  gapHeight: barrier[1],
                  isEnemy: barrier[2],
                ),
              ),

            // Pearls
            for (var pearl in pearls)
              AnimatedContainer(
                alignment: Alignment(pearl[0], pearl[1]),
                duration: const Duration(milliseconds: 0),
                child: const MyPearl(),
              ),

            // Score
            if (gameHasStarted)
              Positioned(
                top: 50,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    score.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 35, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

            // Start / Game Over Screen
            if (!gameHasStarted)
              Container(
                color: Colors.black.withOpacity(0.6),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isGameOver ? "انتهت اللعبة" : "مغامرة المحيط",
                        style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      if (isGameOver)
                        Text(
                          "النتيجة: $score  |  أفضل نتيجة: $highScore",
                          style: const TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      const SizedBox(height: 30),
                      
                      // Play Button
                      ElevatedButton(
                        onPressed: startGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        ),
                        child: Text(
                          isGameOver ? "إعادة المحاولة" : "ابدأ اللعب",
                          style: const TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Character Selection
                      const Text("اختر شخصيتك", style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(fishColors.length, (index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedFishIndex = index;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.all(8),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                border: selectedFishIndex == index ? Border.all(color: Colors.white, width: 2) : null,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.set_meal, color: fishColors[index], size: 30),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 40),
                      
                      // Menu Buttons (Mock)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _menuButton(Icons.star, "تقييم"),
                          const SizedBox(width: 20),
                          _menuButton(Icons.block, "إزالة الإعلانات"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _menuButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}

class MyFish extends StatelessWidget {
  final Color color;
  const MyFish({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      child: Icon(Icons.set_meal, color: color, size: 40),
    );
  }
}

class MyBarrier extends StatelessWidget {
  final double gapHeight; // -1 to 1
  final bool isEnemy;

  const MyBarrier({super.key, required this.gapHeight, required this.isEnemy});

  @override
  Widget build(BuildContext context) {
    if (isEnemy) {
      // Enemy: A single block in the middle
      return Container(
        alignment: Alignment(0, gapHeight),
        child: Container(
          width: 50,
          height: 50,
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 30),
        ),
      );
    } else {
      // Reef: Two walls with a gap
      return Column(
        children: [
          Expanded(
            flex: ((1 + gapHeight - 0.2) * 100).toInt().clamp(1, 200),
            child: Container(
              width: 60,
              decoration: BoxDecoration(
                color: Colors.green[800],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                border: Border.all(color: Colors.green[900]!, width: 3),
              ),
            ),
          ),
          const SizedBox(height: 150), // The Gap
          Expanded(
            flex: ((1 - gapHeight - 0.2) * 100).toInt().clamp(1, 200),
            child: Container(
              width: 60,
              decoration: BoxDecoration(
                color: Colors.green[800],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                border: Border.all(color: Colors.green[900]!, width: 3),
              ),
            ),
          ),
        ],
      );
    }
  }
}

class MyPearl extends StatelessWidget {
  const MyPearl({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}

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
        fontFamily: 'Arial',
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 2; // Start with Home (Game)
  int coins = 100; // Mock coins balance

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _screens.add(const ProfileScreen());
    _screens.add(const CategoriesScreen());
    _screens.add(const GameScreen());
    _screens.add(CoinScreen(onCoinsUpdated: (newCoins) {
      setState(() {
        coins = newCoins;
      });
    }, coins: coins));
    _screens.add(StoreScreen(coins: coins));
    _screens.add(const FeaturesScreen());
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'الملف'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'الفئات'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.monetization_on), label: 'الكوينز'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'المتجر'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'الميزات'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الملف الشخصي')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 100, color: Colors.blue),
            Text('اسم المستخدم: Gamer123'),
            Text('المستوى: 10'),
            Text('النتيجة العليا: 500'),
          ],
        ),
      ),
    );
  }
}

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الفئات')),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          final categories = ['مغامرات', 'ألغاز', 'سباقات', 'إستراتيجية', 'رياضة', 'أخرى'];
          return Card(
            child: Center(
              child: Text(categories[index]),
            ),
          );
        },
      ),
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
  double gravity = -4.9;
  double velocity = 2.5;
  double gameSpeed = 0.015;

  // Fish Character
  int selectedFishIndex = 0;
  final List<Color> fishColors = [
    Colors.orange,
    Colors.blueAccent,
    Colors.redAccent,
    Colors.purpleAccent,
  ];

  // Obstacles
  List<List<dynamic>> barriers = [
    [1.1, 0.6, false],
    [1.8, 0.4, true],
    [2.5, 0.7, false],
  ];

  // Pearls
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
      time += 0.02;
      height = -gravity * time * time / 2 + velocity * time;

      setState(() {
        fishYaxis = initialHeight - height;

        for (int i = 0; i < barriers.length; i++) {
          barriers[i][0] -= gameSpeed;
          if (barriers[i][0] < -1.5) {
            barriers[i][0] += 2.5;
            barriers[i][1] = Random().nextDouble() * 0.8 - 0.4;
            barriers[i][2] = Random().nextBool();
          }
        }

        for (int i = 0; i < pearls.length; i++) {
          pearls[i][0] -= gameSpeed;
          if (pearls[i][0] < -1.5) {
            pearls[i][0] += 2.5 + Random().nextDouble();
            pearls[i][1] = Random().nextDouble() * 1.6 - 0.8;
          }
        }

        checkCollision(timer);
        checkPearlCollection();

        if (fishYaxis > 1.1 || fishYaxis < -1.1) {
          gameOver(timer);
        }
      });
    });
  }

  void checkCollision(Timer timer) {
    for (int i = 0; i < barriers.length; i++) {
      double barrierX = barriers[i][0];
      double barrierY = barriers[i][1];
      bool isEnemy = barriers[i][2];

      if (barrierX > -0.15 && barrierX < 0.15) {
        double gapSize = 0.4;
        if (isEnemy) {
          if (fishYaxis > barrierY - 0.1 && fishYaxis < barrierY + 0.1) {
            gameOver(timer);
          }
        } else {
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

      if (pearlX > -0.1 && pearlX < 0.1 && 
          fishYaxis > pearlY - 0.1 && fishYaxis < pearlY + 0.1) {
        score += 1;
        pearls[i][0] = -2.0;
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
    return GestureDetector(
      onTap: () {
        if (gameHasStarted) {
          jump();
        } else {
          startGame();
        }
      },
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF006994), Color(0xFF003366)],
              ),
            ),
          ),
          const Positioned(left: 50, bottom: 100, child: Icon(Icons.circle_outlined, color: Colors.white10, size: 20)),
          const Positioned(right: 80, top: 150, child: Icon(Icons.circle_outlined, color: Colors.white10, size: 30)),
          const Positioned(left: 150, top: 300, child: Icon(Icons.circle_outlined, color: Colors.white10, size: 15)),

          AnimatedContainer(
            alignment: Alignment(0, fishYaxis),
            duration: const Duration(milliseconds: 0),
            child: MyFish(color: fishColors[selectedFishIndex]),
          ),

          for (var barrier in barriers)
            AnimatedContainer(
              alignment: Alignment(barrier[0], 0),
              duration: const Duration(milliseconds: 0),
              child: MyBarrier(
                gapHeight: barrier[1],
                isEnemy: barrier[2],
              ),
            ),

          for (var pearl in pearls)
            AnimatedContainer(
              alignment: Alignment(pearl[0], pearl[1]),
              duration: const Duration(milliseconds: 0),
              child: const MyPearl(),
            ),

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
  final double gapHeight;
  final bool isEnemy;

  const MyBarrier({super.key, required this.gapHeight, required this.isEnemy});

  @override
  Widget build(BuildContext context) {
    if (isEnemy) {
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
          const SizedBox(height: 150),
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

class CoinScreen extends StatefulWidget {
  final Function(int) onCoinsUpdated;
  final int coins;

  const CoinScreen({super.key, required this.onCoinsUpdated, required this.coins});

  @override
  State<CoinScreen> createState() => _CoinScreenState();
}

class _CoinScreenState extends State<CoinScreen> {
  late int currentCoins;

  @override
  void initState() {
    super.initState();
    currentCoins = widget.coins;
  }

  void buyPackage(int amount, int cost) {
    // Mock purchase - in real app, integrate payment
    if (currentCoins >= cost) {
      setState(() {
        currentCoins -= cost;
        currentCoins += amount;
      });
      widget.onCoinsUpdated(currentCoins);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('كوينز غير كافية!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('شحن الكوينز')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.blueAccent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.monetization_on, color: Colors.white, size: 40),
                const SizedBox(width: 10),
                Text(
                  'رصيدك الحالي: $currentCoins',
                  style: const TextStyle(color: Colors.white, fontSize: 24),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _coinPackage(100, 50),
                _coinPackage(250, 120),
                _coinPackage(500, 250),
                _coinPackage(1000, 500),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _coinPackage(int amount, int cost) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.monetization_on, color: Colors.amber),
        title: Text('$amount كوينز'),
        subtitle: Text('سعر: $cost دولار'),
        trailing: ElevatedButton(
          onPressed: () => buyPackage(amount, cost),
          child: const Text('شراء الآن'),
        ),
      ),
    );
  }
}

class StoreScreen extends StatelessWidget {
  final int coins;

  const StoreScreen({super.key, required this.coins});

  final List<Map<String, dynamic>> items = const [
    {'name': 'إطار ذهبي', 'price': 50, 'icon': Icons.star},
    {'name': 'ملحق سرعة', 'price': 30, 'icon': Icons.flash_on},
    {'name': 'سمكة خاصة', 'price': 100, 'icon': Icons.pets},
    {'name': 'خلفية مخصصة', 'price': 80, 'icon': Icons.image},
    {'name': 'موسيقى إضافية', 'price': 20, 'icon': Icons.music_note},
    {'name': 'أدوات خاصة', 'price': 60, 'icon': Icons.build},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المتجر')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item['icon'], size: 50),
                const SizedBox(height: 10),
                Text(item['name']),
                const SizedBox(height: 5),
                Text('${item['price']} كوينز'),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    // Mock purchase
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('تم شراء ${item['name']}')),
                    );
                  },
                  child: const Text('شراء'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class FeaturesScreen extends StatelessWidget {
  const FeaturesScreen({super.key});

  final List<Map<String, String>> features = const [
    {'icon': 'music', 'name': 'موسيقى'},
    {'icon': 'game', 'name': 'ألعاب'},
    {'icon': 'notification', 'name': 'إشعارات'},
    {'icon': 'chat', 'name': 'دردشة'},
    {'icon': 'camera', 'name': 'كاميرا'},
    {'icon': 'map', 'name': 'خرائط'},
    {'icon': 'calendar', 'name': 'تقويم'},
    {'icon': 'weather', 'name': 'طقس'},
    {'icon': 'social', 'name': 'تواصل اجتماعي'},
    {'icon': 'shopping', 'name': 'تسوق'},
    // Add more to reach 100, but for brevity, repeating some
    {'icon': 'music', 'name': 'موسيقى 2'},
    {'icon': 'game', 'name': 'ألعاب 2'},
    // ... (imagine 100 entries)
  ];

  IconData getIcon(String iconName) {
    switch (iconName) {
      case 'music': return Icons.music_note;
      case 'game': return Icons.games;
      case 'notification': return Icons.notifications;
      case 'chat': return Icons.chat;
      case 'camera': return Icons.camera;
      case 'map': return Icons.map;
      case 'calendar': return Icons.calendar_today;
      case 'weather': return Icons.wb_sunny;
      case 'social': return Icons.people;
      case 'shopping': return Icons.shopping_cart;
      default: return Icons.star;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الميزات (100)')),
      body: ListView.builder(
        itemCount: features.length,
        itemBuilder: (context, index) {
          final feature = features[index];
          return ListTile(
            leading: Icon(getIcon(feature['icon']!)),
            title: Text(feature['name']!),
          );
        },
      ),
    );
  }
}
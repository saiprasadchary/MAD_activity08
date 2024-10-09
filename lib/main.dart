


import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';

void main() {
  runApp(SpookyHalloweenGame());
}

class SpookyHalloweenGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spooky Halloween Game',
      theme: ThemeData.dark(),
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late AudioPlayer _audioPlayer;
  List<AnimationController> _controllerGhosts = [];
  List<AnimationController> _controllerPumpkins = [];
  List<AnimationController> _controllerBats = [];
  bool _hasWon = false;
  int _totalItems = 15;  // Total number of items: 5 ghosts, 5 pumpkins, 5 bats

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    // Create controllers for the 5 ghosts
    for (int i = 0; i < 5; i++) {
      _controllerGhosts.add(AnimationController(
        vsync: this,
        duration: Duration(seconds: Random().nextInt(3) + 2),
      )..repeat(reverse: true));
    }

    // Create controllers for the 5 pumpkins
    for (int i = 0; i < 5; i++) {
      _controllerPumpkins.add(AnimationController(
        vsync: this,
        duration: Duration(seconds: Random().nextInt(3) + 2),
      )..repeat(reverse: true));
    }

    // Create controllers for the 5 bats
    for (int i = 0; i < 5; i++) {
      _controllerBats.add(AnimationController(
        vsync: this,
        duration: Duration(seconds: Random().nextInt(3) + 2),
      )..repeat(reverse: true));
    }

    _playBackgroundMusic(); // Play looping background music
  }

  // Play background music in a loop
  void _playBackgroundMusic() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(AssetSource('spooky_halloween.mp3'));
  }

  // Play sound effect based on the asset path
  void _playSoundEffect(String path) async {
    await _audioPlayer.play(AssetSource(path));
  }

  // Handle click events to trigger traps or winning item
  void _handleClick({bool isTrap = false}) {
    if (isTrap) {
      _playSoundEffect('jump_scare.mp3');
    } else {
      _playSoundEffect('success.mp3');
      _showSuccessMessage();
      setState(() {
        _hasWon = true;
      });
    }
  }

  // Show success message when the player wins
  void _showSuccessMessage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text("You Found It!", style: TextStyle(fontSize: 24)),
          actions: <Widget>[
            TextButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _controllerGhosts.forEach((controller) => controller.dispose());
    _controllerPumpkins.forEach((controller) => controller.dispose());
    _controllerBats.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Spooky Halloween Game'),
      ),
      body: Stack(
        children: [
          // Display status message (won or not)
          Center(
            child: Text(
              _hasWon ? "You Won!" : "Find the hidden item!",
              style: TextStyle(fontSize: 24),
            ),
          ),

          // 5 Ghosts (trap items)
          for (int i = 0; i < 5; i++)
            _buildMovingItem(
              controller: _controllerGhosts[i],
              imagePath: 'assets/ghost.png',
              glowColor: Colors.blueAccent,
              isTrap: true,
            ),

          // 5 Pumpkins (one of them is the hidden item)
          for (int i = 0; i < 5; i++)
            _buildMovingItem(
              controller: _controllerPumpkins[i],
              imagePath: 'assets/pumpkin.png',
              glowColor: Colors.orangeAccent,
              isTrap: i != 2,  // The third pumpkin is the winning item
            ),

          // 5 Bats (trap items)
          for (int i = 0; i < 5; i++)
            _buildMovingItem(
              controller: _controllerBats[i],
              imagePath: 'assets/bat.png',
              glowColor: Colors.purpleAccent,
              isTrap: true,
            ),
        ],
      ),
    );
  }

  // Function to create animated moving items with a glow effect
  Widget _buildMovingItem({
    required AnimationController controller,
    required String imagePath,
    required Color glowColor,
    required bool isTrap,
  }) {
    return Positioned(
      top: Random().nextDouble() * MediaQuery.of(context).size.height,
      left: Random().nextDouble() * MediaQuery.of(context).size.width,
      child: GestureDetector(
        onTap: () => _handleClick(isTrap: isTrap),
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                50 * sin(controller.value * 2 * pi),  // Horizontal movement
                50 * cos(controller.value * 2 * pi),  // Vertical movement
              ),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: glowColor.withOpacity(0.8),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Image.asset(imagePath, width: 100, height: 100),
              ),
            );
          },
        ),
      ),
    );
  }
}

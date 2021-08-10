import 'dart:math';
import 'dart:ui';

import 'package:fast_game/components/enemy.dart';
import 'package:fast_game/components/health_bar.dart';
import 'package:fast_game/components/highscore_text.dart';
import 'package:fast_game/components/player.dart';
import 'package:fast_game/components/score_text.dart';
import 'package:fast_game/components/start_button.dart';
import 'package:fast_game/enemy_spawner.dart';
import 'package:fast_game/state.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameController extends BaseGame with TapDetector {
  final SharedPreferences storage;
  Random rand;
  Size screenSize;
  double tileSize;
  Player player;
  List<Enemy> enemies;
  HealthBar healthBar;
  EnemySpawner enemySpawner;
  int score;
  ScoreText scoreText;
  GameState state;
  HighscoreText highscoreText;
  StartButton startButton;

  GameController(this.storage) {
    initialize();
  }

  void initialize() async {
    resize(await Flame.util.initialDimensions());
    rand = Random();
    state = GameState.menu;
    player = Player(this);
    enemies = [];
    enemySpawner = EnemySpawner(this);
    healthBar = HealthBar(this);
    score = 0;
    scoreText = ScoreText(this);
    highscoreText = HighscoreText(this);
    startButton = StartButton(this);
  }

  void render(Canvas c) {
    super.render(c);
    Rect background = Rect.fromLTRB(0, 0, screenSize.width, screenSize.height);
    Paint backgroundPaint = Paint()..color = Color(0xFFFCE4EC);
    c.drawRect(background, backgroundPaint);

    player.render(c);
    if (state == GameState.menu) {
      startButton.render(c);
      highscoreText.render(c);
    } else if (state == GameState.playing) {
      enemies.forEach((Enemy enemy) => enemy.render(c));
      scoreText.render(c);
      healthBar.render(c);
    }
  }

  @override
  void update(double t) {
    super.update(t);
    if (state == GameState.menu) {
      startButton.update(t);
      highscoreText.update(t);
    } else if (state == GameState.playing) {
      enemySpawner.update(t);
      enemies.forEach((Enemy enemy) => enemy.update(t));
      enemies.removeWhere((Enemy enemy) => enemy.isDead);
      player.update(t);
      scoreText.update(t);
      healthBar.update(t);
    }
  }

  void resize(Size size) {
    super.resize(size);
    screenSize = size;
    tileSize = screenSize.width / 10;
  }

  @override
  void onTapDown(TapDownDetails d) {
    if (state == GameState.menu) {
      state = GameState.playing;
    } else if (state == GameState.playing) {
      enemies.forEach((Enemy enemy) {
        if (enemy.enemyRect.contains(d.globalPosition)) {
          enemy.onTapDown();
        }
      });
    }
  }

  void spawnEnemy() {
    double x, y;
    switch (rand.nextInt(4)) {
      case 0:
        // Top
        x = rand.nextDouble() * screenSize.width;
        y = -tileSize * 2.5;
        break;
      case 1:
        // Right
        x = screenSize.width + tileSize * 2.5;
        y = rand.nextDouble() * screenSize.height;
        break;
      case 2:
        // Bottom
        x = rand.nextDouble() * screenSize.width;
        y = screenSize.height + tileSize * 2.5;
        break;
      case 3:
        // Left
        x = -tileSize * 2.5;
        y = rand.nextDouble() * screenSize.height;
        break;
    }
    enemies.add(Enemy(this, x, y));
  }
}

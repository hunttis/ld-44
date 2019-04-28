package states;

import flixel.system.FlxSound;
import flixel.FlxState;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class GameOverState extends FlxState {

  private var gameOverText: FlxText;
  private var continueText: FlxText;
  private var gameoverSound: FlxSound;
  private var soundPlayed: Bool = false;

  override public function create(): Void {
    super.create();
    createTitle();
    createInstructions();
    gameoverSound = FlxG.sound.load('assets/die.wav');
  }

  override public function update(elapsed: Float): Void {
    super.update(elapsed);
    if (!soundPlayed) {
      soundPlayed = true;
      gameoverSound.play();
    }
    Util.checkQuitKey();
    if (FlxG.keys.justPressed.SPACE) {
      FlxG.switchState(new MainMenuState());
    }
  }

  private function createTitle(): Void {
    gameOverText = new FlxText(FlxG.width / 2, 100, "Game over!", 64);
    gameOverText.x -= gameOverText.width / 2;
    gameOverText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.RED, 2, 1);
    add(gameOverText);
  }

  private function createInstructions(): Void {
    continueText = new FlxText(FlxG.width / 2, 300, "Press space to return to main menu", 16);
    continueText.x -= continueText.width / 2;
    add(continueText);
  }

}
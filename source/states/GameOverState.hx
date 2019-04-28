package states;

import flixel.effects.particles.FlxEmitter;
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
  private var bloodEmitter: FlxEmitter;

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
    bloodEmitter = createBloodEmitter();
    add(bloodEmitter);
    add(gameOverText);
  }

  private function createInstructions(): Void {
    continueText = new FlxText(FlxG.width / 2, 300, "Press space to return to main menu", 16);
    continueText.x -= continueText.width / 2;
    add(continueText);
  }

    private function createBloodEmitter() {
    var emitter = new FlxEmitter(0, 0, 100);
    emitter.loadParticles('assets/blood.png', 100);
    emitter.setSize(gameOverText.width, gameOverText.height);
    emitter.lifespan.set(1, 2);
    emitter.alpha.set(0.75, 1, 0, 0);
    emitter.scale.set(0.5, 0.5, 1, 1, 1, 1, 1.5, 1.5);
    emitter.launchMode = FlxEmitterMode.SQUARE;
    emitter.velocity.set(0, 100, 0, 200, 0, 100, 0, 200);
    emitter.setPosition(gameOverText.x, gameOverText.y);
    return emitter;
  }


}
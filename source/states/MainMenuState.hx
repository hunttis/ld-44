package states;

import flixel.effects.particles.FlxEmitter;
import flixel.FlxState;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import states.Util;

class MainMenuState extends FlxState {

  private var titleText: FlxText;
  private var startText: FlxText;
  private var bloodEmitter: FlxEmitter;

  override public function create(): Void {
    super.create();
    createTitle();
    createInstructions();
    Util.startMusic();
  }

  override public function update(elapsed: Float): Void {
    super.update(elapsed);
    Util.checkQuitKey();
    if (FlxG.keys.justPressed.SPACE) {
      FlxG.switchState(new InstructionsState());
    }
    bloodEmitter.start(true, 0.1, 1);
  }

  private function createTitle(): Void {
    titleText = new FlxText(FlxG.width / 2, 50, "    Don't wake a\nsleeping vampire", 48);
    titleText.x -= titleText.width / 2;
    titleText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.GRAY, 2, 1);
    bloodEmitter = createBloodEmitter();
    add(bloodEmitter);
    add(titleText);
  }

  private function createInstructions(): Void {
    var soundInstructions = new FlxText(FlxG.width / 2, 400, "Zero disables sounds, + and - control volume", 16);
    soundInstructions.x -= soundInstructions.width / 2;
    add(soundInstructions);
    startText = new FlxText(FlxG.width / 2, 300, "Press space to start", 16);
    startText.x -= startText.width / 2;
    add(startText);
  }

  private function createBloodEmitter() {
    var emitter = new FlxEmitter(0, 0, 100);
    emitter.loadParticles('assets/blood.png', 100);
    emitter.setSize(titleText.width, titleText.height);
    emitter.lifespan.set(1, 2);
    emitter.alpha.set(0.75, 1, 0, 0);
    emitter.scale.set(0.5, 0.5, 1, 1, 1, 1, 1.5, 1.5);
    emitter.launchMode = FlxEmitterMode.SQUARE;
    emitter.velocity.set(0, 100, 0, 200, 0, 100, 0, 200);
    emitter.setPosition(titleText.x, titleText.y);
    return emitter;
  }

}
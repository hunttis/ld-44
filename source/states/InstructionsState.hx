package states;

import flixel.effects.particles.FlxEmitter;
import flixel.FlxState;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import states.Util;

class InstructionsState extends FlxState {

  private var titleText: FlxText;
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
      FlxG.switchState(new PlayState());
    }
    bloodEmitter.start(true, 0.1, 1);
  }

  private function createTitle(): Void {
    titleText = new FlxText(FlxG.width / 2, 50, "Instructions", 32);
    titleText.x -= titleText.width / 2;
    titleText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.GRAY, 2, 1);
    bloodEmitter = createBloodEmitter();
    add(bloodEmitter);
    add(titleText);
  }

  private function createInstructions(): Void {
    var soundInstructions = new FlxText(100, 150, "ARROW KEYS: control character", 16);
    add(soundInstructions);
    var meldText = new FlxText(100, 200, "SPACE: meld with shadows and step out of them", 16);
    add(meldText);
    var stunText = new FlxText(100, 250, "DOWN: While jumping to dive down and stun an enemy.", 16);
    add(stunText);
    var meldText2 = new FlxText(100, 300, "Kill all enemies by ambushing them with meld shadows.\nMelding in or out kills them", 16);
    add(meldText2);
    var drainText = new FlxText(100, 360, "Beware! Using powers (meld and stun) drains your life!", 16);
    add(drainText);
    var restartText = new FlxText(100, 450, "Pressing R restarts a level. Pressing 9 skips a level. You can also use a gamepad to play.", 12);
    add(restartText);
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
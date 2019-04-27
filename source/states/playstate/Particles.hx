package states.playstate;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxColor;
import flixel.effects.particles.FlxParticle;
import flixel.math.FlxPoint;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.effects.particles.FlxEmitter;
import flixel.group.FlxGroup;
import states.playstate.particles.Smoke;

class Particles extends FlxGroup {

  var parent: GameLevel;
  var smokeEmitter: FlxEmitter;
  var bloodEmitter: FlxEmitter;
  var listener: FlxTypedSignal<FlxPoint->Void>;

  public function new(parent: GameLevel) {
    super();
    this.parent = parent;
    smokeEmitter = createSmokeEmitter();
    this.add(smokeEmitter);

    bloodEmitter = createBloodEmitter();
    this.add(bloodEmitter);
  }

  override public function update(elapsed: Float) {
    FlxG.collide(parent.levelMap.getForegroundLayer(), bloodEmitter);
    FlxG.collide(parent.levelMap.getForegroundLayer(), smokeEmitter);
    super.update(elapsed);
  }

  private function createSmokeEmitter() {
    var emitter = new FlxEmitter(0, 0, 100);
    emitter.makeParticles(8, 8, FlxColor.fromRGB(80, 80, 80, 180), 100);
    emitter.setSize(16, 16);
    emitter.lifespan.set(1, 2);
    emitter.alpha.set(0.75, 1, 0, 0);
    emitter.allowCollisions = FlxObject.FLOOR | FlxObject.WALL;
    return emitter;
  }

  private function createBloodEmitter() {
    var emitter = new FlxEmitter(0, 0, 100);
    emitter.makeParticles(3, 3, FlxColor.RED, 100);
    emitter.setSize(16, 16);
    emitter.lifespan.set(1, 2);
    emitter.alpha.set(0.75, 1, 0, 0);
    emitter.allowCollisions = FlxObject.FLOOR | FlxObject.WALL;
    return emitter;
  }

  public function smokePuff(xLoc: Float, yLoc: Float) {
    smokeEmitter.setPosition(xLoc, yLoc);
    smokeEmitter.start(true, 0.1 , 30);
  }

  public function sprayBlood(xLoc: Float, yLoc: Float) {
    bloodEmitter.setPosition(xLoc, yLoc);
    bloodEmitter.start(false, 0.02, 20);
  }

  public function risingSmoke() {

  }

}

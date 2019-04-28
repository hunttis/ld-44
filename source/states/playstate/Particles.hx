package states.playstate;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.effects.particles.FlxEmitter;
import flixel.group.FlxGroup;

class Particles extends FlxGroup {

  var parent: GameLevel;
  var smokeEmitter: FlxEmitter;
  var bloodEmitter: FlxEmitter;
  var alertEmitter: FlxEmitter;
  var aggroEmitter: FlxEmitter;
  var sparkEmitter: FlxEmitter;
  var glitterEmitter: FlxEmitter;
  var listener: FlxTypedSignal<FlxPoint->Void>;

  public function new(parent: GameLevel) {
    super();
    this.parent = parent;

    smokeEmitter = createSmokeEmitter();
    this.add(smokeEmitter);

    bloodEmitter = createBloodEmitter();
    this.add(bloodEmitter);

    alertEmitter = createAlertEmitter();
    this.add(alertEmitter);

    aggroEmitter = createAggroEmitter();
    this.add(aggroEmitter);

    sparkEmitter = createSparkEmitter();
    this.add(sparkEmitter);

    glitterEmitter = createGlitterEmitter();
    this.add(glitterEmitter);
  }

  override public function update(elapsed: Float) {
    FlxG.collide(parent.levelMap.getForegroundLayer(), bloodEmitter);
    FlxG.collide(parent.levelMap.getForegroundLayer(), smokeEmitter);
    super.update(elapsed);
  }

  private function createSmokeEmitter() {
    var emitter = new FlxEmitter(0, 0, 100);
    emitter.loadParticles('assets/smoke.png', 100);
    emitter.lifespan.set(0.25, 0.5);
    emitter.alpha.set(0.75, 1, 0, 0);
    emitter.launchMode = FlxEmitterMode.SQUARE;
    emitter.allowCollisions = FlxObject.FLOOR | FlxObject.WALL;
    return emitter;
  }

  private function createBloodEmitter() {
    var emitter = new FlxEmitter(0, 0, 100);
    emitter.loadParticles('assets/blood.png', 100);
    emitter.setSize(16, 16);
    emitter.lifespan.set(1, 2);
    emitter.alpha.set(0.75, 1, 0, 0);
    emitter.scale.set(0.5, 0.5, 1, 1, 1, 1, 1.5, 1.5);
    emitter.launchMode = FlxEmitterMode.SQUARE;
    emitter.velocity.set(-20, -100, 20, 0, -10, -10, 10, 0);
    emitter.allowCollisions = FlxObject.FLOOR | FlxObject.WALL | FlxObject.CEILING;
    return emitter;
  }

  private function createAlertEmitter() {
    var emitter = new FlxEmitter(0, 0, 100);
    emitter.loadParticles('assets/alert.png', 10);
    emitter.setSize(1, 1);
    emitter.lifespan.set(1, 1);
    emitter.alpha.set(0.75, 1, 0, 0);
    emitter.scale.set(0.5, 0.5, 1, 1, 1, 1, 1.5, 1.5);
    emitter.launchMode = FlxEmitterMode.SQUARE;
    emitter.velocity.set(0, -10, 0, -10,0, 0, 0, 0);
    // emitter.allowCollisions = FlxObject.FLOOR | FlxObject.WALL | FlxObject.CEILING;
    return emitter;
  }

  private function createAggroEmitter() {
    var emitter = new FlxEmitter(0, 0, 100);
    emitter.loadParticles('assets/aggro.png', 10);
    emitter.setSize(1, 1);
    emitter.lifespan.set(1, 1);
    emitter.alpha.set(0.75, 1, 0, 0);
    emitter.scale.set(0.5, 0.5, 1, 1, 1, 1, 1.5, 1.5);
    emitter.launchMode = FlxEmitterMode.SQUARE;
    emitter.velocity.set(0, -50, 0, -50,0, 0, 0, 0);
    // emitter.allowCollisions = FlxObject.FLOOR | FlxObject.WALL | FlxObject.CEILING;
    return emitter;
  }

  private function createSparkEmitter() {
    var emitter = new FlxEmitter(0, 0, 100);
    emitter.makeParticles(2, 2, FlxColor.CYAN, 100);
    emitter.setSize(1, 1);
    emitter.lifespan.set(0, 1);
    // emitter.alpha.set(0.75, 1, 0, 0);
    // emitter.scale.set(0.5, 0.5, 1, 1, 1, 1, 1.5, 1.5);
    emitter.launchMode = FlxEmitterMode.SQUARE;
    emitter.velocity.set(-10, -10, 10, 10, 0, 0, 0, 0);
    // emitter.allowCollisions = FlxObject.FLOOR | FlxObject.WALL | FlxObject.CEILING;
    return emitter;
  }

  private function createGlitterEmitter() {
    var emitter = new FlxEmitter(0, 0, 100);
    emitter.makeParticles(2, 2, FlxColor.WHITE, 100);
    emitter.setSize(16, 32);
    emitter.scale.set(0.25, 0.25, 0.5, 0.5, 1, 1, 1.5, 1.5);
    emitter.angularVelocity.set(60, 60, 60, 60);
    emitter.lifespan.set(0.25, 0.3);
    emitter.alpha.set(0.75, 1, 0, 0);
    emitter.launchMode = FlxEmitterMode.SQUARE;
    emitter.velocity.set(-10, -10, 10, 10, 0, 0, 0, 0);
    // emitter.allowCollisions = FlxObject.FLOOR | FlxObject.WALL;
    return emitter;
  }

  public function smokePuff(xLoc: Float, yLoc: Float) {
    smokeEmitter.setSize(16, 32);
    smokeEmitter.velocity.set(-10, -10, 10, 0, -10, -10, 10, 0);
    smokeEmitter.setPosition(xLoc, yLoc - 16);
    smokeEmitter.scale.set(0.25, 0.25, 0.5, 0.5, 1, 1, 1.5, 1.5);
    smokeEmitter.start(true, 0.1 , 30);
  }

  public function smokeBlast(xLoc: Float, yLoc: Float) {
    smokeEmitter.setSize(16, 8);
    smokeEmitter.velocity.set(-100, -10, 100, 0, -10, -20, 10, 0);
    smokeEmitter.setPosition(xLoc, yLoc);
    smokeEmitter.scale.set(0.25, 0.25, 0.5, 0.5, 0.5, 0.5, 0.75, 0.75);
    smokeEmitter.start(true, 0.1 , 30);
  }

  public function sprayBlood(xLoc: Float, yLoc: Float) {
    bloodEmitter.setPosition(xLoc, yLoc);
    bloodEmitter.start(false, 0.02, 20);
  }

  public function alert(xLoc: Float, yLoc: Float) {
    alertEmitter.setPosition(xLoc + 8, yLoc - 8);
    alertEmitter.start(true, 1, 1);
  }

  public function aggro(xLoc: Float, yLoc: Float) {
    aggroEmitter.setPosition(xLoc + 8, yLoc - 8);
    aggroEmitter.start(true, 1, 1);
  }

  public function spark(xLoc: Float, yLoc: Float) {
    sparkEmitter.setPosition(xLoc, yLoc);
    sparkEmitter.start(true, 1, 1);
  }

  public function glitter(xLoc: Float, yLoc: Float) {
    glitterEmitter.setPosition(xLoc, yLoc);
    glitterEmitter.start(true, 0.1 , 1);
  }
}

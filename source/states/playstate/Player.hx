package states.playstate;

import flixel.system.FlxSound;
import flixel.tile.FlxTilemap;
import flixel.math.FlxPoint;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.FlxG;

enum PlayerState {
  Darkness;
  Smoke;
  Lit;
}

class Player extends FlxSprite {

  var parent: GameLevel;
  var enemies: FlxTypedGroup<Enemy>;
  var shadowPowerAvailable: Bool = true;
  var shadowPowerActive: Bool = false;
  var stunPowerAvailable: Bool = true;
  var stunPowerActive: Float = 0;
  var playerState: PlayerState;
  var defaultGravity: Float = 600;
  var shadowGravity: Float = 100;
  var defaultMaxVelocity: FlxPoint = new FlxPoint(200, 350);
  var shadowMaxVelocity: FlxPoint = new FlxPoint(0, 50);
  var maxHealth: Float = 100;
  
  var lightLayer: FlxTilemap;
  var isStandingInLight: Bool;
  var jumpSound: FlxSound;
  var smokeSound: FlxSound;
  var biteSound: FlxSound;
  var thumpSound: FlxSound;

  public function new(xLoc: Float, yLoc: Float, enemies: FlxTypedGroup<Enemy> ,lightLayer: FlxTilemap, parent: GameLevel) {
    super(xLoc, yLoc);
    loadGraphic('assets/player.png', true, 16, 32);
    animation.add('idle', [0, 0, 0, 3], 2, true);
    animation.add('walk', [0, 0, 1, 1, 0, 2], 5, true);
    animation.add('shadow', [3, 4], 5, false);
    animation.play('shadow');
    setFacingFlip(FlxObject.LEFT, true, false);
    setFacingFlip(FlxObject.RIGHT, false, false);
    acceleration.y = defaultGravity;
    maxVelocity.set(defaultMaxVelocity.x, defaultMaxVelocity.y);
    drag.x = maxVelocity.x;
    health = maxHealth;
    playerState = Darkness;
    this.enemies = enemies;
    this.lightLayer = lightLayer;
    this.parent = parent;
    jumpSound = FlxG.sound.load('assets/jump.wav');
    smokeSound = FlxG.sound.load('assets/smoke.wav');
    biteSound = FlxG.sound.load('assets/bite.wav');
    thumpSound = FlxG.sound.load('assets/thump.wav');
  }

  override public function update(elapsed: Float): Void {
    if (lightLayer != null) {
      isStandingInLight = lightLayer.overlaps(this);
    }
    
    if (isStandingInLight) {
      parent.particles.glitter(this.x, this.y);
    }

    if (isTouching(FlxObject.FLOOR) && stunPowerActive > 0) {
      parent.particles.smokeBlast(this.x, this.y + 24);
      stunPowerActive = 0;
      thumpSound.play();
    } else if (stunPowerActive > 0) {
      checkStun();
      stunPowerActive -= elapsed;
      parent.particles.spark(this.x +4, this.y);
    }

    if (playerState == Darkness && isStandingInLight) {
      playerState = Lit;
    } else if (playerState == Lit && !isStandingInLight) {
      playerState = Darkness;
    }

    if (Math.abs(velocity.x) > 0 && !shadowPowerActive) {
      animation.play('walk');
    } else if (velocity.x == 0 && !shadowPowerActive) {
      animation.play('idle');
    }

    acceleration.x = 0;
    checkKeys();
    checkGamepads();

    if (acceleration.x == 0) {
      velocity.x = velocity.x * 0.9;
    }

    if (shadowPowerActive) {
      health -= elapsed;
    }

    super.update(elapsed);
  }

  private function checkKeys(): Void {
    if (FlxG.keys.pressed.UP) {
      jump();
    }
    
    if (FlxG.keys.justPressed.DOWN) {
      dive();
    }

    if (FlxG.keys.pressed.LEFT ) {
      moveLeft();
    } else if (FlxG.keys.pressed.RIGHT ) {
      moveRight();
    }

    if (FlxG.keys.justPressed.SPACE) {
      checkPower();
    }
  }

  private function checkGamepads(): Void {
    var gamepad = FlxG.gamepads.lastActive;

    if (gamepad == null) {
      return;
    }

    if (gamepad.justPressed.A || gamepad.justPressed.DPAD_UP) {
      jump();
    }
    if (gamepad.justPressed.Y || gamepad.justPressed.DPAD_DOWN) {
      dive();
    }

    if (gamepad.pressed.DPAD_LEFT) {
      moveLeft();
    } else if (gamepad.pressed.DPAD_RIGHT) {
      moveRight();
    }

    if (gamepad.justPressed.B) {
      checkPower();
    }

  }

  private function moveLeft() {
    acceleration.x = -maxVelocity.x * 2;
    facing = FlxObject.LEFT;
  }

  private function moveRight() {
    acceleration.x = maxVelocity.x * 2;
    facing = FlxObject.RIGHT;
    
  }

  private function jump() {
    if (isTouching(FlxObject.FLOOR) && !shadowPowerActive) {
      jumpSound.play();
      velocity.y = -maxVelocity.y;
    }
  }

  private function dive() {
    if (!isTouching(FlxObject.FLOOR)) {
      velocity.y = maxVelocity.y;
      stunPowerActive = 1;
    }
  }

  private function checkPower() {
    if (shadowPowerAvailable && !shadowPowerActive) {
      shadowPowerActive = true;
      
      playerState = Smoke;
      velocity.x = 0;
      if (velocity.y < 0) {
        velocity.y = velocity.y / 4;
      }
      acceleration.y = shadowGravity;
      maxVelocity.set(shadowMaxVelocity.x, shadowMaxVelocity.y);
      parent.particles.smokePuff(this.x, this.getGraphicMidpoint().y - 4);
      animation.play('shadow');
      alpha = 0.5;
      smokeSound.play(true);
      FlxG.overlap(this, this.enemies, usePowerOnEnemy);
    } else if (shadowPowerAvailable && shadowPowerActive) {
      playerState = Darkness;
      shadowPowerActive = false;
      animation.play('idle');
      FlxG.overlap(this, this.enemies, usePowerOnEnemy);
      acceleration.y = defaultGravity;
      maxVelocity.set(defaultMaxVelocity.x, defaultMaxVelocity.y);
      alpha = 1;
    }
  }

  private function checkStun() {
    if (stunPowerActive > 0) {
      FlxG.overlap(this, this.enemies, stunEnemy);
    }
  }

  private function usePowerOnEnemy(player, enemy: Enemy) {
    if (shadowPowerActive || (!shadowPowerActive && enemy.isStunned())) {
      if (enemy.devour()) {
        biteSound.play(true);
        addHealth(10);
        parent.particles.sprayBlood(enemy.x, enemy.y);
      }
    }
  }

  private function stunEnemy(player, enemy: Enemy) {
    if (enemy.stun()) {
      biteSound.play(true);
    }
  }

  private function addHealth(amount: Float) {
    health += amount;
    if (health > maxHealth) {
      health = maxHealth;
    }
  }

  public function isCorporeal(): Bool {
    return !shadowPowerActive;
  }

  public function standingInLight(): Bool {
    return isStandingInLight;
  }


}
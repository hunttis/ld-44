package states.playstate;

import flixel.tile.FlxTilemap;
import flixel.math.FlxPoint;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.util.FlxColor;
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

  var playerState: PlayerState;

  var defaultGravity: Float = 600;
  var shadowGravity: Float = 100;
  var defaultMaxVelocity: FlxPoint = new FlxPoint(200, 400);
  var shadowMaxVelocity: FlxPoint = new FlxPoint(0, 50);
  var maxHealth: Float = 1000;

  var lightLayer: FlxTilemap;
  var isStandingInLight: Bool;

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
  }

  override public function update(elapsed: Float): Void {
    if (lightLayer != null) {
      isStandingInLight = lightLayer.overlaps(this);
    }
    
    if (playerState == Darkness && isStandingInLight) {
      playerState = Lit;
      // makeGraphic(16, 32, FlxColor.CYAN);
    } else if (playerState == Lit && !isStandingInLight) {
      playerState = Darkness;
      // makeGraphic(16, 32, FlxColor.BLUE);
    }

    if (Math.abs(velocity.x) > 0 && !shadowPowerActive) {
      animation.play('walk');
    } else if (velocity.x == 0 && !shadowPowerActive) {
      animation.play('idle');
    }

    acceleration.x = 0;
    checkKeys();
    checkGamepads();

    if (shadowPowerActive) {
      health -= elapsed;
    }

    // You probably want to do most of the logic before super.update(). This is because after the update, 
    // colliding objects are separated and will no longer be touching.
    super.update(elapsed);
  }

  private function checkKeys(): Void {
    // FlxG.keys.pressed is true while the key is down
    if (FlxG.keys.pressed.UP) {
      jump();
    }
    
    // FlxG.keys.justPressed is true only once per press
    if (FlxG.keys.justPressed.DOWN) {
      velocity.y = maxVelocity.y;
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
      velocity.y = -maxVelocity.y;
    }
  }

  private function dive() {
    if (!isTouching(FlxObject.FLOOR)) {
      velocity.y = maxVelocity.y;
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

  private function usePowerOnEnemy(player, enemy) {
    enemy.destroy();
    addHealth(10);
    parent.particles.sprayBlood(player.x, player.y);
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
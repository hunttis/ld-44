package states.playstate;

import flixel.ui.FlxBar;
import flixel.math.FlxPoint;
import flixel.tile.FlxTilemap;
import flixel.FlxObject;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import states.playstate.gameobjects.Arrow;

enum EnemyState {
  PatrolLeft;
  PatrolRight;
  TurningLeft;
  TurningRight;
}

enum MindState {
  Idle;
  Alert;
  Aggressive;
}

class Enemy extends FlxSprite {

  var state: EnemyState = PatrolLeft;
  var mindState: MindState = Idle;
  var stateCooldown: Float = 0;
  var alertLevel: Float = 0;

  var aggroThreshold: Float = 1;
  var shootCooldown: Float = 0.2;
  var maxShootCooldown: Float = 0.5;

  var player: Player;
  var level: FlxTilemap;
  var parent: GameLevel;
  var lostSightOfPlayer: Bool = true;
  var aggroParticleCooldown: Float = 0;
  var aggroParticleCooldownMax: Float = 0.5;

  public function new(xLoc: Float, yLoc: Float, player: Player, level: FlxTilemap, parent: GameLevel) {
    super(xLoc, yLoc);
    loadGraphic('assets/guard.png', false, 16, 32);
    setFacingFlip(FlxObject.LEFT, false, false);
    setFacingFlip(FlxObject.RIGHT, true, false);
    acceleration.y = 600;
    maxVelocity.set(100, 400);
    drag.x = maxVelocity.x;
    this.player = player;
    this.level = level;
    this.parent = parent;
  }

  override public function update(elapsed: Float): Void {
    acceleration.x = 0;

    if (level == null) {
      return;
    }

    if (mindState == Alert) {

    } else if (mindState == Idle) {
      if (state == PatrolLeft) {
        acceleration.x = -maxVelocity.x * 2;
        facing = FlxObject.LEFT;
        if (isTouching(FlxObject.WALL)) {
          state = TurningRight;
          stateCooldown = 1;
        }
      } else if (state == PatrolRight) {
        acceleration.x = maxVelocity.x * 2;
        facing = FlxObject.RIGHT;
        if (isTouching(FlxObject.WALL)) {
          state = TurningLeft;
          stateCooldown = 1;
        }
      } else if (state == TurningLeft) {
        if (stateCooldown > 0) {
          stateCooldown -= elapsed;
        } else {
          state = PatrolLeft;
        }
      } else if (state == TurningRight) {
        if (stateCooldown > 0) {
          stateCooldown -= elapsed;
        } else {
          state = PatrolRight;
        }
      }
    }

    var canSeePlayer = checkIfSeesPlayer();

    switch mindState {
      case Idle: {
        if (canSeePlayer) {
          mindState = Alert;
          parent.particles.alert(this.x, this.y);
          increaseAlertness(elapsed);
        } else {
          reduceAlertness(elapsed);
        }
      }
      case Alert: {
        if (canSeePlayer) {
          increaseAlertness(elapsed);
          if (alertLevel > aggroThreshold) {
            mindState = Aggressive;
            parent.particles.aggro(this.x, this.y);
            alertLevel = 10;
          }
        } else {
          reduceAlertness(elapsed);
          if (alertLevel <= 0) {
            mindState = Idle;
          }
        }
      }
      case Aggressive: {
        aggroParticleCooldown -= elapsed;

        var eyesLevel = new FlxPoint(this.getGraphicMidpoint().x, this.getGraphicMidpoint().y - 8);
        if (!lostSightOfPlayer && level.ray(eyesLevel, player.getGraphicMidpoint())) {
          fireAggroParticle();
          if (player.x < this.x) {
            facing == FlxObject.LEFT;
          } else {
            facing == FlxObject.RIGHT;
          }
        } else {
          fireAlertParticle();
          lostSightOfPlayer = true;
        }

        if (canSeePlayer) {
          lostSightOfPlayer = false;
          if (shootCooldown < 0) {
            fire();
            shootCooldown = maxShootCooldown;
          } else {
            shootCooldown -= elapsed;
          }
        } else {
          reduceAlertness(elapsed);
          if (alertLevel <= 2) {
            mindState = Alert;
            parent.particles.alert(this.x, this.y);
          }
        }
      }
    }

    super.update(elapsed);
  }

  private function fire() {
    trace("Attack!");
    var arrow = new Arrow(getGraphicMidpoint().x, getGraphicMidpoint().y - 8, player.getGraphicMidpoint().x, player.getGraphicMidpoint().y);
    parent.projectiles.add(arrow);
  }

  private function increaseAlertness(amount: Float) {
    alertLevel = alertLevel + amount;
  }

  private function reduceAlertness(amount: Float) {
    alertLevel = alertLevel - amount;
    if (alertLevel < 0) {
      alertLevel = 0;
    }
  }

  private function fireAggroParticle() {
    if (aggroParticleCooldown < 0) {
      parent.particles.aggro(this.x, this.y);
      aggroParticleCooldown = aggroParticleCooldownMax;
    }
  }

  private function fireAlertParticle() {
    if (aggroParticleCooldown < 0) {
      parent.particles.alert(this.x, this.y);
      aggroParticleCooldown = aggroParticleCooldownMax;
    }
  }

  private function checkIfSeesPlayer() {
    var playerInFrontOfEnemy = (player.x < this.x && facing == FlxObject.LEFT) || (player.x > this.x && facing == FlxObject.RIGHT);
    var angleBetween = Math.abs(this.getGraphicMidpoint().angleBetween(player.getGraphicMidpoint()));
    var eyesLevel = new FlxPoint(this.getGraphicMidpoint().x, this.getGraphicMidpoint().y - 8);
    var range = (mindState == Aggressive ? 200 : 100) + (player.standingInLight() ? 300 : 100);
    var inRange = eyesLevel.distanceTo(player.getGraphicMidpoint()) <= range;

    if (player.isCorporeal() &&
      inRange &&
      playerInFrontOfEnemy &&
      angleBetween > 70 &&
      angleBetween < 100 &&
      level.ray(eyesLevel, player.getGraphicMidpoint())
    ) {
      return true;
    }
    return false;
  }

}
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

  var aggroThreshold: Float = 2;
  var shootCooldown: Float = 0.2;
  var maxShootCooldown: Float = 0.2;

  var player: Player;
  var level: FlxTilemap;
  var parent: GameLevel;
  var aggroBar: FlxBar;

  public function new(xLoc: Float, yLoc: Float, player: Player, level: FlxTilemap, parent: GameLevel) {
    super(xLoc, yLoc);
    makeGraphic(16, 32, FlxColor.YELLOW);
    acceleration.y = 600;
    maxVelocity.set(100, 400);
    drag.x = maxVelocity.x;
    this.player = player;
    this.level = level;
    this.parent = parent;
  }

  override public function update(elapsed: Float): Void {
    if (aggroBar == null) {
      aggroBar = new FlxBar(10, 10, FlxBarFillDirection.LEFT_TO_RIGHT, 16, 8, this, 'alertLevel', 0, 10, true);
      aggroBar.trackParent(0, -16);
      parent.uiLayer.add(aggroBar);
    }

    acceleration.x = 0;

    if (level == null) {
      return;
    }

    if (mindState == Alert) {

    } else if (mindState == Idle) {
      if (state == PatrolLeft) {
        acceleration.x = -maxVelocity.x * 2;
        if (isTouching(FlxObject.WALL)) {
          state = TurningRight;
          stateCooldown = 1;
        }
      } else if (state == PatrolRight) {
        acceleration.x = maxVelocity.x * 2;
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
          trace("Alert!");
          mindState = Alert;
          makeGraphic(16, 32, FlxColor.ORANGE);
          increaseAlertness(elapsed);
        } else {
          reduceAlertness(elapsed);
        }
      }
      case Alert: {
        if (canSeePlayer) {
          increaseAlertness(elapsed);
          if (alertLevel > aggroThreshold) {
            trace("Aggressive!");
            mindState = Aggressive;
            makeGraphic(16, 32, FlxColor.RED);
            alertLevel = 10;
          }
        } else {
          reduceAlertness(elapsed);
          if (alertLevel <= 0) {
            trace("Going back to idle");
            mindState = Idle;
            makeGraphic(16, 32, FlxColor.YELLOW);
          }
        }
      }
      case Aggressive: {
        if (canSeePlayer) {
          if (shootCooldown < 0) {
            fire();
            shootCooldown = maxShootCooldown;
          } else {
            shootCooldown -= elapsed;
          }
        } else {
          reduceAlertness(elapsed);
          if (alertLevel <= 2) {
            trace("Going back to Alert");
            mindState = Alert;
            makeGraphic(16, 32, FlxColor.ORANGE);
          }
        }
      }
    }

    // trace("Mindstate: " + mindState + " - Alert: " + Math.round(alertLevel * 100) / 100);

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


  private function checkIfSeesPlayer() {
    var playerInFrontOfEnemy = (player.x < this.x && state == PatrolLeft) || (player.x > this.x && state == PatrolRight);
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

  override public function destroy() {
    aggroBar.destroy();
    super.destroy();
  }

}
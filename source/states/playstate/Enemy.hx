package states.playstate;

import flixel.FlxG;
import flixel.system.FlxSound;
import flixel.ui.FlxBar;
import flixel.math.FlxPoint;
import flixel.tile.FlxTilemap;
import flixel.FlxObject;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import states.playstate.gameobjects.Arrow;

enum Activity {
  PatrolLeft;
  PatrolRight;
  TurningLeft;
  TurningRight;
  Confused;
  SpottedPlayer;
  Attacking;
  LookingForPlayer;
}

enum MindState {
  Idle;
  Alert;
  Aggressive;
  BeingDevoured;
  Stunned;
}

class Enemy extends FlxSprite {

  var activity: Activity = PatrolLeft;
  var mindState: MindState = Idle;
  
  var stateCooldown: Float = 0;
  var alertLevel: Float = 0;

  var minAlertness: Float = 0;
  var maxAlertness: Float = 10;

  var aggroThreshold: Float = 0.5;
  var shootCooldown: Float = 0.2;
  var maxShootCooldown: Float = 0.5;
  var lookingWalkMaxCooldown: Float = 0.5;
  var beingDevoured: Bool = false;

  var player: Player;
  var level: FlxTilemap;
  var parent: GameLevel;
  var lostSightOfPlayer: Bool = true;
  var aggroParticleCooldown: Float = 0;
  var aggroParticleCooldownMax: Float = 0.5;

  var spellSound: FlxSound;

  public function new(xLoc: Float, yLoc: Float, player: Player, level: FlxTilemap, parent: GameLevel) {
    super(xLoc, yLoc);
    loadGraphic('assets/guard.png', true, 16, 32);
    animation.add('walk', [0, 1, 2], 10, true);
    animation.add('idle', [0], 1, false);
    animation.add('aggro', [3], 1, false);
    setFacingFlip(FlxObject.LEFT, false, false);
    setFacingFlip(FlxObject.RIGHT, true, false);
    acceleration.y = 600;
    maxVelocity.set(50, 400);
    drag.x = maxVelocity.x;
    this.player = player;
    this.level = level;
    this.parent = parent;
    spellSound = FlxG.sound.load('assets/shoot.wav');
  }

  override public function update(elapsed: Float): Void {
    acceleration.x = 0;

    if (level == null) {
      return;
    }
    
    switch mindState {
      case Idle: {
        idleStateLoop(elapsed);
      }
      case Alert: {
        alertStateLoop(elapsed);
      }
      case Aggressive: {
        aggroStateLoop(elapsed);
      }
      case BeingDevoured: {
        beingDevouredLoop(elapsed);
      }
      case Stunned: {
        stunnedLoop(elapsed);
      }
    }

    if (alive) {
      super.update(elapsed);
    }
  }

  private function idleStateLoop(elapsed: Float) {
    if (activity == PatrolLeft) {
      acceleration.x = -maxVelocity.x;
      animation.play('walk');
      facing = FlxObject.LEFT;
      if (isTouching(FlxObject.WALL)) {
        activity = TurningRight;
        stateCooldown = 1;
      }
    } else if (activity == PatrolRight) {
      acceleration.x = maxVelocity.x;
      animation.play('walk');
      facing = FlxObject.RIGHT;
      if (isTouching(FlxObject.WALL)) {
        activity = TurningLeft;
        stateCooldown = 1;
      }
    } else if (activity == TurningLeft) {
      animation.play('idle');
      if (stateCooldown > 0) {
        stateCooldown -= elapsed;
      } else {
        activity = PatrolLeft;
      }
    } else if (activity == TurningRight) {
      animation.play('idle');
      if (stateCooldown > 0) {
        stateCooldown -= elapsed;
      } else {
        activity = PatrolRight;
      }
    }

    var canSeePlayer = checkIfSeesPlayer();
    if (canSeePlayer) {
      mindState = Alert;
      parent.particles.alert(this.x, this.y);
      increaseAlertness(elapsed);
    } else {
      reduceAlertness(elapsed);
    }
  }

  private function alertStateLoop(elapsed: Float) {
    animation.play('idle');
    var canSeePlayer = checkIfSeesPlayer();
    if (canSeePlayer) {
      increaseAlertness(elapsed);
      if (alertLevel > aggroThreshold) {
        mindState = Aggressive;
        fireAggroParticle();
        alertLevel = 10;
        activity = Attacking;
      }
    } else {
      fireAlertParticle();
      reduceAlertness(elapsed);
      if (alertLevel <= 0) {
        startPatrolling();
      }
    }
  }

  private function startPatrolling() {
    mindState = Idle;
    if (facing == FlxObject.LEFT) {
      activity = PatrolLeft;
    } else {
      activity = PatrolRight;
    }
  }

  private function aggroStateLoop(elapsed: Float) {
    animation.play('aggro');

    aggroParticleCooldown -= elapsed;
    var canSeePlayer = checkIfSeesPlayer(true);

    switch activity {
      case Attacking: {
        if (canSeePlayer) {
          fireAggroParticle();
          if (player.x < this.x) {
            facing == FlxObject.LEFT;
          } else {
            facing == FlxObject.RIGHT;
          }
          if (shootCooldown < 0) {
            fire();
            shootCooldown = maxShootCooldown;
          } else {
            shootCooldown -= elapsed;
          }
        } else {
          activity = LookingForPlayer;
          stateCooldown = lookingWalkMaxCooldown;
          fireAlertParticle();
        }
      }
      case LookingForPlayer: {
        if (canSeePlayer) {
          activity = Attacking;
        } else {
          if (stateCooldown < 0) {
            flipFacing();
            stateCooldown = lookingWalkMaxCooldown;
          } else {
            stateCooldown -= elapsed;
          }
          if (facing == FlxObject.LEFT) {
            acceleration.x = -maxVelocity.x / 2;
          } else {
            acceleration.x = maxVelocity.x / 2;
          }
          fireAggroParticle();
          reduceAlertness(elapsed);
          if (alertLevel <= 2) {
            mindState = Alert;
            parent.particles.alert(this.x, this.y);
          }
        }
      }
      default: {
        // Nothing
      }
    }
  }

  private function beingDevouredLoop(elapsed: Float) {
    alpha = stateCooldown;
    stateCooldown -= elapsed;
    velocity.x = 0;
    if (stateCooldown <= 0) {
      hurt(1);
    }
  }

  private function stunnedLoop(elapsed: Float) {
    stateCooldown -= elapsed;
    velocity.x = 0;
    scale.x = Math.max(0.8, 1 - Math.random());
    scale.y = Math.max(0.8, 1 - Math.random());
    if (stateCooldown <= 0) {
      increaseAlertness(4);
      mindState = Alert;
      scale.x = 1;
      scale.y = 1;
    }
  }

  private function flipFacing() {
    if (facing == FlxObject.LEFT) {
      facing = FlxObject.RIGHT;
    } else {
      facing = FlxObject.LEFT;
    }
  }

  private function fire() {
    var arrow = new Arrow(getGraphicMidpoint().x, getGraphicMidpoint().y - 8, player.getGraphicMidpoint().x, player.getGraphicMidpoint().y, parent);
    parent.projectiles.add(arrow);
    spellSound.play();
  }

  private function increaseAlertness(amount: Float) {
    alertLevel = Math.min(maxAlertness, alertLevel + amount);
  }

  private function reduceAlertness(amount: Float) {
    alertLevel = Math.max(0, alertLevel - amount);
  }

  private function fireAggroParticle(force: Bool = false) {
    if (aggroParticleCooldown < 0 || force) {
      parent.particles.aggro(this.x, this.y);
      aggroParticleCooldown = aggroParticleCooldownMax;
    }
  }

  private function fireAlertParticle(force: Bool = false) {
    if (aggroParticleCooldown < 0 || force) {
      parent.particles.alert(this.x, this.y);
      aggroParticleCooldown = aggroParticleCooldownMax;
    }
  }

  private function checkIfSeesPlayer(ignoreFacing: Bool = false, ignoreShadowForm: Bool = false) {
    var playerInFrontOfEnemy = ignoreFacing || (player.x < this.x && facing == FlxObject.LEFT) || (player.x > this.x && facing == FlxObject.RIGHT);
    var angleBetween = Math.abs(this.getGraphicMidpoint().angleBetween(player.getGraphicMidpoint()));
    var atVisionLevel = ignoreFacing || (angleBetween > 70 && angleBetween < 100);
    var eyesLevel = new FlxPoint(this.getGraphicMidpoint().x, this.getGraphicMidpoint().y - 4);
    var range = (mindState == Aggressive ? 200 : 100) + (player.standingInLight() ? 300 : 100);
    var inRange = eyesLevel.distanceTo(player.getGraphicMidpoint()) <= range;
    var isVisible = player.isCorporeal() || ignoreShadowForm;

    if (isVisible &&
      inRange &&
      playerInFrontOfEnemy &&
      atVisionLevel &&
      level.ray(eyesLevel, player.getGraphicMidpoint())
    ) {
      return true;
    }
    return false;
  }

  public function devour(): Bool {
    if (!beingDevoured) {
      beingDevoured = true;
      mindState = BeingDevoured;
      stateCooldown = 1;
      parent.enemies.forEachAlive((enemy: Enemy) -> {
        enemy.checkIfSeesDevouring();
      });
      return true;
    }
    return false;
  }

  public function checkIfSeesDevouring(): Void {
    if (checkIfSeesPlayer(false, true)) {
      increaseAlertness(4);
    }
  }

  public function stun(): Bool {
    if (mindState != Stunned) {
      mindState = Stunned;
      stateCooldown = 2;
      return true;
    }
    return false;
  }

  public function isStunned() {
    return mindState == Stunned && stateCooldown > 0;
  }

}
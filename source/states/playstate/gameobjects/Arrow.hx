package states.playstate.gameobjects;

import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import flixel.util.FlxColor;
import flixel.FlxSprite;

class Arrow extends FlxSprite {

  var targetX: Float;
  var targetY: Float;
  var vector: FlxVector;
  var parent: GameLevel;

  var speed: Float = 10000;
  public var passive: Bool = false;
  var sparkCooldown: Float = 0;
  var sparkCooldownMax: Float = 0.03;

  public function new(xLoc: Float, yLoc: Float, targetX: Float, targetY: Float, parent: GameLevel) {
    super(xLoc, yLoc);
    this.parent = parent;
    makeGraphic(2, 8, FlxColor.CYAN);
    this.targetX = targetX;
    this.targetY = targetY;
    vector = new FlxVector(targetX - xLoc, targetY - yLoc);
    vector = vector.normalize();
    this.angle = this.getGraphicMidpoint().angleBetween(new FlxPoint(targetX, targetY));
    this.width = 8;
    this.height = 2;
    this.centerOffsets();
  }

  override public function update(elapsed: Float) {
    if (passive) {
      return;
    }

    velocity.x = vector.x * speed * elapsed;
    velocity.y = vector.y * speed * elapsed;

    sparkCooldown -= elapsed;
    if (sparkCooldown < 0) {
      sparkCooldown = sparkCooldownMax;
      parent.particles.spark(this.x, this.y);
    }

    super.update(elapsed);

    if (!this.isOnScreen()) {
      this.destroy();
    }
  }

  public function hitGround() {
    this.passive = true;
  }
}
package states.playstate.gameobjects;

import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import flixel.util.FlxColor;
import flixel.FlxSprite;

class Arrow extends FlxSprite {

  var targetX: Float;
  var targetY: Float;
  var vector: FlxVector;

  var speed: Float = 10000;
  public var passive: Bool = false;

  public function new(xLoc: Float, yLoc: Float, targetX: Float, targetY: Float) {
    super(xLoc, yLoc);
    makeGraphic(2, 8, FlxColor.WHITE);
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

    super.update(elapsed);

    if (!this.isOnScreen()) {
      this.destroy();
    }
  }

  public function hitGround() {
    this.passive = true;
  }
}
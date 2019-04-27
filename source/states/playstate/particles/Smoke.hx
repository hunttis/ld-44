package states.playstate.particles;

import flixel.util.helpers.FlxRange;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.effects.particles.FlxParticle;

class Smoke extends FlxParticle {

  public function new() {
    super();
    makeGraphic(8, 8, FlxColor.fromRGB(80, 80, 80, 100));    
  }

}


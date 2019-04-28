package states;

import flash.system.System;
import flixel.FlxG;

class Util {
  public static function checkQuitKey(): Void {
    if (FlxG.keys.pressed.ESCAPE) {
      System.exit(0);
    }
  }

  public static function startMusic(): Void {
    if (FlxG.sound.music == null) {
      #if !debug
        FlxG.sound.playMusic('assets/ld44-theme.mp3', 1, true);
      #end
    }
  }
}
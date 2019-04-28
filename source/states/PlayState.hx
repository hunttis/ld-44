package states;

import flixel.FlxG;
import flixel.FlxState;
import states.playstate.GameLevel;
import states.Util;
import states.GameCompleteState;

class PlayState extends FlxState {

  private var currentLevel: GameLevel;
  private var currentLevelNumber: Int;

  public function new(levelNumber: Int = 1) {
    super();
    this.currentLevelNumber = levelNumber;
  }

  override public function create(): Void {
    super.create();
    currentLevel = loadLevel(currentLevelNumber);
    add(currentLevel);
    Util.startMusic();
  }

  override public function update(elapsed: Float): Void {
    super.update(elapsed);
    Util.checkQuitKey();
    checkForLevelRestart();
    checkForGameOver();
    checkForLevelEnd();
  }

  private function checkForLevelRestart(): Void {
    if (FlxG.keys.pressed.R) {
      FlxG.switchState(new PlayState(currentLevelNumber));
    }
  }

  private function loadLevel(levelNumber: Int): GameLevel {
    return new GameLevel(levelNumber);
  }

  private function checkForGameOver(): Void {
    if (currentLevel.isGameOver()) {
      FlxG.switchState(new GameOverState());
    }
  }

  private function checkForLevelEnd(): Void {
    // Remember to account for the fact that there might not be a "next level"!
    if (currentLevel.isLevelComplete()) {
      currentLevelNumber++;
      if (currentLevelNumber == 5) {
        FlxG.switchState(new GameCompleteState());
      } else {
        FlxG.switchState(new PlayState(currentLevelNumber));
      }
    }
  }

}

package states.playstate;

import flixel.FlxSprite;
import flixel.addons.display.FlxTiledSprite;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxBar;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import states.playstate.LevelMap;
import states.playstate.gameobjects.Arrow;

class GameLevel extends FlxGroup {

  public var levelMap: LevelMap;

  private var backgroundLayer: FlxGroup;
  private var foregroundLayer: FlxGroup;
  public var uiLayer: FlxGroup;

  private var player: Player;
  private var enemies: FlxTypedGroup<Enemy>;

  private var playerLifeBar: FlxBar;

  public var particles: Particles;
  public var projectiles: FlxTypedGroup<Arrow> = new FlxTypedGroup<Arrow>();

  public function new(levelNumber): Void {
    super();
    loadLevel(levelNumber);
  }
  
  override public function update(elapsed: Float): Void {
    super.update(elapsed);
    checkControls(elapsed);
  }

  private function checkControls(elapsed: Float): Void {
    checkMouse(elapsed);
    checkCollisions(elapsed);
  }

  private function checkCollisions(elapsed: Float): Void {
    if (levelMap != null && enemies != null && player != null) {
      FlxG.collide(levelMap.getForegroundLayer(), player);
      FlxG.collide(levelMap.getForegroundLayer(), enemies);
      FlxG.collide(levelMap.getPatrolLimitsLayer(), enemies);
    }
    if (player != null && levelMap != null) {
      FlxG.collide(levelMap.getForegroundLayer(), projectiles, arrowHitsGround);
      FlxG.overlap(player, projectiles, playerHitByArrow);
    }
  }

  private function checkMouse(elapsed: Float): Void {
    #if (!mobile)
      // Mouse not on mobile!
      
    #end
  }

  private function arrowHitsGround(layer: FlxTilemap, arrow: Arrow) {
    arrow.hitGround();
  }

  private function playerHitByArrow(player: Player, arrow: Arrow) {
    if (arrow.passive) {
      return;
    }
    if (player.isCorporeal()) {
      arrow.destroy();
      player.hurt(10);
    } else {
      player.hurt(0.05);
    }
  }

  private function loadLevel(levelNumber: Int): Void {
    createLayers();

    levelMap = new LevelMap(levelNumber, this);
    add(levelMap);

    var backgroundImage = new FlxTiledSprite('assets/sky.png', 1280 , 480, true, false);
    backgroundLayer.add(backgroundImage);

    var moon = new FlxSprite('assets/moon.png');
    backgroundLayer.add(moon);
    moon.x = 600;
    moon.y = 100;
    moon.scale.set(2, 2);
    moon.scrollFactor.set(0.3, 0.3);

    var parallaxLayer = levelMap.getParallaxLayer();
    backgroundLayer.add(parallaxLayer);
    parallaxLayer.scrollFactor.set(0.5, 0.5);

    var backgroundMapLayer = levelMap.getBackgroundLayer();
    backgroundLayer.add(backgroundMapLayer);
    
    foregroundLayer.add(levelMap.getForegroundLayer());

    enemies = levelMap.getEnemies();
    foregroundLayer.add(enemies);
    foregroundLayer.add(levelMap.getLightLayer());

    player = levelMap.getPlayer();
    foregroundLayer.add(player);

    playerLifeBar = new FlxBar(10, 10, FlxBarFillDirection.LEFT_TO_RIGHT, 100, 8, player, 'health', 0, 100, true);
    playerLifeBar.scrollFactor.set(0, 0);

    particles = new Particles(this);
    foregroundLayer.add(particles);
    foregroundLayer.add(projectiles);
    
    uiLayer.add(playerLifeBar);

    FlxG.camera.setScrollBoundsRect(0, 0, levelMap.getForegroundLayer().width, levelMap.getForegroundLayer().height, true);
    FlxG.camera.follow(player, PLATFORMER, 0.3);
    FlxG.camera.setScale(1, 1);
    
    FlxG.camera.pixelPerfectRender = true;
    
  }

  private function createLayers(): Void {
    backgroundLayer = new FlxGroup();
    foregroundLayer = new FlxGroup();
    uiLayer = new FlxGroup();

    add(backgroundLayer);
    add(foregroundLayer);
    add(uiLayer);
  }

  public function isGameOver(): Bool {
    #if debug // This part (cheat) of the code is only active if the -debug parameter is present
      if (FlxG.keys.justPressed.ZERO) {
        return true;
      }
    #end
    // Write your game over check here
    return !player.alive;
  }

  public function isLevelComplete(): Bool {
    #if debug // Read above comment
      if (FlxG.keys.justPressed.NINE) {
        return true;
      }
    #end
    // Write your level completion terms here
    return enemies.countLiving() == 0;
  }

}

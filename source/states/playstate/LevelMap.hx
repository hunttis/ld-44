package states.playstate;

import flixel.util.FlxColor;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledLayer.TiledLayerType;
import flixel.group.FlxGroup;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.tile.FlxTilemap;

class LevelMap extends FlxGroup {

  private var foregroundLayer: FlxTilemap;
  private var lightLayer: FlxTilemap;
  private var backgroundLayer: FlxTilemap;
  private var parallaxLayer: FlxTilemap;
  private var patrollimitsLayer: FlxTilemap;
  private var player: Player;
  private var enemies: FlxTypedGroup<Enemy> = new FlxTypedGroup<Enemy>();

  public function new(levelNumber: Int, parent: GameLevel) {
    super();
    var tiledData: TiledMap = new TiledMap("assets/level" + levelNumber + ".tmx", "assets/");

    var tileSize = tiledData.tileWidth;
    var mapWidth = tiledData.width;
    var mapHeight = tiledData.height;

    @SuppressWarning("checkstyle:Trace")
    trace("Loaded map with: " + tileSize + " size tiles and " + mapWidth + "x" + mapHeight + " map");

    for (layer in tiledData.layers) {
      if (layer.type == TiledLayerType.TILE) {
        var tileLayer = cast(layer, TiledTileLayer);

        // trace("Loading TILE LAYER: " + layer.name);
        if (tileLayer.name == "light") {
          lightLayer = new FlxTilemap();
          lightLayer.loadMapFromCSV(tileLayer.csvData, "assets/lights.png", 16, 16, null, 193, 193, 193);
          lightLayer.alpha = 0.1;
          lightLayer.useScaleHack = false;
        } else if (tileLayer.name == "foreground") {
          // trace("Creating foreground!");
          foregroundLayer = new FlxTilemap();
          foregroundLayer.loadMapFromCSV(tileLayer.csvData, "assets/foregroundtiles.png", 16, 16, null, 1, 1, 1);
          foregroundLayer.useScaleHack = false;
        } else if (tileLayer.name == "background") {
          // trace("Creating background!");
          backgroundLayer = new FlxTilemap();
          backgroundLayer.loadMapFromCSV(tileLayer.csvData, "assets/backgroundtiles.png", 16, 16, null, 65, 65, 65);
          backgroundLayer.useScaleHack = false;
        } else if (tileLayer.name == "parallax") {
          // trace("Creating background!");
          parallaxLayer = new FlxTilemap();
          parallaxLayer.loadMapFromCSV(tileLayer.csvData, "assets/backgroundtiles.png", 16, 16, null, 65, 65, 65);
          parallaxLayer.useScaleHack = false;
          parallaxLayer.color = FlxColor.BLACK;
          parallaxLayer.x = -4;
        } else if (tileLayer.name == "patrollimits") {
          trace("Creating Patrol limits!");
          patrollimitsLayer = new FlxTilemap();
          patrollimitsLayer.loadMapFromCSV(tileLayer.csvData, "assets/entities.png", 16, 16, null, 129, 129, 129);
          patrollimitsLayer.useScaleHack = false;
        } else {
          @SuppressWarning("checkstyle:Trace")
          trace("Unknown layer, not creating! " + tileLayer.name);
        }
      } else {
        @SuppressWarning("checkstyle:Trace")
        trace("Other layer! " + layer.name + " - " + layer.type);
      }
    }

    for (layer in tiledData.layers) {
      if (layer.type == TiledLayerType.OBJECT) {
        trace("Object layer! " + layer.name);
        
        var objectLayer = cast(layer, TiledObjectLayer);
        // trace(objectLayer.objects);
        for (levelObject in objectLayer.objects) {
          trace("Type: " + levelObject.name);
          if (levelObject.name == "vampire") {
            player = new Player(levelObject.x, levelObject.y - 16, enemies, lightLayer, parent);
          } else if (levelObject.name == "guard") {
            var enemy: Enemy = new Enemy(levelObject.x, levelObject.y - 16, player, foregroundLayer, parent);
            enemies.add(enemy);
          }
        }
      } else {
        @SuppressWarning("checkstyle:Trace")
        trace("Other layer! " + layer.name + " - " + layer.type);
      }
    }
  }

  public function getEnemies() {
    return enemies;
  }

  public function getPlayer() {
    return player;
  }

  public function getForegroundLayer(): FlxTilemap {
    return foregroundLayer;
  }

  public function getBackgroundLayer(): FlxTilemap {
    return backgroundLayer;
  }

  public function getLightLayer(): FlxTilemap {
    return lightLayer;
  }

  public function getPatrolLimitsLayer(): FlxTilemap {
    return patrollimitsLayer;
  }

  public function getParallaxLayer(): FlxTilemap {
    return parallaxLayer;
  }

}
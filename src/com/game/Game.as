package com.game 
{
	import com.camera.GameCamera;
	import com.Facade;
	import com.game.entity.BaseEntity;
	import com.game.entity.EntityFactory;
	import com.game.entity.LocationObject;
	import com.game.entity.Racer;
	import com.game.gameInterface.GameInterface;
	import com.game.plugins.ai.AiPlugin;
	import com.game.plugins.BasePlugin;
	import com.game.plugins.cameraControl.CameraControlPlugin;
	import com.game.plugins.dilog.DilogPlugin;
	import com.game.plugins.log.LogPlugin;
	import com.game.plugins.navigation.NavigationPlugin;
	import com.game.plugins.physics.PhysicsPlugin;
	import com.game.plugins.playerControl.PlayerControl;
	import com.game.plugins.statGame.StartGamePlugin;
	import com.game.plugins.task.TaskSynchronizer;
	import com.game.settings.GameSettings;
	import com.game.settings.Player;
	import com.managers.info.components.LocationContentInfo;
	import com.managers.info.components.LocationInfo;
	import com.managers.info.components.SpawnerInfo;
	import com.view.ApplicationSprite;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	[Event(name = "connection_log_generated", type = "com.game.GameEvent")]
	[Event(name = "log_entries_applied", type = "com.game.GameEvent")]
	[Event(name = "race_started", type = "com.game.GameEvent")]
	[Event(name="race_completed", type="com.game.GameEvent")]
	public class Game extends ApplicationSprite
	{
		private var _settings:GameSettings;
		private var _progress:GameProgress;
		
		private var _camera:GameCamera
		private var _gameInterface:GameInterface
		private var _plugins:Vector.<BasePlugin>;
		private var _synchronizer:TaskSynchronizer
		private var _logger:LogPlugin
		private var _cameraControlPlugin:CameraControlPlugin;
		private var _physics:PhysicsPlugin;
		private var _playerControl:PlayerControl;
		private var _navigation:NavigationPlugin;
		private var _ai:AiPlugin
		private var _dilog:DilogPlugin
		
		private var _objects:Vector.<LocationObject>
		private var _racers:Vector.<Racer>
		private var _componentsDict:Dictionary
		
		private var _lastFrameTime:int;
		
		public function Game():void
		{
			_plugins = new Vector.<BasePlugin>
			_synchronizer = new TaskSynchronizer(this);
			addPlugin(_synchronizer);
			
			_camera = new GameCamera();
			addChild(_camera);
			
			_gameInterface = new GameInterface(this);
			addChild(_gameInterface);
			
			
			_logger = new LogPlugin(this);
			addPlugin(_logger);
			
			_cameraControlPlugin = new CameraControlPlugin(this);
			addPlugin(_cameraControlPlugin);
			
			_physics = new PhysicsPlugin(this);
			addPlugin(_physics);
			
			_playerControl = new PlayerControl(this);
			addPlugin(_playerControl);
			
			_navigation = new NavigationPlugin(this);
			addPlugin(_navigation);
			
			_ai = new AiPlugin(this);
			addPlugin(_ai);
			
			var startGamePlugin:StartGamePlugin = new StartGamePlugin(this);
			addPlugin(startGamePlugin);
			
			_dilog = new DilogPlugin(this);
			addPlugin(_dilog);
			
		}
		public function init(settings:GameSettings):void
		{
			_settings = settings;
			
			_camera.setCameraSize(settings.screenWidth / settings.screenScale, settings.screenHeight / settings.screenScale, settings.screenScale);
			_camera.setLocation(settings.locationID);
			_camera.render();
			
			_gameInterface.setSize(settings.screenWidth, settings.screenHeight);
			
			_componentsDict = new Dictionary();
			_componentsDict[_camera.id] = _camera;
			
			_progress = new GameProgress();
			_progress.currentUpdateStep = 0;
			
			
			
			
			
			_racers = new Vector.<Racer>();
			_objects = new Vector.<LocationObject>();
			
			
			
			var locationInfo:LocationInfo = Facade.instance.info.getInfoComponentByID(settings.locationID) as LocationInfo;
			var currentEntity:BaseEntity
			for each(var contentInfo:LocationContentInfo in locationInfo.content) {
				currentEntity = EntityFactory.instance.createByTemplateID(contentInfo.templateID);
				if (!currentEntity) continue;
				currentEntity.wordX = contentInfo.x;
				currentEntity.wordY = contentInfo.y;
				currentEntity.id = contentInfo.templateID + "_" + contentInfo.x + "_" + contentInfo.y;
				
				_componentsDict[currentEntity.id] = currentEntity;
				_camera.addRenderedObject(currentEntity);
				if (currentEntity is LocationObject) {
					_objects.push(currentEntity as LocationObject);
				}
			}
			var player:Player
			var spawner:SpawnerInfo
			for (var i:uint = 0; i < _settings.players.length;i++ ) {
				player = _settings.players[i];
				spawner = locationInfo.spawners[i];
				currentEntity = EntityFactory.instance.createByTemplateID(player.racerTemplate);
				if (!currentEntity) continue;
				(currentEntity as Racer).player = player;
				currentEntity.id = player.name;
				currentEntity.wordX = spawner.worldX;
				currentEntity.wordY = spawner.worldY;
				currentEntity.worldAngle = spawner.worldAngle;
				
				_componentsDict[currentEntity.id] = currentEntity;
				_camera.addRenderedObject(currentEntity);
				_racers.push(currentEntity as Racer);
				
			}
			
			_synchronizer.executeInitializationTasks();
			
		}
		public function destroy():void
		{
			var plugin:BasePlugin;
			for (var i:int = _plugins.length - 1; i >= 0; i-- ) {
				plugin = _plugins[i];
				removePlugin(plugin)
			}
			
		}
		
		public function start():void
		{
			if (progress.running) return;
			progress.running = true;
			_lastFrameTime = getTimer();
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		
		public function stop():void
		{
			if (!progress.running) return;
			progress.running = false;
			removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		public function addPlugin(value:BasePlugin):void
		{
			if ((!value) || (_plugins.indexOf(value) >= 0)) return;
			_plugins.push(value);
			value.onEnter();
		}
		public function removePlugin(value:BasePlugin):void
		{
			var index:int = (value)?_plugins.indexOf(value): -1;
			if (index < 0) return;
			_plugins.splice(index, 1);
			value.onExit();
		}
		
		
		
		private function enterFrameHandler(e:Event):void 
		{
			var currentTime:int = getTimer();
			var updateTimes:int = (currentTime-_lastFrameTime) / _settings.updateStepDuration;
			_lastFrameTime += updateTimes * _settings.updateStepDuration;
			for (var i:uint = 0; i < updateTimes; i++ ) {
				update()
			}
			render();
			
		}
		
		
		
		private function render():void
		{
			_synchronizer.executeEnterFrameTasks();
		}
		private function update():void
		{
			_progress.currentUpdateStep++;
			
			_synchronizer.executeUpdateTasks();
			
		}
		
		public function getComponentByID(id:String):*
		{
			return _componentsDict[id];
		}
		
		public function get camera():GameCamera {return _camera;}
		public function get gameInterface():GameInterface {	return _gameInterface; }
		
		public function get progress():GameProgress {return _progress;}
		public function get settings():GameSettings {return _settings;}
		public function get synchronizer():TaskSynchronizer	{return _synchronizer;}
		public function get logger():LogPlugin{	return _logger;}
		
		
		
		public function get racers():Vector.<Racer> {return _racers;}
		public function get objects():Vector.<LocationObject> {return _objects;	}
		
		
		
		
		
	}

}
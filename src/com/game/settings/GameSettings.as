package com.game.settings 
{
	import com.game.plugins.log.ReplayRepository;
	import com.model.connection.P2PConnection;
	import flash.ui.Keyboard;
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class GameSettings 
	{
		public var hostGame:Boolean = true;
				
		public var screenWidth:Number=100;
		public var screenHeight:Number=100;
		public var screenScale:Number = 1;
		public var locationID:int = 1;
		
		public var frameRate:Number = 25;
		public var updateRate:Number = 50;
		
		
		private var _frameStepDuration:int;
		private var _updateStepDuration:int;
		
		public var stepsPerReplayEntry:int = 100;
		public var steepsPerConnectionEntry:int = 100;
		
		
		public var writeReplay:Boolean = false;
		public var playReplay:Boolean = false;
		public var replayName:String;
		
		
		
		
		
		private var _players:Vector.<Player>
		
		public var keyLeft:int = Keyboard.LEFT;
		public var keyRight:int = Keyboard.RIGHT;
		public var keyForward:int = Keyboard.UP;
		public var keyBackward:int = Keyboard.DOWN;
		
		public var stepsPerMiniMapRender:int = 5;
		public var preRaceStartCountTimes:int = 3;
		
		public function GameSettings() 
		{
			_players = new Vector.<Player>();
			
		}
		public function configurate():void
		{
			calculateStepsDuration();
			var log:String;
			if (playReplay) {
				log = ReplayRepository.instansce.getInitializationLog(replayName);
				if ((log) && (log.length)) {
					applyInitializationLog(log);
				}else {
					playReplay = false;
					replayName = null;
				}
			}
			
			if (writeReplay) {
				log = generateInitializationLog();
				ReplayRepository.instansce.saveInitializationLog(replayName, log);
			}
		}
		
		
		public function setReplayParams(replayName:String,writeReplay:Boolean):void
		{
			this.replayName = replayName;
			this.writeReplay = writeReplay;
			this.playReplay = (!writeReplay);
			
		}
		
		
		private function generateInitializationLog():String
		{
			var initializationLog:String;
			
			var logSource:XML =<start/>;
			logSource["@locationID"] = locationID;
			var childNode:XML
			for each(var player:Player in players) {
				childNode =<player/>;
				childNode["@name"] = player.name;
				childNode["@racerTemplate"] = player.racerTemplate;
				childNode["@type"] = player.type;
				
				logSource.appendChild(childNode);
			}
			initializationLog = logSource.toXMLString();

			return initializationLog;
		}
		private function applyInitializationLog(value:String):void
		{
			var logSource:XML = new XML(value);
			locationID = parseInt(logSource["@locationID"]);
			var currentPlayer:Player;
			var editedPlayer:Player;
			
			var name:String;
			var templateID:int;
			var type:int;
			for each(var childNode:XML in logSource["player"]) {
				name = childNode["@name"];
				templateID = parseInt(childNode["@racerTemplate"]);
				type = parseInt(childNode["@type"]);
				
				if (Player.searchPlayerByName(_players,name)) {
					continue
				}
				
				if ((type == Player.TYPE_OWNER) && (Player.searchPlayerByType(_players, Player.TYPE_OWNER))) {
					type = Player.TYPE_REMOTE_PLAYER;
				}
				currentPlayer = new Player();
				currentPlayer.name = name;
				currentPlayer.id = name;
				currentPlayer.racerTemplate = templateID;
				currentPlayer.type = type;
				_players.push(currentPlayer);
				
			}
		}
		
		
		public function addPlayer(value:Player):void
		{
			if ((!value) || (_players.indexOf(value) >= 0)) return;
			_players.push(value);
			
		}
		
		private function calculateStepsDuration():void
		{
			_frameStepDuration = 1000 / frameRate;
			_updateStepDuration = 1000 / updateRate;
		}
		
		public function get frameStepDuration():int {	return _frameStepDuration;	}
		public function get updateStepDuration():int {	return _updateStepDuration;	}
		
		public function get players():Vector.<Player> {	return _players;}
		
	}

}
package com.game.plugins.log 
{
	import flash.net.SharedObject;
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class ReplayRepository 
	{
		static public const PREINSTALLED_LOG_NAME:String = "preinstalled";
		
		static private var _instansce:ReplayRepository = new ReplayRepository();
		private var _so:SharedObject
		
		public function ReplayRepository() 
		{
			if (instansce) {
				throw new Error("sdsd");
				return
			}
			_so = SharedObject.getLocal("ReplayRepository");
			
		}
		public function getReplaysList():Array
		{
			var result:Array = [];
			for (var replayName:String in _so.data) {
				result.push(replayName);
			}
			return result;
		}
		public function saveInitializationLog(replayName:String, log:String):void
		{
			if (!_so.data[replayName]) {
				_so.data[replayName] = { };
			}
			var replay:Object = _so.data[replayName];
			replay.initializationLog = log;
			_so.flush();
		}
		public function saveGamePlayLog(replayName:String, log:String):void
		{
			if (!_so.data[replayName]) {
				_so.data[replayName] = { };
			}
			var replay:Object = _so.data[replayName];
			replay.gameplayLog = log;
			_so.flush();
		}
		
		
		
		public function getInitializationLog(replayName:String):String 
		{
			var result:String
			//replayName = PREINSTALLED_LOG_NAME;
			if (replayName == PREINSTALLED_LOG_NAME) {
				result = PreinstalledReplay.INITIALIZATION_SOURCE;
				return result;
			}
			
			var replay:Object = _so.data[replayName];
			replay = replay?replay.initializationLog:"";
			return result;
		}
		public function getGameplayLog(replayName:String):String
		{
			var result:String 
			//replayName = PREINSTALLED_LOG_NAME;
			if (replayName==PREINSTALLED_LOG_NAME) {
				result = PreinstalledReplay.GAME_PLAY_SOURCE;
				return result;
			}
			
			var replay:Object = _so.data[replayName];
			result = replay?replay.gameplayLog:"";
			return result;
		}
		
		
		
		
		static public function get instansce():ReplayRepository{return _instansce;}
		
	}

}
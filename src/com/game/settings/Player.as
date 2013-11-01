package com.game.settings 
{
	import com.Facade;
	import com.game.entity.Racer;
	import com.managers.info.components.RacerInfo;
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class Player 
	{
		static private var _nexBotIndex:int = 0;
		static public const defaultNames:Array=["Bob","Sam","Mike"]
		
		static public const TYPE_OWNER:int = 1;
		static public const TYPE_CPU:int = 2;
		static public const TYPE_REMOTE_PLAYER:int = 3;
		
		public var name:String;
		public var type:int
		public var racerTemplate:int;
		public var id:String
		
		public function Player() 
		{
			name = "player_" + int(1000 * Math.random());
			id = name;
			
			type = TYPE_OWNER;
			racerTemplate = 100;
		}
		public function initAsCPU():void
		{
			var racers:Vector.<RacerInfo> = Facade.instance.info.racersInfoList;
			var racer:RacerInfo = racers[int(Math.random() * racers.length)];
			
			name = defaultNames[int(Math.random() * defaultNames.length)];
			racerTemplate = racer.infoID;
			id = "cpu_" + (++_nexBotIndex);
			type = TYPE_CPU;
			
		}
		
		public function getDescription():XML
		{
			var result:XML =<player/>;

			result["@name"] = name;
			result["@type"] = type;
			result["@racerTemplate"] = racerTemplate;
			result["@id"] = id;
			
			return result;
		}
		public function setDescription(value:XML):void
		{
			name = value["@name"];
			id = value["@id"];
			type = parseInt(value["@type"]);
			racerTemplate = parseInt(value["@racerTemplate"]);
			
		}
		
		public function clone():Player
		{
			var result:Player = new Player();
			result.name = name;
			result.type = type;
			result.racerTemplate = racerTemplate;
			result.id = id;
			
			return result;
		}
		
		static public function searchPlayerByName(group:Object, playerName:String):Player
		{
			var length:int = group.length;
			var result:Player;
			var currentPlayer:Player
			for (var i:int = 0; i < length; i++ ) {
				currentPlayer = group[i];
				if (currentPlayer.name == playerName) {
					result = currentPlayer;
					break;
				}
			}
			
			return result;
			
		}
		static public function searchPlayerByType(group:Object, playerType:int):Player
		{
			var length:int = group.length;
			var result:Player;
			var currentPlayer:Player
			for (var i:int = 0; i < length; i++ ) {
				currentPlayer = group[i];
				if (currentPlayer.type == playerType) {
					result = currentPlayer;
					break;
				}
			}
			
			return result;
			
		}
		
	}

}
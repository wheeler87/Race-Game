package com.model.connection 
{
	import com.game.settings.Player;
	import com.model.Model;
	import com.model.player.PlayerManager;
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class GameRoomData 
	{
		public var roomCapacity:uint = 2;
		
		public var name:String;
		public var foundername:String;
		public var founderID:String;
		
		private var _players:Vector.<Player>
		
		public function GameRoomData() 
		{
			_players=new Vector.<Player>()
		}
		public function getDescription():String
		{
			var data:XML = <room/>;
			data["@name"] = name;
			data["@founder"] = foundername;
			data["@opened"] = opened;
			data["@founderID"] = founderID;
			data["@roomCapacity"] = roomCapacity;
			
			var childNode:XML
			for (var i:uint = 0; i < _players.length; i++ ) {
				childNode = _players[i].getDescription();
				data.appendChild(childNode);
			}
			
			var result:String = data.toXMLString();
			
			return result;
		}
		public function setDescription(value:String,ownerPlayer:Player):void
		{
			var isFounder:Boolean = ownerPlayer.id == founderID;
			
			var data:XML = new XML(value);
			name = data["@name"];
			foundername = data["@founder"];
			founderID = data["@founderID"];
			roomCapacity = parseInt(data["@roomCapacity"]);
			
			var preExistedPlayers:Vector.<Player> = _players.slice();
			var childNode:XML;
			var currentPlayer:Player
			var playerID:String
			for each(childNode in data["player"]) {
				playerID = childNode["@id"];
				currentPlayer = getPlayerByID(playerID);
				if (currentPlayer) {
					preExistedPlayers.splice(preExistedPlayers.indexOf(currentPlayer), 1);
				}else {
					currentPlayer = new Player();
					addPlayer(currentPlayer);
				}
				currentPlayer.setDescription(childNode);
				if (!isFounder) {
					if (currentPlayer.id == ownerPlayer.id) {
						currentPlayer.type = Player.TYPE_OWNER;
					}else {
						currentPlayer.type = Player.TYPE_REMOTE_PLAYER;
					}
				}
			}
			for each(currentPlayer in preExistedPlayers) {
				playerID = currentPlayer.id;
				removePlayer(playerID);
			}
		}
		
		
		public function get opened():Boolean
		{
			return _players.length<roomCapacity;
		}
		
		public function get players():Vector.<Player> 
		{
			return _players;
		}
		
		static public function sorter(a:GameRoomData, b:GameRoomData):int
		{
			if (a.name < b.name) return -1;
			if (a.name > b.name) return 1;
			return 0;
		}
		
		public function getPlayerByID(playerID:String):Player
		{
			for each(var player:Player in _players) {
				if (player.id == playerID) {
					return player;
				}
			}
			return null;
		}
		public function addPlayer(player:Player,replaceIfExist:Boolean=true):void
		{
			var oldPlayer:Player = getPlayerByID(player.id);
			if ((oldPlayer) && (replaceIfExist)) {
				_players.splice(_players.indexOf(oldPlayer), 1);
				oldPlayer = null;
			}
			if (oldPlayer) return;
			_players.push(player);
		}
		public function removePlayer(playerID:String):void
		{
			var target:Player = getPlayerByID(playerID);
			var index:int = (_players)?_players.indexOf(target): -1;
			if (index >= 0) {
				_players.splice(index, 1);
			}
		}
		
		public function getPlayerFromTypeGroup(types:Array, groupIndex:int = 0):Player
		{
			var result:Player
			var currentPlayer:Player
			var currentGroupIndex:int = -1;
			for (var i:uint = 0; i < _players.length; i++ ) {
				currentPlayer = _players[i];
				if (types.indexOf(currentPlayer.type)<0) continue;
				currentGroupIndex++;
				if (currentGroupIndex == groupIndex) {
					result = currentPlayer;
					break;
				}
			}
			
			return result;
		}
		
	}

}
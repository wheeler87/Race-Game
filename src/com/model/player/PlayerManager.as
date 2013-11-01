package com.model.player 
{
	import com.game.settings.Player;
	import com.model.Model;
	import flash.net.SharedObject;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class PlayerManager 
	{
		private var _model:Model
		
		private var _ownerPlayer:Player
		private var _playersDict:Dictionary
		private var _playersList:Vector.<Player>
		
		public function PlayerManager(model:Model) 
		{
			_model = model;
			
			_playersDict = new Dictionary();
			_playersList = new Vector.<Player>();
			
			createOwnerPlayer();
		}
		private function createOwnerPlayer():void
		{
			var so:SharedObject = SharedObject.getLocal("PlayerData");
			
			var type:int = Player.TYPE_OWNER;
			var name:String = (so && so.data.hasOwnProperty("name"))?so.data.name:"Player_" + int(Math.random() * 1000);
			var racerTemplate:int = (so && so.data.hasOwnProperty("racerTemplate"))?so.data.racerTemplate:100;
			
			_ownerPlayer = addPlayer(name)
			_ownerPlayer.name = name;
			_ownerPlayer.racerTemplate = racerTemplate;
			_ownerPlayer.type = type;
			
			
		}
		
		public function addPlayer(playerID:String):Player
		{
			var result:Player;
			
			if (!_playersDict[playerID]) {
				result = new Player();
				result.id = playerID;
				_playersDict[playerID] = result;
				_playersList.push(result);
			}
			result = _playersDict[playerID];
			return result;
			
		}
		public function removePlayer(playerID:String):Player
		{
			var result:Player = _playersDict[playerID];
			var index:int = (result)?_playersList.indexOf(result): -1;
			
			_playersDict[playerID] = null;
			delete _playersDict[playerID];
			
			if (index >= 0) {
				_playersList.splice(index, 1);
			}
			return result;
		}
		
		public function onPlayerParamsChange(player:Player):void
		{
			if (_playersList.indexOf(player) < 0) {
				return;
			}
			
			if (player.type == Player.TYPE_OWNER) {
				var so:SharedObject = SharedObject.getLocal("PlayerData");
				so.data.name = player.name;
				so.data.racerTemplate = player.racerTemplate;
				so.flush();
			}
			var otherPlayer:Player = getPlayerById(player.id);
			if (otherPlayer != player) {
				if (otherPlayer) {
					removePlayer(otherPlayer.id);
				}
				for (var p:String in _playersDict) {
					otherPlayer = _playersDict[p];
					if (otherPlayer == player) {
						_playersDict[p] = null;
						delete _playersDict[p];
						break;
					}
				}
				_playersDict[player.id] = player;
				
			}
			
		}
		
		
		
		public function getPlayerById(playerID:String):Player
		{
			var result:Player = _playersDict[playerID];
			return result;
		}
		
		
		public function get ownerPlayer():Player 
		{
			return _ownerPlayer;
		}
		
		public function get playersList():Vector.<Player> 
		{
			return _playersList;
		}
		
	}

}
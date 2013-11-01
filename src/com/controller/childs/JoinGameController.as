package com.controller.childs 
{
	import com.game.settings.Player;
	import com.model.ApplicationState;
	import com.model.connection.ConnectionData;
	import com.model.connection.ConnectionEvent;
	import com.model.connection.GameRoomData;
	import com.model.connection.MessageData;
	import com.view.components.joinGame.JoinGameScreen;
	
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class JoinGameController extends BaseChildController 
	{
		
		static private var _instance:JoinGameController = new JoinGameController();
		
		private var _stateScreen:JoinGameScreen
		
		private var _createdGamesList:Vector.<GameRoomData>
		private var _createdGamesDict:Dictionary
		
		public function JoinGameController() 
		{
			super();
			
		}
		override public function onEnter():void 
		{
			super.onEnter();
			
			
			
			
			if (!_stateScreen) {
				var screenWidth:Number = model.screenWidth;
				var screenHeight:Number = model.screenHeight;
				_stateScreen = new JoinGameScreen(screenWidth, screenHeight);
			}
			_createdGamesList = new Vector.<GameRoomData>();
			_createdGamesDict = new Dictionary();
			setPlayerData();
			refreshRomsList();
			
			view.addChildAt(_stateScreen, 0);
			
			
			_stateScreen.activate();
			_stateScreen.backBtn.addEventListener(MouseEvent.CLICK, onBackBtnClick);
			_stateScreen.joinBtn.addEventListener(MouseEvent.CLICK, onJoinBtnClick);
			
			model.connectionManager.gameGroupConnection.addEventListener(ConnectionEvent.MESSAGE, onGameGroupConnectionEvent);
			model.connectionManager.gameGroupConnection.addEventListener(ConnectionEvent.PLAYER_REMOVED, onGameGroupConnectionEvent);
			model.connectionManager.connectToGamesGroupRoom();
			
			
			
			
			trace(this)
		}
		
		
		
		
		
		override public function onExit():void 
		{
			super.onExit();
			_stateScreen.deactivate();
			_stateScreen.backBtn.removeEventListener(MouseEvent.CLICK, onBackBtnClick);
			_stateScreen.joinBtn.removeEventListener(MouseEvent.CLICK, onJoinBtnClick);
			view.removeChild(_stateScreen);
			
			model.connectionManager.gameGroupConnection.removeEventListener(ConnectionEvent.MESSAGE, onGameGroupConnectionEvent);
			model.connectionManager.gameGroupConnection.removeEventListener(ConnectionEvent.PLAYER_REMOVED, onGameGroupConnectionEvent);
			model.connectionManager.gameGroupConnection.closeConnection();
			
		}
		
		static public function get instance():JoinGameController 
		{
			return _instance;
		}
		
		
		private function onBackBtnClick(e:MouseEvent):void 
		{
			model.applicationState = ApplicationState.MAIN_MENU;
		}
		private function onJoinBtnClick(e:MouseEvent):void 
		{
			savePlayerData();
			
			
			model.isGameFounder = false;
			model.gameName = _stateScreen.gameName;
			
			model.applicationState = ApplicationState.LOBBY;
		}
		private function onGameGroupConnectionEvent(e:ConnectionEvent):void 
		{
			var messageData:MessageData
			var connectionData:ConnectionData
			var roomData:GameRoomData
			switch (e.type) 
			{
				case ConnectionEvent.MESSAGE:
					messageData = e.data as MessageData;
					if (messageData.name != MessageData.GAME_ROOM_UPDATE) return;
					
					var roomDescription:String = messageData.data.game;
					var founderPeerID:String = messageData.peerID;
					if (!_createdGamesDict[founderPeerID]) {
						roomData = new GameRoomData();
						_createdGamesDict[founderPeerID] = roomData;
						_createdGamesList.push(roomData);
						
					}
					roomData=_createdGamesDict[founderPeerID]
					roomData.setDescription(roomDescription,model.playerManager.ownerPlayer);
					refreshRomsList();
					
				break;
				case ConnectionEvent.PLAYER_REMOVED:
					connectionData = e.data as ConnectionData;
					var playerPeerID:String = connectionData.peerID;
					roomData = _createdGamesDict[playerPeerID]
					if (!roomData) return;
					_createdGamesDict[playerPeerID] = null;
					delete _createdGamesDict[playerPeerID];
					_createdGamesList.splice(_createdGamesList.indexOf(roomData), 1);
					refreshRomsList()
					
				break;
				
			}
		}
		
		private function refreshRomsList():void
		{
			_createdGamesList.sort(GameRoomData.sorter);
			_stateScreen.setCreatedGamesData(_createdGamesList);
		}
		private function setPlayerData():void
		{
			var ownerPlayer:Player = model.playerManager.ownerPlayer;
			_stateScreen.username = ownerPlayer.name;
			_stateScreen.racerTemplateID = ownerPlayer.racerTemplate;
		}
		private function savePlayerData():void
		{
			var ownerPlayer:Player = model.playerManager.ownerPlayer;
			ownerPlayer.name = _stateScreen.username;
			ownerPlayer.racerTemplate = _stateScreen.racerTemplateID;
			
			model.playerManager.onPlayerParamsChange(ownerPlayer);
		}
	}

}
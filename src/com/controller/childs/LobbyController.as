package com.controller.childs 
{
	import com.game.settings.Player;
	import com.managers.assets.AssetNamesConst;
	import com.model.ApplicationState;
	import com.model.connection.ConnectionData;
	import com.model.connection.ConnectionEvent;
	import com.model.connection.GameRoomData;
	import com.model.connection.MessageData;
	import com.model.Model;
	import com.view.components.lobby.LobbyScreen;
	import com.view.components.lobby.SlotContentRenderer;
	import fl.controls.ComboBox;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class LobbyController extends BaseChildController 
	{
		static private var _instance:LobbyController=new LobbyController()
		
		private var _createdGameRoom:GameRoomData;
		private var _selectedGameRoom:GameRoomData;
		
		private var _stateScreen:LobbyScreen
		
		private var _inGameTransition:Boolean;
		private var _gameTransitionTimer:Timer
		
		public function LobbyController() 
		{
			super();
			if (instance) {
				throw new Error("asas");
				return;
			}
		}
		override public function onEnter():void 
		{
			super.onEnter();
			
			if (!_stateScreen) {
				var screenWidth:Number = model.screenWidth;
				var screenHeight:Number = model.screenHeight;
				var slotsAmount:int = Model.PLAYERS_MAXIMUM;
				_stateScreen = new LobbyScreen(screenWidth, screenHeight,slotsAmount);
			}
			if (!_gameTransitionTimer) {
				_gameTransitionTimer = new Timer(1000);
				_gameTransitionTimer.addEventListener(TimerEvent.TIMER, onGameTransitionTimerEvent);
			}
			
			view.addChildAt(_stateScreen, 0);
			_stateScreen.activate();
			_stateScreen.addEventListener(LobbyScreen.SLOT_TYPE_CHANGE, onSlotTypeChange);
			_stateScreen.backBtn.addEventListener(MouseEvent.CLICK,onBackButtonClick)
			_stateScreen.startBtn.addEventListener(MouseEvent.CLICK,onStartButtonClick)
			resetStateScreen();
			
			model.connectionManager.gameConnection.addEventListener(ConnectionEvent.CONNECT, gameConnectionHandler);
			model.connectionManager.connectToGameRoom(model.gameName);
			
			_stateScreen.mouseEnabled = false;
			_stateScreen.mouseChildren = false;
			_inGameTransition = false;
			
		}
		
		
		override public function onExit():void 
		{
			super.onExit();
			_stateScreen.deactivate();
			_stateScreen.parent.removeChild(_stateScreen);
			
			_stateScreen.removeEventListener(LobbyScreen.SLOT_TYPE_CHANGE, onSlotTypeChange);
			_stateScreen.backBtn.removeEventListener(MouseEvent.CLICK,onBackButtonClick)
			_stateScreen.startBtn.removeEventListener(MouseEvent.CLICK, onStartButtonClick)
			
			model.connectionManager.gameConnection.removeEventListener(ConnectionEvent.CONNECT, gameConnectionHandler);
			model.connectionManager.gameConnection.removeEventListener(ConnectionEvent.PLAYER_ADDED, hostSideGameConnectionEventsHandler);
			model.connectionManager.gameConnection.removeEventListener(ConnectionEvent.PLAYER_REMOVED, hostSideGameConnectionEventsHandler);
			model.connectionManager.gameConnection.removeEventListener(ConnectionEvent.MESSAGE, hostSideGameConnectionEventsHandler);
			
			model.connectionManager.gameGroupConnection.removeEventListener(ConnectionEvent.CONNECT, gameGroupConnectionHadler);
			model.connectionManager.gameGroupConnection.removeEventListener(ConnectionEvent.PLAYER_ADDED, gameGroupConnectionHadler);
			
			model.connectionManager.gameConnection.removeEventListener(ConnectionEvent.MESSAGE, clientSideGameConnectionEventsHandler);
			model.connectionManager.gameConnection.removeEventListener(ConnectionEvent.PLAYER_REMOVED, clientSideGameConnectionEventsHandler);
			
			_gameTransitionTimer.stop();
			
			if (_inGameTransition) {
				var roomData:GameRoomData = (model.isGameFounder)?_createdGameRoom:_selectedGameRoom;
				var player:Player
				var registredPlayer:Player
				for (var i:uint = 0; i < roomData.players.length; i++ ) {
					player = roomData.players[i];
					if (player.id == model.playerManager.ownerPlayer.id) {
						continue;
					}
					model.playerManager.addPlayer(player.id);
					registredPlayer = model.playerManager.getPlayerById(player.id);
					registredPlayer.setDescription(player.getDescription());
					model.playerManager.onPlayerParamsChange(registredPlayer);
					
				}
			}else {
				model.isGameFounder = false;
				model.gameName = null;
				model.connectionManager.gameConnection.closeConnection();
			}
			
			_createdGameRoom = null;
			_selectedGameRoom = null;
			model.connectionManager.gameGroupConnection.closeConnection();
		}
		
		
		private function onStartButtonClick(e:MouseEvent):void 
		{
			sendStartGameMessage();
			startLeaveState(true);
		}
		
		private function onBackButtonClick(e:MouseEvent):void 
		{
			startLeaveState(false);
		}
		
		private function onSlotTypeChange(e:DataEvent):void 
		{
			grabDataFromStateScreen(_createdGameRoom);
			renderStateScreen(_createdGameRoom);
			sendInfoAboutCreatedGame();
			
		}
		
		
		
		private function gameConnectionHandler(e:ConnectionEvent):void 
		{
			_stateScreen.mouseEnabled = true;
			_stateScreen.mouseChildren = true;
			
			if (model.isGameFounder) {
				model.playerManager.ownerPlayer.id = model.connectionManager.gameConnection.peerID;
				model.playerManager.onPlayerParamsChange(model.playerManager.ownerPlayer);
				
				_createdGameRoom = new GameRoomData();
				_createdGameRoom.name = model.gameName;
				_createdGameRoom.roomCapacity = Model.PLAYERS_MAXIMUM;
				_createdGameRoom.foundername = model.playerManager.ownerPlayer.name;
				_createdGameRoom.founderID = model.playerManager.ownerPlayer.id;
				_createdGameRoom.addPlayer(model.playerManager.ownerPlayer.clone());
				renderStateScreen(_createdGameRoom);
				
				model.connectionManager.gameConnection.addEventListener(ConnectionEvent.PLAYER_ADDED, hostSideGameConnectionEventsHandler);
				model.connectionManager.gameConnection.addEventListener(ConnectionEvent.PLAYER_REMOVED, hostSideGameConnectionEventsHandler);
				model.connectionManager.gameConnection.addEventListener(ConnectionEvent.MESSAGE, hostSideGameConnectionEventsHandler);
				
				model.connectionManager.gameGroupConnection.addEventListener(ConnectionEvent.CONNECT, gameGroupConnectionHadler);
				model.connectionManager.gameGroupConnection.addEventListener(ConnectionEvent.PLAYER_ADDED, gameGroupConnectionHadler);
				model.connectionManager.connectToGamesGroupRoom();
			}else {
				model.playerManager.ownerPlayer.id = (e.data as ConnectionData).peerID;
				model.playerManager.onPlayerParamsChange(model.playerManager.ownerPlayer);
				
				_selectedGameRoom = new GameRoomData();
				_selectedGameRoom.name = model.gameName;	
				renderStateScreen(_selectedGameRoom);
				
				model.connectionManager.gameConnection.addEventListener(ConnectionEvent.MESSAGE, clientSideGameConnectionEventsHandler);
				model.connectionManager.gameConnection.addEventListener(ConnectionEvent.PLAYER_REMOVED, clientSideGameConnectionEventsHandler);
				
				sendPlayerInfo(300);
			}
		}
		private function resetStateScreen():void
		{
			var isFounder:Boolean = model.isGameFounder;
			var currentCombo:ComboBox
			for (var i:uint = 0; i < _stateScreen.totalSlots; i++ ) {
				_stateScreen.setSlotType(i, LobbyScreen.SLOT_TYPE_OPENED);
				_stateScreen.setSlotContent(i, null);
				currentCombo = _stateScreen.getSlotTypeSelectorAt(i);
				currentCombo.visible = isFounder;
				currentCombo.enabled = true;
			}
			
			_stateScreen.startBtn.visible = isFounder;
		}
		
		
		private function renderStateScreen(value:GameRoomData):void
		{
			var ownerPlayer:Player = model.playerManager.ownerPlayer;
			var isFounder:Boolean = (value.founderID == ownerPlayer.id);
			
			var currentPlayer:Player;
			var groupIndex1:int = 0;
			var groupIndex2:int = 0;
			var groupTypes1:Array = [Player.TYPE_OWNER,Player.TYPE_REMOTE_PLAYER];
			var groupTypes2:Array=[Player.TYPE_CPU]
			
			
			var currentTypeRenderer:ComboBox
			
			var currentSlotType:int
			for (var i:uint = 0; i < _stateScreen.totalSlots; i++ ) {
				currentSlotType = _stateScreen.getSlotType(i);
				
				if (currentSlotType == LobbyScreen.SLOT_TYPE_CLOSED) {
					currentPlayer = null;
				}else if (currentSlotType == LobbyScreen.SLOT_TYPE_OPENED) {
					currentPlayer = value.getPlayerFromTypeGroup(groupTypes1, groupIndex1);
					groupIndex1++;
				}else if (currentSlotType == LobbyScreen.SLOT_TYPE_CPU) {
					currentPlayer = value.getPlayerFromTypeGroup(groupTypes2, groupIndex2);
					groupIndex2++;
				}
				
				currentTypeRenderer = _stateScreen.getSlotTypeSelectorAt(i);
				currentTypeRenderer.enabled = ((!currentPlayer) || (currentPlayer.id != ownerPlayer.id));
				
				_stateScreen.setSlotContent(i, currentPlayer);
			}
		}
		private function grabDataFromStateScreen(target:GameRoomData):void
		{
			
			var founderMode:Boolean = (model.isGameFounder);
			var slotType:int;
			var playerID:String
			var playerInSlot:Player	
			
			
			for (var i:uint = 0; i < _stateScreen.totalSlots; i++ ) {
				slotType = _stateScreen.getSlotType(i);
				playerInSlot = _stateScreen.getSlotContent(i);
				playerID = (playerInSlot)?playerInSlot.id:"";
				
				if (slotType == LobbyScreen.SLOT_TYPE_CLOSED) 
				{
					if (playerInSlot) {
						target.removePlayer(playerID)
						if ((playerInSlot.type != Player.TYPE_CPU) && (founderMode)) {
							sendCickMessage(playerID);
						}
					}
				}else if (slotType == LobbyScreen.SLOT_TYPE_CPU) {
					if ((playerInSlot) && (playerInSlot.type != Player.TYPE_CPU)) {
						target.removePlayer(playerID);
						if (founderMode) {
							sendCickMessage(playerID);
						}
						playerInSlot = null;
					}
					if (!playerInSlot) {
						var cpu:Player = new Player();
						cpu.initAsCPU();
						target.addPlayer(cpu)
					}
				}else if (slotType == LobbyScreen.SLOT_TYPE_OPENED) {
					if ((playerInSlot) && (playerInSlot.type == Player.TYPE_CPU)) {
						target.removePlayer(playerID)
					}
				}
			}
			target.roomCapacity = _stateScreen.totalSlots - _stateScreen.getSlotsAmountWithType(LobbyScreen.SLOT_TYPE_CLOSED);
		}
		
		private function hostSideGameConnectionEventsHandler(e:ConnectionEvent):void
		{
			var connectionData:ConnectionData
			var messageData:MessageData
			var playerId:String
			
			switch (e.type) 
			{
				case ConnectionEvent.PLAYER_ADDED:
					connectionData = e.data as ConnectionData;
					playerId = connectionData.peerID;
					if (_createdGameRoom.opened) {
						var player:Player = new Player();
						player.id = playerId;
						player.name = "";
						_createdGameRoom.addPlayer(player);
						renderStateScreen(_createdGameRoom);
						sendInfoAboutCreatedGame();
					}else {
						sendCickMessage(playerId);
					}
					
					
				break;
				case ConnectionEvent.PLAYER_REMOVED:
					connectionData = e.data as ConnectionData;
					playerId = connectionData.peerID;
					_createdGameRoom.removePlayer(playerId);
					renderStateScreen(_createdGameRoom);
					sendInfoAboutCreatedGame();
					
					
				break;
				case ConnectionEvent.MESSAGE:
					messageData=e.data as MessageData
					switch (messageData.name) 
					{
						case MessageData.PLAYER_INFO:
							grabPlayerInfo(messageData);
							renderStateScreen(_createdGameRoom);
							sendInfoAboutCreatedGame();
						break;
						
					}
				break;
				
			}
		}
		
		private function clientSideGameConnectionEventsHandler(e:ConnectionEvent):void
		{
			var connectionData:ConnectionData
			var messageData:MessageData
			switch (e.type) 
			{
				case ConnectionEvent.PLAYER_REMOVED:
					connectionData = e.data as ConnectionData;
					if (connectionData.peerID != _selectedGameRoom.founderID) {
						return;
					}
					
					startLeaveState(false)
				break;
				case ConnectionEvent.MESSAGE:
					messageData = e.data as MessageData;
					switch (messageData.name) 
					{
						case MessageData.GAME_ROOM_UPDATE:
							grabInfoAboutSelectedGameRoom(messageData);
							renderStateScreen(_selectedGameRoom);
						break;
						case MessageData.PLAYER_KICK:
							handleCickMessage(messageData);
						break;
						case MessageData.START_GAME:
							handleStartGameMessage(messageData);
						break;
						
					}
				break;
				
			}
		}
		
		
		
		private function gameGroupConnectionHadler(e:ConnectionEvent):void 
		{
			switch (e.type) 
			{
				case ConnectionEvent.CONNECT:
					sendInfoAboutCreatedGame();
				break;
				case ConnectionEvent.PLAYER_ADDED:
					
					sendInfoAboutCreatedGame();
				break;
				
			}
		}
		
		
		
		private function sendInfoAboutCreatedGame():void
		{
			var data:Object = { };
			data.game = _createdGameRoom.getDescription();
			model.connectionManager.gameGroupConnection.sendCommand(MessageData.GAME_ROOM_UPDATE, data);
			model.connectionManager.gameConnection.sendCommand(MessageData.GAME_ROOM_UPDATE, data);
		}
		private function grabInfoAboutSelectedGameRoom(messageData:MessageData):void
		{
			var roomDescription:String = messageData.data.game;
			var ownerPlayer:Player = model.playerManager.ownerPlayer;
			_selectedGameRoom.setDescription(roomDescription,ownerPlayer);
		}
		
		private function sendPlayerInfo(delay:int):void
		{
			var description:String = model.playerManager.ownerPlayer.getDescription().toXMLString();
			var data:Object = new Object();
			data.info = description;
			
			model.connectionManager.gameConnection.sendCommand(MessageData.PLAYER_INFO, data,delay);
		}
		private function grabPlayerInfo(messageData:MessageData):void
		{
			var playerId:String = messageData.peerID;
			var descriptionSRC:String = messageData.data.info;
			var description:XML = new XML(descriptionSRC);
			
			var player:Player = _createdGameRoom.getPlayerByID(playerId);
			if (!player) return;
			player.setDescription(description);
			player.type = Player.TYPE_REMOTE_PLAYER;
			player.id = playerId;
		}
		private function sendCickMessage(receiverId:String):void
		{
			
			var data:Object = new Object();
			data.receiverId = receiverId;
			model.connectionManager.gameConnection.sendCommand(MessageData.PLAYER_KICK, data);
		}
		private function handleCickMessage(messageData:MessageData):void
		{
			var recieverID:String = messageData.data.receiverId;
			if (recieverID == model.playerManager.ownerPlayer.id) {
				startLeaveState(false);
			}
		}
		private function sendStartGameMessage():void
		{
			model.connectionManager.gameConnection.sendCommand(MessageData.START_GAME,null);
		}
		private function handleStartGameMessage(messageData:MessageData):void
		{
			if (model.isGameFounder) {
				return;
			}
			startLeaveState(true);
			
		}
		
		private function startLeaveState(moveInGame:Boolean):void
		{
			_inGameTransition=moveInGame
			var nextState:int=(moveInGame)?ApplicationState.GAME:((model.isGameFounder)?ApplicationState.CREATE_GAME:ApplicationState.JOIN_GAME)
			
			if (_inGameTransition) {
				_stateScreen.mouseEnabled = false;
				_stateScreen.mouseChildren = false;
				_gameTransitionTimer.reset();
				_gameTransitionTimer.start();
			}else {
				model.applicationState = nextState;
			}
		}
		
		private function onGameTransitionTimerEvent(e:TimerEvent):void 
		{
			
			var totalTicks:int = 5;
			//var totalTicks:int = 1;
			
			if (_gameTransitionTimer.currentCount < totalTicks) {
				var sendername:String = "Game will start through";
				var speech:String = (totalTicks - _gameTransitionTimer.currentCount).toString();
				var color:uint = AssetNamesConst.COLOR_GREEN;
				ChatController.instance.panel.addMessage(sendername, color, speech, color);
			}else {
				_gameTransitionTimer.stop();
				model.applicationState = ApplicationState.GAME;
			}
		}
		
		
		static public function get instance():LobbyController 
		{
			return _instance;
		}
		
	}

}
package com.controller.childs 
{
	import com.game.Game;
	import com.game.GameEvent;
	import com.game.settings.GameSettings;
	import com.game.settings.Player;
	import com.managers.assets.AssetNamesConst;
	import com.model.ApplicationState;
	import com.model.connection.ConnectionData;
	import com.model.connection.ConnectionEvent;
	import com.model.connection.MessageData;
	import com.view.components.game.PostGameMenu;
	import flash.events.Event;
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class GameController extends BaseChildController 
	{
		static private var _instance:GameController=new GameController()
		
		private var _game:Game
		private var _postGameMenu:PostGameMenu;
		
		public function GameController() 
		{
			super();
			if (instance) {
				throw new Error("asas");
			}
		}
		
		override public function onEnter():void 
		{
			super.onEnter();
			
			
			
			var settings:GameSettings = generateGameSettings();
			_game = new Game();
			view.addChildAt(_game, 0);
			_game.init(settings);
			_game.start();
			
			_game.addEventListener(GameEvent.CONNECTION_LOG_GENERATED, onLogGenerated);
			_game.addEventListener(GameEvent.RACE_COMPLETED, onRaceCompleted);
			model.connectionManager.gameConnection.addEventListener(ConnectionEvent.MESSAGE, gameConnectionEventsHandler);
			model.connectionManager.gameConnection.addEventListener(ConnectionEvent.PLAYER_REMOVED, gameConnectionEventsHandler);
			
			if (!_postGameMenu) {
				var screenWidth:Number = model.screenWidth;
				var screenHeight:Number = model.screenHeight;
				
				var menuWidth:Number = PostGameMenu.WIDTH;
				var menuHeight:Number = PostGameMenu.HEIGHT;
				
				_postGameMenu = new PostGameMenu();
				_postGameMenu.x = screenWidth - menuWidth-10;
				_postGameMenu.y = (screenHeight - menuHeight) * 0.5;
				_postGameMenu.addEventListener(PostGameMenu.LEAVE_REQUEST,onLeaveGameRequest)
				
			}
			view.addChild(_postGameMenu);
			_postGameMenu.visible = false;
			
			
			
		}
		
		
		override public function onExit():void 
		{
			super.onExit();
			_postGameMenu.deactivate();
			if (_postGameMenu.parent) {
				_postGameMenu.parent.removeChild(_postGameMenu);
			}
			model.gameName = null;
			model.isGameFounder = false;
			
			_game.stop();
			_game.destroy();
			_game.parent.removeChild(_game);
			_game = null;
			model.connectionManager.gameConnection.removeEventListener(ConnectionEvent.MESSAGE, gameConnectionEventsHandler);
			model.connectionManager.gameConnection.removeEventListener(ConnectionEvent.PLAYER_REMOVED, gameConnectionEventsHandler);
		}
		
		
		private function onRaceCompleted(e:GameEvent):void 
		{
			_postGameMenu.visible = true;
			_postGameMenu.reset();
			_postGameMenu.activate();
			
		}
		
		private function onLeaveGameRequest(e:Event):void 
		{
			var appropriateState:int = (model.isGameFounder)?ApplicationState.CREATE_GAME:ApplicationState.JOIN_GAME;
			model.applicationState = appropriateState;
		}
		
		
		private function gameConnectionEventsHandler(e:ConnectionEvent):void 
		{
			var messageData:MessageData
			var connectionData:ConnectionData;
			switch (e.type) 
			{
				
				case ConnectionEvent.MESSAGE:
					messageData = e.data as MessageData;
					switch (messageData.name) 
					{
						case MessageData.PLAYER_LOG:
							handleLogMessage(messageData);
						break;
						
					}
				break;
				case ConnectionEvent.PLAYER_REMOVED:
					connectionData = e.data as ConnectionData;
					handlePlayerDisconnection(connectionData);
				break
			}
		}
		
		private function onLogGenerated(e:GameEvent):void 
		{
			var log:String = e.data as String;
			sendGameLog(log);
		}
		
		
		private function generateGameSettings():GameSettings
		{
			var result:GameSettings = new GameSettings();
			result.hostGame = model.isGameFounder;
			result.screenWidth = model.screenWidth;
			result.screenHeight = model.screenHeight;
			result.screenScale = 3;
			result.locationID = 1;
			
			var currentPlayer:Player;
			for (var i:uint = 0; i < model.playerManager.playersList.length; i++ ) {
				currentPlayer = model.playerManager.playersList[i];
				result.addPlayer(currentPlayer);
			}
			result.configurate();
			return result;
		}
		private function sendGameLog(log:String):void
		{
			var data:Object = new Object();
			data.log = log;
			
			model.connectionManager.gameConnection.sendCommand(MessageData.PLAYER_LOG, data);
		}
		private function handleLogMessage(messageData:MessageData):void
		{
			var senderId:String = messageData.peerID;
			var log:String = messageData.data.log;
			if (senderId == model.playerManager.ownerPlayer.id) {
				return;
			}
			_game.logger.read(log);
		}
		private function handlePlayerDisconnection(connectionData:ConnectionData):void
		{
			var playerID:String = connectionData.peerID;
			var player:Player = model.playerManager.getPlayerById(playerID);
			var senderName:String = "Warnimg";
			var senderColor:uint = AssetNamesConst.COLOR_RED;
			
			var speech:String = (player)?player.name:"player";
			speech += " diconnected";
			var speechColor:uint = AssetNamesConst.COLOR_RED;
			ChatController.instance.panel.addMessage(senderName, senderColor, speech, speechColor);
			
		}
		
		static public function get instance():GameController {return _instance;}
		
	}

}
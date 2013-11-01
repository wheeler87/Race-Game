package com.controller.childs 
{
	import com.game.settings.Player;
	import com.model.ApplicationState;
	import com.model.connection.ConnectionData;
	import com.model.connection.ConnectionEvent;
	import com.view.components.createGame.CreateGameScreen;
	
	
	
	
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class CreateGameController extends BaseChildController 
	{
		static private var _instance:CreateGameController = new CreateGameController();
		
		private var _createGameScreen:CreateGameScreen
		
		public function CreateGameController() 
		{
			super();
			if (instance) {
				throw new Error("singletone");
			}
		}
		override public function onEnter():void 
		{
			super.onEnter();
			if (!_createGameScreen) {
				var screenWidth:Number = model.screenWidth;
				var screenHeight:Number = model.screenHeight;
				_createGameScreen = new CreateGameScreen(screenWidth, screenHeight);
			}
			view.addChildAt(_createGameScreen, 0);
			_createGameScreen.activate();
			_createGameScreen.backBtn.addEventListener(MouseEvent.CLICK, onBackRequest);
			_createGameScreen.createBtn.addEventListener(MouseEvent.CLICK, onCreateRequest);
			
			setPlayerData()
		}
		
		
		override public function onExit():void 
		{
			super.onExit();
			_createGameScreen.deactivate();
			_createGameScreen.parent.removeChild(_createGameScreen);
			_createGameScreen.backBtn.addEventListener(MouseEvent.CLICK, onBackRequest);
			_createGameScreen.createBtn.removeEventListener(MouseEvent.CLICK, onCreateRequest);_createGameScreen.backBtn.addEventListener(MouseEvent.CLICK, onBackRequest);
			_createGameScreen.createBtn.removeEventListener(MouseEvent.CLICK, onCreateRequest);
			
			
		}
		
		
		
		
		
		private function onCreateRequest(e:MouseEvent):void 
		{
			savePlayerData()
			
			var gameName:String = _createGameScreen.gameName;
			model.gameName = gameName;
			model.isGameFounder = true;
			model.applicationState = ApplicationState.LOBBY;
		}
		
		private function onBackRequest(e:MouseEvent):void 
		{
			model.applicationState = ApplicationState.MAIN_MENU;
		}
		
		
		
		private function setPlayerData():void
		{
			var ownerPlayer:Player = model.playerManager.ownerPlayer;
			_createGameScreen.userName = ownerPlayer.name;
			_createGameScreen.racerTemplateID = ownerPlayer.racerTemplate;
		}
		private function savePlayerData():void
		{
			var ownerPlayer:Player = model.playerManager.ownerPlayer;
			ownerPlayer.name = _createGameScreen.userName;
			ownerPlayer.racerTemplate = _createGameScreen.racerTemplateID;
			
			model.playerManager.onPlayerParamsChange(ownerPlayer);
		}
		
		static public function get instance():CreateGameController 
		{
			return _instance;
		}
		
	}

}
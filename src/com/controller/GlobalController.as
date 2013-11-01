package com.controller 
{
	import com.controller.childs.ApplicationInitializationController;
	import com.controller.childs.ChatController;
	import com.controller.childs.CreateGameController;
	import com.controller.childs.GameController;
	import com.controller.childs.JoinGameController;
	import com.controller.childs.LobbyController;
	import com.controller.childs.MainMenuController;
	import com.controller.childs.ReplayController;
	import com.Facade;
	import com.managers.messenger.Message;
	import com.managers.messenger.Messenger;
	import com.model.ApplicationState;
	import com.model.Model;
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class GlobalController 
	{
		private var _childControllers:Vector.<IChildController>
		
		
		public function GlobalController() 
		{
			_childControllers=new Vector.<IChildController>
		}
		public function init():void
		{
			var messanger:Messenger = Facade.instance.messanger;
			messanger.addEventListener(Message.STATE_ENTER, stateEnterHandler);
			messanger.addEventListener(Message.STATE_EXIT, stateExitHandler);
			
			
			
			model.applicationState = ApplicationState.INITIALIZATION;
			
			
		}
		
		public function addChildController(value:IChildController):void
		{
			if ((!value) || (_childControllers.indexOf(value) >= 0)) return;
			_childControllers.push(value);
			value.onEnter();
		}
		public function removeChildController(value:IChildController):void
		{
			var index:int = (value)?_childControllers.indexOf(value): -1;
			if (index < 0) return;
			_childControllers.splice(index, 1);
			value.onExit();
		}
		
		
		
		
		
		//===================================
		//  Handlers
		//===================================
		
		
		private function stateEnterHandler(e:Message):void 
		{
			var state:int = model.applicationState;
			
			switch (state) 
			{
				case ApplicationState.INITIALIZATION:
					addChildController(ApplicationInitializationController.instance);
				break;
				case ApplicationState.MAIN_MENU:
					addChildController(MainMenuController.instance);
				break;
				case ApplicationState.CREATE_GAME:
					addChildController(CreateGameController.instance);
				break;
				case ApplicationState.JOIN_GAME:
					addChildController(JoinGameController.instance);
				break;
				case ApplicationState.LOBBY:
					addChildController(LobbyController.instance);
				break;
				case ApplicationState.GAME:
					addChildController(GameController.instance);
				break;
				case ApplicationState.GAME_REPLAY:
					addChildController(ReplayController.instance);
				break;
				
			}
			
		}
		private function stateExitHandler(e:Message):void 
		{
			var state:int = model.applicationState;
			
			switch (state) 
			{
				case ApplicationState.INITIALIZATION:
					removeChildController(ApplicationInitializationController.instance);
					addChildController(ChatController.instance);
				break;
				case ApplicationState.MAIN_MENU:
					removeChildController(MainMenuController.instance);
				break;
				case ApplicationState.CREATE_GAME:
					removeChildController(CreateGameController.instance);
				break;
				case ApplicationState.JOIN_GAME:
					removeChildController(JoinGameController.instance);
				break;
				case ApplicationState.LOBBY:
					removeChildController(LobbyController.instance);
				break;
				case ApplicationState.GAME:
					removeChildController(GameController.instance);
				break;
				case ApplicationState.GAME_REPLAY:
					removeChildController(ReplayController.instance);
				break;
				
			}
			
		}
		
		
		private function get model():Model { return Facade.instance.model };
		
		
	}

}
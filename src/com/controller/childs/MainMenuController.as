package com.controller.childs 
{
	import com.model.ApplicationState;
	import com.view.components.mainMenu.MainMenuScreen;
	import com.view.components.mainMenu.RaceChar;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.getTimer;
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class MainMenuController extends BaseChildController 
	{
		
		static private var _instance:MainMenuController = new MainMenuController();
		
		private var _stateScreen:MainMenuScreen
		
		private var _selectedState:int
		private var _lastActivityTime:int;
		private var _delayToReplayActivation:int=1000*10;
		
		
		
		public function MainMenuController() 
		{
			super();
			if (instance) {
				throw new Error("ass");
			}
			
		}
		override public function onEnter():void 
		{
			super.onEnter();
			if (!_stateScreen) {
				var screenWidth:Number = model.screenWidth;
				var screenHeight:Number = model.screenHeight;
				
				_stateScreen = new MainMenuScreen(screenWidth, screenHeight);
			}
			view.addChildAt(_stateScreen, 0);
			_stateScreen.reset();
			_stateScreen.activate();
			
			_stateScreen.joinGameMenuItem.addEventListener(Event.SELECT, menuItemSelectionHadler);
			_stateScreen.createGameMenuItem.addEventListener(Event.SELECT, menuItemSelectionHadler);
			_stateScreen.addEventListener(Event.CLOSE, onStateScreenClosed);
			
			startReplayActivationPolicy();
			
		}
		
		
		override public function onExit():void 
		{
			super.onExit();
			_stateScreen.deactivate();
			_stateScreen.parent.removeChild(_stateScreen);
			
			_stateScreen.joinGameMenuItem.removeEventListener(Event.SELECT, menuItemSelectionHadler);
			_stateScreen.createGameMenuItem.removeEventListener(Event.SELECT, menuItemSelectionHadler);
			_stateScreen.removeEventListener(Event.CLOSE, onStateScreenClosed);
			stopReplayActivationPolicy();
		}
		
		private function menuItemSelectionHadler(e:Event):void 
		{
			var appropriateState:int = (e.currentTarget == _stateScreen.joinGameMenuItem)?ApplicationState.JOIN_GAME:ApplicationState.CREATE_GAME;
			stopReplayActivationPolicy();
			startStateTransition(appropriateState);
			
			
		}
		private function startStateTransition(selectedState:int):void
		{
			_selectedState = selectedState;
			_stateScreen.close();
			
		}
		private function onStateScreenClosed(e:Event):void 
		{
			model.applicationState = _selectedState;
		}
		
		
		private function startReplayActivationPolicy():void
		{
			_lastActivityTime = getTimer();
			view.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			
		}
		private function stopReplayActivationPolicy():void
		{
			view.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		private function enterFrameHandler(e:Event):void 
		{
			var currentTime:int = getTimer();
			if ((currentTime-_lastActivityTime) >= _delayToReplayActivation) {
				model.applicationState = ApplicationState.GAME_REPLAY;
			}
		}
		
		
		static public function get instance():MainMenuController {	return _instance;}
		
	}

}
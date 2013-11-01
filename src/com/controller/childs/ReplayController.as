package com.controller.childs 
{
	import com.game.Game;
	import com.game.GameEvent;
	import com.game.plugins.log.ReplayRepository;
	import com.game.settings.GameSettings;
	import com.game.settings.Player;
	import com.greensock.TweenMax;
	import com.model.ApplicationState;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class ReplayController extends BaseChildController 
	{
		static private var _instance:ReplayController = new ReplayController();
		
		private var _game:Game
		
		
		public function ReplayController() 
		{
			super();
			if (instance) {
				throw new Error("asas asasa");
			}
			
		}
		override public function onEnter():void 
		{
			super.onEnter();
			var settings:GameSettings = new GameSettings();
			settings.locationID = 1;
			settings.screenWidth = model.screenWidth;
			settings.screenHeight = model.screenHeight;
			settings.screenScale = 3;
			
			settings.setReplayParams(ReplayRepository.PREINSTALLED_LOG_NAME, false);
			
			settings.configurate();
			
			_game = new Game();
			view.addChildAt(_game, 0);
			_game.init(settings);
			_game.start();
			
			view.stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseInputHandler);
			view.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyboardInputHandler);
			
			_game.addEventListener(GameEvent.LOG_ENTRIES_APPLIED, onReplayComplete);
		}
		
		
		
		override public function onExit():void 
		{
			super.onExit();
			_game.removeEventListener(GameEvent.LOG_ENTRIES_APPLIED, onReplayComplete);
			_game.stop();
			_game.destroy();
			view.removeChild(_game);
			_game = null;
			
			view.stage.removeEventListener(MouseEvent.MOUSE_DOWN, mouseInputHandler);
			view.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyboardInputHandler);
			TweenMax.killDelayedCallsTo(delayedStateTransitionHandler);
		}
		
		
		private function keyboardInputHandler(e:KeyboardEvent):void 
		{
			model.applicationState = ApplicationState.MAIN_MENU;
		}
		
		private function mouseInputHandler(e:MouseEvent):void 
		{
			model.applicationState = ApplicationState.MAIN_MENU;
		}
		private function onReplayComplete(e:GameEvent):void 
		{
			TweenMax.delayedCall(1, delayedStateTransitionHandler);
		}
		private function delayedStateTransitionHandler():void
		{
			model.applicationState = ApplicationState.MAIN_MENU;
		}
		
		static public function get instance():ReplayController 	{return _instance;	}
		
		
	}

}
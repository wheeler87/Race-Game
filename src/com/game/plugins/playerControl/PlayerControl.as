package com.game.plugins.playerControl 
{
	import com.Facade;
	import com.game.entity.Racer;
	import com.game.Game;
	import com.game.plugins.BasePlugin;
	import com.game.plugins.task.PriorityInitialization;
	import com.game.plugins.task.PriorityUpdate;
	import com.game.settings.Player;
	import flash.display.Stage;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.geom.Vector3D;
	
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class PlayerControl extends BasePlugin 
	{
		private var _controlledRacer:Racer
		
		private var _keyLeft:int;
		private var _keyRight:int;
		private var _keyForward:int;
		private var _keyBackward:int;
		
		private var _keyLeftActive:Boolean;
		private var _keyRightActive:Boolean;
		private var _keyForwardActive:Boolean;
		private var _keyBackwardActive:Boolean;
		
		
		private var _helperV1:Vector3D = new Vector3D();
		private var _helperV2:Vector3D = new Vector3D();
		
		public function PlayerControl(owner:Game) 
		{
			super(owner);
			
		}
		override public function onEnter():void 
		{
			super.onEnter();
			
			owner.synchronizer.addInitializationTask(initialize, PriorityInitialization.PLAYER_CONTROLL_PLUGIN_INITIALIZATION);
		}
		override public function onExit():void 
		{
			super.onExit();
			
			owner.synchronizer.removeInitializationTask(initialize);
			owner.synchronizer.removeUpdateTask(applyPlayerInput);
			detachListeners();
		}
		
		
		private function initialize():void
		{
			getControlledRacer();
			getKeyboardValues();
			assignListeners();
			owner.synchronizer.addUpdateTask(applyPlayerInput, PriorityUpdate.APPLY_PLAYER_INPUT);
		}
		private function applyPlayerInput():void
		{
			_controlledRacer.turnForce = 0;
			_controlledRacer.dragForce.scaleBy(0);
			_controlledRacer.angularVelocity = 0;
			
			
			var heading:Vector3D = _helperV1;
			heading.x = Math.cos(_controlledRacer.worldAngle);
			heading.y = Math.sin(_controlledRacer.worldAngle);
			var velocityProjection:Number = heading.dotProduct(_controlledRacer.velocity);
			
			var turnForce:Number = _controlledRacer.racerIfo.turnForce;
			
			if (_keyLeftActive) {
				_controlledRacer.turnForce = (_keyBackwardActive)? turnForce:-turnForce;
			}else if (_keyRightActive) {
				_controlledRacer.turnForce = (_keyBackwardActive)? -turnForce:turnForce;
			}
			if (_keyForwardActive) {
				_controlledRacer.dragForce.x = Math.cos(_controlledRacer.worldAngle)*_controlledRacer.racerIfo.engineForce;
				_controlledRacer.dragForce.y = Math.sin(_controlledRacer.worldAngle)*_controlledRacer.racerIfo.engineForce;
			}else if(_keyBackwardActive) {
				//_controlledRacer.dragForce = -_controlledRacer.racerIfo.breakForce;
				_controlledRacer.dragForce.x = Math.cos(_controlledRacer.worldAngle+Math.PI)*_controlledRacer.racerIfo.breakForce;
				_controlledRacer.dragForce.y = Math.sin(_controlledRacer.worldAngle+Math.PI)*_controlledRacer.racerIfo.breakForce;
			}
			
		}
		
		private function assignListeners():void
		{
			Facade.instance.stage.addEventListener(KeyboardEvent.KEY_DOWN,keyboardInputHandler)
			Facade.instance.stage.addEventListener(KeyboardEvent.KEY_UP, keyboardInputHandler)
			
			
			
		}
		private function detachListeners():void
		{
			Facade.instance.stage.removeEventListener(KeyboardEvent.KEY_DOWN,keyboardInputHandler)
			Facade.instance.stage.removeEventListener(KeyboardEvent.KEY_UP,keyboardInputHandler)
		}
		
		private function keyboardInputHandler(e:KeyboardEvent):void 
		{
			var activeKey:Boolean = (e.type == KeyboardEvent.KEY_DOWN);
			switch (e.keyCode) 
			{
				case _keyLeft:
					_keyLeftActive = activeKey;
				break;
				case _keyRight:
					_keyRightActive = activeKey;
				break;
				case _keyForward:
					_keyForwardActive = activeKey;
				break;
				case _keyBackward:
					_keyBackwardActive = activeKey;
				break;
				
			}
		}
		private function getControlledRacer():void
		{
			for each(var racer:Racer in owner.racers) {
				if (racer.player.type == Player.TYPE_OWNER) {
					_controlledRacer = racer;
					break;
				}
			}
		}
		private function getKeyboardValues():void
		{
			_keyLeft = owner.settings.keyLeft;
			_keyRight = owner.settings.keyRight;
			_keyForward = owner.settings.keyForward;
			_keyBackward = owner.settings.keyBackward;
		}
	}

}
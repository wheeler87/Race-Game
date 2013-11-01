package com.game.plugins.statGame 
{
	import com.game.entity.Racer;
	import com.game.Game;
	import com.game.GameEvent;
	import com.game.plugins.BasePlugin;
	import com.game.plugins.task.PriorityInitialization;
	import com.game.plugins.task.PriorityUpdate;
	import com.managers.assets.AssetNamesConst;
	import com.view.text.ApplicationTF;
	import com.view.text.TextStyle;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class StartGamePlugin extends BasePlugin 
	{
		private var _initialStatesDict:Dictionary
		
		
		private var _messageTF:ApplicationTF;
		private var _holdRacers:Boolean;
		
		
		private var _messages:Array
		private var _currentMessageIndex:int;
		private var _lastMessage:Boolean;
		private var _fadeDuration:int;
		private var _messageExistanceDuration:int;
		private var _timeToNextMessage:int
		
		
		public function StartGamePlugin(owner:Game) 
		{
			super(owner);
			
		}
		override public function onEnter():void 
		{
			super.onEnter();
			owner.synchronizer.addInitializationTask(initialize, PriorityInitialization.START_GAME_INITIALIZATION);
			
		}
		override public function onExit():void 
		{
			super.onExit();
			if (_messageTF) {
				if (_messageTF.parent) {
					_messageTF.parent.removeChild(_messageTF);
				}
				_messageTF = null;
			}
			
			_initialStatesDict = null;
			owner.synchronizer.removeInitializationTask(initialize);
			owner.synchronizer.removeUpdateTask(update);
		}
		
		private function initialize():void
		{
			configurateMessageTF();
			createInitialStates();
			configurateTransitionParams();
			owner.synchronizer.addUpdateTask(update,PriorityUpdate.GAME_START_PLUGIN_UPDATE);
		}
		
		private function createInitialStates():void
		{
			_initialStatesDict = new Dictionary();
			var currentRacer:Racer
			var currentState:RacerInitialState;
			for each(currentRacer in owner.racers) {
				currentState = new RacerInitialState();
				currentState.read(currentRacer);
				
				_initialStatesDict[currentRacer] = currentState;
			}
		}
		
		private function applyInitialStates():void
		{
			var state:RacerInitialState;
			for each(var racer:Racer in owner.racers) {
				state = _initialStatesDict[racer];
				state.apply(racer);
			}
		}
		private function configurateMessageTF():void
		{
			_messageTF = new ApplicationTF();
			_messageTF.alpha = 0;
			owner.gameInterface.addChild(_messageTF);
			
			var style:TextStyle = _messageTF.style;
			style.size = 84;
			style.color = AssetNamesConst.COLOR_RED;
			_messageTF.filters = [AssetNamesConst.WHITE_LINE_THIN];
			_messageTF.update();
			_messageTF.text = "Ready";
			
		}
		private function configurateTransitionParams():void
		{
			_holdRacers = true;
			_fadeDuration = 700;
			_messageExistanceDuration = 1000;
			_timeToNextMessage = 0;
			_currentMessageIndex = -1;
			_lastMessage = false;
			_messages = new Array();
			_messages.push("Ready?");
			for (var i:int = owner.settings.preRaceStartCountTimes; i > 0; i-- ) {
				_messages.push(i.toString());
			}
			_messages.push("Go!")
		}
		
		private function update():void
		{
			var dt:int = owner.settings.updateStepDuration;
			_timeToNextMessage-= dt;
			if (_timeToNextMessage <= 0) {
				_timeToNextMessage = _messageExistanceDuration;
				_currentMessageIndex++;
				if (_messages.length) {
					_lastMessage = (_messages.length == 1);
					_holdRacers = !_lastMessage;
					var message:String = _messages.shift();
					_messageTF.text = message;
					_messageTF.x = (owner.gameInterface.width - _messageTF.width) * 0.5;
					_messageTF.y = (owner.gameInterface.height - _messageTF.height) * 0.5;
					if (_lastMessage) {
						owner.progress.raceStarted = true;
						owner.progress.raceStartTime = getTimer();
						owner.dispatchEvent(new GameEvent(GameEvent.RACE_STARTED));
					}
				}else {
					_lastMessage = false;
					owner.removePlugin(this);
				}
			}
			if(_currentMessageIndex==0) {
				_messageTF.alpha = Math.min((_messageExistanceDuration - _timeToNextMessage) / (Number(_fadeDuration)), 1);
			}else if (_lastMessage) {
				_messageTF.alpha = Math.min((_timeToNextMessage / Number(_fadeDuration)), 1);
			}
			
			
			
			
			if (_holdRacers) {
				applyInitialStates();
			}
			
			
		}
		
	}

}
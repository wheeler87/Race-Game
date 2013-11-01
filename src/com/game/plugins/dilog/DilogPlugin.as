package com.game.plugins.dilog 
{
	import com.game.entity.Racer;
	import com.game.Game;
	import com.game.GameEvent;
	import com.game.plugins.BasePlugin;
	import com.game.plugins.task.PriorityInitialization;
	import com.game.plugins.task.PriorityUpdate;
	import com.game.settings.Player;
	import com.managers.info.components.RacerDilogInfo;
	import com.managers.info.components.RacerInfo;
	
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class DilogPlugin extends BasePlugin 
	{
		private var _displayDilogDuration:int = 3000;
		private var _localRacer:Racer;
		private var _casedTrigerIndex:int;
		private var _cashedPosition:int;
		private var _timeToNextWrongDirectionDialog:int = -1;
		private var _timeToNextPositionChangeDialod:int = _displayDilogDuration * 2;
		private var _timeToNextCollisionMessage:int = _displayDilogDuration * 3;
		
		public function DilogPlugin(owner:Game) 
		{
			super(owner);
			
		}
		
		override public function onEnter():void 
		{
			super.onEnter();
			
			owner.synchronizer.addInitializationTask(initialize, PriorityInitialization.DIALOG_PLUGIN_INIIALIZATION);
		}
		override public function onExit():void 
		{
			super.onExit();
			owner.synchronizer.removeInitializationTask(initialize);
			owner.synchronizer.removeUpdateTask(update);
		}
		
		private function initialize():void
		{
			grabLocalRacer();
			displayDilogForStartRaceCase();
			owner.synchronizer.addUpdateTask(update, PriorityUpdate.DIALOG_PLUGIN_UPDATE);
			owner.addEventListener(GameEvent.RACE_COMPLETED, onRaceCompleted);
		}
		
		private function update():void
		{
			var dt:int = owner.settings.updateStepDuration;
			advanceWrongDirectionDilogPolicy(dt);
			advancePositionChangeDilogPolicy(dt);
			advanceCollisionDialogPolicy(dt);
		}
		
		private function advanceWrongDirectionDilogPolicy(dt:int):void
		{
			var currentTrigger:int = _localRacer.currentTrigger;
			
			if (_timeToNextWrongDirectionDialog >0) {
				_timeToNextWrongDirectionDialog -= dt;
				if (_timeToNextWrongDirectionDialog > 0) {
					_casedTrigerIndex = currentTrigger;
					return;
				}
			}
			
			if ((owner.progress.raceStarted) && (!owner.progress.raceCompleted)) {
				var delta:int = currentTrigger - _casedTrigerIndex;
				if ((delta == -1) || (delta > 1)) {
					displayDilogForWrongDirectionCase();
					_timeToNextWrongDirectionDialog = 1.5 * _displayDilogDuration;
				}
			}
			_casedTrigerIndex = currentTrigger;
		}
		private function advancePositionChangeDilogPolicy(dt:int):void
		{
			
			var currentPosition:int = owner.progress.currentRacePosition;
			if (_timeToNextPositionChangeDialod > 0) {
				_timeToNextPositionChangeDialod -= dt;
				if (_timeToNextPositionChangeDialod > 0) {
					_cashedPosition = currentPosition;
					return;
				}
			}
			if ((owner.progress.raceStarted) && (!owner.progress.raceCompleted)) {
				var delta:int = currentPosition - _cashedPosition;
				if (delta > 0) {
					displayDilogForFailPositionCase();
					_timeToNextPositionChangeDialod = _displayDilogDuration * 1.1;
				}else if (delta < 0) {
					displayDilogForWinPositionCase();
					_timeToNextPositionChangeDialod = _displayDilogDuration * 1.1;
				}
			}
			_cashedPosition = currentPosition;
		}
		private function advanceCollisionDialogPolicy(dt:int):void
		{
			if (_timeToNextCollisionMessage > 0) {
				_timeToNextCollisionMessage-= dt;
				if (_timeToNextCollisionMessage > 0) {
					return;
				}
			}
			if ((_localRacer.justCollidedWithBound) || (_localRacer.justCollidedWithEntity)) {
				displayDilogForCollisionCase();
				_timeToNextCollisionMessage = _displayDilogDuration * 1.5;
			}
		}
		
		private function grabLocalRacer():void
		{
			for each(var racer:Racer in owner.racers) {
				if (racer.player.type == Player.TYPE_OWNER) {
					_localRacer = racer;
					break;
				}
			}
			
			
		}
		private function onRaceCompleted(e:GameEvent):void 
		{
			if (owner.progress.finalRacePosition == 1) {
				displayDilogForWinRaceCase();
			}else {
				displayDilogForFailRaceCase()
			}
		}
		
		
		
		private function displayDilogForStartRaceCase():void
		{
			var dialogs:Vector.<RacerDilogInfo> = _localRacer.racerIfo.raceStartDilogs;
			if (!dialogs.length) return;
			var selectedDialog:RacerDilogInfo = dialogs[int(Math.random() * dialogs.length)];
			if (!selectedDialog.message.length) return;
			owner.gameInterface.displayDilog(selectedDialog.message, selectedDialog.expression, _displayDilogDuration);
		}
		private function displayDilogForWinRaceCase():void
		{
			var dialogs:Vector.<RacerDilogInfo> = _localRacer.racerIfo.raceWinDilogs;
			if (!dialogs.length) return;
			var selectedDialog:RacerDilogInfo = dialogs[int(Math.random() * dialogs.length)];
			if (!selectedDialog.message.length) return;
			owner.gameInterface.displayDilog(selectedDialog.message, selectedDialog.expression, _displayDilogDuration);
		}
		private function displayDilogForFailRaceCase():void
		{
			var dialogs:Vector.<RacerDilogInfo> = _localRacer.racerIfo.raceFailDilogs;
			if (!dialogs.length) return;
			var selectedDialog:RacerDilogInfo = dialogs[int(Math.random() * dialogs.length)];
			if (!selectedDialog.message.length) return;
			owner.gameInterface.displayDilog(selectedDialog.message, selectedDialog.expression, _displayDilogDuration);
		}
		private function displayDilogForWrongDirectionCase():void
		{
			var dialogs:Vector.<RacerDilogInfo> = _localRacer.racerIfo.wrongDirectionDilogs;
			if (!dialogs.length) return;
			var selectedDialog:RacerDilogInfo = dialogs[int(Math.random() * dialogs.length)];
			if (!selectedDialog.message.length) return;
			owner.gameInterface.displayDilog(selectedDialog.message, selectedDialog.expression, _displayDilogDuration);
		}
		private function displayDilogForWinPositionCase():void
		{
			var dialogs:Vector.<RacerDilogInfo> = _localRacer.racerIfo.positionWinDilogs;
			if (!dialogs.length) return;
			var selectedDialog:RacerDilogInfo = dialogs[int(Math.random() * dialogs.length)];
			if (!selectedDialog.message.length) return;
			owner.gameInterface.displayDilog(selectedDialog.message, selectedDialog.expression, _displayDilogDuration);
		}
		private function displayDilogForFailPositionCase():void
		{
			var dialogs:Vector.<RacerDilogInfo> = _localRacer.racerIfo.positionFailDilogs;
			if (!dialogs.length) return;
			var selectedDialog:RacerDilogInfo = dialogs[int(Math.random() * dialogs.length)];
			if (!selectedDialog.message.length) return;
			owner.gameInterface.displayDilog(selectedDialog.message, selectedDialog.expression, _displayDilogDuration);
		}
		private function displayDilogForCollisionCase():void
		{
			var dialogs:Vector.<RacerDilogInfo> = _localRacer.racerIfo.collisionDialogs;
			if (!dialogs.length) return;
			var selectedDialog:RacerDilogInfo = dialogs[int(Math.random() * dialogs.length)];
			if (!selectedDialog.message.length) return;
			owner.gameInterface.displayDilog(selectedDialog.message, selectedDialog.expression, _displayDilogDuration);
		}
		
		
	}

}
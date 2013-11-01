package com.game.plugins.log 
{
	import com.game.entity.Racer;
	import com.game.Game;
	import com.game.GameEvent;
	import com.game.plugins.BasePlugin;
	import com.game.plugins.task.PriorityInitialization;
	import com.game.plugins.task.PriorityUpdate;
	import com.game.plugins.task.Task;
	import com.game.settings.Player;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class LogPlugin extends BasePlugin 
	{
		private static var _instance:LogPlugin
		
		private var _replayLogInvolvedItems:Vector.<ILogItem>;
		private var _gamePlayLog:String;
		private var _stepsToNextReplayLogEntry:int;
		
		private var _connectionLogIvolvedItems:Vector.<ILogItem>;
		private var _stepsToNextConnectionLogEntry:int;
		
		private var _entriesForApply:Vector.<XML>
		private var _applyEntriesStepInterval:int
		
		private var _alignedItmems:Object
		private var _alignedItemsAmount:int
		
		public function LogPlugin(owner:Game) 
		{
			super(owner);
			_replayLogInvolvedItems = new Vector.<ILogItem>();
			_connectionLogIvolvedItems = new Vector.<ILogItem>();
			_entriesForApply = new Vector.<XML>();
			
			_alignedItmems = new Object();
			_alignedItemsAmount = 0;
		}
		
		override public function onEnter():void 
		{
			super.onEnter();
			owner.synchronizer.addInitializationTask(initialize,PriorityInitialization.LOG_PLUGIN_INITIALIZATION);
		}
		override public function onExit():void 
		{
			super.onExit();
			owner.synchronizer.removeInitializationTask(initialize);
		}
		public function read(value:String):void
		{
			var source:XMLList = new XMLList(value);
			var currentEntry:XML
			for (var i:uint = 0; i < source.length(); i++ ) {
				currentEntry = source[i];
				_entriesForApply.push(currentEntry);
			}
			_entriesForApply.sort(entriesCompareFunc);
			
		}
		
		private function initialize():void
		{
			owner.synchronizer.addUpdateTask(alignLogItems, PriorityUpdate.LOG_ALIGN);
			var currentRacer:Racer;
			
			
			if (owner.settings.writeReplay) {
				_gamePlayLog = "";
				_stepsToNextReplayLogEntry = 0;
				
				for each(currentRacer in owner.racers) {
					_replayLogInvolvedItems.push(currentRacer);
				}
				
				
				owner.synchronizer.addUpdateTask(addReplayLogEntry, PriorityUpdate.LOG_WRITE);
			}
			
			var containsRemootePlayers:Boolean;
			for each(var player:Player in owner.settings.players) {
				if (player.type != Player.TYPE_REMOTE_PLAYER) continue;
				containsRemootePlayers = true;
				break
			}
			
			if (containsRemootePlayers) {
				for each(player in owner.settings.players) {
					if (player.type == Player.TYPE_REMOTE_PLAYER) continue
					currentRacer = owner.getComponentByID(player.name) as Racer;
					_connectionLogIvolvedItems.push(currentRacer);
					
				}
				
				_stepsToNextConnectionLogEntry = 0;
				owner.synchronizer.addUpdateTask(addConnectionLogEntry, PriorityUpdate.LOG_WRITE);
			}
			_applyEntriesStepInterval = (containsRemootePlayers)?owner.settings.steepsPerConnectionEntry:owner.settings.stepsPerReplayEntry;
			owner.synchronizer.addUpdateTask(advanceEntryApply, PriorityUpdate.LOG_READ);
			
			
			if (owner.settings.playReplay) {
				
				var playedReplay:String = ReplayRepository.instansce.getGameplayLog(owner.settings.replayName);
				read(playedReplay);
			}
			
		}
		
		private function addReplayLogEntry():void
		{
			if (_stepsToNextReplayLogEntry <= 0) {
				_stepsToNextReplayLogEntry = owner.settings.stepsPerReplayEntry-1;
				var entry:String = generateLogEntry(_replayLogInvolvedItems);
				_gamePlayLog += entry;
				
			}else {
				_stepsToNextReplayLogEntry--;
			}
			if (int(owner.progress.currentUpdateStep%1000)==0) {
				ReplayRepository.instansce.saveGamePlayLog(owner.settings.replayName, _gamePlayLog);
			}
			
			
		}
		private function addConnectionLogEntry():void
		{
			if (_stepsToNextConnectionLogEntry <= 0) {
				_stepsToNextConnectionLogEntry = owner.settings.steepsPerConnectionEntry - 1;
				var entry:String = generateLogEntry(_connectionLogIvolvedItems);
				owner.dispatchEvent(new GameEvent(GameEvent.CONNECTION_LOG_GENERATED, entry));
			}else {
				_stepsToNextConnectionLogEntry--;
			}
		}
		
		
		
		private function generateLogEntry(involvedItems:Vector.<ILogItem>):String
		{
			var source:XML =<step/>
			source["@index"] = owner.progress.currentUpdateStep;
			var childNode:XML
			for each(var logItem:ILogItem in involvedItems) {
				childNode =<item/>;
				childNode["@id"] = logItem.id;
				childNode["@state"] = logItem.write();
				
				source.appendChild(childNode);
			}
			
			var result:String = source.toXMLString();
			return result;
		}
		
		
		private function advanceEntryApply():void
		{
			if ((!_entriesForApply) || (!_entriesForApply.length)) return;
			var maxStepIndex:int = owner.progress.currentUpdateStep + _applyEntriesStepInterval - 1;
			var updateStepForClosestEntry:int = parseInt(_entriesForApply[0]["@index"]);
			
			while (updateStepForClosestEntry <= maxStepIndex) {
				applyLogEntry(_entriesForApply.shift());
				if (_entriesForApply.length) {
					updateStepForClosestEntry=parseInt(_entriesForApply[0]["@index"]);
				}else {
					break;
				}
				
			}
			
		}
		
		
		private function applyLogEntry(data:XML):void
		{
			var currentGameStep:int = owner.progress.currentUpdateStep;
			var stepIndex:int = parseInt(data["@index"]);
			var stepInterval:int = _applyEntriesStepInterval;
			var itemId:String
			var item:ILogItem
			var state:String;
			for each(var childNode:XML in data["item"]) {
				itemId = childNode["@id"];
				state = childNode["@state"];
				
				item = owner.getComponentByID(itemId) as ILogItem;
				if (!_alignedItmems[itemId]) {
					_alignedItemsAmount++;
				}
				
				_alignedItmems[item.id] = item;
				
				item.read(stepIndex,stepInterval,state,currentGameStep);
			}
			
		}
		
		private function entriesCompareFunc(a:XML, b:XML):int
		{
			var stepAIndex:int = parseInt(a["@index"]);
			var stepBIndex:int = parseInt(b["@index"]);
			if (stepAIndex < stepBIndex) return -1;
			if (stepAIndex > stepBIndex) return 1;
			return 0;
		}
		
		private function alignLogItems():void
		{
			var currentGameStep:int = owner.progress.currentUpdateStep;
			var logItem:ILogItem;
			var previousAmount:int = _alignedItemsAmount;
			for (var itemId:String in _alignedItmems) {
				logItem = _alignedItmems[itemId];
				if (logItem.lastAlignmentStepIndex < currentGameStep) {
					_alignedItmems[itemId] = null;
					delete _alignedItmems[itemId];
					_alignedItemsAmount--;
					
				}else {
					logItem.align(currentGameStep);
				}
			}
			
			if ((previousAmount > 0) && (_alignedItemsAmount <= 0) && (!_entriesForApply.length)) {
				owner.dispatchEvent(new GameEvent(GameEvent.LOG_ENTRIES_APPLIED))
			}
		}
		
		
		
		
		static public function get instance():LogPlugin {return _instance;}
		
	}

}
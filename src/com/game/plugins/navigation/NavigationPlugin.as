package com.game.plugins.navigation 
{
	import com.Facade;
	import com.game.entity.Racer;
	import com.game.Game;
	import com.game.GameEvent;
	import com.game.plugins.BasePlugin;
	import com.game.plugins.task.PriorityInitialization;
	import com.game.plugins.task.PriorityUpdate;
	import com.game.settings.Player;
	import com.managers.info.components.LocationInfo;
	import com.managers.info.components.TriggerInfo;
	import flash.geom.Vector3D;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class NavigationPlugin extends BasePlugin 
	{
		private var _helperV1:Vector3D = new Vector3D();
		private var _helperV2:Vector3D = new Vector3D();
		private var _helperV3:Vector3D = new Vector3D();
		
		
		private var _localRacer:Racer;
		
		private var _trigers:Vector.<TriggerInfo>
		private var _lapsAmount:int
		
		public function NavigationPlugin(owner:Game) 
		{
			super(owner);
			
		}
		override public function onEnter():void 
		{
			super.onEnter();
			owner.synchronizer.addInitializationTask(initialize, PriorityInitialization.NAVIGATION_PLUGIN_INITIALIZATION);
		}
		override public function onExit():void 
		{
			super.onExit();
			owner.synchronizer.removeInitializationTask(initialize);
		}
		
		private function initialize():void
		{
			grabLocalRacer();
			resetRacersRaceProgress();
			var locationInfo:LocationInfo = Facade.instance.info.getInfoComponentByID(owner.settings.locationID) as LocationInfo;
			_trigers = locationInfo.triggers;
			_lapsAmount = locationInfo.laps;
			owner.synchronizer.addUpdateTask(updateRaceProgress, PriorityUpdate.NAVIGATION_UPDATE_RACE_PROGRESS);
			owner.synchronizer.addUpdateTask(calculateRacePosition, PriorityUpdate.NAVIGATION_CALCULATE_RACE_POSITION);
		}
		
		private function updateRaceProgress():void
		{
			var intersects:Boolean;
			
			for each(var racer:Racer in owner.racers) {
				var previousTrigerIndex:int = getValidatedTrigerIndex(racer.currentTrigger);
				var nextTrigerIndex:int = getValidatedTrigerIndex(previousTrigerIndex + 1);
				var previousTrigger:TriggerInfo = _trigers[previousTrigerIndex];
				var nextTrigger:TriggerInfo = _trigers[nextTrigerIndex];
				
				intersects = isTriggerIntersection(racer, previousTrigger);
				if (intersects) {
					//backward chekpoit intersection
					previousTrigerIndex = getValidatedTrigerIndex(previousTrigerIndex-1);
					nextTrigerIndex = getValidatedTrigerIndex(previousTrigerIndex + 1);
					if (previousTrigerIndex == (_trigers.length-1)) {
						racer.currentLap--;
					}
					
					
				}else {
					intersects = isTriggerIntersection(racer, nextTrigger);
					if (intersects) {
						//forward checkpoint intersection
						previousTrigerIndex = getValidatedTrigerIndex(previousTrigerIndex+1);
						nextTrigerIndex = getValidatedTrigerIndex(previousTrigerIndex + 1);
						if (previousTrigerIndex == 0) {
							racer.currentLap++;
						}
						if ((racer.currentLap > _lapsAmount) && (!owner.progress.raceCompleted)) {
							calculateRacePosition();
							owner.progress.raceCompleted = true;
							owner.progress.raceCompletionTime = getTimer();
							owner.progress.finalRacePosition = owner.progress.currentRacePosition;
							owner.dispatchEvent(new GameEvent(GameEvent.RACE_COMPLETED));
						}
					}
				}
				racer.currentTrigger = previousTrigerIndex;
				previousTrigger = _trigers[previousTrigerIndex];
				nextTrigger = _trigers[nextTrigerIndex];
				
				var toNextTrigger:Vector3D = _helperV1;
				toNextTrigger.x = nextTrigger.worldX - previousTrigger.worldX;
				toNextTrigger.y = nextTrigger.worldY - previousTrigger.worldY;
				
				var toRacer:Vector3D = _helperV2;
				toRacer.x = racer.wordX - previousTrigger.worldX;
				toRacer.y = racer.wordY - previousTrigger.worldY;
				
				var helper1:Number = toNextTrigger.length;
				toNextTrigger.normalize();
				var helper2:Number = toRacer.dotProduct(toNextTrigger);
				
				var progress:Number=previousTrigerIndex/Number(_trigers.length)+(helper2/helper1)/_trigers.length
				racer.lapProgress = progress;
				
				//trace(progress)
			}
			
		}
		
		private function isTriggerIntersection(racer:Racer, trigger:TriggerInfo):Boolean
		{
			var rightNormal:Vector3D = _helperV1;
			rightNormal.x = Math.cos(trigger.worldAngle + Math.PI * 0.5);
			rightNormal.y = Math.sin(trigger.worldAngle + Math.PI * 0.5);
			
			var toPrevPos:Vector3D = _helperV2;
			toPrevPos.x = racer.lastWorldX - trigger.worldX;
			toPrevPos.y = racer.lastWorldY - trigger.worldY;
			
			var toCurPos:Vector3D = _helperV3;
			toCurPos.x = racer.wordX - trigger.worldX;
			toCurPos.y = racer.wordY - trigger.worldY;
			
			var prevDot:Number = toPrevPos.dotProduct(rightNormal);
			var curDot:Number = toCurPos.dotProduct(rightNormal);
			//trace(prevDot, curDot);
			var forwardIntersection:Boolean = ((prevDot<=0)&&(curDot>0));
			var backwardIntersection:Boolean = ((prevDot >= 0) && (curDot < 0));

			return forwardIntersection||backwardIntersection
			
		}
		private function getValidatedTrigerIndex(value:int):int
		{
			if (value < 0) return _trigers.length - 1;
			if (value >= _trigers.length) return 0;
			return value;
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
		private function resetRacersRaceProgress():void
		{
			for each(var racer:Racer in owner.racers) {
				racer.currentLap = 0;
				racer.currentTrigger = -1;
				racer.lapProgress = 0;
				racer.lastWorldX = racer.wordX;
				racer.lastWorldY = racer.wordY;
			}
			
		}
		private function calculateRacePosition():void
		{
			var currentProgress:Number = _localRacer.lapProgress;
			var currentLap:int = _localRacer.currentLap;
			var position:int = owner.racers.length;
			for each(var racer:Racer in owner.racers) {
				if (racer.currentLap > currentLap) continue;
				if (racer.lapProgress >= currentProgress) continue;
				position--
			}
			owner.progress.currentRacePosition = position;
			
		}
	}

}
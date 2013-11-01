package com.game.plugins.ai 
{
	import com.game.entity.Racer;
	import com.managers.info.components.LocationInfo;
	import com.managers.info.components.TriggerInfo;
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class RacerAi 
	{
		private var _helperV1:Vector3D = new Vector3D();
		private var _helperV2:Vector3D = new Vector3D();
		private var _helperV3:Vector3D = new Vector3D();
		
		private var _cotrolledRacer:Racer
		private var _locationInfo:LocationInfo;
		
		
		
		private var _nextTrigerIndex:int;
		private var _triggerLongitudinalOffsetMax:Number=120;
		private var _triggerNormalOffsetRegular:Number = 10;
		private var _dragForceMinRatio:Number = 0.7;
		
		private var _alignedWorldX:Number;
		private var _alignedWorldY:Number;
		private var _dragForceValue:Number;
		
		
		public function RacerAi() 
		{
			
		}
		
		public function init(controlledRacer:Racer, locationInfo:LocationInfo):void
		{
			_cotrolledRacer = controlledRacer;
			_locationInfo = locationInfo;
			
			_nextTrigerIndex = _locationInfo.triggers.length - 1;
			_alignedWorldX = controlledRacer.wordX;
			_alignedWorldY = controlledRacer.wordY;
			
		}
		public function update():void
		{
			if (triggerReelectionRequires()) {
				reselectTrigger();
			}
			stearRacer();
		}
		
		
		private function triggerReelectionRequires():Boolean
		{
			var result:Boolean = (_cotrolledRacer.currentTrigger == _nextTrigerIndex);
			return result;
		}
		private function reselectTrigger():void
		{
			if (_cotrolledRacer.currentTrigger < 0) return;
			_nextTrigerIndex = getValidatedTriggerIndex(_cotrolledRacer.currentTrigger + 1);
			var trigger:TriggerInfo = _locationInfo.triggers[_nextTrigerIndex];
			
			
			var triggerHeading:Vector3D = _helperV1;
			triggerHeading.x = Math.cos(trigger.worldAngle);
			triggerHeading.y = Math.sin(trigger.worldAngle);
			
			var triggerRNormal:Vector3D = _helperV2;
			triggerRNormal.x = Math.cos(trigger.worldAngle + Math.PI * 0.5);
			triggerRNormal.y = Math.sin(trigger.worldAngle + Math.PI * 0.5);
			
			var offsetL:Number = -0.5 * _triggerLongitudinalOffsetMax + Math.random() * _triggerLongitudinalOffsetMax * 0.5;
			var offsetN:Number = _triggerNormalOffsetRegular;
			
			_alignedWorldX = trigger.worldX + offsetL * triggerHeading.x + offsetN * triggerRNormal.x;
			_alignedWorldY = trigger.worldY + offsetL * triggerHeading.y + offsetN * triggerRNormal.y;
			
			_dragForceValue = _cotrolledRacer.racerIfo.engineForce*(_dragForceMinRatio+Math.random()*(1-_dragForceMinRatio));
		}
		private function stearRacer():void
		{
			var angleToDetination:Number = Math.atan2(_alignedWorldY - _cotrolledRacer.wordY, _alignedWorldX - _cotrolledRacer.lastWorldX);
			var heading:Vector3D = _helperV1;
			heading.x = Math.cos(angleToDetination);
			heading.y = Math.sin(angleToDetination);
			
			//var normalL:Vector3D = _helperV2;
			//normalL.x = Math.cos(angleToDetination + Math.PI * 0.5);
			//normalL.y = Math.sin(angleToDetination + Math.PI * 0.5);
			//
			//var racerHeading:Vector3D = _helperV3;
			//racerHeading.x = Math.cos(_cotrolledRacer.worldAngle);
			//racerHeading.y = Math.sin(_cotrolledRacer.worldAngle);
			//
			
			_cotrolledRacer.dragForce.x = heading.x * _dragForceValue;
			_cotrolledRacer.dragForce.y = heading.y * _dragForceValue;
			_cotrolledRacer.worldAngle=angleToDetination
			
			
			//var deviationValue:Number = Vector3D.angleBetween(heading, racerHeading);
			//var deviationOrt:int = (normalL.dotProduct(racerHeading) < 0)?1: -1;
			//if (deviationValue > (Math.PI / 180.0 * 20)) {
				//
				//
				//var turnForceValue:Number = _cotrolledRacer.racerIfo.turnForce*0.25;
				//_cotrolledRacer.turnForce = turnForceValue * deviationOrt;
				
			//}
			//
			
		}
		
		private function getValidatedTriggerIndex(value:int):int
		{
			if (value < 0) return _locationInfo.triggers.length - 1;
			if (value >= _locationInfo.triggers.length) return 0;
			return value;
		}
	}

}
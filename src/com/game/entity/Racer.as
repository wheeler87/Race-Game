package com.game.entity 
{
	import com.game.plugins.log.ILogItem;
	import com.game.settings.Player;
	import com.managers.info.components.RacerInfo;
	import com.managers.info.components.SheetInfo;
	import com.view.Sheet;
	import flash.display.Bitmap;
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class Racer extends BaseEntity implements ILogItem
	{
		public var player:Player;
		
		public var currentLap:int;
		public var lapProgress:Number;
		public var currentTrigger:int
		
		
		private var _racerIfo:RacerInfo;
		private var _frameRenderer:Bitmap
		private var _detailedSheet:Sheet;
		private var _generalSheet:Sheet
		
		private var _lastEntryStepIndex:int = -1;
		private var _lastEntryWorldX:Number;
		private var _lastEntryWorldY:Number;
		
		
		private var _lastAlignmentStepIndex:int
		private var _aligmentWorldX:Number;
		private var _aligmentWorldY:Number;
		private var _aligmentWorldAngle:Number;
		
		private var _alignWorldXPerStep:Number;
		private var _alignWorldYPerStep:Number;
		private var _alignWorldAnglePerStep:Number;
		
		public function Racer() 
		{
			super();
			
			_gameCameraSkin.graphics.clear();
			_gameCameraSkin.graphics.beginFill(0);
			_frameRenderer = new Bitmap();
			gameCameraSkin.addChild(_frameRenderer);
			_frameRenderer.scaleX = _frameRenderer.scaleY = 0.8;
			_detailedSheet = new Sheet();
			_generalSheet = new Sheet();
			
			_wordX = 100;
			_wordY = 100;
			_worldAngle = (Math.PI / 180.0) * (0);
			
		}
		override public function init(templateID:int):void 
		{
			super.init(templateID);
			_racerIfo = baseInfo as RacerInfo;
			_detailedSheet.init(_racerIfo.detailedRaceSheetID);
			_generalSheet.init(_racerIfo.generalRaceSheetID);
			
			
			mass = _racerIfo.mass;
			boundRadius = 20;
			updateSkin();
		}
		
		
		
		public function get racerIfo():RacerInfo {	return _racerIfo;}
		
		override public function set screenAngle(value:Number):void 
		{
			super.screenAngle = value;
			updateSkin();
			
		}
		
		override public function set boundRadius(value:Number):void 
		{
			super.boundRadius = value;
			updateSkin();
		}
		
		private function updateSkin():void
		{
			var screenRotation:Number = super.screenAngle / Math.PI * 180.0;
			var generalSheetRequires:Boolean = ((screenRotation > _racerIfo.maxDeviationAngle) && (screenRotation<(360-_racerIfo.maxDeviationAngle)))
			//generalSheetRequires = true;
			var actualSheet:Sheet = (generalSheetRequires)?_generalSheet:_detailedSheet;
			if (actualSheet.framePixels != _frameRenderer.bitmapData) {
				_frameRenderer.bitmapData = actualSheet.framePixels;
				_frameRenderer.x = -_frameRenderer.width * 0.5;
				
			}
			_frameRenderer.y = -_frameRenderer.height+boundRadius;
			
			var actualFrameIdex:int
			var ratio:Number
			if (generalSheetRequires) {
				if (screenRotation < (360.0 / _generalSheet.tilesAmount)) {
					screenRotation = 360;
				}
				ratio = (1 - (screenRotation / 360.0));
			}else {
				if (screenRotation > _racerIfo.maxDeviationAngle) screenRotation -= 360;
				ratio = (screenRotation + _racerIfo.maxDeviationAngle) / (2 * _racerIfo.maxDeviationAngle);
			}
			actualFrameIdex = Math.round((actualSheet.tilesAmount - 1) * ratio);
			if (actualSheet.selectedTileIndex != actualFrameIdex) {
				actualSheet.selectedTileIndex = actualFrameIdex;
			}
		}
		
		
		
		/* INTERFACE com.game.plugins.log.ILogItem */
		
		public function get lastAlignmentStepIndex():int 
		{
			return _lastAlignmentStepIndex;
		}
		
		public function write():String 
		{
			var params:Array = [];
			params.push(int(wordX));
			params.push(int(wordY));
			
			
			var result:String = params.join(",");
			return result;
		}
		
		public function read(entryStepIndex:int, stepInterval:int, value:String, currentStepIndex:int):void 
		{
			var params:Array = value.split(",");
			var currentEntryWorldX:Number = params[0];
			var currentEntryWorldY:Number = params[1];
			var currentEntryWorldAngle:Number = params[2];
			if (_lastEntryStepIndex < 0) {
				_lastEntryWorldX = currentEntryWorldX;
				_lastEntryWorldY = currentEntryWorldY;
				
			}
			var intepolationDuration:int = currentStepIndex + stepInterval - entryStepIndex;
			
			var kX:Number = Math.atan2(currentEntryWorldX - _lastEntryWorldX, stepInterval);
			var kY:Number = Math.atan2(currentEntryWorldY - _lastEntryWorldY, stepInterval);
			
			
			_lastAlignmentStepIndex = entryStepIndex;
			_lastEntryWorldX = currentEntryWorldX;
			_lastEntryWorldY = currentEntryWorldY;
			
			
			
			_lastAlignmentStepIndex = currentStepIndex + stepInterval - 1;
			_aligmentWorldX = currentEntryWorldX + Math.tan(kX) * intepolationDuration;
			_aligmentWorldY = currentEntryWorldY + Math.tan(kY) * intepolationDuration;
			
			
			var alignmentWA:Number = Math.atan2(_aligmentWorldY - _wordY, _aligmentWorldX - _wordX);
			
			_alignWorldXPerStep = Math.abs((_aligmentWorldX - _wordX) / Number(stepInterval));
			_alignWorldYPerStep = Math.abs((_aligmentWorldY - _wordY) / Number(stepInterval));
			_alignWorldAnglePerStep = Math.abs((alignmentWA-_worldAngle) / Number(stepInterval));
			
			
		}
		
		public function align(currentGameStep:int):void 
		{
			var stepXAbs:Number = Math.min(_alignWorldXPerStep, Math.abs(_wordX - _aligmentWorldX));
			var stepXOrt:Number = (_wordX < _aligmentWorldX)?1: -1;
			
			var stepYAbs:Number = Math.min(_alignWorldYPerStep, Math.abs(_wordY - _aligmentWorldY));
			var stepYOrt:Number = (_wordY < _aligmentWorldY)?1: -1;
			
			
			
			_wordX += stepXAbs* stepXOrt;
			_wordY += stepYAbs * stepYOrt;
			if ((stepXAbs > 0) || (stepYAbs > 0)) {
				var wishfulWorldAngle:Number = Math.atan2(_aligmentWorldY - _wordY, _aligmentWorldX - _wordX);
				var angleDelta:Number = wishfulWorldAngle-_worldAngle;
				if (angleDelta > Math.PI) {
					angleDelta -= Math.PI * 2;
				}else if (angleDelta < ( -Math.PI)) {
					angleDelta += Math.PI * 2;
				}
				var angleOrt:int = (angleDelta < 0)? -1:1;
				angleDelta=Math.min(Math.abs(angleDelta),Math.PI/180*1)*angleOrt
				
				_worldAngle += angleDelta;
				
			}
			
			
		}
	}

}
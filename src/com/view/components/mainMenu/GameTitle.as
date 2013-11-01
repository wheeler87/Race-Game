package com.view.components.mainMenu 
{
	//import com.greensock.TimelineMax;
	import com.greensock.TweenMax;
	import com.view.ApplicationSprite;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.filters.DropShadowFilter;
	
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class GameTitle extends ApplicationSprite 
	{
		private var _charW:int = 50;
		private var _charH:int = 70;
		private var _charFontSize:int=48
		
		private var _gameNameCharsSection1:Vector.<RaceChar>
		private var _gameNameCharsSection2:Vector.<RaceChar>
		
		private var _active:Boolean;
		private var _pulsiveAnimationMinDelay:Number = 4.5;
		private var _pulsiveAnimationExtraDelay:Number = 2.5;
		
		private var _zoomedAnimationMinDelay:Number = 0.75;
		private var _zoomedAnimationExtraDelay:Number = 0.75;
		
		public function GameTitle() 
		{
			super();
			
			createChars();
			occupySpace();
			reset();
			
			
		}
		public function reset():void
		{
			RaceChar.position(_gameNameCharsSection1, _charW*0.5,_charH*0.5 , _charW+4, 0, this);
			RaceChar.position(_gameNameCharsSection2, _charW * 0.5 + 150, _charH * 1.5 + 15 , _charW+4, 0, this);
		}
		public function activate():void
		{
			_active = true;
			startIntroAnimation();
		}
		public function deactivate():void
		{
			_active = false;
			TweenMax.killChildTweensOf(this);
			TweenMax.killDelayedCallsTo(runPulsiveAnimation);
			TweenMax.killDelayedCallsTo(runZoomedAnimation);
		}
		public function close():int
		{
			var charsList:Vector.<RaceChar> = _gameNameCharsSection1.concat(_gameNameCharsSection2);
			var duration:Number = 0.99;
			var vars:Object
			var dr:Number
			for each(var raceChar:RaceChar in charsList) {
				vars = new Object();
				
				dr = 180.0 * raceChar.x / (_charH * Math.PI * 0.5);
				
				vars.x = _charW * 0.5;
				vars.rotation = -dr;
				
				TweenMax.to(raceChar, duration, vars);
			}
			
			return duration;
		}
		
		
		private function createChars():void
		{
			
			
			_gameNameCharsSection1 = RaceChar.generateFromString("Squeeze", RaceChar.TYPE_BLACK, _charW, _charH, _charFontSize, true);
			_gameNameCharsSection2 = RaceChar.generateFromString("pedal", RaceChar.TYPE_BLACK, _charW, _charH, _charFontSize, true);
			
		}
		private function occupySpace():void
		{
			var g:Graphics = graphics;
			g.clear();
			g.beginFill(0xfffffff, 0.2);
			g.drawRect(0, 0, width, height);
		}
		
		
		
		private function startIntroAnimation():void
		{
			var delayPerItem:Number = 0.051;
			var duration:Number = 0.05;
			var delay:Number;
			var extraDelay:Number=0;
			var currentSection:Vector.<RaceChar>=_gameNameCharsSection1;
			var currentCharRenderer:RaceChar;
			
			for (var i:uint = 0; i < currentSection.length; i++ ) {
				
				currentCharRenderer = currentSection[i];
				currentCharRenderer.rotationY = -90;
				currentCharRenderer.rotation = 0;
				delay = extraDelay + delayPerItem * i;
				applyIntroAnimation(currentCharRenderer, delay, duration);
			}
			
			currentSection=_gameNameCharsSection2;
			extraDelay = 3 * delayPerItem;
			
			for (i= 0; i < currentSection.length; i++ ) {
				
				currentCharRenderer = currentSection[i];
				currentCharRenderer.rotationY = -90;
				currentCharRenderer.rotation = 0;
				delay = extraDelay + delayPerItem * i;
				applyIntroAnimation(currentCharRenderer, delay, duration);
			}
			TweenMax.delayedCall(delay + delayPerItem, onIntroAnimationComplete);
			
			
			
		}
		private function onIntroAnimationComplete():void
		{
			runPulsiveAnimation();
			TweenMax.delayedCall(_zoomedAnimationMinDelay, runZoomedAnimation);
		}
		
		private function runPulsiveAnimation():void
		{
			if (!_active) return;
			
			
			var currentChar:RaceChar;
			var delayPerItem:Number = 0.1;
			var duration:Number = 0.15;
			var extraDelay:Number = 0;
			var delay:Number;
			var displacementY:Number = (Math.random() < 0.5)? -25:25;
			
			var currentSection:Vector.<RaceChar>=_gameNameCharsSection1
			
			for (var i:uint = 0; i < currentSection.length; i++ ) {
				currentChar = currentSection[i];
				
				delay = extraDelay + delayPerItem * i;
				applyDiplacementAnimation(currentChar, delay, displacementY, duration,2);
				
			}
			extraDelay = delayPerItem*3;
			
			currentSection = _gameNameCharsSection2;
			for (i = 0; i < currentSection.length; i++ ) {
				currentChar = currentSection[i];
				
				delay = extraDelay + delayPerItem * i;
				applyDiplacementAnimation(currentChar, delay, displacementY, duration,2);
				
			}
			
			
			var timeToNextCall:Number = _pulsiveAnimationMinDelay + Math.random() * _pulsiveAnimationExtraDelay;
			TweenMax.delayedCall(timeToNextCall, runPulsiveAnimation);
			
			
			
		}
		private function runZoomedAnimation():void
		{
			if (!_active) return;
			var appropriateList:Vector.<RaceChar> = (Math.random() < 0.5)?_gameNameCharsSection1:_gameNameCharsSection2;
			var selectedChar:RaceChar = appropriateList[int(appropriateList.length * Math.random())];
			var timeToNextCall:Number = _zoomedAnimationMinDelay + Math.random() * _zoomedAnimationExtraDelay;
			var delay:Number = 0.0;
			var zoomAmount:Number = 1.1;
			var iterations:int = 2;
			var duration:Number = 0.15;
			
			applyZoomedAimation(selectedChar, zoomAmount, delay, duration, iterations);
			
			TweenMax.delayedCall(timeToNextCall, runZoomedAnimation);
		}
		
		private function applyDiplacementAnimation(target:DisplayObject,delay:Number, displacementY:Number,duration:Number,iterations:int):void
		{
			if (iterations <= 0) return;
			var vars:Object = new Object();
			vars.y = target.y + displacementY;
			vars.delay = delay;
			vars.onComplete = applyDiplacementAnimation;
			vars.onCompleteParams = [target, 0.0, -displacementY, duration, iterations - 1];
			
			TweenMax.to(target, duration, vars);
			
		}
		private function applyIntroAnimation(target:DisplayObject, delay:Number, duration:Number):void
		{
			var vars:Object = new Object();
			vars.delay = delay;
			vars.rotationY = 0;
			TweenMax.to(target, duration, vars);
		}
		private function applyZoomedAimation(target:DisplayObject, maxZoom:Number,delay:Number, duration:Number, iterations:int):void
		{
			if (iterations <= 0) return;
			
			var actualZoom:Number = (iterations % 2)?1.0 / maxZoom:maxZoom;
			iterations--;
			
			var vars:Object = new Object();
			vars.delay = delay
			vars.scaleX = actualZoom;
			vars.scaleY = actualZoom;
			vars.onComplete = applyZoomedAimation;
			vars.onCompleteParams = [target, maxZoom, delay, duration, iterations];
			
			TweenMax.to(target, duration, vars);
			
		}
		
	}

}
package com.view.components.mainMenu 
{
	import com.greensock.TweenMax;
	import com.view.ApplicationSprite;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	[Event(name="select", type="flash.events.Event")]
	public class MenuItem extends ApplicationSprite 
	{
		private var _charsList:Vector.<RaceChar>
		
		private var _label:String;
		private var _charWidth:Number = 30;
		private var _charHeight:Number = 40;
		private var _charsGap:Number=5
		private var _fontSize:uint = 24;
		
		private var _width:Number;
		private var _height:Number;
		
		private var _active:Boolean;
		private var _attractiveAimationEnabled:Boolean;
		
		private var _defaultRotationsDict:Dictionary
		
		
		
		public function MenuItem() 
		{
			super();
			
			mouseChildren = false;
		}
		public function init(label:String):void
		{
			_defaultRotationsDict = new Dictionary();
			while (numChildren) {
				removeChildAt(0);
			}
			_label = label;
			var startType:int = RaceChar.TYPE_BLACK;
			
			_charsList=RaceChar.generateFromString(label, startType, _charWidth, _charHeight, _fontSize, true);
			_width = _charsList.length * _charWidth;
			_height = _charHeight;
			
			
			ocuppySpace();
			reset();
		}
		private function ocuppySpace():void
		{
			var g:Graphics = graphics;
			g.clear();
			g.beginFill(0, 0.0);
			g.drawRect(0, 0, _width, _height);
		}
		
		public function reset():void
		{
			RaceChar.position(_charsList, _charWidth * 0.5, _charHeight * 0.5, _charWidth + _charsGap, 0, this);
			setDefaultRotations();
		}
		
		public function close():void
		{
			var speed:Number = 300;
			var dx:Number;
			var dr:Number;
			var vars:Object
			
			var delayPerItem:Number=_charWidth/speed
			var currentDuraton:Number
			var currentDelay:Number
			var maxAnimationDuration:Number=0
			
			for each(var raceChar:RaceChar in _charsList) {
				dx = raceChar.x;
				dr = 180.0 * dx / (Math.PI * _charHeight * 0.5);
				
				vars = new Object();
				vars.x = 0;
				vars.rotation = raceChar.rotation - dr;
				
				//currentDelay=(_charsList.length - i - 1) * delayPerItem;
				currentDuraton = dx / speed;
				
				TweenMax.to(raceChar, currentDuraton, vars);
			}
		}
		
		public function activate():void
		{
			if (_active) return;
			_active = true;
			startIntroAnimation();
		}
		public function deactivate():void
		{
			if (!_active) return;
			_active = false;
			_attractiveAimationEnabled = false;
			TweenMax.killChildTweensOf(this);
			TweenMax.killDelayedCallsTo(onIntroAnimationComplete);
			TweenMax.killDelayedCallsTo(startAttractiveAnimation);
			TweenMax.killDelayedCallsTo(onInAlignedStateTransitionCoplete);
			
			detachMouseListeners();
		}
		
		
		static public function position(group:Vector.<MenuItem>, startX:Number, startY:Number, gapH:Number, gapV:Number, parent:DisplayObjectContainer):void
		{
			var length:int = (group)?group.length:0;
			
			var currentMenuItem:MenuItem;
			for (var i:uint = 0; i < length; i++ ) {
				currentMenuItem = group[i];
				currentMenuItem.x = startX + i * gapH;
				currentMenuItem.y = startY + i * gapV;
				
				if (parent) {
					parent.addChild(currentMenuItem);
				}
			}
		}
		
		private function setDefaultRotations():void
		{
			var minRotation:Number = -40;
			var roatationRange:Number = 80;
			var currentRotation:Number;
			for each(var raceChar:RaceChar in _charsList) {
				currentRotation = minRotation + Math.random() * roatationRange;
				_defaultRotationsDict[raceChar] = currentRotation;
			}
		}
		
		private function startIntroAnimation():void
		{
			var currentChar:RaceChar;
			var dx:Number
			var dr:Number;
			var startRotation:Number
			
			var vars:Object
			var speed:Number = 300;
			var delayPerItem:Number=_charWidth/speed
			var currentDuraton:Number
			var currentDelay:Number
			var maxAnimationDuration:Number=0
			
			for (var i:uint = 0; i < _charsList.length; i++ ) {
				currentChar = _charsList[i];
				startRotation = _defaultRotationsDict[currentChar];
				currentChar.rotation = startRotation;
				
				dx = currentChar.x - (_charWidth * 0.5);
				dr =180.0*dx / (Math.PI * _charHeight*0.5);
				
				currentDelay=(_charsList.length - i - 1) * delayPerItem;
				currentDuraton = dx / speed;
				
				vars = new Object();
				vars.x = currentChar.x - dx;
				vars.rotation = currentChar.rotation - dr;
				vars.delay = currentDelay;
				
				
				TweenMax.from(currentChar, currentDuraton, vars);
				
				if (maxAnimationDuration < (currentDelay + currentDuraton)) {
					maxAnimationDuration = currentDuraton + currentDelay;
				}
			}
			
			TweenMax.delayedCall(maxAnimationDuration + 0.1, onIntroAnimationComplete);
		}
		
		
		private function onIntroAnimationComplete():void
		{
			if (!_active) return;
			attachMouseListeners();
		}
		private function attachMouseListeners():void
		{
			addEventListener(MouseEvent.ROLL_OVER, mouseEventHadler);
			addEventListener(MouseEvent.ROLL_OUT, mouseEventHadler);
			addEventListener(MouseEvent.CLICK, mouseEventHadler);
			buttonMode = true;
		}
		private function detachMouseListeners():void
		{
			removeEventListener(MouseEvent.ROLL_OVER, mouseEventHadler);
			removeEventListener(MouseEvent.ROLL_OUT, mouseEventHadler);
			removeEventListener(MouseEvent.CLICK, mouseEventHadler);
			buttonMode = false;
		}
		
		private function mouseEventHadler(e:MouseEvent):void
		{
			switch (e.type) 
			{
				case MouseEvent.CLICK:
					dispatchEvent(new Event(Event.SELECT));
				break;
				case MouseEvent.ROLL_OVER:
					startInAlignedStateTransition();
				break;
				case MouseEvent.ROLL_OUT:
					startFromAlignedStateTransition();
				break;
				
			}
		}
		
		private function startInAlignedStateTransition():void
		{
			var duration:Number = 0.25;
			
			var vars:Object
			
			for each(var raceChar:RaceChar in _charsList) {
				vars = new Object();
				vars.rotation = 0;
				
				TweenMax.to(raceChar, duration, vars);
			}
			TweenMax.delayedCall(duration,onInAlignedStateTransitionCoplete);
		}
		private function startFromAlignedStateTransition():void
		{
			_attractiveAimationEnabled = false;
			TweenMax.killDelayedCallsTo(startAttractiveAnimation);
			TweenMax.killDelayedCallsTo(onInAlignedStateTransitionCoplete);
			
			var duration:Number = 0.25;
			var vars:Object;
			var defaulRotation:Number
			for each(var raceChar:RaceChar in _charsList) {
				defaulRotation = _defaultRotationsDict[raceChar];
				vars = new Object();
				vars.rotation = defaulRotation;
				
				TweenMax.to(raceChar, duration, vars);
			}
		}
		private function onInAlignedStateTransitionCoplete():void
		{
			if (!_active) return;
			if (_attractiveAimationEnabled) return;
			_attractiveAimationEnabled = true;
			startAttractiveAnimation();
		}
		private function startAttractiveAnimation():void
		{
			if ((!_active) || (!_attractiveAimationEnabled)) {
				return;
			}
			
			var currentChar:RaceChar
			var currentScale:Number = 1.1;
			var totalIterations:int = 2;
			var iterationDuration:Number = 0.4/totalIterations;
			var delayPerItem:Number = 0.01;
			var currentDelay:Number
			
			for (var i:uint = 0; i < _charsList.length; i++ ) {
				currentChar = _charsList[i];
				currentDelay = i * delayPerItem;
				applyAttractItemAnimation(currentChar, currentScale, iterationDuration, totalIterations,currentDelay);
			}
			
			var minDelayToNextCall:Number = 1;
			var extraDelayToNextCall:Number = 1;
			var timeToNextCall:Number = delayPerItem * (_charsList.length) + iterationDuration * totalIterations+minDelayToNextCall+Math.random()*extraDelayToNextCall;
			TweenMax.delayedCall(timeToNextCall, startAttractiveAnimation);
		}
		
		private function applyAttractItemAnimation(target:DisplayObject, maxScale:Number, duration:Number, currentIteration:int,currentDelay:Number):void
		{
			if (currentIteration <= 0) return;
			
			var currentScale:Number = (currentIteration % 2)?1.0:maxScale;
			
			currentIteration--;
			
			var vars:Object = new Object();
			vars.scaleX = currentScale;
			vars.scaleY = currentScale;
			vars.delay = currentDelay;
			vars.onComplete = applyAttractItemAnimation;
			vars.onCompleteParams = [target, maxScale, duration, currentIteration,0];
			
			TweenMax.to(target, duration, vars);
			
			
			
		}
		
		
	}

}
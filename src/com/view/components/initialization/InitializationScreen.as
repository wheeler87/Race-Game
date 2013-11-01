package com.view.components.initialization 
{
	import com.greensock.TweenMax;
	import com.managers.assets.AssetNamesConst;
	import com.view.ApplicationSprite;
	import com.view.components.mainMenu.RaceChar;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class InitializationScreen extends ApplicationSprite 
	{
		private var _width:Number;
		private var _height:Number;
		private var _charWidth:Number=40;
		private var _charHeight:Number=40;
		private var _charSize:int=24
		private var _labelChars:Vector.<RaceChar>
		private var _labelContainer:Sprite
		
		
		
		
		
		public function InitializationScreen(width:Number,height:Number):void
		{
			super();
			
			_width = width;
			_height = height;
			
			addBG();
			addLabelContent();
			align();
		}
		public function activate():void
		{
			startFocusAnimation();
		}
		
		public function deactivate():void
		{
			TweenMax.killChildTweensOf(this);
			TweenMax.killDelayedCallsTo(startFocusAnimation);
			TweenMax.killDelayedCallsTo(applyFocusAnimation);
			TweenMax.killDelayedCallsTo(triggerCharactersTypes);
		}
		
		private function addBG():void
		{
			var g:Graphics = graphics;
			g.beginFill(AssetNamesConst.COLOR_LIGHT_BLACK);
			g.drawRect(0, 0, _width, _height);
		}
		private function addLabelContent():void
		{
			var startType:int = RaceChar.TYPE_WHITE;
			var charsGap:int = 5;
			_labelContainer = new Sprite();
			addChild(_labelContainer);
			_labelChars = RaceChar.generateFromString("Loading", startType, _charWidth, _charHeight, _charSize, true);
			RaceChar.position(_labelChars, _charWidth * 0.5, _charHeight * 0.5, _charWidth + charsGap, 0, _labelContainer);
			_labelContainer.graphics.beginFill(0, 0);
			_labelContainer.graphics.drawRect(0, 0, _labelChars.length * (_charWidth + charsGap), _charHeight);
			
		}
		
		private function align():void
		{
			_labelContainer.x = (_width - _labelContainer.width) * 0.5;
			_labelContainer.y = (_height - _labelContainer.height) * 0.5;
		}
		
		private function startFocusAnimation():void
		{
			var delayPerItem:Number=0.3
			var durationPerItem:Number = 1.25;
			var currentChar:RaceChar;
			
			var currentDelay:Number;
			
			
			
			for (var i:uint = 0; i < _labelChars.length; i++ ) {
				currentChar = _labelChars[i];
				currentDelay = i * delayPerItem;
				TweenMax.delayedCall(currentDelay, applyFocusAnimation, [currentChar, durationPerItem])
			}
			
			var timeToNextCall:int = _labelChars.length * delayPerItem;
			TweenMax.delayedCall(timeToNextCall,startFocusAnimation);
			TweenMax.delayedCall(timeToNextCall,triggerCharactersTypes);
		}
		private function applyFocusAnimation(target:RaceChar,duration:Number):void
		{
			var varsFrom:Object
			var varsTo:Object
			
			
			varsFrom = new Object();
			varsFrom.glowFilter = { color:0x91e600, alpha:1, blurX:30, blurY:30,strength:2 };
				
			varsTo = new Object();
			varsTo.glowFilter = { color:0x91e600, alpha:0, blurX:10, blurY:10,strength:2 };
			
			TweenMax.fromTo(target, duration, varsFrom, varsTo);
		}
		
		private function triggerCharactersTypes():void
		{
			
			for each(var raceChar:RaceChar in _labelChars) {
				raceChar.type = (raceChar.type == RaceChar.TYPE_BLACK)?RaceChar.TYPE_WHITE:RaceChar.TYPE_BLACK;
			}
			
			
		}
		
		
	}

}
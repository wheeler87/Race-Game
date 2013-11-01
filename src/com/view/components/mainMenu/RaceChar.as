package com.view.components.mainMenu 
{
	import com.view.ApplicationSprite;
	import com.view.text.ApplicationTF;
	import com.view.text.TextStyle;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.Shape;
	
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class RaceChar extends ApplicationSprite 
	{
		static public const TYPE_WHITE:int = 0;
		static public const TYPE_BLACK:int = 1;
		
		static private const COLOR_WHITE:uint = 0xffffff;
		static private const COLOR_BLACK:uint = 0x000000;
		
		
		
		private var _type:int
		private var _colorBG:uint=COLOR_WHITE
		private var _colorTF:uint=COLOR_BLACK;
		
		private var _width:Number=60;
		private var _height:Number = 60;
		private var _sizeFont:uint = 48;
		
		private var _char:String = "e";
		
		private var _midPointAlignment:Boolean;
		
		private var _background:Shape
		private var _charRenderer:ApplicationTF;
		
		public function RaceChar() 
		{
			super();
			
			createComponents();
			reRender();
			align();
		}
		private function createComponents():void
		{
			_background = new Shape();
			addChild(_background)
			
			_charRenderer = new ApplicationTF();
			addChild(_charRenderer);
			
		}
		public function setSize(width:Number, height:Number, fontSize:uint):void
		{
			_width = width;
			_height = height;
			_sizeFont = fontSize;
			reRender();
			align();
		}
		
		private function reRender():void
		{
			var g:Graphics = _background.graphics;
			
			g.clear();
			g.beginFill(_colorBG);
			g.drawRect(0, 0, _width, _height);
			
			var style:TextStyle = _charRenderer.style;
			style.size = _sizeFont;
			style.color = _colorTF;
			
			_charRenderer.update();
			_charRenderer.text = _char;
		}
		private function align():void
		{
			if (_midPointAlignment) {
				_background.x = -0.5 * _width;
				_background.y = -0.5 * _height;
			}else {
				_background.x = 0;
				_background.y = 0;
			}
			_charRenderer.x = _background.x + (_background.width - _charRenderer.width) * 0.5;
			_charRenderer.y = _background.y + (_background.height - _charRenderer.height) * 0.5;
		}
		
		
		public function get type():int 
		{
			return _type;
		}
		
		public function set type(value:int):void 
		{
			_type = value;
			if (_type == TYPE_BLACK) {
				_colorBG = COLOR_BLACK;
				_colorTF = COLOR_WHITE;
			}else {
				_colorBG = COLOR_WHITE;
				_colorTF = COLOR_BLACK;
			}
			reRender();
		}
		
		public function get midPointAlignment():Boolean 
		{
			return _midPointAlignment;
		}
		
		public function set midPointAlignment(value:Boolean):void 
		{
			_midPointAlignment = value;
			align()
		}
		
		public function get char():String 
		{
			return _char;
		}
		
		public function set char(value:String):void 
		{
			_char = value;
			reRender();
			align();
		}
		
		
		static public function generateFromString(source:String, startType:int, width:Number, height:Number, fontSize:int, midPointAlign:Boolean,hideWhiteSpaces:Boolean=true):Vector.<RaceChar>
		{
			var length:int = (source)?source.length:0;
			var result:Vector.<RaceChar> = new Vector.<RaceChar>();
			
			var currentCharRenderer:RaceChar;
			var currentType:int = startType;
			var currentChar:String;
			var whiteSpaceReg:RegExp=/\s/
			
			for (var i:uint = 0; i < length; i++ ) {
				
				currentChar = source.substr(0, 1);
				
				currentCharRenderer = new RaceChar();
				currentCharRenderer.setSize(width, height, fontSize);
				currentCharRenderer.midPointAlignment = midPointAlign;
				currentCharRenderer.char = currentChar;
				currentCharRenderer.type = currentType;
				currentCharRenderer.visible = ((!hideWhiteSpaces) || (!whiteSpaceReg.test(currentChar)));
				
				source = (source.length > 1)?source.substr(1):source;
				currentType = (currentType == TYPE_BLACK)?TYPE_WHITE:TYPE_BLACK;
				
				result.push(currentCharRenderer);
			}
			
			return result;
		}
		static public function position(group:Vector.<RaceChar>, startX:int, startY:int, offsetX:int, offsetY:int, parent:DisplayObjectContainer):void
		{
			var length:int = (group)?group.length:0;
			var currentCharRenderer:RaceChar;
			for (var i:int = 0; i < length; i++ ) {
				currentCharRenderer = group[i];
				currentCharRenderer.x = startX + i * offsetX;
				currentCharRenderer.y = startY + i * offsetY;
				if (parent) {
					parent.addChild(currentCharRenderer);
				}
			}
		}
	}

}
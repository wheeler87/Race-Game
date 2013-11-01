package com.view.text 
{
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class ApplicationTF extends TextField 
	{
		private var _style:TextStyle = new TextStyle();
		
		public function ApplicationTF() 
		{
			super();
			
			update();
		}
		
		public function get style():TextStyle 
		{
			return _style;
		}
		public function update():void
		{
			var format:TextFormat = defaultTextFormat;
			format.size = style.size;
			format.color = style.color;
			format.font = style.font;
			format.align = style.align;
			
			defaultTextFormat = format;
			
			autoSize = style.autoSize;
			wordWrap = style.wordWrap;
			multiline = style.multiline;
			selectable = style.selectable;
			
			embedFonts = true;
			
			text = text;
			
		}
		
	}

}
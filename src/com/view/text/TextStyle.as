package com.view.text 
{
	import com.managers.assets.AssetNamesConst;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class TextStyle 
	{
		[Embed(source='../../../../bin/assets/embeded/nokiafc22.ttf', fontName="applicationFont", mimeType = "application/x-font",advancedAntiAliasing="true",      embedAsCFF="false")]
		private var fontSource:Class
		
		static public const APPLICATION_FONT_NAME:String = "applicationFont";
		
		public const AUTOSIZE_NONE:String=TextFieldAutoSize.NONE
		public const AUTOSIZE_LEFT:String=TextFieldAutoSize.LEFT
		public const AUTOSIZE_RIGHT:String=TextFieldAutoSize.RIGHT
		public const AUTOSIZE_CENTER:String = TextFieldAutoSize.CENTER
		
		public const ALIGN_LEFT:String = TextFormatAlign.LEFT;
		public const ALIGN_RIGHT:String = TextFormatAlign.RIGHT;
		public const ALIGN_CENTER:String = TextFormatAlign.CENTER;
		public const ALIGN_JUSTIFY:String = TextFormatAlign.JUSTIFY;
		
		public const COLOR_BLACK:int = 0x000000;
		
		public var size:int = 12;
		public var color:uint = COLOR_BLACK;
		public var align:String = ALIGN_CENTER;
		
		private var _font:String = APPLICATION_FONT_NAME;
		
		
		public var autoSize:String = AUTOSIZE_LEFT;
		public var wordWrap:Boolean;
		public var multiline:Boolean;
		public var selectable:Boolean;
		
		
		public function TextStyle() 
		{
			
		}
		
		static public function getFormatForButton():TextFormat
		{
			var format:TextFormat = new TextFormat();
			format.font = TextStyle.APPLICATION_FONT_NAME;
			format.color = AssetNamesConst.COLOR_LIGHT_BLACK;
			
			return format
		}
		
		
		public function get font():String {return _font;}
		
	}

}
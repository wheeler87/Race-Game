package com.managers.info.components 
{
	import com.managers.info.IInfoComponent;
	
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class SheetInfo implements IInfoComponent 
	{
		private var _infoID:int;
		public var source:String;
		public var tileWidth:Number;
		public var tileHeight:Number;
		public var totalTiles:int;
		
		public function SheetInfo() 
		{
			
		}
		public function init(value:XML):void
		{
			_infoID = parseInt(value["@infoID"]);
			source = value["@source"];
			tileWidth = parseInt(value["@tileWidth"]);
			tileHeight = parseInt(value["@tileHeight"]);
			totalTiles = parseInt(value["@totalTiles"]);
			
		}
		public function toString():String
		{
			var result:String = "SheetInfo";
			result += " source - " + source;
			result += " tileWidth - " + tileWidth;
			result += " tileHeight - " + tileHeight;
			
			return result;
		}
		
		/* INTERFACE com.managers.info.IInfoComponent */
		
		
		public function get infoID():int 
		{
			return _infoID;
		}
		
	}

}
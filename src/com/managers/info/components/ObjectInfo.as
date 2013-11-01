package com.managers.info.components 
{
	import com.managers.info.IInfoComponent;
	
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class ObjectInfo implements IInfoComponent 
	{
		private var _infoID:int;
		public var skin:String
		public var mass:Number;
		public var boundRadius:Number
		
		public function ObjectInfo() 
		{
			
		}
		public function init(value:Object):void
		{
			_infoID = parseInt(value["@infoID"]);
			skin = value["@skin"];
			mass = parseFloat(value["@mass"])
			boundRadius=parseFloat(value["@boundRadius"])
		}
		public function toString():String
		{
			var result:String = "ObjectInfo:";
			result += " infoID - " + infoID;
			result += " skin - " + skin;
			
			return result;
		}
		
		
		/* INTERFACE com.managers.info.IInfoComponent */
		
		public function get infoID():int 
		{
			return _infoID;
		}
		
	}

}
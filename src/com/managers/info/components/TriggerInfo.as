package com.managers.info.components 
{
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class TriggerInfo 
	{
		public var worldX:Number
		public var worldY:Number;
		public var worldAngle:Number;
		public var intex:int;
		
		public function TriggerInfo() 
		{
			
		}
		
		static public function sorter(a:TriggerInfo, b:TriggerInfo):int
		{
			if (a.intex < b.intex) return -1;
			if (a.intex > b.intex) return 1;
			return 0;
		}
		
	}

}
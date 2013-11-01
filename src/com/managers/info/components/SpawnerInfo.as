package com.managers.info.components 
{
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class SpawnerInfo 
	{
		public var worldX:Number;
		public var worldY:Number;
		public var worldAngle:Number;
		public var index:int;
		
		public function SpawnerInfo() 
		{
			
		}
		static public function spawnerSorter(a:SpawnerInfo, b:SpawnerInfo):int
		{
			if (a.index < b.index) return -1;
			if (a.index > b.index) return 1;
			return 0;
		}
	}

}
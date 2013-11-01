package com.game.plugins.task 
{
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class Task 
	{
		public var priority:int;
		public var callBack:Function;
		
		public function Task() 
		{
			
		}
		public function execute():void
		{
			callBack();
		}
		
		
		static public function tasksCompareFunc(a:Task, b:Task):int
		{
			if (a.priority < b.priority) return 1;
			if (a.priority > b.priority) return -1;
			return 0;
		}
		
	}

}
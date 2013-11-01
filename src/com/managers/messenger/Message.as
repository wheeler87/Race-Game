package com.managers.messenger 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	[Event(name="application_initialized", type="com.managers.messenger.Message")]
	[Event(name="state_enter", type="com.managers.messenger.Message")]
	[Event(name="state_exit", type="com.managers.messenger.Message")]
	public class Message extends Event 
	{
		static public const STATE_ENTER:String = "state_enter";
		static public const STATE_EXIT:String = "state_exit";
		
		
		private var _data:Object
		
		public function Message(type:String, data:Object=null) 
		{
			_data = data;
			super(type, false, false);
			
		}
		
		public function get data():Object 
		{
			return _data;
		}
		override public function clone():Event 
		{
			 return new Message(type,data);
		}
		
	}

}
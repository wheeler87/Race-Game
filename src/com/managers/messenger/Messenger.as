package com.managers.messenger 
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	[Event(name="application_initialized", type="com.managers.messenger.Message")]
	public class Messenger extends EventDispatcher 
	{
		
		public function Messenger() 
		{
			super(null);
		}
		
		public function sendMessage(type:String, data:Object=null):void
		{
			var message:Message = new Message(type, data);
			dispatchEvent(message);
		}
		
	}

}
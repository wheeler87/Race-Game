package com.controller.childs 
{
	import com.Application;
	import com.controller.GlobalController;
	import com.controller.IChildController;
	import com.Facade;
	import com.managers.messenger.Messenger;
	import com.model.Model;
	
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class BaseChildController implements IChildController 
	{
		
		public function BaseChildController() 
		{
			
		}
		
		/* INTERFACE com.controller.IChildController */
		
		public function onEnter():void 
		{
			
		}
		
		public function onExit():void 
		{
			
		}
		
		protected function get view():Application { return Facade.instance.view }
		protected function get globalController():GlobalController { return Facade.instance.globalController }
		protected function get model():Model { return Facade.instance.model }
		protected function get messaeger():Messenger { return Facade.instance.messanger }
	}

}
package com 
{
	import com.controller.GlobalController;
	import com.managers.assets.AssetManager;
	import com.managers.info.Info;
	import com.managers.messenger.Messenger;
	import com.model.Model;
	import flash.display.Stage;
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class Facade 
	{
		static private var _instance:Facade = new Facade();
		
		private var _view:Application;
		private var _stage:Stage;
		
		private var _model:Model
		private var _globalController:GlobalController
		
		private var _messanger:Messenger
		private var _assetManager:AssetManager
		private var _info:Info;
		
		public function Facade() 
		{
			if (instance) {
				throw new Error("singletone");
				return;
			}
			
			_messanger = new Messenger();
			_assetManager = new AssetManager();
			_info = new Info();
		}
		
		public function init(application:Application):void
		{
			_view = application;
			_stage = application.stage;
			
			_model = new Model(_messanger);
			
			_globalController = new GlobalController();
			_globalController.init();
		}
		
		
		
		static public function get instance():Facade 
		{
			return _instance;
		}
		
		public function get view():Application 
		{
			return _view;
		}
		
		public function get stage():Stage 
		{
			return _stage;
		}
		
		public function get model():Model 
		{
			return _model;
		}
		
		public function get globalController():GlobalController 
		{
			return _globalController;
		}
		
		public function get messanger():Messenger 
		{
			return _messanger;
		}
		
		public function get assetManager():AssetManager 
		{
			return _assetManager;
		}
		
		public function get info():Info 
		{
			return _info;
		}
		
		
		
	}

}
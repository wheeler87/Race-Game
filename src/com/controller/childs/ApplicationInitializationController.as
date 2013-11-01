package com.controller.childs 
{
	import com.Facade;
	import com.managers.assets.AssetNamesConst;
	import com.managers.messenger.Message;
	import com.model.ApplicationState;
	import com.view.components.initialization.InitializationScreen;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class ApplicationInitializationController extends BaseChildController 
	{
		static private var _instance:ApplicationInitializationController = new ApplicationInitializationController();
		
		private var _assetsQueue:Vector.<String>;
		private var _modelInitializationRequires:Boolean
		private var _assetLoadRequires:Boolean;
		private var _infoInitializationRequires:Boolean
		private var _interfaceCreationRequires:Boolean
		
		private var _stateScreen:InitializationScreen
		
		public function ApplicationInitializationController() 
		{
			super();
			if (instance) {
				throw new Error("asas");
				return;
			}
			
			
		}
		override public function onEnter():void 
		{
			super.onEnter();
			addStateScreen();
			resetInitialization();
			advanceInitialization();
			
		}
		override public function onExit():void 
		{
			super.onExit();
			removeStateScreen();
		}
		private function resetInitialization():void
		{
			_modelInitializationRequires=true
			_assetLoadRequires = true;
			_infoInitializationRequires = true;
			_interfaceCreationRequires = true;
		}
		private function advanceInitialization():void
		{
			if (_modelInitializationRequires) {
				_modelInitializationRequires = false
				model.screenWidth = Facade.instance.stage.stageWidth;
				model.screenHeight = Facade.instance.stage.stageHeight;
				
				advanceInitialization();
			}else if (_assetLoadRequires) {
				_assetLoadRequires = false;
				generateAssetsQueue();
				advanceAssetLoading();
			}else if (_infoInitializationRequires) {
				_infoInitializationRequires = false;
				startInfoInitialization();
			}else if (_interfaceCreationRequires) {
				_interfaceCreationRequires = false;
				startInterfaceCreation();
			
			} 
			
			
			else {
				model.applicationState = ApplicationState.MAIN_MENU;
			}
			
			
		}
		
		private function generateAssetsQueue():void
		{
			_assetsQueue = new Vector.<String>();
			_assetsQueue.push("assets/assets.swf")
		}
		private function advanceAssetLoading():void
		{
			if ((!_assetsQueue) || (!_assetsQueue.length)) {
				advanceInitialization();
				return;
			}
			var url:String = _assetsQueue.shift();
			var request:URLRequest = new URLRequest(url);
			
			var context:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
			var loaderInfo:LoaderInfo = new Loader().contentLoaderInfo;
			loaderInfo.addEventListener(Event.COMPLETE, onAssetLoaded);
			//loaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onAssetLoadEror);
			
			loaderInfo.loader.load(request,context);
			
		}
		
		private function onAssetLoadEror(e:IOErrorEvent):void 
		{
			advanceAssetLoading();
		}
		
		private function onAssetLoaded(e:Event):void 
		{
			var loaderInfo:LoaderInfo = e.currentTarget as LoaderInfo;
			
			advanceAssetLoading();
		}
		private function startInterfaceCreation():void
		{
			view.createUIComponents();
			advanceInitialization();
		}
		private function startInfoInitialization():void
		{
			var url:String = "assets/info.xml";
			var request:URLRequest = new URLRequest(url);
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onInfoSourceDataLoaded);
			loader.load(request);
		}
		
		private function onInfoSourceDataLoaded(e:Event):void 
		{
			var data:XML = new XML((e.currentTarget as URLLoader).data);
			Facade.instance.info.init(data);
			advanceInitialization();
		}
		
		private function addStateScreen():void
		{
			var screenWidth:Number = view.stage.stageWidth;
			var screenHeight:Number = view.stage.stageHeight;
			
			_stateScreen = new InitializationScreen(screenWidth, screenHeight);
			view.addChild(_stateScreen);
			_stateScreen.activate();
		}
		private function removeStateScreen():void
		{
			_stateScreen.deactivate();
			view.removeChild(_stateScreen);
			_stateScreen = null;
		}
		
		static public function get instance():ApplicationInitializationController 
		{
			return _instance;
		}
		
	}

}
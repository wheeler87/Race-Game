package com.view.components.mainMenu 
{
	import com.greensock.TweenMax;
	import com.managers.assets.AssetNamesConst;
	import com.model.Model;
	import com.view.ApplicationSprite;
	import com.view.text.ApplicationTF;
	import com.view.text.TextStyle;
	import fl.controls.Label;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	[Event(name="close", type="flash.events.Event")]
	public class MainMenuScreen extends ApplicationSprite 
	{
		private var _width:Number;
		private var _height:Number;
		
		private var _background:Shape
		private var _gameTitle:GameTitle;
		
		private var _menuItemsList:Vector.<MenuItem>
		private var _createGameMenuItem:MenuItem;
		private var _joinGameMenuItem:MenuItem;
		
		private var _homepageContainer:Sprite
		private var _homePageTF:ApplicationTF;
		
		
		public function MainMenuScreen(width:Number,height:Number):void
		{
			super();
			
			_width = width;
			_height = height;
			createBackground();
			createGameTitle()
			createMenuItems()
			createHompageLabel();
			
		}
		public function reset():void
		{
			_gameTitle.reset();
			for each(var menuItem:MenuItem in _menuItemsList) {
				menuItem.reset();
			}
		}
		public function activate():void
		{
			_gameTitle.activate();
			for each(var menuItem:MenuItem in _menuItemsList) {
				menuItem.activate();
			}
		}
		public function deactivate():void
		{
			_gameTitle.deactivate();
			for each(var menuItem:MenuItem in _menuItemsList) {
				menuItem.deactivate();
			}
		}
		public function close():void
		{
			_gameTitle.deactivate();
			_gameTitle.close();
			for each(var menuItem:MenuItem in _menuItemsList) {
				menuItem.deactivate();
				menuItem.close();
			}
			TweenMax.delayedCall(1.0, onScreenClosed);
		}
		private function onScreenClosed():void
		{
			dispatchEvent(new Event(Event.CLOSE));
		}
		
		private function createBackground():void
		{
			_background = new Shape();
			addChild(_background);
			
			var g:Graphics = _background.graphics;
			g.clear();
			g.beginFill(AssetNamesConst.COLOR_LIGHT_BLACK);
			g.drawRect(0, 0, _width, _height);
		}
		private function createGameTitle():void
		{
			_gameTitle = new GameTitle();
			addChild(_gameTitle);
			
			_gameTitle.x = (_width - _gameTitle.width) * 0.5;
			_gameTitle.y = 80;
		}
		private function createMenuItems():void
		{
			
			_createGameMenuItem = new MenuItem();
			_createGameMenuItem.init("Create Game");
			
			_joinGameMenuItem = new MenuItem();
			_joinGameMenuItem.init("Join Game");
			
			_menuItemsList = new Vector.<MenuItem>();
			_menuItemsList.push(_createGameMenuItem);
			_menuItemsList.push(_joinGameMenuItem);
			
			var startX:Number = _width * 0.5 - 150;
			var startY:Number = 300;
			
			var gapH:Number = 0;
			var gapV:Number = 70;
			
			MenuItem.position(_menuItemsList, startX, startY, gapH, gapV, this);
		}
		private function createHompageLabel():void
		{
			_homepageContainer = new Sprite();
			
			_homePageTF = new ApplicationTF();
			
			addChild(_homepageContainer);
			_homepageContainer.addChild(_homePageTF);
			
			var style:TextStyle =_homePageTF.style;
			style.color = AssetNamesConst.COLOR_BLUE;
			style.size = 12;
			
			
			
			_homePageTF.update();
			_homePageTF.text = "Home page";
			
			_homepageContainer.x = _width - _homepageContainer.width - 50;
			_homepageContainer.y = _height - _homepageContainer.height - 40;
			
			_homepageContainer.useHandCursor = true;
			_homepageContainer.buttonMode = true;
			_homepageContainer.mouseChildren = false;
			
			_homepageContainer.addEventListener(MouseEvent.CLICK, onHomePageBtnClick);
		}
		
		
		public function get createGameMenuItem():MenuItem 
		{
			return _createGameMenuItem;
		}
		
		public function get joinGameMenuItem():MenuItem 
		{
			return _joinGameMenuItem;
		}
		
		private function onHomePageBtnClick(e:MouseEvent):void 
		{
			var url:String = Model.HOME_PAGE;
			var request:URLRequest = new URLRequest(url);
			navigateToURL(request, "_blank");
		}
		
	}

}
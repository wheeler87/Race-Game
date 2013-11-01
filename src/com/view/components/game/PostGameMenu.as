package com.view.components.game 
{
	import com.managers.assets.AssetNamesConst;
	import com.model.Model;
	import com.view.ApplicationSprite;
	import com.view.text.TextStyle;
	import fl.controls.Button;
	import fl.controls.Label;
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	[Event(name="leave_request", type="com.view.components.game.PostGameMenu")]
	public class PostGameMenu extends ApplicationSprite 
	{
		static public const LEAVE_REQUEST:String="leave_request"
		static public const WIDTH:int = 95;
		static public const HEIGHT:int = 60;
		
		private var _indentH:int = 5;
		private var _indentV:int = 5;
		
		private var _leaveBtn:Button;
		private var _homePageBtn:Button
		
		private var _alphaMin:Number = 0.95;
		private var _alphaMax:Number = 1.3;
		
		private var _lastFrameTime:int
		private var _fadeDuration:int=2000;
		private var _fadeOrt:int;
		
		public function PostGameMenu():void
		{
			super();
			fillBG();
			createButtons();
			align();
		}
		
		private function fillBG():void
		{
			var g:Graphics = graphics;
			g.clear();
			g.beginFill(AssetNamesConst.COLOR_LIGHT_GREEN, 0.5);
			g.drawRect(0, 0, WIDTH, HEIGHT);
			
		}
		private function createButtons():void
		{
			var format:TextFormat
			format = TextStyle.getFormatForButton();
			format.color = AssetNamesConst.COLOR_BLUE;
			
			_leaveBtn = new Button();
			_leaveBtn.width = WIDTH - 2 * _indentH;
			_leaveBtn.setStyle("embedFonts", true);
			_leaveBtn.setStyle("textFormat", format);
			_leaveBtn.setStyle("disabledTextFormat", format);
			_leaveBtn.label = "Leave";
			
			addChild(_leaveBtn);
			
			_leaveBtn.addEventListener(MouseEvent.CLICK,onLeaveBtnClick)
			
			format = new TextFormat();
			format.font = TextStyle.APPLICATION_FONT_NAME;
			format.color = AssetNamesConst.COLOR_BLUE;
			
			_homePageBtn = new Button();
			_homePageBtn.width = WIDTH - 2 * _indentH;
			_homePageBtn.setStyle("embedFonts", true);
			_homePageBtn.setStyle("textFormat", format);
			_homePageBtn.setStyle("disabledTextFormat", format);
			
			
			_homePageBtn.label = "Home Page";
			addChild(_homePageBtn);
			
			_homePageBtn.addEventListener(MouseEvent.CLICK, onHomePageBtnClick);
			
			
		}
		
		
		private function align():void
		{
			_homePageBtn.x = _indentH;
			_homePageBtn.y = _indentV;
			
			_leaveBtn.x = _indentH;
			_leaveBtn.y = HEIGHT - _leaveBtn.height - _indentV;
		}
		
		
		
		private function onHomePageBtnClick(e:MouseEvent):void
		{
			var url:String = Model.HOME_PAGE;
			var request:URLRequest = new URLRequest(url);
			navigateToURL(request, "_blank");
		}
		
		private function onLeaveBtnClick(e:MouseEvent):void 
		{
			dispatchEvent(new Event(LEAVE_REQUEST))
		}
		
		
		
		public function reset():void
		{
			alpha = 0;
		}
		public function activate():void
		{
			_lastFrameTime = getTimer();
			addEventListener(Event.ENTER_FRAME,onEnterFrame)
		}
		
		public function deactivate():void
		{
			removeEventListener(Event.ENTER_FRAME,onEnterFrame)
		}
		
		private function onEnterFrame(e:Event):void 
		{
			var dt:int = getTimer() - _lastFrameTime;
			_lastFrameTime += dt;
			if (alpha < _alphaMin) {
				_fadeOrt = 1;
			}else if (alpha >= _alphaMax) {
				_fadeOrt = -1;
				
				deactivate()
			}
			var fadeAmount:Number = (dt / (Number(_fadeDuration))) * _fadeOrt;
			alpha += fadeAmount;
		}
	}

}
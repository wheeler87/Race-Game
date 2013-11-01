package com.view.components.createGame 
{
	import com.managers.assets.AssetNamesConst;
	import com.view.ApplicationSprite;
	import com.view.components.common.PlayerProfile;
	import com.view.text.TextStyle;
	import fl.controls.Button;
	import fl.controls.Label;
	import fl.controls.TextInput;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class CreateGameScreen extends ApplicationSprite 
	{
		private var _width:Number;
		private var _height:Number;
		
		private var _playerProfile:PlayerProfile;
		
		private var _gameNameLabel:Label;
		private var _gameNameInput:TextInput;
		
		private var _backBtn:Button;
		private var _createBtn:Button;
		
		private var _gameName:String
		
		
		public function CreateGameScreen(width:Number,height:Number) 
		{
			super();
			
			
			_width = width;
			_height = height;
			
			fillBG();
			addPlayerProfile();
			addGameRelatedComponents();
			addButtons();
			align();
		}
		public function activate():void
		{
			_playerProfile.activate();
			_gameNameInput.addEventListener(Event.CHANGE, onGameNameChange);
			_playerProfile.addEventListener(PlayerProfile.USERNAME_CHANGE, onUserNameChange);
			validateButtonsStatus();
		}
		
		
		public function deactivate():void
		{
			_playerProfile.deactivate();
			_gameNameInput.removeEventListener(Event.CHANGE, onGameNameChange);
			_playerProfile.removeEventListener(PlayerProfile.USERNAME_CHANGE, onUserNameChange);
		}
		
		private function fillBG():void 
		{
			var g:Graphics = graphics;
			g.clear();
			g.beginFill(AssetNamesConst.COLOR_LIGHT_BLACK, 1.0);
			g.drawRect(0, 0, _width, _height);
		}
		
		private function addPlayerProfile():void 
		{
			_playerProfile = new PlayerProfile();
			addChild(_playerProfile);
		}
		
		private function addGameRelatedComponents():void 
		{
			var format:TextFormat;
			format = new TextFormat();
			format.font = TextStyle.APPLICATION_FONT_NAME;
			format.color = AssetNamesConst.COLOR_WHITE_DARK;
			format.size = 20;
			
			_gameNameLabel = new Label();
			_gameNameLabel.autoSize = TextFieldAutoSize.LEFT;
			_gameNameLabel.setStyle("embedFonts", true);
			_gameNameLabel.setStyle("textFormat", format);
			_gameNameLabel.text="Game name:"
			
			addChild(_gameNameLabel)
			
			format = new TextFormat();
			format.font = TextStyle.APPLICATION_FONT_NAME;
			format.color = AssetNamesConst.COLOR_LIGHT_BLACK;
			format.size = 18;
			
			
			_gameNameInput = new TextInput();
			_gameNameInput.width = 430;
			_gameNameInput.setStyle("embedFonts", true);
			_gameNameInput.setStyle("textFormat", format);
			addChild(_gameNameInput);
		}
		
		private function addButtons():void 
		{
			var format:TextFormat = TextStyle.getFormatForButton();
			
			
			_backBtn = new Button();
			_backBtn.label = "Back";
			_backBtn.setStyle("embedFonts", true);
			_backBtn.setStyle("textFormat", format);
			addChild(_backBtn);
			
			
			_createBtn = new Button();
			_createBtn.label = "Create";
			_createBtn.setStyle("embedFonts", true);
			_createBtn.setStyle("textFormat", format);
			_createBtn.setStyle("disabledTextFormat", format);
			addChild(_createBtn);
			
			
			
		}
		
		private function align():void 
		{
			_gameNameLabel.x = 10;
			_gameNameLabel.y = 18;
			
			_gameNameInput.x = 200;
			_gameNameInput.y = 20;
			
			_playerProfile.x = 10;
			_playerProfile.y = 50;
			
			_createBtn.x = (_playerProfile.x+_playerProfile.width)+(_width-_playerProfile.width-_playerProfile.x- _createBtn.width )*0.5;
			_createBtn.y = _playerProfile.y;
			
			_backBtn.x = _createBtn.x;
			_backBtn.y = _createBtn.y - _backBtn.height - 10;
		}
		
		public function get backBtn():Button {	return _backBtn;}
		public function get createBtn():Button {return _createBtn;}
		
		public function get userName():String 
		{
			return _playerProfile.username;
		}
		
		public function set userName(value:String):void 
		{
			_playerProfile.username = value;
			validateButtonsStatus();
			
		}
		
		public function get racerTemplateID():int 
		{
			return _playerProfile.racerTemplateID;
		}
		
		public function set racerTemplateID(value:int):void 
		{
			_playerProfile.racerTemplateID = value;
		}
		
		public function get gameName():String 
		{
			return _gameName;
		}
		
		public function set gameName(value:String):void 
		{
			_gameName = value;
			_gameNameInput.text = _gameName;
			validateButtonsStatus();
		}
		
		private function onUserNameChange(e:Event):void 
		{
			validateButtonsStatus();
		}
		
		private function onGameNameChange(e:Event):void 
		{
			_gameName = _gameNameInput.text;
			validateButtonsStatus();
		}
		public function validateButtonsStatus():void
		{
			_createBtn.enabled = (gameName) && (userName) && (gameName.length) && (userName.length);
		}
	}

}
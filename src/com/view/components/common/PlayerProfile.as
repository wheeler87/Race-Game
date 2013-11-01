package com.view.components.common 
{
	import com.Facade;
	import com.managers.assets.AssetNamesConst;
	import com.managers.info.components.RacerInfo;
	import com.managers.info.components.SheetInfo;
	import com.view.ApplicationSprite;
	import com.view.Sheet;
	import com.view.text.TextStyle;
	import fl.controls.ComboBox;
	import fl.controls.Label;
	import fl.controls.TextInput;
	import fl.data.DataProvider;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class PlayerProfile extends ApplicationSprite 
	{
		static public const USERNAME_CHANGE:String = "username_change";
		
		
		private var _width:Number = 620;
		private var _height:Number = 180;
		
		private var _usernameLabel:Label;
		private var _usernameInput:TextInput;
		private var _racerLabel:Label;
		private var _racerSelector:ComboBox
		
		private var _racerInfoRenderer:RacerInfoRenderer
		
		private var _racersList:Vector.<RacerInfo>
		
		private var _username:String;
		private var _racerTemplateID:int
		
		public function PlayerProfile() 
		{
			super();
			
			createComponents();
			alighnComponents();
			populateData();
			activate();
			
			username="Player_"+int(Math.random()*1000)
		}
		private function createComponents():void
		{
			var g:Graphics = graphics;
			g.clear();
			g.beginFill(0xffffff, 0.05);
			g.drawRect(0, 0, _width, _height);
			
			var textFormat:TextFormat
			textFormat= new TextFormat();
			textFormat.font = TextStyle.APPLICATION_FONT_NAME;
			textFormat.size = 14;
			textFormat.color = AssetNamesConst.COLOR_WHITE_DARK;
			
			
			_usernameLabel = new Label();
			_usernameLabel.autoSize = TextFieldAutoSize.LEFT;
			_usernameLabel.text="Username:"
			_usernameLabel.setStyle("textFormat", textFormat);
			_usernameLabel.setStyle("embedFonts", true);
			addChild(_usernameLabel);
			
			
			
			textFormat = new TextFormat();
			textFormat.font = TextStyle.APPLICATION_FONT_NAME;
			textFormat.size = 12;
			textFormat.color = AssetNamesConst.COLOR_LIGHT_BLACK;
			
			_usernameInput = new TextInput();
			_usernameInput.width = 150;
			_usernameInput.setStyle("textFormat", textFormat);
			_usernameInput.setStyle("embedFonts", true);
			//_usernameInput.enabled = false;
			
			addChild(_usernameInput);
			
			
			textFormat = new TextFormat();
			textFormat.font = TextStyle.APPLICATION_FONT_NAME;
			textFormat.size = 12;
			textFormat.color = AssetNamesConst.COLOR_WHITE_DARK;
			
			_racerLabel = new Label();
			_racerLabel.autoSize = TextFieldAutoSize.LEFT;
			_racerLabel.text="Racer:"
			_racerLabel.setStyle("textFormat", textFormat);
			_racerLabel.setStyle("embedFonts", true);
			
			
			addChild(_racerLabel);
			
			textFormat = new TextFormat();
			textFormat.font = TextStyle.APPLICATION_FONT_NAME;
			textFormat.size = 12;
			textFormat.color = AssetNamesConst.COLOR_WHITE_DARK;
			
			
			_racerSelector = new ComboBox();
			_racerSelector.rowCount = 5;
			addChild(_racerSelector);
			
			_racerSelector.setStyle("textFormat", textFormat);
			_racerSelector.setStyle("embedFonts", true);
			
			
			
			_racerInfoRenderer = new RacerInfoRenderer();
			addChild(_racerInfoRenderer);
			
		}
		
		private function alighnComponents():void
		{
			var pLeft:int = 10;
			var pTop:int = 7;
			
			_usernameLabel.x = pLeft;
			_usernameLabel.y = 3+pTop;
			
			_usernameInput.x = _usernameLabel.x+_usernameLabel.width+10;
			_usernameInput.y = 0+pTop;
			
			
			_racerLabel.x = _racerLabel.x = _usernameInput.x + _usernameInput.width + 10;
			_racerLabel.y = 3+pTop;
			
			_racerSelector.x = _racerLabel.x+_racerLabel.width+10-30;
			_racerSelector.y = 0+pTop;
			
			_racerInfoRenderer.y = 40+pTop;
			_racerInfoRenderer.x = pLeft;
			
		}
		private function populateData():void
		{
			_racersList = Facade.instance.info.racersInfoList;
			
			var racerInfo:RacerInfo
			
			var selectorDataProvider:DataProvider=new DataProvider();
			var selectorData:Object
			
			var sheetInfo:SheetInfo;
			
			
			for (var i:uint = 0; i < _racersList.length; i++ ) {
				racerInfo = _racersList[i];
				
				selectorData = new Object();
				selectorData.label = racerInfo.name;
				selectorDataProvider.addItem(selectorData);
				
			}
			_racerSelector.dataProvider = selectorDataProvider;
			_racerSelector.selectedIndex = 0;
			
			onRacerSelectionChange();
		}
		
		
		public function activate():void
		{
			_racerSelector.addEventListener(Event.CHANGE, onracerSelectorChange);
			_usernameInput.addEventListener(Event.CHANGE, onUserNameInputChange);
			
			
		}
		public function deactivate():void
		{
			_racerSelector.removeEventListener(Event.CHANGE, onracerSelectorChange);
			_usernameInput.removeEventListener(Event.CHANGE, onUserNameInputChange);
			_racerInfoRenderer.deactivate();
		}
		private function onUserNameInputChange(e:Event):void 
		{
			_username = _usernameInput.text;
			dispatchEvent(new Event(USERNAME_CHANGE));
		}
		
		
		private function onracerSelectorChange(e:Event):void 
		{
			onRacerSelectionChange();
		}
		
		private function onRacerSelectionChange():void
		{
			_racerInfoRenderer.racerInfo = _racersList[selectedRacerIndex];
			_racerTemplateID = _racersList[selectedRacerIndex].infoID;
			
		}
		
		private function get selectedRacerIndex():int {return _racerSelector.selectedIndex;}
		
		public function get username():String 
		{
			return _username;
		}
		
		public function set username(value:String):void 
		{
			_username = value;
			_usernameInput.text = _username;
		}
		
		public function get racerTemplateID():int {	return _racerTemplateID;}
		
		public function set racerTemplateID(value:int):void 
		{
			_racerTemplateID = value;
			var racerInfo:RacerInfo = info.getInfoComponentByID(_racerTemplateID) as RacerInfo
			var index:int = (racerInfo)?_racersList.indexOf(racerInfo):0;
			_racerSelector.selectedIndex = index;
			onRacerSelectionChange();
		}
	}

}
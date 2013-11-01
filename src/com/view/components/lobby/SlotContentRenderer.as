package com.view.components.lobby 
{
	import com.game.settings.Player;
	import com.managers.assets.AssetNamesConst;
	import com.managers.info.components.RacerInfo;
	import com.view.ApplicationSprite;
	import com.view.Sheet;
	import com.view.text.TextStyle;
	import fl.controls.Label;
	import flash.display.Bitmap;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class SlotContentRenderer extends ApplicationSprite 
	{
		private var _width:Number=250;
		private var _height:Number = 70;
		
		private var _player:Player;
		private var _racerInfo:RacerInfo;
		private var _racerFaceSheet:Sheet;
		
		
		private var _racerFaceRenderer:Bitmap;
		private var _racerNameRenderer:Label;
		private var _playerNameRenderer:Label;
		
		public function SlotContentRenderer() 
		{
			super();
			
			createComponents();
		}
		
		private function createComponents():void
		{
			var g:Graphics = graphics;
			
			g.clear();
			g.beginFill(AssetNamesConst.COLOR_WHITE_DARK, 0.3);
			g.drawRect(0, 0, _width, _height);
			
			_racerFaceRenderer = new Bitmap();
			addChild(_racerFaceRenderer);
			
			var format:TextFormat;
			
			format = new TextFormat();
			format.font = TextStyle.APPLICATION_FONT_NAME;
			format.color = AssetNamesConst.COLOR_GREEN;
			format.size = 20;
			
			_playerNameRenderer = new Label();
			addChild(_playerNameRenderer);
			
			_playerNameRenderer.setStyle("embedFonts", true);
			_playerNameRenderer.setStyle("textFormat", format);
			_playerNameRenderer.autoSize = TextFieldAutoSize.LEFT;
			
			
			format = new TextFormat();
			format.font = TextStyle.APPLICATION_FONT_NAME;
			format.color = AssetNamesConst.COLOR_BLUE;
			format.size = 12;
			
			_racerNameRenderer = new Label();
			addChild(_racerNameRenderer);
			
			_racerNameRenderer.setStyle("embedFonts", true);
			_racerNameRenderer.setStyle("textFormat", format);
			_racerNameRenderer.autoSize = TextFieldAutoSize.LEFT;
			
			_racerFaceSheet = new Sheet();
			
			var mask:Shape = new Shape();
			g = mask.graphics;
			g.beginFill(0);
			g.drawRect(0, 0, _width, _height);
			this.mask = mask;
			addChild(mask);
			
		}
		
		public function get player():Player {return _player;}
		
		public function set player(value:Player):void 
		{
			_player = value;
			if (_player) {
				_racerInfo = info.getInfoComponentByID(_player.racerTemplate) as RacerInfo;
			}else {
				_racerInfo = null;
			}
			reRender();
			align();
		}
		
		private function reRender():void
		{
			_racerFaceSheet.init((_racerInfo)?_racerInfo.faceSheetID: -1);
			_racerFaceSheet.selectedTileIndex = 0;
			
			_racerFaceRenderer.bitmapData = _racerFaceSheet.framePixels;
			
			_playerNameRenderer.text = (_player)?_player.name:"";
			_racerNameRenderer.text = (_racerInfo)?_racerInfo.name:"";
			
		}
		private function align():void
		{
			_racerFaceRenderer.x = 5;
			_racerFaceRenderer.y = (_height - _racerFaceRenderer.height) * 0.5;
			
			
			
			
			
			_racerNameRenderer.x = _racerFaceRenderer.x + _racerFaceRenderer.width + 10;
			_racerNameRenderer.y = _racerFaceRenderer.y + _racerFaceRenderer.height - _racerNameRenderer.height + 5;
			
			_playerNameRenderer.x = _racerFaceRenderer.x + _racerFaceRenderer.width + 10;
			_playerNameRenderer.y = _racerNameRenderer.y - _playerNameRenderer.height - 5;;
		}
		
	}

}
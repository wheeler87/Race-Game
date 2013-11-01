package com.view 
{
	import com.Facade;
	import com.managers.info.components.SheetInfo;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class Sheet 
	{
		static private var _helperP:Point = new Point();
		static private var _helperR:Rectangle = new Rectangle();
		
		private var _selectedTileIndex:int
		private var _framePixels:BitmapData;
		private var _tilesList:Vector.<BitmapData>;
		private var _info:SheetInfo;
		
		public function Sheet() 
		{
			
		}
		public function init(sheetID:int):void
		{
			if (_framePixels) {
				_framePixels.fillRect(_framePixels.rect, 0);
			}
			if (!_tilesList) {
				_tilesList = new Vector.<BitmapData>();
			}
			_tilesList.length = 0;
			
			_info = Facade.instance.info.getInfoComponentByID(sheetID) as SheetInfo;
			if (!_info) {
				return;
			}
			_helperP.x = 0;
			_helperP.y = 0;
			
			_helperR.width = _info.tileWidth;
			_helperR.height = _info.tileHeight;
			
			var source:BitmapData = Facade.instance.assetManager.getBitmapData(_info.source);
			_framePixels = new BitmapData(_info.tileWidth, _info.tileHeight, true, 0);
			
			
			var currentTile:BitmapData
			for (var i:uint = 0; i < _info.totalTiles; i++ ) {
				_helperR.x = (i * _info.tileWidth) % source.width;
				_helperR.y = int((i * _info.tileWidth) / source.width) * _info.tileHeight;
				currentTile = new BitmapData(_info.tileWidth, _info.tileHeight, true, 0);
				currentTile.copyPixels(source, _helperR, _helperP, null,null, true);
				_tilesList.push(currentTile);
			}
			selectedTileIndex = 0;
		}
		
		public function get info():SheetInfo {return _info;}
		public function get tilesList():Vector.<BitmapData> {return _tilesList;	}
		public function get framePixels():BitmapData {return _framePixels;}
		public function get selectedTileIndex():int {return _selectedTileIndex;}
		public function get tilesAmount():int { return _tilesList.length };
		public function set selectedTileIndex(value:int):void 
		{
			if ((!_tilesList) || (!_tilesList.length)) return;
			value = Math.max(-1, Math.min(value, _tilesList.length - 1));
			_selectedTileIndex = value;
			_framePixels.fillRect(_framePixels.rect, 0);
			if (_selectedTileIndex < 0) {
				return;
			}
			var selectedTile:BitmapData = _tilesList[_selectedTileIndex];
			_helperP.x = 0;
			_helperP.y = 0;
			_framePixels.copyPixels(selectedTile, selectedTile.rect, _helperP);
		}
	}

}
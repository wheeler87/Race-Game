package com.managers.info 
{
	import com.managers.info.components.LocationInfo;
	import com.managers.info.components.ObjectInfo;
	import com.managers.info.components.RacerInfo;
	import com.managers.info.components.SheetInfo;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class Info 
	{
		private var _locationInfoList:Vector.<LocationInfo>;
		private var _objectsInfoList:Vector.<ObjectInfo>;
		private var _racersInfoList:Vector.<RacerInfo>;
		private var _sheetInfoList:Vector.<SheetInfo>;
		
		private var _componentsDict:Dictionary = new Dictionary();
		
		
		public function Info() 
		{
			
		}
		public function init(description:XML):void
		{
			_componentsDict = new Dictionary();
			_locationInfoList = new Vector.<LocationInfo>();
			_objectsInfoList = new Vector.<ObjectInfo>();
			_racersInfoList = new Vector.<RacerInfo>();
			_sheetInfoList = new Vector.<SheetInfo>();
			
			saveLocationInfo(description["location"]);
			saveObjectInfo(description["object"]);
			saveracersInfo(description["racer"]);
			saveSheetInfo(description["sheet"]);
		}
		
		private function saveLocationInfo(value:XMLList):void
		{
			var length:int = (value)?value.length():0;
			var currentInfo:LocationInfo;
			var currentInfoSource:XML;
			for (var i:int = 0; i < length; i++ ) {
				currentInfoSource = value[i];
				currentInfo = new LocationInfo();
				currentInfo.init(currentInfoSource);
				
				_locationInfoList.push(currentInfo);
				_componentsDict[currentInfo.infoID] = currentInfo;
				
			}
			
		}
		private function saveObjectInfo(value:XMLList):void
		{
			var length:int = (value)?value.length():0;
			var currentInfo:ObjectInfo;
			var currentInfoSource:XML;
			for (var i:uint = 0; i < length; i++ ) {
				currentInfoSource = value[i];
				currentInfo = new ObjectInfo();
				currentInfo.init(currentInfoSource);
				
				_objectsInfoList.push(currentInfo);
				_componentsDict[currentInfo.infoID] = currentInfo;
			}
		}
		private function saveracersInfo(value:XMLList):void
		{
			var length:int = (value)?value.length():0;
			var currentInfo:RacerInfo;
			var currentInfoSource:XML;
			for (var i:uint = 0; i < length; i++ ) {
				currentInfoSource = value[i];
				currentInfo = new RacerInfo();
				currentInfo.init(currentInfoSource);
				
				_racersInfoList.push(currentInfo);
				_componentsDict[currentInfo.infoID] = currentInfo;
			}
		}
		private function saveSheetInfo(value:XMLList):void
		{
			var length:int = (value)?value.length():0;
			
			var currentSheetInfo:SheetInfo
			var source:XML
			for (var i:uint = 0; i < length; i++ ) {
				source = value[i];
				currentSheetInfo = new SheetInfo();
				currentSheetInfo.init(source);
				
				_sheetInfoList.push(currentSheetInfo);
				_componentsDict[currentSheetInfo.infoID] = currentSheetInfo;
			}
		}
		
		public function getInfoComponentByID(infoID:int):IInfoComponent
		{
			return _componentsDict[infoID];
		}
		
		public function get locationInfoList():Vector.<LocationInfo> 
		{
			return _locationInfoList;
		}
		
		public function get objectsInfoList():Vector.<ObjectInfo> 
		{
			return _objectsInfoList;
		}
		
		public function get racersInfoList():Vector.<RacerInfo> 
		{
			return _racersInfoList;
		}
		
		public function get sheetInfoList():Vector.<SheetInfo> {return _sheetInfoList;}
	}

}
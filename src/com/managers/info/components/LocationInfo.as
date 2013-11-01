package com.managers.info.components 
{
	import com.Facade;
	import com.geom.Polygon;
	import com.managers.info.IInfoComponent;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class LocationInfo implements IInfoComponent
	{
		public var name:String;
		public var width:Number
		public var height:Number
		public var laps:int;
		
		public var environment:String;
		public var closerBG:String;
		public var fartherBG:String;
		public var frictionMap:String;
		public var description:String
		
		public var frictionMin:Number;
		public var frictionMax:Number;
		
		private var _infoID:int;
		
		private var _descriptionParsed:Boolean
		
		private var _content:Vector.<LocationContentInfo>;
		private var _spawners:Vector.<SpawnerInfo>;
		private var _triggers:Vector.<TriggerInfo>
		private var _bounds:Vector.<Polygon>
		private var _frictionMapBD:BitmapData
		
		private var _helperV1:Vector3D = new Vector3D();
		
		public function LocationInfo() 
		{
			
		}
		public function init(value:XML):void
		{
			_infoID = parseInt(value["@infoID"]);
			width = parseInt(value["@width"]);
			height = parseInt(value["@height"]);
			laps = parseInt(value["@laps"])
			
			name = value["@name"];
			environment = value["@environment"];
			closerBG = value["@closerBG"];
			fartherBG = value["@fartherBG"];
			frictionMap = value["@frictionMap"];
			description = value["@description"];
			frictionMin = parseFloat(value["@frictionMin"]);
			frictionMax = parseFloat(value["@frictionMax"]);
			
			parseDescription();
			
		}
		public function toString():String
		{
			var result:String = "LocationInfo:";
			result += " id - " + infoID;
			result += " width - " + width;
			result += " height - " + height;
			result += " name - " + name;
			result += " environment - " + environment;
			result += " closerBG - " + closerBG;
			result += " fartherBG - " + fartherBG;
			
			return result;
		}
		
		/* INTERFACE com.managers.info.IInfoComponent */
		
		public function get infoID():int 
		{
			return _infoID;
		}
		
		private function parseDescription():void
		{
			if (descriptionParsed) return;
			_descriptionParsed = true;
			
			_content = new Vector.<LocationContentInfo>();
			_spawners = new Vector.<SpawnerInfo>();
			_triggers = new Vector.<TriggerInfo>();
			_bounds = new Vector.<Polygon>();
			
			_frictionMapBD = Facade.instance.assetManager.getBitmapData(frictionMap);
			
			
			var value:MovieClip = Facade.instance.assetManager.getMovieClip(description);
			var currentChild:MovieClip
			var objectnamePrefix:RegExp =/object_/i;
			var spawnernamePrefix:RegExp =/spawner_/i;
			var triggerNamePrefix:RegExp =/trigger_/i;
			var boundNamePrefix:RegExp =/bound_/i;
			
			var currentID:int;
			var currentContentInfo:LocationContentInfo;
			var currentSpawnerInfo:SpawnerInfo;
			var currentTriggerInfo:TriggerInfo;
			var currentBound:Polygon;
			var boundsDict:Dictionary = new Dictionary();
			
			for (var i:uint = 0; i < value.numChildren; i++ ) {
				currentChild = value.getChildAt(i) as MovieClip;
				if (!currentChild) continue;
				
				if (objectnamePrefix.test(currentChild.name)) {
					currentID = parseInt(currentChild.name.replace(objectnamePrefix,""));
					if (currentID <= 0) {
						continue;
					}
					currentContentInfo = new LocationContentInfo()
					currentContentInfo.templateID = currentID;
					currentContentInfo.x = currentChild.x;
					currentContentInfo.y = currentChild.y;
					_content.push(currentContentInfo);
				}else if (spawnernamePrefix.test(currentChild.name)) {
					var spawnerIndex:int = parseInt(currentChild.name.replace(spawnernamePrefix, ""));
					currentSpawnerInfo = new SpawnerInfo();
					currentSpawnerInfo.index = spawnerIndex;
					currentSpawnerInfo.worldX = currentChild.x;
					currentSpawnerInfo.worldY = currentChild.y;
					currentSpawnerInfo.worldAngle = currentChild.rotation / 180.0 * Math.PI;
					
					_spawners.push(currentSpawnerInfo);
					
				}else if (triggerNamePrefix.test(currentChild.name)) {
					var triggerIndex:int = parseInt(currentChild.name.replace(triggerNamePrefix, ""));
					currentTriggerInfo = new TriggerInfo();
					currentTriggerInfo.intex = triggerIndex;
					currentTriggerInfo.worldAngle = currentChild.rotation / 180.0 * Math.PI;
					currentTriggerInfo.worldX = currentChild.x;
					currentTriggerInfo.worldY = currentChild.y;
					
					_triggers.push(currentTriggerInfo);
					
				}else if (boundNamePrefix.test(currentChild.name)) {
					var boundIndex:int = parseInt(currentChild.name.replace(boundNamePrefix, ""));
					if (!boundsDict[boundIndex]) {
						currentBound = new Polygon();
						boundsDict[boundIndex] = currentBound;
						_bounds.push(currentBound);
					}
					currentBound = boundsDict[boundIndex];
					var startX:Number = currentChild.x;
					var startY:Number = currentChild.y;
					
					var lengh:Number = Math.max(currentChild.width, currentChild.height);
					var angle:Number = currentChild.rotation / 180.0 * Math.PI;
					
					var endX:Number = startX + Math.cos(angle) * lengh;
					var endY:Number = startY + Math.sin(angle) * lengh;
					
					currentBound.addSide(startX, startY, endX, endY);
				}
				
				
				else {
					continue;
				}
			}
			_spawners.sort(SpawnerInfo.spawnerSorter);
			_triggers.sort(TriggerInfo.sorter);
			
		}
		
		public function get descriptionParsed():Boolean {return _descriptionParsed;	}
		
		public function get content():Vector.<LocationContentInfo> 
		{
			return _content;
		}
		
		public function get spawners():Vector.<SpawnerInfo> 
		{
			return _spawners;
		}
		
		public function get triggers():Vector.<TriggerInfo> 
		{
			return _triggers;
		}
		
		public function get bounds():Vector.<Polygon> 
		{
			return _bounds;
		}
		
		public function get frictionMapBD():BitmapData 
		{
			return _frictionMapBD;
		}
		
		
	}

}
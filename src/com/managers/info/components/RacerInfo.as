package com.managers.info.components 
{
	import com.managers.info.IInfoComponent;
	
	
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class RacerInfo implements IInfoComponent 
	{
		private var _infoID:int;
		
		public var name:String
		public var faceSheetID:int;
		public var detailedRaceSheetID:int;
		public var generalRaceSheetID:int;
		public var maxDeviationAngle:Number;
		
		public var mass:Number;
		public var engineForce:Number;
		public var breakForce:Number;
		public var turnForce:Number;
		
		public var raceStartDilogs:Vector.<RacerDilogInfo>
		public var raceWinDilogs:Vector.<RacerDilogInfo>;
		public var raceFailDilogs:Vector.<RacerDilogInfo>;
		public var wrongDirectionDilogs:Vector.<RacerDilogInfo>;
		public var positionWinDilogs:Vector.<RacerDilogInfo>
		public var positionFailDilogs:Vector.<RacerDilogInfo>
		public var collisionDialogs:Vector.<RacerDilogInfo>
		
		public function RacerInfo() 
		{
			raceStartDilogs = new Vector.<RacerDilogInfo>();
			raceWinDilogs = new Vector.<RacerDilogInfo>();
			raceFailDilogs = new Vector.<RacerDilogInfo>();
			wrongDirectionDilogs = new Vector.<RacerDilogInfo>();
			positionWinDilogs = new Vector.<RacerDilogInfo>();
			positionFailDilogs = new Vector.<RacerDilogInfo>();
			collisionDialogs = new Vector.<RacerDilogInfo>();
		}
		public function init(value:XML):void
		{
			_infoID = parseInt(value["@infoID"]);
			name = value["@name"];
			faceSheetID = parseInt(value["@faceSheetID"])
			detailedRaceSheetID = parseInt(value["@detailedRaceSheetID"])
			generalRaceSheetID = parseInt(value["@generalRaceSheetID"])
			maxDeviationAngle = parseInt(value["@maxDeviationAngle"])
			
			mass = parseFloat(value["@mass"]);
			engineForce = parseFloat(value["@engineForce"]);
			breakForce = parseFloat(value["@breakForce"]);
			turnForce = parseFloat(value["@turnForce"]);
			
			parceDilogs(value["startRaceMessages"]["message"], raceStartDilogs);
			parceDilogs(value["raceWinMessages"]["message"], raceWinDilogs);
			parceDilogs(value["raceFailMessages"]["message"], raceFailDilogs);
			parceDilogs(value["wrongDirectionMessages"]["message"], wrongDirectionDilogs);
			parceDilogs(value["positionWinMessages"]["message"], positionWinDilogs);
			parceDilogs(value["positionFailMessages"]["message"], positionFailDilogs);
			parceDilogs(value["collisionMessages"]["message"], collisionDialogs);
		}
		
		private function parceDilogs(source:XMLList, destination:Vector.<RacerDilogInfo>):void
		{
			var currentDilog:RacerDilogInfo
			for each(var childNode:XML in source) 
			{
				currentDilog = new RacerDilogInfo();
				currentDilog.message = childNode["@text"];
				currentDilog.expression = parseInt(childNode["@expression"])
				
				destination.push(currentDilog);
			}
			
		}
		
		public function toString():String
		{
			
			var result:String = "RacerInfo:";
			result += " infoID - " + infoID;
			result += " name - " + name;
			
			return result;
			
			
		}
		
		
		/* INTERFACE com.managers.info.IInfoComponent */
		
		public function get infoID():int 
		{
			return _infoID;
		}
		
	}

}
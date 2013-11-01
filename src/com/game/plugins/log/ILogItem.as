package com.game.plugins.log 
{
	
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public interface ILogItem 
	{
		function get id():String
		function write():String;
		function read(entryStepIndex:int,stepInterval:int,value:String,currentStepIndex:int):void
		
		function align(currentGameStep:int):void
		function get lastAlignmentStepIndex():int;
	}
	
}
package com.game.plugins.statGame 
{
	import com.game.entity.Racer;
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class RacerInitialState 
	{
		public var worldX:Number;
		public var worldY:Number;
		public var worldAngle:Number;
		
		public function RacerInitialState() 
		{
			
		}
		public function read(target:Racer):void
		{
			worldX = target.wordX;
			worldY = target.wordY;
			worldAngle = target.worldAngle;
		}
		public function apply(target:Racer):void
		{
			target.wordX = worldX;
			target.wordY = worldY;
			target.worldAngle = worldAngle;
			
			target.velocity.scaleBy(0);
			target.angularVelocity = 0;
			
		}
		
	}

}
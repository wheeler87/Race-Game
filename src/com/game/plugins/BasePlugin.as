package com.game.plugins 
{
	import com.game.Game;
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class BasePlugin 
	{
		private var _owner:Game
		
		
		public function BasePlugin(owner:Game) :void
		{
			_owner = owner;
			
		}
		
		public function onEnter():void
		{
			
		}
		public function onExit():void
		{
			
		}
		
		public function get owner():Game {return _owner;}
		
		
		
	}

}
package com.managers.assets 
{
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class AssetNamesConst 
	{
		//===================================
		// Objects
		//===================================
		static public const MAIL_BOX:String = "mailBox";
		static public const SIGN_STOP:String = "signStop";
		static public const SIGN_TURN_COMPLEX:String = "signTurnComplex";
		static public const SIGN_TURN_SIMPLE:String = "signTurnSimple";
		static public const STREET_LIGHT:String = "streetLight";
		static public const TREE_BIG:String = "treeBig";
		static public const TREE_MEDIUM:String = "treeMedium";
		static public const TREE_SMALL:String = "treeSmall";
		static public const BUCKED:String = "bucked";
		static public const CAP:String = "cap";
		
		//===================================
		// Environment
		//===================================
		static public const CLOSER_BG:String = "closerBG";
		static public const FARTHER_BG:String = "fartherBG";
		static public const MAP:String = "map";
		static public const LOCATION:String = "location";
		static public const friction_map:String = "frictionMap";
		
		
		//===================================
		// Racers
		//===================================
		static public const MURIEL_FACE_SHEET:String="murielFaceSheet"
		static public const MURIEL_REGULAR_RACE_SHEET:String="murielRegularRaceSheet"
		static public const MURIEL_SPIN_RACE_SHEET:String="murielSpinRaceSheet"
		
		static public const SUPER_COW_FACE_SHEET:String="superCowFaceSheet"
		static public const SUPER_COW_REGULAR_RACE_SHEET:String="superCowRegularRaceSheet"
		static public const SUPER_COW_SPIN_RACE_SHEET:String="superCowSpinRaceSheet"
		
		static public const CHICKEN_FACE_SHEET:String="chickenFaceSheet"
		static public const CHICKENL_REGULAR_RACE_SHEET:String="chickenlRegularRaceSheet"
		static public const CHICKEN_SPIN_RACE_SHEET:String="chickenSpinRaceSheet"
		
		
		//===================================
		//Colors
		//===================================
		static public const COLOR_LIGHT_BLACK:uint = 0x333333;
		static public const COLOR_WHITE_DARK:uint = 0xdddddd;
		static public const COLOR_LIGHT_GREEN:uint = 0x003300
		static public const COLOR_BLUE:uint = 0x313d61;
		static public const COLOR_RED:uint = 0x61313d;
		static public const COLOR_GREEN:uint = 0x31613d;
		//===================================
		//Filters
		//===================================
		public static const FILTER_SHADOW:DropShadowFilter = new DropShadowFilter(8, 45, 0, 0.6, 4, 4, 1)
		public static const WHITE_LINE_THIN:GlowFilter = new GlowFilter(0xFFFFFF, 1, 2, 2, 100, BitmapFilterQuality.LOW);
		public static const WHITE_LINE_THIN_4:GlowFilter = new GlowFilter(0xFFFFFF, 1, 4, 4, 100, BitmapFilterQuality.LOW);
		
		public function AssetNamesConst() 
		{
			
		}
		
	}

}
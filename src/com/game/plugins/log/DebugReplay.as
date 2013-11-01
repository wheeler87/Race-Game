package com.game.plugins.log 
{
	/**
	 * ...
	 * @author Viacheslav.Kolesnyk
	 */
	public class DebugReplay 
	{
		
		
		
		public function DebugReplay() 
		{
			
		}
		
		static public function getDebugReplay():String
		{
			var result:String= ' <step index="1"><item id="GameCamera" state="200,150,-90"/></step><step index="101"><item id="GameCamera" state="200,130,-30"/></step><step index="201"><item id="GameCamera" state="234.64101615137758,150,30"/></step><step index="301"><item id="GameCamera" state="329.9038105676657,205,30"/></step><step index="401"><item id="GameCamera" state="416.50635094610936,255,30"/></step><step index="501"><item id="GameCamera" state="503.10889132455304,305,30"/></step><step index="601"><item id="GameCamera" state="561.7691453623975,310,0"/></step><step index="701"><item id="GameCamera" state="671.7691453623975,310,0"/></step><step index="801"><item id="GameCamera" state="741.7691453623975,310,20"/></step><step index="901"><item id="GameCamera" state="819.7114317029973,355,30"/></step><step index="1001"><item id="GameCamera" state="913.6806937815884,389.20201433256693,20"/></step><step index="1101"><item id="GameCamera" state="998.2530296523204,419.98382723187717,20"/></step><step index="1201"><item id="GameCamera" state="1092.2222917309107,454.1858415644441,20"/></step><step index="1301"><item id="GameCamera" state="1186.1915538095006,488.38785589701104,20"/></step><step index="1401"><item id="GameCamera" state="1280.1608158880906,522.589870229578,20"/></step><step index="1501"><item id="GameCamera" state="1374.1300779666806,556.7918845621449,20"/></step><step index="1601"><item id="GameCamera" state="1458.7024138374115,587.5736974614551,20"/></step><step index="1701"><item id="GameCamera" state="1503.2077706405914,625.0558780527278,50"/></step><step index="1801"><item id="GameCamera" state="1551.0635228343224,700.9985451800185,60"/></step><step index="1901"><item id="GameCamera" state="1568.2172921206873,758.282405071699,80"/></step>'
			//var result:String= ' <step index="1"><item id="GameCamera" state="200,150,-90"/></step>'
			
			
			return result;
		}
		
		static public function getLastReplay():String
		{
			var result:String = '<step index="1"><item id="GameCamera" state="200,150,-90"/></step><step index="101"> <item id="GameCamera" state="200,150,-50"/></step><step index="201"> <item id="GameCamera" state="220,150,0"/></step><step index="301"><item id="GameCamera" state="318.48077530122066,167.36481776669308,10"/></step><step index="401"><item id="GameCamera" state="407.41731801207504,179.52019020337823,0"/></step><step index="501"><item id="GameCamera" state="517.417318012075,179.52019020337823,0"/></step><step index="601"><item id="GameCamera" state="597.417318012075,179.52019020337823,10"/></step><step index="701"><item id="GameCamera" state="695.8980933132956,196.8850079700713,10"/></step><step index="801"><item id="GameCamera" state="794.3788686145161,214.2498257367644,10"/></step><step index="901"><item id="GameCamera" state="884.3788686145161,214.2498257367644,0"/></step>';
			return result;
			

		}
		static public function getRacerDebugReplay():String
		{
			var result:String = '<step index="1"><item id="player_746" state="100,100,4.363323129985824"/></step><step index="101"><item id="player_746" state="135,9,5"/></step><step index="201"><item id="player_746" state="321,35,0.4665378228062508"/></step><step index="301"><item id="player_746" state="582,188,0.8313378228062506"/></step><step index="401"><item id="player_746" state="603,473,1.8649378228062563"/></step><step index="501"><item id="player_746" state="601,773,1.3329378228062527"/></step><step index="601"><item id="player_746" state="610,1070,1.8953378228062565"/></step><step index="701"><item id="player_746" state="709,1327,0.4513378228062509"/></step><step index="801"><item id="player_746" state="1001,1398,6.263323129985837"/></step><step index="901"><item id="player_746" state="1301,1364,5.868123129985834"/></step>';
			return result;
		}
	}

}
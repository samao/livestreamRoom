package xing.screenshot.com
{
	import flash.display.MovieClip;
	import flash.text.*;
	import flash.display.SimpleButton;
	public class LoadIngMc extends MovieClip
	{
		public var loadIng:MovieClip;
		public var messTxt:TextField;
		public var outBtn:SimpleButton;
		public function LoadIngMc()
		{
			outBtn.visible=false;
			messTxt.text="";
			messTxt.selectable=false;
			loadIng.gotoAndStop(1);
		}
	}
}
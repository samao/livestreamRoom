package xing.upLoad
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.*;
	public class Btn extends MovieClip
	{
		private var txtUpBtn:TextField;
		public function Btn(txt:String)
		{
			txtUpBtn = new TextField();
			txtUpBtn.autoSize = TextFieldAutoSize.LEFT;
			txtUpBtn.width=50;
			txtUpBtn.textColor=0x000000;
			txtUpBtn.selectable=false;
			txtUpBtn.text=txt;
			this.addChild(txtUpBtn);
			
			
		}
		
		public function init():void{
			var spMask:Sprite=new Sprite();
			spMask.graphics.beginFill(0x000000,0);
			spMask.graphics.drawRect(0,0,width,height);
			spMask.graphics.endFill();
			this.addChild(spMask);
		}
		
		public function setColor(o:uint):void{
			txtUpBtn.textColor=o;
		}
	}
}
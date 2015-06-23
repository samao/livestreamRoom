package xing.screenshot.com
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	public class RectBtn extends Sprite
	{
		public var id:int;
		public function RectBtn(i:int)
		{
			id=i;
			this.name="btn"+id.toString();
			this.graphics.clear();
			this.graphics.beginFill(0xCCCCCC,0);
			this.graphics.lineStyle(1, 0x0000FF);
			this.graphics.drawRect(-2.5, -2.5, 5, 5);
			this.graphics.endFill();
			this.buttonMode=true;
		}
	}
}
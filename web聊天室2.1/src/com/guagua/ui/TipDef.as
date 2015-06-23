package com.guagua.ui 
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Transform;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author idzeir
	 */
	public class TipDef extends Sprite 
	{
		private var tf:TextFormat = new TextFormat();
		private var txt:TextField = new TextField();
		
		private var tri:Shape = new Shape();
		
		public function TipDef() 
		{			
			mouseEnabled = false;
			txt.autoSize = TextFieldAutoSize.CENTER;				
			tf.align = TextFormatAlign.CENTER;			
			
			this.txt.defaultTextFormat = tf;
			
			this.addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		
		private function onAdded(e:Event):void 
		{
			this.txt.antiAliasType = AntiAliasType.ADVANCED;
			removeEventListener(Event.ADDED_TO_STAGE, onAdded);		
			//text = "";
			this.addChild(txt);
			createTri();			
			this.addChild(tri)
		}
		
		/**提示框倒三角*/
		private function createTri():Shape {
			tri.graphics.clear();
			tri.graphics.lineStyle(1, 0x000000);
			tri.graphics.beginFill(0xffffff, 1);			
			tri.graphics.moveTo( -5, 0);
			tri.graphics.lineTo(0, 7);
			tri.graphics.lineTo(5, 0);	
			tri.graphics.lineStyle(1, 0x000000, 0);
			tri.graphics.lineTo( -5, 0);
			tri.graphics.endFill();
			return tri;
		}
		
		public function get minHeight():Number {
			return Math.max(this.height, txt.textHeight, 25.5);
		}
		
		public function set text(arg:String):void {
			this.txt.text = arg;
			if (arg != "") {
				this.txt.border = true;
				this.txt.background = true;
				this.txt.thickness = 2;
				this.txt.backgroundColor = 0xffffff;	
				tri.visible = true;
			}else {				
				this.txt.border = false;
				this.txt.background = false;	
				tri.visible = false;
			}
			this.txt.x = -this.txt.width * .5;
			tri.y = this.txt.y + this.txt.height - 1;
		}
		
	}

}
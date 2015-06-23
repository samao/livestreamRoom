package com.guagua.ui 
{
	import com.bit101.components.InputText;
	import com.bit101.components.Label;
	import com.bit101.components.PushButton;
	import com.bit101.components.Style;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author idzeir mailto:qiyanlong@wozine.com
	 */
	public class DebugUI extends Sprite 
	{
		private var inTxt:InputText;
		private var fun:Function;
		
		public function DebugUI(fn:Function) 
		{
			fun = fn;
			this.addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		
		private function onAdded(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAdded);
			Style.fontSize = 12;
			Style.BACKGROUND = 0xffffff;
			Style.fontName = "宋体";
			
			var label:Label = new Label(this, 0, 0, "ROOM ID: ");
			label.textField.defaultTextFormat = new TextFormat(null, 14);
			inTxt = new InputText(this,label.width+2,0,"207429");
			inTxt.restrict = "0123456789";
			inTxt.maxChars = 6;
			var but:PushButton = new PushButton(this, inTxt.x+inTxt.width + 2, 0, "enter", clickHandler);	
			label.height=inTxt.height = but.height = 20;
			but.width = 50;
			
			x = (stage.stageWidth - this.width) / 2;
			y = (stage.stageHeight - inTxt.height) / 2;
		}
		
		private function clickHandler(e:MouseEvent):void 
		{
			if (inTxt.text.length <= 6)
			{
				this.visible = false;
				fun(inTxt.text);
			}			
		}
		
	}

}
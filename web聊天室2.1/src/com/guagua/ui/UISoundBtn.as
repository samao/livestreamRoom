package com.guagua.ui 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Wen
	 */
	public class UISoundBtn extends Sprite {
		public var btn:MovieClip;
		public var bj:MovieClip;
		public var myMask:Sprite;
		private var dragI:Number = 1;
		private var sounI:Number = 1;
		private var startI:Number = 3;
		private var stopI:Number = 40;
		private var moveDef:MovieClip
		
		
        //3----->40    37;
		public function UISoundBtn(){
			super();
			Init();
		}
		
		public function InitSound(i:Number):void {
			btn.x = startI + (stopI-startI) * i;
			myMask.width = (btn.x - startI) / (stopI - startI) * 42;
			
		}

		public function Init():void {
			myMask = new Sprite();
			this.addChild(myMask);
			myMask.x = bj.x;
			myMask.y = bj.y - 3;
			myMask.graphics.beginFill(0x000000, 0);
			myMask.graphics.drawRect(0, 0, bj.width, bj.height);
			bj.mask = myMask;
			//trace(myMask.width);
			btn.buttonMode = true;
			btn.x = stopI;
			btn.addEventListener(MouseEvent.MOUSE_DOWN, BtnClick);
			
			moveDef=this["moveDef1"]
			moveDef.addEventListener(MouseEvent.CLICK, clickHandler);
			
		}
		
		private function clickHandler(e:MouseEvent):void 
		{
			var value:Number = (this.mouseX - bj.x) / moveDef.width;
			sounI = value;
			this.dispatchEvent(new Event("changeSound"));
			InitSound(value);
		}

		private function BtnClick(e:MouseEvent):void {
			btn.startDrag(false, new Rectangle(startI, btn.y, stopI-startI, 0));
			stage.addEventListener(MouseEvent.MOUSE_UP, Up);
			this.addEventListener(Event.ENTER_FRAME, ENTER_FRAME);
			//trace(9);

		}
		
		

		public function Close(b:Boolean):void {
			
			if (b){
				sounI = 0;
				btn.x = startI;	
			} else {
				sounI = dragI==0?.6:dragI;
				btn.x = sounI*(stopI - startI)+startI;
			}
			//trace(this,"CLOSE",sounI)
			myMask.width = sounI * 42;
			this.dispatchEvent(new Event("changeSound"));
		}

		private function Up(e:MouseEvent):void {
			btn.stopDrag();
			stage.removeEventListener(MouseEvent.MOUSE_UP, Up);
			this.removeEventListener(Event.ENTER_FRAME, ENTER_FRAME);
			myMask.width = (btn.x - startI) / (stopI-startI) * 42;
			sounI = (btn.x - startI) / (stopI - startI);
			dragI = sounI;
			//trace(btn.x+"   "+sounI+"   "+dragI);
			this.dispatchEvent(new Event("changeSound"));
		}

		private function ENTER_FRAME(e:Event):void {
			myMask.width = (btn.x - startI) / (stopI-startI) * 42;
		}
		
		public function get volume():Number {
			return sounI;
		}
	}

}
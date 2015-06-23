package com.guagua.starling
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	
	
	/**
	 *@Date:2012-10-25 上午11:04:54	
	 */
	
	public class World extends Sprite
	{		
		private var xml:XML;
		private var texture:Texture;
		
		private const xmlURL:String="../Assets/atlas.xml"
		private const textureURL:String="../Assets/atlas.png"
			
		private var birdsVector:Vector.<MovieClip>=new Vector.<MovieClip>();

		private var vector:Vector.<uint>;
		
		public function World()
		{
			super();
			
			this.addEventListener(starling.events.Event.ADDED_TO_STAGE,onAdded);
		}
		
		private function onAdded(event:starling.events.Event):void
		{
			trace("This is starling world")
			
			initSource();	
		}
		
		private function initSource():void
		{
			var urlLoader:URLLoader=new URLLoader();
			urlLoader.addEventListener(flash.events.Event.COMPLETE,xmlReady);
			urlLoader.load(new URLRequest(this.xmlURL));
		}
		
		protected function xmlReady(event:flash.events.Event):void
		{
			this.xml=XML(event.target.data);
			
			var loader:Loader=new Loader();
			loader.contentLoaderInfo.addEventListener(flash.events.Event.COMPLETE,atlasReady);
			loader.load(new URLRequest(this.textureURL));
		}
		
		protected function atlasReady(event:flash.events.Event):void
		{			
			this.texture=Texture.fromBitmap(event.target.content);
			
			var atlas:TextureAtlas=new TextureAtlas(this.texture,this.xml);
			vector=new Vector.<uint>();
			var movie:MovieClip
			for(var i:uint=0;i<1000;i++){
				movie=new MovieClip(atlas.getTextures("flight_"),Math.random()*20+10);	
				movie.loop=true;
				movie.pivotX=movie.width*.5;
				movie.pivotY=movie.height*.5;
				movie.scaleX=movie.scaleY=0.2+Math.random()*0.1;
				movie.x=Math.random()*(this.stage.stageWidth-40)+20;
				movie.y=Math.random()*(this.stage.stageHeight-40)+20;
				this.addChild(movie);				
				movie.play();				
				Starling.juggler.add(movie);
				birdsVector.push(movie);
				vector.push(uint(Math.random()*3+1));
			}			
			
			this.addEventListener(starling.events.Event.ENTER_FRAME,flyHandler);
		}
		
		private function flyHandler(event:starling.events.Event):void
		{
			var index:uint=0;
			for each(var i:MovieClip in birdsVector){
				if(i.x>stage.stageWidth){
					i.x=-i.width;					
				}
				i.x+=vector[index++];
			}
			
		}
	}
}
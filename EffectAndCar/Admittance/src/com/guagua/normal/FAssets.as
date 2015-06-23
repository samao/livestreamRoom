package com.guagua.normal
{
	import com.adobe.serialization.json.JSON;
	import com.guagua.events.FAssetsEvent;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	
	/**
	 * 外部资源管理类
	 *@Date:2012-11-1 下午05:44:22	
	 */
	
	public class FAssets extends EventDispatcher
	{
		/**存储所有加载过的皮肤*/
		private var assetsHash:Dictionary=new Dictionary();
		
		/**加载完皮肤以后给车辆标记*/
		private var user:FUserInfor;		
		
		static private var instance:FAssets;
		
		/**排队加载资源用户*/
		private var userVector:Vector.<FUserInfor>=new Vector.<FUserInfor>();
		
		private var libPath:URLRequest=new URLRequest();
		private var loader:Loader=new Loader();
		private var ldr:LoaderContext=new LoaderContext(false,ApplicationDomain.currentDomain);
		
		/**已加载的汽车资源标签库*/
		private var tagVector:Vector.<CarNode>=new Vector.<CarNode>();	
		
		public function FAssets()
		{
			super();
			
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,readyHandler);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,ioHandler);
		}
		
		/**本地没找到资源文件*/
		protected function ioHandler(event:IOErrorEvent):void
		{
			trace(libPath.url," is not exist !");
			userVector.splice(0,1);
			this.dispatchEvent(new FAssetsEvent(FAssetsEvent.READY));
		}
		
		/**成功加载车辆资源*/
		protected function readyHandler(event:Event=null):void
		{			
			userVector[0].isReady=true;
			if(event!=null){
				tagVector.push(new CarNode(userVector[0].m_lCarID,event.target.content.libId))	
			}
			
			userVector[0].libMap=event==null?String(getLidMapID(userVector[0].m_lCarID)):String(event.target.content.libId);
			userVector.splice(0,1);
			this.dispatchEvent(new FAssetsEvent(FAssetsEvent.READY,true));			
			
			//加载队列完毕
			if(userVector.length==0){			
				this.dispatchEvent(new FAssetsEvent(FAssetsEvent.FINISH));				
			}
		}
		
		static public function getInstance():FAssets{
			if(instance==null){
				instance=new FAssets();
			}
			return instance;
		}
		
		/**
		 * 检查是否加载过皮肤
		 * @param type:检查皮肤的关键字
		 * @return 搜索结果
		 * */
		public function hasAssets(type:String):Boolean{
			return assetsHash.hasOwnProperty(type)			
		}
		
		/**
		 * 获取指定皮肤
		 * @param type:要获取皮肤的关键字
		 * @return 搜索到的皮肤
		 * */
		public function getAssets(type:String):DisplayObject{
			return assetsHash[type];	
		}
		
		/**
		 * 添加存储资源信息
		 * @param tag:资源标识
		 * @param value:资源皮肤
		 * */
		public function addAssets(tag:String,value:DisplayObject=null):Boolean{
			if(!ApplicationDomain.currentDomain.hasDefinition("com.guagua.display."+tag)){
				var text:TextField=new TextField();
				text.text=tag+" is not in lib!"
				assetsHash[tag]=text;
				return false
			}
			var DomainObject:Class=ApplicationDomain.currentDomain.getDefinition("com.guagua.display."+tag) as Class;
			var displayDef:DisplayObject=new DomainObject() as DisplayObject;
			assetsHash[tag]=displayDef;
			return true;
		}
		
		/**
		 * 将用户加入资源加载队列
		 * @param value用户模型
		 * */
		public function insertUser(value:FUserInfor):void{
			var curUser:FUserInfor=value;
			//如果在队列中了，添加到末尾；
			for(var i:uint=0;i<userVector.length;i++){
				if(curUser.m_i64UserID==userVector[i].m_i64UserID){
					curUser=userVector[i];
					userVector.splice(i,1);
					break;
				}
			}
			userVector.push(curUser);			
		}
		
		/**加载外部资源*/
		public function loadAssets():void{
			if(getLidMapID(userVector[0].m_lCarID)!="0"){
				this.readyHandler();
				return
			}			
			libPath.url=this.userVector[0].m_szCarResPath;//ConstVal.ASSETS_FLODER+this.userVector[0].m_lCarID+".swf";
			loader.load(libPath,ldr);
		}		
		
		private function getLidMapID(carID:String):String{
			for each(var i:CarNode in this.tagVector){
				if(i.gid==carID){
					return i.libId;
				}
			}
			return "0";
		}
	}
}
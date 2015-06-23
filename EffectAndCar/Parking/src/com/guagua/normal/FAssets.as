package com.guagua.normal
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	
	
	/**
	 * rsl资源皮肤管理类
	 *@Date:2012-11-1 下午05:44:22	
	 */
	
	public class FAssets extends EventDispatcher
	{
		/**存储所有加载过的皮肤*/
		private var assetsHash:Dictionary=new Dictionary();
		
		/**加载完皮肤以后给车辆标记*/
		private var user:FUserInfor;		
		
		private var _tagVector:Vector.<CarNode>=new Vector.<CarNode>();
		
		/**基础资源加载完成标记*/
		public var isReady:Boolean=false;
		
		static private var instance:FAssets;
		
		public function FAssets()
		{
			super();
			instance=this;
		}
		
		/**加载过的车辆库标记，防止重复加载*/
		public function get tagVector():Vector.<CarNode>
		{
			return _tagVector;
		}

		/**
		 * @private
		 */
		public function set tagVector(value:Vector.<CarNode>):void
		{
			_tagVector = value;
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
		 * 在rsl资源库中寻找资源ui
		 * @param tag:皮肤查找标识
		 * @param value:皮肤值
		 * @return 存在皮肤返回true，不存在返回false
		 * */
		public function addAssets(tag:String,value:DisplayObject=null):Boolean{
			//trace(tag,ApplicationDomain.currentDomain.hasDefinition("com.guagua.display."+tag))
			if(!ApplicationDomain.currentDomain.hasDefinition("com.guagua.display."+tag)){
				var text:TextField=new TextField();
				//text.text=tag+" is not in lib!"
				assetsHash[tag]=text;			
				
				return false;
			}
			var DomainObject:Class=ApplicationDomain.currentDomain.getDefinition("com.guagua.display."+tag) as Class;
			var displayDef:DisplayObject=new DomainObject() as DisplayObject;
			assetsHash[tag]=displayDef;
			return true
		}
		
		/**加载外部资源*/
		public function loadAssets(user:FUserInfor=null):void{
			
		}
		
		public function getLidMapID(carID:String):String{
			for each(var i:CarNode in this.tagVector){
				if(i.gid==carID){
					return i.libId;
				}
			}
			return "0";
		}
	}
}
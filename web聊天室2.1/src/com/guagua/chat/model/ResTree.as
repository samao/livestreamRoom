package com.guagua.chat.model 
{
	//import com.adobe.serialization.json.JSON;
	import flash.utils.Dictionary;
	/**
	 * ... 
	 * @author idzeir
	 */
	public class ResTree 
	{
		static private var instance:ResTree;
		
		private var treeDic:Dictionary = new Dictionary();
		
		/**资源统计数量*/
		public var size:uint = 0;
		
		/**资源下载完成*/
		static public var isReady:Boolean = false;
		
		public function ResTree() 
		{
			
		}
		
		static public function getInstance():ResTree {
			if (instance == null) {
				instance = new ResTree();
			}
			
			return instance;
		}
		
		/**
		 * 向树里添加一个资源项
		 * @param value:ResNode 资源节点
		 * */
		public function addRes(value:uint):void {
			if (!hasNode(value)) {
				treeDic["res_" + value] = value;
				size++;
				//trace("资源数：", size,JSON.stringify(value));
			}
		}
		
		/**
		 * 判断资源树里面是否存在资源项
		 * @param value:uint需要判断资源id
		 * */
		public function hasNode(value:uint):Boolean {
			return treeDic.hasOwnProperty("res_" + value);	
		}
		
		/**
		 * 获取资源信息
		 * @param id:uint需要获取的资源id;
		 * */
		public function getResProperty(id:uint):Number {
			return treeDic["res_" + id];
		}		
		
	}

}
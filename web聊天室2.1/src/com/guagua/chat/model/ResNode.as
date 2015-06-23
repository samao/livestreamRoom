package com.guagua.chat.model 
{
	/**
	 * ...
	 * @author idzeir
	 */
	
	 
	/**资源节点信息*/
	public class ResNode 
	{
		public var resID:uint = 0;
		public var grade:Number = 0;
		public var name:String = "";
		public var des:String = "";
		
		public function ResNode(obj:Object=null) 
		{
			resID = obj.resID;
			grade = obj.grade;
			//name = obj.name;
			//des = obj.des;
		}
		
		/**获取资源的权限属性*/
		public function getProperty():Number {
			return grade;
		}
	}

}
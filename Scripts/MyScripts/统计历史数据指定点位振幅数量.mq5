//+------------------------------------------------------------------+
//|                                统计3600天振幅大于500点的天数.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//使脚本可以提供用户输入界面
#property script_show_inputs
//+------------------------------------------------------------------+
//| 引入程序需要的类库并创建对象                                     |
//+------------------------------------------------------------------+
#include <MyClass\shuju.mqh>
ShuJu shuju;

//+------------------------------------------------------------------+
//| 初始化全局变量                                                   |
//+------------------------------------------------------------------+
input string 交易品种名称 = "EURUSD";
input ENUM_TIMEFRAMES 图表周期 = PERIOD_CURRENT;
input datetime 开始时间 = D'2000.1.1 00.00.00';
input int 浮动点位 = 100;

double highData[];
double lowData[];
double openData[];
//+------------------------------------------------------------------+
//| 程序仅执行一次                                                   |
//+------------------------------------------------------------------+
void OnStart()
{
   int counter = 0;
   int totle_k = iBarShift(交易品种名称, 图表周期, 开始时间, false);
   double bili = 0.0;
   
   shuju.gethigh(highData, totle_k, 交易品种名称, 图表周期);
   shuju.getopen(openData, totle_k, 交易品种名称, 图表周期);
   shuju.getlow (lowData,  totle_k, 交易品种名称, 图表周期);
   
   if(totle_k == -1)
   {
      printf("未找到指定开始时间的K线，请重新尝试！");
   }
   else
   {
      for(int i=1;i<totle_k;i++)
      {
         if(highData[i] - openData[i] > 浮动点位 * Point() || openData[i] - lowData[i] > 浮动点位 * Point()) 
         {
            counter += 1;
         }
      }
      bili = NormalizeDouble((double(counter)/double(totle_k)) * 100, 2);
      printf("共计: " + string(totle_k) + "根K线，以开盘价为基础上涨或下降" + string(浮动点位) + "点有" + string(counter) + "根，占比:" + string(bili) + "%%");
   }
}
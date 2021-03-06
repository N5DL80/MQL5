//+------------------------------------------------------------------+
//|                                                    OpenOrder.mq5 |
//|                                            五分钟BTP辅助下单脚本 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "五分钟BTP辅助下单脚本"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property script_show_inputs  //使脚本可以提供用户输入界面

//+------------------------------------------------------------------+
//| 引入程序需要的类库并创建对象                                     |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
#include <MyClass\shuju.mqh>
#include <MyClass\交易类\信息类.mqh>
#include <MyClass\交易类\仓位管理.mqh>

CTrade ct;
ShuJu sj;
账户信息 zh;
仓位管理 cw;

//+------------------------------------------------------------------+
//| 初始化全局变量                                                   |
//+------------------------------------------------------------------+
input string OrderType = "buy"; //订单类型
input double MaxRisk = 0.01;    // 允许最大损失占余额比例

double high[];
double low[];
double highPrice, lowPrice = 0.0;
//+------------------------------------------------------------------+
//| 脚本执行入口程序，仅执行一次                                     |
//+------------------------------------------------------------------+
void OnStart()
{
   printf(OrderType);
   sj.gethigh(high, 6);
   sj.getlow(low, 6);
   highPrice = high[ArrayMaximum(high, 1)];    //寻找前5根K线最高价
   lowPrice = low[ArrayMinimum(low, 1)];       //寻找前5根K线最低价
   
   int SL_PIP = 0;
   double TP, TP2 = 0.0;
   double buyPrice, sellPrice, Lots, SL = 0.0;
   double pip = cw.PIP_Value(Symbol());        // 一标准手价格波动1pip对应的账户资金价值
   double maxLoss = MaxRisk * zh.账户余额();   // 允许的最大损失所对应的余额价值
   
   if(OrderType == "BUY" || OrderType == "buy")
   {
      //计算开仓价、止损点位及下单手数
      SL = low[1] - 3 * Point();                             //止损价格
      buyPrice = highPrice + 3 * Point();                    //以此价格做多                         
      SL_PIP = int((buyPrice - SL) / Point());         //计算止损点数
      TP = buyPrice + SL_PIP * Point();
      TP2 = buyPrice + SL_PIP * 2 * Point();
      Lots = NormalizeDouble(maxLoss / 2 / (SL_PIP * pip), 2);   //计算下单手数
      
      for(int i = 0; i<2; i++)
      {
         if(i < 1)
            ct.BuyStop(Lots, buyPrice, NULL, SL, TP);                  //下单
         else
            ct.BuyStop(Lots, buyPrice, NULL, SL, TP2);                 //下单
      }
   }
   
   if(OrderType == "SELL" || OrderType == "sell")
   {
      //计算开仓价、止损点位及下单手数
      SL = high[1] + 3 * Point();                            //止损价格
      sellPrice = lowPrice - 3 * Point();                    //以此价格做空
      SL_PIP = int((SL - sellPrice) / Point());              //计算止损点位
      Lots = NormalizeDouble(maxLoss / 2 / (SL_PIP * pip), 2);   //计算下单手数
      TP = sellPrice - SL_PIP * Point();
      TP2 = sellPrice - SL_PIP * 2 * Point();
      
      for(int i=0; i<2; i++)
      {
         if(i < 1)
            ct.SellStop(Lots, sellPrice, NULL, SL, TP);                //下单
         else
            ct.SellStop(Lots, sellPrice, NULL, SL, TP2);               //下单
      }
   }

}
//+------------------------------------------------------------------+

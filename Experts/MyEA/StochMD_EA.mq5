#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <MyClass\shuju.mqh>
ShuJu shuju;
#include <MyClass\交易类\信息类.mqh>
仓位信息 cw;
#include <MyClass\交易类\交易指令.mqh>
交易指令 jy;

input double lots = 0.01;
int sl = 1000;
int tp = 1000;
int deviation = 5;
int magic_StochMD = 666;
string commBuy = "BUY";
string commSell = "SELL";

double 最大手数 = 0.64;
int 追单阈值 = tp;

datetime 开盘时间 = 0;
datetime openTime[];

double Stoch[];
double Signal[];

double openLots = 0.0;
double openPrice = 0.0;
double openSXF = 0.0; 

int OnInit()
{

return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{

}

void OnTick()
{
   shuju.gettime(openTime, 3);

   shuju.Stochastic(Stoch, Signal, 3, Symbol(), PERIOD_CURRENT, 5, 3, 3, MODE_SMA, STO_LOWHIGH);
   
   int OrderNumber_BUY = cw.OrderNumber(Symbol(), 0, magic_StochMD);
   int OrderNumber_SELL = cw.OrderNumber(Symbol(), 1, magic_StochMD);
   
   ulong orderID = cw.OrderZJLS(Symbol(), openLots, openPrice, openSXF);
   

   if(OrderNumber_BUY == 0 && OrderNumber_SELL == 0)
   {  
      //做多条件(EMA金叉)  
      if(Stoch[2]<Signal[2] && Stoch[1]>Signal[1])
      {
         //如果历史订单有盈利，下单量 = 最小手数(Lots)
         if(openPrice-openSXF >= 0 || openLots == 最大手数)
         {
            if(jy.OrderOpen(Symbol(), ORDER_TYPE_BUY, lots, sl, tp, commBuy, magic_StochMD, deviation)>0)
            {
               jy.OrderModify(Symbol(), POSITION_TYPE_BUY, 0, 0, magic_StochMD);
            }           
         }
         //如果历史订单亏损，下单量 = 最近亏损单量 * 2
         if(openPrice-openSXF < 0 && openLots < 最大手数)
         {
            if(jy.OrderOpen(Symbol(), ORDER_TYPE_BUY, openLots*2, sl, tp, commBuy, magic_StochMD, deviation)>0)
            {
               jy.OrderModify(Symbol(), POSITION_TYPE_BUY, 0, 0, magic_StochMD);
            }
         }  
      }
      //做空条件(EMA死叉)
      if(Stoch[2]>Signal[2] && Stoch[1]<Signal[1])
      {
         //如果历史订单有盈利，下单量 = 最小手数(Lots)
         if(openPrice-openSXF >= 0 || openLots == 最大手数)
         {
            if(jy.OrderOpen(Symbol(), ORDER_TYPE_SELL, lots, sl, tp, commBuy, magic_StochMD, deviation)>0)
            {
               jy.OrderModify(Symbol(), POSITION_TYPE_SELL, 0, 0, magic_StochMD);
            }
         }
         //如果历史订单亏损，下单量 = 最近亏损单量 * 2
         if(openPrice-openSXF < 0 && openLots < 最大手数)
         {
            if(jy.OrderOpen(Symbol(), ORDER_TYPE_SELL, openLots*2, sl, tp, commBuy, magic_StochMD, deviation)>0)
            {
               jy.OrderModify(Symbol(), POSITION_TYPE_SELL, 0, 0, magic_StochMD);
            } 
         }  
      }  
   }  
   
   //平仓
   if(开盘时间 != openTime[0])
   {  
      if(OrderNumber_BUY > 0 || OrderNumber_SELL > 0)
      {
         if(Stoch[0]<Signal[0])
         {
            jy.OrderClose(Symbol(), ORDER_TYPE_BUY, deviation, magic_StochMD);
         }
         if(Stoch[0]>Signal[0])
         {
            jy.OrderClose(Symbol(), ORDER_TYPE_SELL, deviation, magic_StochMD);
         }
      }
      
      开盘时间 = openTime[0];
   }
}

//+------------------------------------------------------------------+
//|                                                       新建EA模板 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "基于RSI指标的倒卖策略"
#property link      "https://www.mql5.com"
#property version   "1.00"

//+------------------------------------------------------------------+
//| 引入程序需要的类库并创建对象                                     |
//+------------------------------------------------------------------+
#include <MyClass\shuju.mqh>
#include <MyClass\交易类\信息类.mqh>
#include <MyClass\交易类\交易指令.mqh>

ShuJu shuju;
账户信息 zh;
仓位信息 cw;
交易指令 jy;

//+------------------------------------------------------------------+
//| 初始化全局变量                                                   |
//+------------------------------------------------------------------+
input int RSI_MA = 12;

int SL, TP = 0;
int ma_h1 = 8;

datetime OPEN_TIME = 0;    //开盘时间
datetime openTime[];

double RSI_DATA[];
double high_h1[], low_h1[], close_h1[], high_m5[], low_m5[], close_m5[];
double MA_H1[];
//+------------------------------------------------------------------+
//| 初始化函数，程序首次运行仅执行一次                               |
//+------------------------------------------------------------------+
int OnInit()
{
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| 主函数，价格每波动一次执行一次                                   |
//+------------------------------------------------------------------+
void OnTick()
{
   //调用自定义函数
   ScanPrice();
}

//+------------------------------------------------------------------+
//| 程序关闭时执行一次，释放占用内存                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   printf("智能交易程序已关闭！");
   printf("图表窗口被关闭或者智能程序被卸载！");
}

//+------------------------------------------------------------------+
//|  信号筛选函数                                                    |
//+------------------------------------------------------------------+
void ScanPrice()
{
   //自定义功能函数
   shuju.gettime(openTime, 1, Symbol(), PERIOD_H1);  //开盘时间
   shuju.RSI(RSI_DATA, 3, Symbol(), PERIOD_M5, RSI_MA, PRICE_CLOSE);
   shuju.MA(MA_H1, 5, Symbol(), PERIOD_H1, ma_h1, 0, MODE_EMA, PRICE_CLOSE);
   
   shuju.gethigh(high_h1, 4, Symbol(), PERIOD_H1);
   shuju.getlow(low_h1, 4, Symbol(), PERIOD_H1);
   shuju.getclose(close_h1, 4, Symbol(), PERIOD_H1);
   
   shuju.gethigh(high_m5, 6, Symbol(), PERIOD_M5);
   shuju.getlow(low_m5, 6, Symbol(), PERIOD_M5);
   shuju.getclose(close_m5, 6, Symbol(), PERIOD_M5);
   
   double ask = shuju.getask(Symbol());
   double bid = shuju.getbid(Symbol());

   double highPrice = high_h1[ArrayMaximum(high_h1, 1)];    //寻找前3根K线最高价
   double lowPrice = low_h1[ArrayMinimum(low_h1, 1)];       //寻找前3根K线最低价
   
   if(OPEN_TIME != openTime[0])
   {
      if(close_h1[2]>MA_H1[2] && close_h1[1]<low_h1[2])
      {
         SL = int((highPrice - bid) / Point());    //计算止损点位
         TP = SL;
         jy.OrderOpen(Symbol(), ORDER_TYPE_SELL, 0.01, SL, TP, "SELL", 333, 3);
         OPEN_TIME = openTime[0];
      }
      /*
      if(RSI_DATA[2] < 30 && RSI_DATA[1] > 30 && close[1] > open[1])
      {
         printf("做多");
         SL = int((ask - lowPrice) / Point());      //计算止损点位
         TP = SL;
         jy.OrderOpen(Symbol(), ORDER_TYPE_BUY, 0.01, SL, TP, "SELL", 333, 3);
         OPEN_TIME = openTime[0];
      }*/
   }
} 

//=========================== 程序的最后一行==========================


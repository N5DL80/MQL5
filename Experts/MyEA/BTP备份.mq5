//+------------------------------------------------------------------+
//|                      https://www.youtube.com/watch?v=zhEukjCzXwM |
//|                                 上面链接中介绍的五分钟剥头皮策略         |
//+------------------------------------------------------------------+
#property copyright "五分钟剥头皮策略"
#property link      "https://www.mql5.com"
#property version   "1.00"

//+------------------------------------------------------------------+
//| 引入程序需要的类库并创建对象                                     |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
#include <Trade\OrderInfo.mqh>
#include <MyClass\shuju.mqh>
#include <MyClass\交易类\信息类.mqh>
#include <MyClass\交易类\交易指令.mqh>
#include <MyClass\交易类\仓位管理.mqh>
       
CTrade ct;
COrderInfo co;
ShuJu shuju;
账户信息 zh;
仓位信息 cw_xx;
交易指令 jy;
仓位管理 cw_gl;

//+------------------------------------------------------------------+
//| 初始化全局变量                                                   |
//+------------------------------------------------------------------+
input string SYMBOL = "EURUSD" ; //货币对名称
input double MaxRisk = 2;        //最大本金损失比例

int SL_PIPS = 0;            //止损点数
int TP_PIPS = 0;            //止盈点数
double SL_PRICE = 0.0;      //止损价格
double TP_PRICE = 0.0;      //止损价格
double P2_TP_PRICE = 0.0;

double Lots = 0.0;          //下单量 
int DEVIATION = 3;          //允许最大滑点
int MAGIC = 789;            //自定义EA编码

double ASK_PRICE  = 0.0;    //实时做多价格
double BID_PRICE  = 0.0;    //实时做空价格
double BUY_PRICE  = 0.0;    //开仓做多价格
double SELL_PRICE = 0.0;    //开仓做空价格

string commBuy  = "_BUY";   //订单注释
string commSell = "_SELL";  //订单注释
string ArrowBuy = "BUY_Arrow";
string ArrowSELL = "SELL_Arrow";

string ORDER_SWITCH = "";   //开仓开关
datetime OPEN_TIME = 0;     //开盘时间
datetime openTime[];

int N_ORDER_BUY  = 0;       //已开多单数量
int N_ORDER_SELL = 0;       //已开空单数量
int N_ORDER_GUA  = 0;       //已开挂单数量

double HIGH_PRICE = 0.0;    //五日内最高价
double LOW_PRICE  = 0.0;    //五日内最低价

int kma_h1 = 8;
int mma_h1 = 21;
int kma_m5 = 8;
int zma_m5 = 13;
int mma_m5 = 21;
double KMA_H1[];
double MMA_H1[];
double KMA_M5[];
double ZMA_M5[];
double MMA_M5[];

double open_m5[];
double high_m5[];
double low_m5[];
double close_m5[];
double close_h1[];



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
   //初始化必要的账户、市场、仓位等信息变量
   N_ORDER_BUY  = cw_xx.OrderNumber(SYMBOL, 0, MAGIC);
   N_ORDER_SELL = cw_xx.OrderNumber(SYMBOL, 1, MAGIC);
   N_ORDER_GUA = OrdersTotal();
   
   shuju.getopen(open_m5, 7, SYMBOL, PERIOD_M5);
   shuju.gethigh(high_m5, 7, SYMBOL, PERIOD_M5);
   shuju.getlow(low_m5, 7, SYMBOL, PERIOD_M5);
   shuju.getclose(close_h1, 3, SYMBOL, PERIOD_H1);
   shuju.getclose(close_m5, 3, SYMBOL, PERIOD_M5);
   
   //市价扫描，寻找开仓机会
   ScanPrice();
   
   //开单函数
   OpenOrder();
   
   //监听虚假开仓信号，找到后关闭开仓信号开关
   CloseSwitch();
   
   OrderModify();
   
   //移动止损触发器
   TrailingStop();
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
//|  市价扫描函数——寻找开仓条件                                      |
//+------------------------------------------------------------------+
void ScanPrice()
{
   //初始化必要的账户、市场、仓位等信息变量
   shuju.gettime(openTime, 1);        //开盘时间  
   ASK_PRICE = shuju.getask(SYMBOL);  //当前做多价格
   BID_PRICE = shuju.getbid(SYMBOL);  //当前做空价格   
 
   shuju.MA(KMA_H1, 10, SYMBOL, PERIOD_H1, kma_h1, 0, MODE_EMA, PRICE_CLOSE); 
   shuju.MA(MMA_H1, 10, SYMBOL, PERIOD_H1, mma_h1, 0, MODE_EMA, PRICE_CLOSE);
   shuju.MA(KMA_M5, 10, SYMBOL, PERIOD_M5, kma_m5, 0, MODE_EMA, PRICE_CLOSE); 
   shuju.MA(ZMA_M5, 10, SYMBOL, PERIOD_M5, zma_m5, 0, MODE_EMA, PRICE_CLOSE); 
   shuju.MA(MMA_M5, 10, SYMBOL, PERIOD_M5, mma_m5, 0, MODE_EMA, PRICE_CLOSE);
   
   //检查是否空仓并且是一根未扫描过的新K线
   if(N_ORDER_BUY + N_ORDER_SELL == 0 && OPEN_TIME != openTime[0])
   {
      //寻找做空机会
      if(close_h1[1] < KMA_H1[1] && KMA_H1[1] < MMA_H1[1])
      {
         if(MMA_M5[1] - ZMA_M5[1] > 7*Point() && ZMA_M5[1] - KMA_M5[1] > 7*Point())
         {
            if(close_m5[1] > open_m5[1] && high_m5[1] >= KMA_M5[1])
            {               
               //打开做空开关
               ORDER_SWITCH = "SELL";
               
               //计算下单量，按指定每单最大可承受本金损失比例开单
               Operation_Lots(ORDER_SWITCH); 
               
               OPEN_TIME = openTime[0];   //用开盘时间作为已扫描的标记
            }
         }
      }
   }
} 

//+------------------------------------------------------------------+
//| 开单函数                                                         |
//+------------------------------------------------------------------+

void OpenOrder()
{
   if(ORDER_SWITCH == "SELL" && BID_PRICE <= SELL_PRICE && N_ORDER_BUY + N_ORDER_SELL == 0)
   {
      for(int i=0; i<2; i++)
      {
         if(i == 0)
         {
            jy.OrderOpen(SYMBOL,ORDER_TYPE_SELL, Lots, SL_PIPS, TP_PIPS, "P1"+commSell, MAGIC, DEVIATION);
         }
         else
         {
            jy.OrderOpen(SYMBOL,ORDER_TYPE_SELL, Lots, SL_PIPS, TP_PIPS*2, "P2"+commSell, MAGIC, DEVIATION);
         }
         ORDER_SWITCH = "";
      }
   }
}

//+------------------------------------------------------------------+
//| 修改订单函数                                                     |
//+------------------------------------------------------------------+
void OrderModify()
{
   if(N_ORDER_BUY + N_ORDER_SELL == 1)
   {
      double openPrice_k = 0.0;
      cw_xx.OrderZJ(SYMBOL, MAGIC, openPrice_k);
      
      if(N_ORDER_BUY == 1)
         jy.OrderModify(SYMBOL, POSITION_TYPE_BUY, openPrice_k, -1, MAGIC);
      if(N_ORDER_SELL == 1)
         jy.OrderModify(SYMBOL, POSITION_TYPE_SELL, openPrice_k, -1, MAGIC);
   }
}

//+------------------------------------------------------------------+
//| 监听虚假开仓信号，找到后关闭开仓信号开关                         |
//+------------------------------------------------------------------+
void CloseSwitch()
{
   if(BID_PRICE >= SL_PRICE && ORDER_SWITCH == "SELL")
   {
      //关闭开关并初始化下单参数
      ORDER_SWITCH = "";
      ObjectDelete(0, ArrowSELL);
      SELL_PRICE = 0.0;
      SL_PIPS = 0;
      TP_PIPS = 0;
      Lots = 0.0;
   }
   /*
   if(N_ORDER_GUA > 0 && BID_PRICE > SL_PRICE)
   {
      for(int i=N_ORDER_GUA-1; i>=0; i--)
      {
         ct.OrderDelete(OrderGetTicket(i));
      }
   }*/
}

//+------------------------------------------------------------------+
//| 计算下单量函数——计算触发止损后每单最大可承受本金损失比例的金额   |
//+------------------------------------------------------------------+
void Operation_Lots(string orderType)
{
   //初始化必要的账户、市场、仓位等信息变量
   HIGH_PRICE = high_m5[ArrayMaximum(high_m5, 1)];        //寻找前5根K线最高价
   LOW_PRICE = low_m5[ArrayMinimum(low_m5, 1)];           //寻找前5根K线最低价
   
   double pip = cw_gl.PIP_Value(SYMBOL);                  // 一标准手价格波动1pip对应的账户资金价值
   double maxLoss = 0.01 * MaxRisk * zh.账户余额();         // 允许的最大损失所对应的余额价值
   
   if(orderType == "SELL")
   {
      //计算开仓价、止损点位及下单手数
      SELL_PRICE = LOW_PRICE - 3 * Point();               //以前六日价格以下三个点为做空价格
      SL_PRICE = high_m5[1] + 3 * Point();                //以前一日内最高价格加三个点为止损价格
      SL_PIPS = int((SL_PRICE - SELL_PRICE) / Point());   //计算买入价与止损价之间点位
      TP_PIPS = SL_PIPS;                                  //止盈点数等于止损点数
      TP_PRICE = SELL_PRICE - SL_PIPS*Point();  
      P2_TP_PRICE = SELL_PRICE - SL_PIPS*2*Point();
      
      Arrow(orderType); //绘制预开仓标记
   }
     
   Lots = NormalizeDouble(maxLoss/ 2 / (SL_PIPS * pip), 2);    //计算下单手数(因为同时下2单所以要除以2)
}

//+------------------------------------------------------------------+
//| 绘制预开仓标记                                                   |
//+------------------------------------------------------------------+
void Arrow(string orderType)
{
   if(orderType == "SELL")
   {
      ObjectCreate(0,ArrowBuy,OBJ_ARROW,0,0,0,0,0);                      //创建一个箭头 
      ObjectSetInteger(0,ArrowBuy,OBJPROP_TIME,OPEN_TIME);               //设置时间 
      ObjectSetInteger(0,ArrowBuy,OBJPROP_COLOR, clrGreenYellow);        //设置箭头颜色
      ObjectSetInteger(0,ArrowBuy,OBJPROP_ARROWCODE,234);                //设置箭头代码    
      ObjectSetDouble(0,ArrowBuy,OBJPROP_PRICE,low_m5[1] - 10*Point());  //预定价格 
      ChartRedraw(0);  //绘制箭头
   }
   if(orderType == "BUY")
   {
      ObjectCreate(0,ArrowSELL,OBJ_ARROW,0,0,0,0,0);                      //创建一个箭头 
      ObjectSetInteger(0,ArrowSELL,OBJPROP_TIME,OPEN_TIME);               //设置时间 
      ObjectSetInteger(0,ArrowSELL,OBJPROP_COLOR, clrRed);                //设置箭头颜色
      ObjectSetInteger(0,ArrowSELL,OBJPROP_ARROWCODE,233);                //设置箭头代码    
      ObjectSetDouble(0,ArrowSELL,OBJPROP_PRICE,high_m5[1] + 10*Point()); //预定价格 
      ChartRedraw(0);  //绘制箭头
   }
}
//+------------------------------------------------------------------+
//|  移动止损触发器                                                  |
//+------------------------------------------------------------------+
void TrailingStop()
{
   //初始化必要的账户、市场、仓位等信息变量
   
   //做多持仓时

   //做空持仓时

} 

//=========================== 程序的最后一行==========================


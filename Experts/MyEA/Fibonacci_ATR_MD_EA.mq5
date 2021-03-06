#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <MyClass\shuju.mqh>
ShuJu shuju;
#include <MyClass\交易类\信息类.mqh>
仓位信息 cw;
#include <MyClass\交易类\交易指令.mqh>
交易指令 jy;

double lots = 0.01;
int sl = 1000;
int tp = 1000;
int deviation = 3;
int magic_MD = 8888;
string commBuy = "BUY";
string commSell = "SELL";

double 最大手数 = 0.21; // 0.21 = 追单8次 | 2.33 = 追单9次
int 追单阈值 = tp;
int 计数器 = 0;
double 斐波那契 = 0;

datetime 开盘时间 = 0;
datetime openTime[];

input int ATR_MA = 20;
double ATRMA[];

double openLots = 0.0;
double openPrice = 0.0;
double openSXF = 0.0; 

string 客户端全局变量名称;
int 客户端全局变量初始化 = 1;

int OnInit()
{
   //客户端全局变量名称 = EA名称 + 货币对名称 + Magic自定义编码名称（使客户端全局变量不与其他EA的客户端全局变量混淆）
   客户端全局变量名称 = MQLInfoString(MQL_PROGRAM_NAME) + Symbol() + IntegerToString(magic_MD);
   if(GlobalVariableCheck(客户端全局变量名称 + "计数器") == false)
   {
      GlobalVariableSet(客户端全局变量名称 + "计数器", 客户端全局变量初始化);
   }
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{

}

void OnTick()
{
   shuju.gettime(openTime, 4);

   shuju.MA(KMA, 3, Symbol(), PERIOD_CURRENT, kma, 0, MODE_EMA, PRICE_CLOSE);  
   shuju.MA(MMA, 3, Symbol(), PERIOD_CURRENT, mma, 0, MODE_EMA, PRICE_CLOSE);  
   
   int OrderNumber_BUY = cw.OrderNumber(Symbol(), 0, magic_MD);
   int OrderNumber_SELL = cw.OrderNumber(Symbol(), 1, magic_MD);
   
   ulong orderID = cw.OrderZJLS(Symbol(), openLots, openPrice, openSXF);
   

   if(OrderNumber_BUY == 0 && OrderNumber_SELL == 0)
   {  
      //做多条件(EMA金叉)  
      if(KMA[2] < MMA[2] && KMA[1] > MMA[1])
      {
         //如果历史订单有盈利，下单量 = 最小手数(Lots)
         if(openPrice-openSXF >= 0 || openLots == 最大手数)
         {
            //初始化客户端全局变量——计数器
            if(GlobalVariableCheck(客户端全局变量名称 + "计数器") == true)
            {
               GlobalVariableSet(客户端全局变量名称 + "计数器", 客户端全局变量初始化);
            }
            //开单
            if(jy.OrderOpen(Symbol(), ORDER_TYPE_BUY, lots, sl, tp, commBuy, magic_MD, deviation)>0)
            {
               jy.OrderModify(Symbol(), POSITION_TYPE_BUY, 0, 0, magic_MD);
            }           
         }
         //如果历史订单亏损，下单量 = 最近亏损单量 * 2
         if(openPrice-openSXF < 0 && openLots < 最大手数)
         {
            //获取客户端全局变量的值
            计数器 = GetUpdata();
            斐波那契 = Fibonacci(计数器);
            
            if(jy.OrderOpen(Symbol(), ORDER_TYPE_BUY, 斐波那契 * 0.01, sl, tp, commBuy, magic_MD, deviation)>0)
            {
               jy.OrderModify(Symbol(), POSITION_TYPE_BUY, 0, 0, magic_MD);
            }
         }  
      }
      //做空条件(EMA死叉)
      if(KMA[2] > MMA[2] && KMA[1] < MMA[1])
      {
         //如果历史订单有盈利，下单量 = 最小手数(Lots)
         if(openPrice-openSXF >= 0 || openLots == 最大手数)
         {
            //初始化客户端全局变量——计数器
            if(GlobalVariableCheck(客户端全局变量名称 + "计数器") == true)
            {
               GlobalVariableSet(客户端全局变量名称 + "计数器", 客户端全局变量初始化);
            }
            //开单
            if(jy.OrderOpen(Symbol(), ORDER_TYPE_SELL, lots, sl, tp, commSell, magic_MD, deviation)>0)
            {
               jy.OrderModify(Symbol(), POSITION_TYPE_SELL, 0, 0, magic_MD);
            }
         }
         //如果历史订单亏损，下单量 = 最近亏损单量 * 2
         if(openPrice-openSXF < 0 && openLots < 最大手数)
         {
            //获取客户端全局变量的值
            计数器 = GetUpdata();
            斐波那契 = Fibonacci(计数器);
            
            //if(jy.OrderOpen(Symbol(), ORDER_TYPE_SELL, openLots*2, sl, tp, commBuy, magic_MD, deviation)>0)
            if(jy.OrderOpen(Symbol(), ORDER_TYPE_SELL, 斐波那契 * 0.01, sl, tp, commSell, magic_MD, deviation)>0)
            {
               jy.OrderModify(Symbol(), POSITION_TYPE_SELL, 0, 0, magic_MD);
            } 
         }  
      }  
   }  
   
   //平仓
   if(开盘时间 != openTime[0])
   {  
      if(OrderNumber_BUY > 0 || OrderNumber_SELL > 0)
      {
         if(KMA[0] < MMA[0])
         {
            jy.OrderClose(Symbol(), ORDER_TYPE_BUY, deviation, magic_MD);
         }
         if(KMA[0] > MMA[0])
         {
            jy.OrderClose(Symbol(), ORDER_TYPE_SELL, deviation, magic_MD);
         }
      }
      
      开盘时间 = openTime[0];
   }

}

//生成斐波那契数的函数
int Fibonacci(int n)
{
    if(n<0)
    {
        return 0;
    }

    if(n == 0 || n==1)
    {
        return n;
    }

    int num1 = 0, num2 = 1;
    
    for(int i=2; i<=n; i++){
        num2 = num1+num2;
        num1 = num2-num1;
    }
    
    return num2;
}

int GetUpdata()
{
   //获取客户端全局变量的值
   int counter = int(GlobalVariableGet(客户端全局变量名称 + "计数器")) + 1;
   
   //更新客户端全局变量——计数器的值
   if(GlobalVariableCheck(客户端全局变量名称 + "计数器") == true)
   {
      GlobalVariableSet(客户端全局变量名称 + "计数器", counter);
   }
   
   return counter;
}
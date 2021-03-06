#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <MyClass\shuju.mqh>
ShuJu shuju;
#include <MyClass\交易类\仓位信息.mqh>
仓位信息 cw;
#include <MyClass\交易类\交易指令.mqh>
交易指令 jy;

input string 交易品种名称 = "EURUSD";
input ENUM_TIMEFRAMES 图表周期 = PERIOD_CURRENT;

datetime 开盘时间 = 0;
datetime openTime[];
double openPrice[];

input int 获利目标 = 1;
int 奖励值 = 0;

double lots = 0.01;
int sl = 1000;
int tp = 1000;
int deviation = 5;
int magic_SGJ = 888888;
string commBuy = "BUY";
string commSell = "SELL";


int OnInit()
{
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{

}

void OnTick()
{ 
   //获取当前k线开盘时间
   shuju.gettime(openTime, 1, 交易品种名称, 图表周期);
   
   if(开盘时间 != openTime[0])
   {
      /*
      //获取账户基本信息
      double  余额 = AccountInfoDouble(ACCOUNT_BALANCE);
      double  净值 = AccountInfoDouble(ACCOUNT_EQUITY);
      double  预付款 = AccountInfoDouble(ACCOUNT_MARGIN);
      double  可用预付款 = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
      //预付款比例到达20%以下爆仓
      double 预付款比例 = AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);    
      */  
      奖励值 = ActioGo(); 
      //如果是一根新的K线就调用SaveFile函数，把数据写入文件
      SaveFile(openTime[0], 奖励值);    
      开盘时间 = openTime[0]; 
   }  

}

//保存数据到文件
void SaveFile(datetime 新的开盘时间, int 奖励)
{
   string FileName = 交易品种名称 + "_" + string(图表周期) + ".csv";
   //获取当前K线开盘价格
   shuju.getopen(openPrice, 1); 
   //获取已开仓订单数量
   int orderNumber_Buy = cw.OrderNumber(Symbol(), 0, magic_SGJ);
   int orderNumber_Sell = cw.OrderNumber(Symbol(), 1, magic_SGJ);
   //以读写方式打开文件(如果没有此文件将创建此文件)
   int SaveData = FileOpen(FileName, FILE_READ|FILE_WRITE|FILE_SHARE_READ|FILE_CSV|FILE_ANSI, ",");
   //判断文件是否正确打开
   if(SaveData != INVALID_HANDLE)
   {
      //当奖励值为100并且空仓状态，说明回合结束。把价格状态设为0
      if(奖励 == 100 && orderNumber_Buy == 0 && orderNumber_Sell == 0)
      {
         openPrice[0] = 0;
      }
      //把开盘时间和开盘价格写入文件
      FileWrite(SaveData, 新的开盘时间, openPrice[0], 奖励, orderNumber_Buy, orderNumber_Sell);
      //关闭文件
      FileClose(SaveData);
      //写入文件成功的提示
      printf("保存成功，数据已写入文件！");
   }
   else
   {
      printf("数据保存失败！");
   }
} 

//动作指令监听器(根据动作转变状态)
string Action()
{
   //初始化一个接收动作指令的变量action,值为：“空”
   string action = "";
   
   //以只读方式打开动作指令文件
   int 文件句柄 = FileOpen("action.csv", FILE_READ|FILE_SHARE_READ|FILE_CSV|FILE_ANSI, ",");
   
   //判断文件是否存在
   if(文件句柄 != INVALID_HANDLE)
   {
      //如果文件存在，读取动作指令
      action = FileReadString(文件句柄);
      //关闭文件
      FileClose(文件句柄);
      //读取动作指令后删除文件
      FileDelete("action.csv");
   }
   else
   {
      //如果没有找到文件，则动作指令的值为：“空”
      action = "";
      printf("动作指令文件未找到！");
   }
   //返回动作指令
   return action;
}

//根据行动指令采取行动,并返回奖励值
int ActioGo()
{
   //获取行动指令
   int action = int(Action());
   //初始化奖励值
   int 奖励 = 0;
   
   //根据不同的指令执行不同的动作
   if(action != 0)
   {
      //获取已开仓订单数量
      int orderNumber_Buy = cw.OrderNumber(Symbol(), 0, magic_SGJ);
      int orderNumber_Sell = cw.OrderNumber(Symbol(), 1, magic_SGJ); 
      //获取账户基本信息
      double  余额 = AccountInfoDouble(ACCOUNT_BALANCE);
      double  净值 = AccountInfoDouble(ACCOUNT_EQUITY);   
      
      //action=1 开单做多
      if(action == 1)
      {  //action=1 开单做多
         if(orderNumber_Buy == 0)
         {
            if(jy.OrderOpen(交易品种名称, 0, lots, sl, tp, commBuy, magic_SGJ, deviation) > 0)
            {
               奖励 = -1;
            }
         }
         else
         {
            if(jy.OrderOpen(交易品种名称, 0, lots, sl, tp, IntegerToString(orderNumber_Buy) + "_" + commBuy, magic_SGJ, deviation) > 0)
            {
               奖励 = -1;
            }
         }
      }
      
      //action=-1 开单做空
      if(action == 2)
      {  
         if(orderNumber_Sell == 0)
         {
            if(jy.OrderOpen(交易品种名称, 1, lots, sl, tp, commSell, magic_SGJ, deviation) > 0)
            {
               奖励 = -1;
            }
         }
         else
         {
            if(jy.OrderOpen(交易品种名称, 1, lots, sl, tp, IntegerToString(orderNumber_Sell) + "_" + commSell, magic_SGJ, deviation) > 0)
            {
               奖励 = -1;
            }
         }
      }
      
      //action=2 对做多订单平仓
      if(action == -1)
      {  
         double 平仓前余额 = 余额;
         jy.OrderClose(交易品种名称, 0, deviation, magic_SGJ);
         double 平仓后余额 = AccountInfoDouble(ACCOUNT_BALANCE);
         if(平仓后余额 - 平仓前余额 < 0)
         {
            奖励 = -100;
         }
         else if(平仓后余额 - 平仓前余额 > 0 && 平仓后余额 - 平仓前余额 < 获利目标)
         {
            奖励 = 0;
         }
         else
         {
            奖励 = 100;
         }
      }
      
      //action=-2 对做空订单平仓
      if(action == -2)
      {  
         double 平仓前余额 = 余额;
         jy.OrderClose(交易品种名称, 1, deviation, magic_SGJ);
         double 平仓后余额 = AccountInfoDouble(ACCOUNT_BALANCE);
         if(平仓后余额 - 平仓前余额 < 0)
         {
            奖励 = -100;
         }
         else if(平仓后余额 - 平仓前余额 > 0 && 平仓后余额 - 平仓前余额 < 获利目标)
         {
            奖励 = 0;
         }
         else
         {
            奖励 = 100;
         }
      }
      
      //action=-3 对所有订单平仓
      if(action == -3)
      {    
         if(净值 - 余额 < 0)
         {
            奖励 = -100;
         }
         else if(净值 - 余额 > 0 && 净值 - 余额 < 获利目标 )
         {
            奖励 = 0;
         }
         else
         {
            奖励 = 100;
         }
         
         jy.OrderClose(交易品种名称, 0, deviation, magic_SGJ);
         jy.OrderClose(交易品种名称, 1, deviation, magic_SGJ);
      }
   }
   return 奖励;
}
#property copyright "神经网络 v1.0（运行在1小时图）"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

/*
   网格交易系统（运行在1小时图）
   0.N = ATR（20）指标
   1.价格在120日均线以上，每上涨指定“网格宽度=0.9N”做多一单
   2.价格在120日均线一下，每下跌指定“网格宽度=0.9N”做空一单
   3.下单量:0.01手
   4.多空止损均为4N的移动止损
*/

#include <MyClass\JiaoYi_Class.mqh>
#include <MyClass\shuju.mqh>
JiaoYi jiaoyi;
ShuJu data;

input double lots = 0.01; //下单量
int sl = 200;
int tp = 200;
int deviation = 10;
string commBuy = "BUY";
string commSell = "SELL";
int magic_NN = 668;

datetime 开单时间 = 0;

//初始化神经网络第一隐藏层的权重
input double w1_0 = -1.0;
input double w1_1 = -1.0;
input double w1_2 = -1.0;
input double w1_3 = -1.0;
input double w1_4 = -1.0;
input double w1_5 = -1.0;
input double w1_6 = -1.0;
input double w1_7 = -1.0;
input double w1_8 = -1.0;
input double w1_9 = -1.0;
//初始化神经网络第二隐藏层的权重
input double w2_0 = -1.0;
input double w2_1 = -1.0;
input double w2_2 = -1.0;
input double w2_3 = -1.0;
input double w2_4 = -1.0;

double inputs[10];
double outputs = 0;
double x_input[10];
double weight_1[10];
double weight_2[5];

int OnInit()
{
   //初始化权重
   weight_1[0] = w1_0;
   weight_1[1] = w1_1;
   weight_1[2] = w1_2;
   weight_1[3] = w1_3;
   weight_1[4] = w1_4;
   weight_1[5] = w1_5;
   weight_1[6] = w1_6;
   weight_1[7] = w1_7;
   weight_1[8] = w1_8;
   weight_1[9] = w1_9;

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{

}

void OnTick()
{  
   if(开单时间 != Time[0])
   {
      zhengTaiHua(10,inputs);
      outputs = CalculateNeuron(inputs,weight_1);
      //printf("ma:" +outputs);
      if(outputs >= 0.5)
      {
         jiaoyi.Buy(Symbol(),lots,deviation,sl,tp,commBuy,magic_NN);
      }
      if(outputs < 0.5)
      {
         jiaoyi.Sell(Symbol(),lots,deviation,sl,tp,commBuy,magic_NN);
      }
      开单时间 = Time[0];
   }
   
   

//------------------------------------------做多------------------------------------------   

//------------------------------------------做空------------------------------------------

//------------------------------------------平仓------------------------------------------

//------------------------------------------结束------------------------------------------
}

void zhengTaiHua(int x_Number,double &x[])
{
   double d1 = 0.0;
   double d2 = 1.0;
   
   for(int i=x_Number-1; i>=0; i--)
   {
      x_input[i] = Close[i];
   }
   
   double x_min = x_input[ArrayMinimum(x_input)];
   double x_max = x_input[ArrayMaximum(x_input)];
   //printf("最高价："+x_max+" 最低价："+x_min);
   for(int i=0;i<ArraySize(x_input);i++)
   {
      x[i]=(((x_input[i]-x_min)*(d2-d1))/(x_max-x_min))+d1;
   }  
}

double CalculateNeuron(double &x[],double &w[])
{
   double NET=0.0;
   for(int n=0;n<ArraySize(x);n++)
   {
      NET+=x[n]*w[n];
   }
   NET*=0.4;
   return(ActivateNeuron(NET));
}

double ActivateNeuron(double x)
{
   double Out;
   Out=1/(1+exp(-x));
   return(Out);
}
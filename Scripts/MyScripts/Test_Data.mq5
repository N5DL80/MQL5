#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <MyClass\shuju.mqh>
ShuJu shuju;

void OnStart()
{ 
   string FileName = Symbol()+ "_" + "M15" + ".txt";
   MqlRates rate[];
   shuju.getrates(rate, 11);
   
   string highData;
   string openData;
   string lowData;
   string closeData;
   
   string timeData;
   datetime openTime[];
   shuju.gettime(openTime, ArraySize(rate), Symbol(), PERIOD_CURRENT);
   
   string OBV_Data;
   double OBV[];
   shuju.OBV(OBV, ArraySize(rate), Symbol(), PERIOD_CURRENT,VOLUME_TICK);
   
   string RSI_Data;
   double RSI[];
   shuju.RSI(RSI, ArraySize(rate), Symbol(), PERIOD_CURRENT, 14, PRICE_CLOSE);
   
   string CCI_Data;
   double CCI[];  
   shuju.CCI(CCI, ArraySize(rate), Symbol(), PERIOD_CURRENT, 14, PRICE_TYPICAL);
   
   int TestData = FileOpen(FileName,FILE_READ|FILE_WRITE|FILE_SHARE_READ|FILE_TXT|FILE_ANSI," ");
   
   if(TestData != INVALID_HANDLE)
   {
      for(int i=1;i<ArraySize(rate);i++)
      {
         highData = DoubleToString(rate[i].high,5);    
         openData = DoubleToString(rate[i].open,5);
         lowData = DoubleToString(rate[i].low,5);
         closeData = DoubleToString(rate[i].close,5); 
         
         timeData = string(openTime[i]);
         OBV_Data = string(OBV[i]);
         RSI_Data = DoubleToString(RSI[i], 2);
         CCI_Data = DoubleToString(CCI[i], 2);
         
         //写入文件
         FileWrite(TestData, timeData, openData, highData, lowData, OBV_Data, RSI_Data, CCI_Data, closeData);
      }
      FileClose(TestData);
      printf("文件已写入！");
   }
   else
   {
      printf("文件写入失败！");
   }
}


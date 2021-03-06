//+------------------------------------------------------------------+
//|                                                   PivotPoint.mq5 |
//|                                                  33041328@qq.com |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "33041328@qq.com"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots   7

input int ma = 1;  //计算轴心点的平均周期
input ENUM_TIMEFRAMES TimeFrames = PERIOD_D1;

//--- plot 阻力位3
#property indicator_label1  "阻力位3"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrAqua
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot 阻力位2
#property indicator_label2  "阻力位2"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrAqua
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot 阻力位1
#property indicator_label3  "阻力位1"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrAqua
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot PivotPoint
#property indicator_label4  "PivotPoint"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrGreenYellow
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- plot 支撑位1
#property indicator_label5  "支撑位1"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrGold
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- plot 支撑位2
#property indicator_label6  "支撑位2"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrGold
#property indicator_style6  STYLE_SOLID
#property indicator_width6  1
//--- plot 支撑位3
#property indicator_label7  "支撑位3"
#property indicator_type7   DRAW_LINE
#property indicator_color7  clrGold
#property indicator_style7  STYLE_SOLID
#property indicator_width7  1
//--- indicator buffers
double         阻力位3Buffer[];
double         阻力位2Buffer[];
double         阻力位1Buffer[];
double         PivotPointBuffer[];
double         支撑位1Buffer[];
double         支撑位2Buffer[];
double         支撑位3Buffer[];

datetime inputTime[];
double High[];
double Low[];
double Close[];

int high_h = 0;
int low_h = 0;
int close_h = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- indicator buffers mapping
   SetIndexBuffer(0,阻力位3Buffer,INDICATOR_DATA);
   SetIndexBuffer(1,阻力位2Buffer,INDICATOR_DATA);
   SetIndexBuffer(2,阻力位1Buffer,INDICATOR_DATA);
   SetIndexBuffer(3,PivotPointBuffer,INDICATOR_DATA);
   SetIndexBuffer(4,支撑位1Buffer,INDICATOR_DATA);
   SetIndexBuffer(5,支撑位2Buffer,INDICATOR_DATA);
   SetIndexBuffer(6,支撑位3Buffer,INDICATOR_DATA);
   
   //倒序排列
   ArraySetAsSeries(阻力位3Buffer, true);
   ArraySetAsSeries(阻力位2Buffer, true);
   ArraySetAsSeries(阻力位1Buffer, true);
   ArraySetAsSeries(PivotPointBuffer, true);
   ArraySetAsSeries(支撑位1Buffer, true);
   ArraySetAsSeries(支撑位2Buffer, true);
   ArraySetAsSeries(支撑位3Buffer, true);
   
   ArraySetAsSeries(inputTime, true);
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);
   ArraySetAsSeries(Close,true);
   
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   //倒序排列
   ArraySetAsSeries(high,  true);
   ArraySetAsSeries(open,  true);
   ArraySetAsSeries(low,   true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(time,  true);
   
   //获取指定时间周期的开盘时间
   CopyTime(Symbol(), TimeFrames, 1, 1000, inputTime);
   //获取指定时间周期的高开低收价格
   CopyHigh(Symbol(),TimeFrames, 1, 1000, High);
   CopyLow(Symbol(),TimeFrames, 1, 1000, Low);
   CopyClose(Symbol(),TimeFrames, 1, 1000, Close);

   //节省算力，每一根新的K线生成后计算当前和前一根K线
   int new_rates_total = 0;
   if(prev_calculated == 0)
   {
      new_rates_total = 3000;
   }
   else
   {
      new_rates_total = 3000 - prev_calculated + 1;
   }
   
   //high[ArrayMaximum(high, i, ma)]; //10条k线的最高价
   int y = 0;

   
   for(int i=0; i<3000; i++)
   {
      if(time[i] < inputTime[y])
      {
         y++;
      }
      /*
      PivotPointBuffer[i] = (high[ArrayMaximum(high, i, ma)] + low[ArrayMaximum(low, i, ma)] + close[ArrayMaximum(close, i, ma)])/3;
      阻力位3Buffer[i] = high[ArrayMaximum(high, i, ma)] + 2 * (PivotPointBuffer[i] - low[ArrayMaximum(low, i, ma)]);
      阻力位2Buffer[i] = PivotPointBuffer[i] + high[ArrayMaximum(high, i, ma)] - low[ArrayMaximum(low, i, ma)];
      阻力位1Buffer[i] = 2 * PivotPointBuffer[i] - low[ArrayMaximum(low, i, ma)];
      
      支撑位1Buffer[i] = 2 * PivotPointBuffer[i] - high[ArrayMaximum(high, i, ma)];
      支撑位2Buffer[i] = PivotPointBuffer[i] - (high[ArrayMaximum(high, i, ma)] - low[ArrayMaximum(low, i, ma)]);
      支撑位3Buffer[i] = low[ArrayMaximum(low, i, ma)] - 2 * (high[ArrayMaximum(high, i, ma)] - PivotPointBuffer[i]);
      */
      PivotPointBuffer[i] = (High[y] + Low[y] + Close[y])/3;
      阻力位3Buffer[i] = High[y] + 2 * (PivotPointBuffer[i] - Low[y]);
      阻力位2Buffer[i] = PivotPointBuffer[i] + High[y] - Low[y];
      阻力位1Buffer[i] = 2 * PivotPointBuffer[i] - Low[y];
      
      支撑位1Buffer[i] = 2 * PivotPointBuffer[i] - High[y];
      支撑位2Buffer[i] = PivotPointBuffer[i] - (High[y] - Low[y]);
      支撑位3Buffer[i] = Low[y] - 2 * (High[y] - PivotPointBuffer[i]);
   }

   //--- return value of prev_calculated for next call
   return(rates_total);
}


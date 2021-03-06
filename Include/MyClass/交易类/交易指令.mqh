//有关订单操作的类
class 交易指令
{
   public:
   ulong OrderOpen(const string 交易品种,const ENUM_ORDER_TYPE 开仓类型,const double 开仓数量,const int 止损,const int 止盈,const string 注释,const int 自定义编号,const int 允许滑点);   
   void OrderModify(const string 交易品种,const ENUM_POSITION_TYPE 开仓类型,const double 止损,const double 止盈,const int 自定义编号);
   void OrderClose(const string 交易品种, const ENUM_ORDER_TYPE 平仓类型, const int 允许滑点, const int 自定义编号);
   void OrderClose(const string 交易品种, const int 允许滑点, const int 自定义编号);
};

//------------------------------------------开单------------------------------------------
ulong 交易指令::OrderOpen(const string 交易品种,const ENUM_ORDER_TYPE 开仓类型,const double 开仓数量,const int 止损,const int 止盈,const string 注释,const int 自定义编号,const int 允许滑点)
{
   int 是否开仓 = 0;     //1已开仓，0未开仓
   ulong 订单号码 = 0; 
   
   int 已开仓订单总数=PositionsTotal();
   for(int i=已开仓订单总数-1;i>=0;i--)
   {
      if(PositionGetTicket(i)>0)
      {
         if(PositionGetString(POSITION_SYMBOL)==交易品种 && PositionGetInteger(POSITION_TYPE)==开仓类型 && PositionGetInteger(POSITION_MAGIC)==自定义编号 && PositionGetString(POSITION_COMMENT)==注释)
         {
            是否开仓=1;
            return(0);
         }
      }    
   }
   if(是否开仓 == 0)
      {
         MqlTradeRequest request={0}; 
         MqlTradeResult  result={0};
         request.action=TRADE_ACTION_DEAL;
         request.symbol=交易品种;
         request.type=开仓类型;
         request.volume=开仓数量;
         request.comment=注释;
         request.magic=自定义编号;
         request.deviation=允许滑点;
         if(开仓类型 == ORDER_TYPE_BUY)    //根据开仓类型决定开单方向（以当前市价做多）
         {
            request.price=SymbolInfoDouble(交易品种,SYMBOL_ASK);
            request.sl=SymbolInfoDouble(交易品种,SYMBOL_ASK)-止损*Point();
            request.tp=SymbolInfoDouble(交易品种,SYMBOL_ASK)+止盈*Point();
         }
         if(开仓类型 == ORDER_TYPE_SELL)   //根据开仓类型决定开单方向（以当前市价做空）
         {
            request.price=SymbolInfoDouble(交易品种,SYMBOL_BID);
            request.sl=SymbolInfoDouble(交易品种,SYMBOL_BID)+止损*Point();
            request.tp=SymbolInfoDouble(交易品种,SYMBOL_BID)-止盈*Point();
         }
         
         if(!OrderSend(request,result))
         {
            if(开仓类型 == ORDER_TYPE_BUY)
            {
               PrintFormat("BUY开仓错误 %d",GetLastError());
            }
            if(开仓类型 == ORDER_TYPE_SELL)
            {
               PrintFormat("SELL开仓错误 %d",GetLastError());
            }
         }
         PrintFormat("交易服务器的返回代码=%u  交易序号=%I64u  订单序号=%I64u",result.retcode,result.deal,result.order);
         订单号码=result.order;
      }
   return(订单号码);
}

//------------------------------------------改单------------------------------------------

void 交易指令::OrderModify(const string 交易品种,const ENUM_POSITION_TYPE 开仓类型,const double 止损,const double 止盈,const int 自定义编号=0)
{
   Sleep(500); //暂停500毫秒后执行(不然服务器ping值高的话，修改会失败)
   int t=PositionsTotal();
   for(int i=t-1;i>=0;i--)
     {
       if(PositionGetTicket(i)>0)
        {
          if(PositionGetString(POSITION_SYMBOL)==交易品种)
           {
             if(开仓类型==POSITION_TYPE_BUY)
              {
                if(自定义编号==0)
                 {
                     if((NormalizeDouble(止损,(int)SymbolInfoInteger(交易品种,SYMBOL_DIGITS))!=NormalizeDouble(PositionGetDouble(POSITION_SL),(int)SymbolInfoInteger(交易品种,SYMBOL_DIGITS))||NormalizeDouble(止盈,(int)SymbolInfoInteger(交易品种,SYMBOL_DIGITS))!=NormalizeDouble(PositionGetDouble(POSITION_TP),(int)SymbolInfoInteger(交易品种,SYMBOL_DIGITS))))
                     {
                         MqlTradeRequest request={0};
                         MqlTradeResult  result={0};
                         request.action=TRADE_ACTION_SLTP;
                         request.position=PositionGetTicket(i);
                         request.symbol=交易品种;
                         request.sl=NormalizeDouble(止损,(int)SymbolInfoInteger(交易品种,SYMBOL_DIGITS));
                         request.tp=NormalizeDouble(止盈,(int)SymbolInfoInteger(交易品种,SYMBOL_DIGITS));
                         if(止损<0) request.sl=NormalizeDouble(PositionGetDouble(POSITION_SL),(int)SymbolInfoInteger(交易品种,SYMBOL_DIGITS));
                         if(止盈<0) request.tp=NormalizeDouble(PositionGetDouble(POSITION_TP),(int)SymbolInfoInteger(交易品种,SYMBOL_DIGITS));
                         if(!OrderSend(request,result))
                         {
                            PrintFormat("BUY单止损止盈修改错误代码： %d",GetLastError()); 
                         }
                      }
                 }
                else
                 {
                    if(PositionGetInteger(POSITION_MAGIC)==自定义编号)
                    {
                        if((NormalizeDouble(止损,(int)SymbolInfoInteger(交易品种,SYMBOL_DIGITS))!=NormalizeDouble(PositionGetDouble(POSITION_SL),(int)SymbolInfoInteger(交易品种,SYMBOL_DIGITS))||NormalizeDouble(止盈,(int)SymbolInfoInteger(交易品种,SYMBOL_DIGITS))!=NormalizeDouble(PositionGetDouble(POSITION_TP),(int)SymbolInfoInteger(交易品种,SYMBOL_DIGITS))))
                         {
                             MqlTradeRequest request={0};
                             MqlTradeResult  result={0};
                             request.action=TRADE_ACTION_SLTP;
                             request.position=PositionGetTicket(i);
                             request.symbol=交易品种;
                             request.sl=NormalizeDouble(止损,(int)SymbolInfoInteger(交易品种,SYMBOL_DIGITS));
                             request.tp=NormalizeDouble(止盈,(int)SymbolInfoInteger(交易品种,SYMBOL_DIGITS));
                             if(止损<0) request.sl=NormalizeDouble(PositionGetDouble(POSITION_SL),(int)SymbolInfoInteger(交易品种,SYMBOL_DIGITS));
                             if(止盈<0) request.tp=NormalizeDouble(PositionGetDouble(POSITION_TP),(int)SymbolInfoInteger(交易品种,SYMBOL_DIGITS));
                             if(!OrderSend(request,result))
                             {
                                 PrintFormat("BUY单止损止盈修改错误代码： %d",GetLastError()); 
                             }
                         }
                    }
                 }
              }
              if(开仓类型==POSITION_TYPE_SELL)
              {
                 if(自定义编号==0)
                  {
                     if((NormalizeDouble(止损,(int)SymbolInfoInteger(交易品种,SYMBOL_DIGITS))!=NormalizeDouble(PositionGetDouble(POSITION_SL),(int)SymbolInfoInteger(交易品种,SYMBOL_DIGITS))||NormalizeDouble(止盈,(int)SymbolInfoInteger(交易品种,SYMBOL_DIGITS))!=NormalizeDouble(PositionGetDouble(POSITION_TP),(int)SymbolInfoInteger(交易品种,SYMBOL_DIGITS))))
                      {
                          MqlTradeRequest request={0};
                          MqlTradeResult  result={0};
                          request.action=TRADE_ACTION_SLTP;
                          request.position=PositionGetTicket(i);
                          request.symbol=交易品种;
                          request.sl=NormalizeDouble(止损,(int)SymbolInfoInteger(交易品种,SYMBOL_DIGITS));
                          request.tp=NormalizeDouble(止盈,(int)SymbolInfoInteger(交易品种,SYMBOL_DIGITS));
                          if(止损<0) request.sl=NormalizeDouble(PositionGetDouble(POSITION_SL),(int)SymbolInfoInteger(交易品种,SYMBOL_DIGITS));
                          if(止盈<0) request.tp=NormalizeDouble(PositionGetDouble(POSITION_TP),(int)SymbolInfoInteger(交易品种,SYMBOL_DIGITS));
                          if(!OrderSend(request,result))
                          {
                              PrintFormat("SELL单止损止盈修改错误代码： %d",GetLastError()); 
                          }
                      }
                 }
                else
                 {
                    if(PositionGetInteger(POSITION_MAGIC)==自定义编号)
                    {
                        if((NormalizeDouble(止损,(int)SymbolInfoInteger(交易品种,SYMBOL_DIGITS))!=NormalizeDouble(PositionGetDouble(POSITION_SL),(int)SymbolInfoInteger(交易品种,SYMBOL_DIGITS))||NormalizeDouble(止盈,(int)SymbolInfoInteger(交易品种,SYMBOL_DIGITS))!=NormalizeDouble(PositionGetDouble(POSITION_TP),(int)SymbolInfoInteger(交易品种,SYMBOL_DIGITS))))
                         {
                             MqlTradeRequest request={0};
                             MqlTradeResult  result={0};
                             request.action=TRADE_ACTION_SLTP;
                             request.position=PositionGetTicket(i);
                             request.symbol=交易品种;
                             request.sl=NormalizeDouble(止损,(int)SymbolInfoInteger(交易品种,SYMBOL_DIGITS));
                             request.tp=NormalizeDouble(止盈,(int)SymbolInfoInteger(交易品种,SYMBOL_DIGITS));
                             if(止损<0) request.sl=NormalizeDouble(PositionGetDouble(POSITION_SL),(int)SymbolInfoInteger(交易品种,SYMBOL_DIGITS));
                             if(止盈<0) request.tp=NormalizeDouble(PositionGetDouble(POSITION_TP),(int)SymbolInfoInteger(交易品种,SYMBOL_DIGITS));
                             if(!OrderSend(request,result))
                             {
                                 PrintFormat("SELL单止损止盈修改错误代码： %d",GetLastError()); 
                             }                         
                         }
                    }
                 }
              }
           } 
        }
     }
}

//------------------------------------------平仓------------------------------------------
void 交易指令::OrderClose(const string 交易品种, const ENUM_ORDER_TYPE 平仓类型, const int 允许滑点, const int 自定义编号)
{
   int saomiao=PositionsTotal();
   for(int i=saomiao-1;i>=0;i--)
   {
      if(PositionGetTicket(i)>0)
      {
         if(PositionGetString(POSITION_SYMBOL)==交易品种 && PositionGetInteger(POSITION_TYPE)==平仓类型 && PositionGetInteger(POSITION_MAGIC)==自定义编号)
         {
            MqlTradeRequest request={0}; 
            MqlTradeResult  result={0};
            request.action=TRADE_ACTION_DEAL;
            request.symbol=交易品种;
            request.position=PositionGetTicket(i);
            if(平仓类型 == ORDER_TYPE_BUY)
            {
               request.type=ORDER_TYPE_SELL;
               request.price=SymbolInfoDouble(交易品种,SYMBOL_BID);
            }
            if(平仓类型 == ORDER_TYPE_SELL)
            {
               request.type=ORDER_TYPE_BUY;
               request.price=SymbolInfoDouble(交易品种,SYMBOL_ASK);
            }
            request.volume=PositionGetDouble(POSITION_VOLUME);
            request.deviation=允许滑点;
            if(!OrderSend(request,result))
            {
               PrintFormat("平仓错误 %d",GetLastError());
            }
               
         }
      }
   }
}

//----------------------------------------平仓重载----------------------------------------
void 交易指令::OrderClose(const string 交易品种, const int 允许滑点, const int 自定义编号)
{
   int saomiao=PositionsTotal();
   for(int i=saomiao-1;i>=0;i--)
   {
      if(PositionGetTicket(i)>0)
      {
         if(PositionGetString(POSITION_SYMBOL)==交易品种 && PositionGetInteger(POSITION_MAGIC)==自定义编号)
         {
            MqlTradeRequest request={0}; 
            MqlTradeResult  result={0};
            request.action=TRADE_ACTION_DEAL;
            request.symbol=交易品种;
            request.position=PositionGetTicket(i);
            
            request.type=ORDER_TYPE_SELL;
            request.price=SymbolInfoDouble(交易品种,SYMBOL_BID);

            request.volume=PositionGetDouble(POSITION_VOLUME);
            request.deviation=允许滑点;
            if(!OrderSend(request,result))
            {
               PrintFormat("平仓错误 %d",GetLastError());
            }  
         }
      }
   }
}
//+------------------------------------------------------------------+
//| GBPUSD MT5 Trading Bot                                           |
//+------------------------------------------------------------------+
#property strict

#include <Trade/Trade.mqh>

CTrade trade;

input double LotSize = 0.01;
input int StopLossPips = 30;
input int TakeProfitPips = 60;
input int FastEMA = 20;
input int SlowEMA = 50;

int fastHandle;
int slowHandle;

int OnInit()
{
   fastHandle = iMA(_Symbol, PERIOD_M15, FastEMA, 0, MODE_EMA, PRICE_CLOSE);
   slowHandle = iMA(_Symbol, PERIOD_M15, SlowEMA, 0, MODE_EMA, PRICE_CLOSE);

   if(fastHandle == INVALID_HANDLE || slowHandle == INVALID_HANDLE)
      return(INIT_FAILED);

   return(INIT_SUCCEEDED);
}

void OnTick()
{
   if(_Symbol != "GBPUSD")
      return;

   if(PositionSelect(_Symbol))
      return;

   double fastEMA[2];
   double slowEMA[2];

   if(CopyBuffer(fastHandle, 0, 0, 2, fastEMA) < 2)
      return;

   if(CopyBuffer(slowHandle, 0, 0, 2, slowEMA) < 2)
      return;

   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);

   double pip = point * 10;

   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

   // BUY: Fast EMA crosses above Slow EMA
   if(fastEMA[1] <= slowEMA[1] && fastEMA[0] > slowEMA[0])
   {
      double sl = NormalizeDouble(ask - StopLossPips * pip, digits);
      double tp = NormalizeDouble(ask + TakeProfitPips * pip, digits);

      trade.Buy(LotSize, _Symbol, ask, sl, tp, "GBPUSD EMA BUY");
   }

   // SELL: Fast EMA crosses below Slow EMA
   if(fastEMA[1] >= slowEMA[1] && fastEMA[0] < slowEMA[0])
   {
      double sl = NormalizeDouble(bid + StopLossPips * pip, digits);
      double tp = NormalizeDouble(bid - TakeProfitPips * pip, digits);

      trade.Sell(LotSize, _Symbol, bid, sl, tp, "GBPUSD EMA SELL");
   }
}

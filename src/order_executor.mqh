//+------------------------------------------------------------------+
//| order_executor.mqh                                               |
//+------------------------------------------------------------------+
#property strict

#ifndef __TRADEBOT_ORDER_EXECUTOR_MQH__
#define __TRADEBOT_ORDER_EXECUTOR_MQH__

#include <Trade/Trade.mqh>
#include "../config/config.mqh"

class COrderExecutor
{
private:
   CTrade m_trade;

public:
   void Init()
   {
      m_trade.SetExpertMagicNumber(InpMagicNumber);
      m_trade.SetDeviationInPoints(20);
   }

   bool HasOpenPosition(const string symbol)
   {
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if(PositionSelectByTicket(ticket))
         {
            if(PositionGetString(POSITION_SYMBOL) == symbol && PositionGetInteger(POSITION_MAGIC) == InpMagicNumber)
               return true;
         }
      }
      return false;
   }

   bool Buy(const string symbol, const double volume, const double sl, const double tp, const string comment)
   {
      double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
      return m_trade.Buy(volume, symbol, ask, sl, tp, comment);
   }

   bool Sell(const string symbol, const double volume, const double sl, const double tp, const string comment)
   {
      double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
      return m_trade.Sell(volume, symbol, bid, sl, tp, comment);
   }

   void CloseAllPositions()
   {
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if(PositionSelectByTicket(ticket))
         {
            if(PositionGetInteger(POSITION_MAGIC) == InpMagicNumber)
               m_trade.PositionClose(ticket);
         }
      }
   }

   void ManageOpenPositions()
   {
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if(!PositionSelectByTicket(ticket))
            continue;

         if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber)
            continue;

         string symbol = PositionGetString(POSITION_SYMBOL);
         long type = PositionGetInteger(POSITION_TYPE);
         double current_sl = PositionGetDouble(POSITION_SL);
         double tp = PositionGetDouble(POSITION_TP);

         int atr_handle = iATR(symbol, PERIOD_CURRENT, InpATRPeriod);
         if(atr_handle == INVALID_HANDLE)
            continue;

         double atr[];
         ArraySetAsSeries(atr, true);
         if(CopyBuffer(atr_handle, 0, 0, 1, atr) < 1)
         {
            IndicatorRelease(atr_handle);
            continue;
         }
         IndicatorRelease(atr_handle);

         double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
         double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
         double trail = atr[0] * InpATRTrailMultiplier;

         if(type == POSITION_TYPE_BUY)
         {
            double new_sl = NormalizeDouble(bid - trail, (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS));
            if(new_sl > current_sl)
               m_trade.PositionModify(ticket, new_sl, tp);
         }
         else if(type == POSITION_TYPE_SELL)
         {
            double new_sl = NormalizeDouble(ask + trail, (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS));
            if(current_sl == 0.0 || new_sl < current_sl)
               m_trade.PositionModify(ticket, new_sl, tp);
         }
      }
   }
};

#endif

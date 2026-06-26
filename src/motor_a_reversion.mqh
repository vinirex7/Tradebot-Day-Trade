//+------------------------------------------------------------------+
//| motor_a_reversion.mqh                                            |
//+------------------------------------------------------------------+
#property strict

#ifndef __TRADEBOT_MOTOR_A_REVERSION_MQH__
#define __TRADEBOT_MOTOR_A_REVERSION_MQH__

#include "../config/config.mqh"
#include "risk_manager.mqh"
#include "order_executor.mqh"

class CMotorAReversion
{
private:
   int m_bb_period;
   double m_bb_deviation;
   int m_rsi_period;

public:
   void Init(const int bb_period, const double bb_deviation, const int rsi_period)
   {
      m_bb_period = bb_period;
      m_bb_deviation = bb_deviation;
      m_rsi_period = rsi_period;
   }

   void Execute(const string symbol, CRiskManager &risk, COrderExecutor &executor)
   {
      if(executor.HasOpenPosition(symbol))
         return;

      int bb_handle = iBands(symbol, PERIOD_CURRENT, m_bb_period, 0, m_bb_deviation, PRICE_CLOSE);
      int rsi_handle = iRSI(symbol, PERIOD_CURRENT, m_rsi_period, PRICE_CLOSE);
      int atr_handle = iATR(symbol, PERIOD_CURRENT, InpATRPeriod);

      if(bb_handle == INVALID_HANDLE || rsi_handle == INVALID_HANDLE || atr_handle == INVALID_HANDLE)
         return;

      double upper[], middle[], lower[], rsi[], atr[];
      ArraySetAsSeries(upper, true);
      ArraySetAsSeries(middle, true);
      ArraySetAsSeries(lower, true);
      ArraySetAsSeries(rsi, true);
      ArraySetAsSeries(atr, true);

      bool ok = CopyBuffer(bb_handle, 0, 0, 1, middle) >= 1 &&
                CopyBuffer(bb_handle, 1, 0, 1, upper) >= 1 &&
                CopyBuffer(bb_handle, 2, 0, 1, lower) >= 1 &&
                CopyBuffer(rsi_handle, 0, 0, 1, rsi) >= 1 &&
                CopyBuffer(atr_handle, 0, 0, 1, atr) >= 1;

      IndicatorRelease(bb_handle);
      IndicatorRelease(rsi_handle);
      IndicatorRelease(atr_handle);

      if(!ok)
         return;

      double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
      double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
      int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
      double stop_distance = atr[0] * InpATRStopMultiplier;
      double stop_points = stop_distance / SymbolInfoDouble(symbol, SYMBOL_POINT);
      double lot = risk.CalculateLot(symbol, stop_points);

      if(bid <= lower[0] && rsi[0] <= InpRSIOversold)
      {
         double sl = NormalizeDouble(ask - stop_distance, digits);
         double tp = NormalizeDouble(middle[0], digits);
         executor.Buy(symbol, lot, sl, tp, "MotorA_Reversion_Buy");
      }
      else if(ask >= upper[0] && rsi[0] >= InpRSIOverbought)
      {
         double sl = NormalizeDouble(bid + stop_distance, digits);
         double tp = NormalizeDouble(middle[0], digits);
         executor.Sell(symbol, lot, sl, tp, "MotorA_Reversion_Sell");
      }
   }
};

#endif

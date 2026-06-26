//+------------------------------------------------------------------+
//| motor_b_trend.mqh                                                |
//+------------------------------------------------------------------+
#property strict

#ifndef __TRADEBOT_MOTOR_B_TREND_MQH__
#define __TRADEBOT_MOTOR_B_TREND_MQH__

#include "../config/config.mqh"
#include "risk_manager.mqh"
#include "order_executor.mqh"
#include "symbol_specs.mqh"

class CMotorBTrend
{
private:
   int m_ema_period;

public:
   void Init(const int ema_period)
   {
      m_ema_period = ema_period;
   }

   void Execute(const string symbol, CRiskManager &risk, COrderExecutor &executor, CSymbolSpecs &specs)
   {
      if(executor.HasOpenPosition(symbol))
         return;

      int ema_handle = iMA(symbol, PERIOD_CURRENT, m_ema_period, 0, MODE_EMA, PRICE_CLOSE);
      int atr_handle = iATR(symbol, PERIOD_CURRENT, InpATRPeriod);
      if(ema_handle == INVALID_HANDLE || atr_handle == INVALID_HANDLE)
         return;

      double ema[], atr[];
      ArraySetAsSeries(ema, true);
      ArraySetAsSeries(atr, true);

      bool ok = CopyBuffer(ema_handle, 0, 0, 2, ema) >= 2 && CopyBuffer(atr_handle, 0, 0, 1, atr) >= 1;
      IndicatorRelease(ema_handle);
      IndicatorRelease(atr_handle);

      if(!ok)
         return;

      double close_1 = iClose(symbol, PERIOD_CURRENT, 1);
      double close_0 = iClose(symbol, PERIOD_CURRENT, 0);
      double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
      double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
      int digits = specs.Digits();

      double stop_distance = atr[0] * InpATRStopMultiplier;
      double stop_points = stop_distance / specs.Point();
      double lot = risk.CalculateLot(symbol, stop_points, specs);

      bool bullish_pullback = close_1 > ema[1] && close_0 <= ema[0] + atr[0] * 0.25 && close_0 >= ema[0] - atr[0] * 0.50;
      bool bearish_pullback = close_1 < ema[1] && close_0 >= ema[0] - atr[0] * 0.25 && close_0 <= ema[0] + atr[0] * 0.50;

      if(bullish_pullback)
      {
         double sl = NormalizeDouble(ask - stop_distance, digits);
         double tp = NormalizeDouble(ask + stop_distance * 2.0, digits);
         if(executor.Buy(symbol, lot, sl, tp, "MotorB_Trend_Buy"))
            risk.RegisterTrade();
      }
      else if(bearish_pullback)
      {
         double sl = NormalizeDouble(bid + stop_distance, digits);
         double tp = NormalizeDouble(bid - stop_distance * 2.0, digits);
         if(executor.Sell(symbol, lot, sl, tp, "MotorB_Trend_Sell"))
            risk.RegisterTrade();
      }
   }
};

#endif

//+------------------------------------------------------------------+
//| risk_manager.mqh                                                 |
//+------------------------------------------------------------------+
#property strict

#ifndef __TRADEBOT_RISK_MANAGER_MQH__
#define __TRADEBOT_RISK_MANAGER_MQH__

#include "../config/config.mqh"

class CRiskManager
{
private:
   double m_day_start_equity;
   int    m_day_of_year;

   int MinutesFromString(const string hhmm)
   {
      string parts[];
      if(StringSplit(hhmm, ':', parts) != 2)
         return 0;
      return (int)StringToInteger(parts[0]) * 60 + (int)StringToInteger(parts[1]);
   }

public:
   void Init()
   {
      MqlDateTime dt;
      TimeToStruct(TimeCurrent(), dt);
      m_day_of_year = dt.day_of_year;
      m_day_start_equity = AccountInfoDouble(ACCOUNT_EQUITY);
   }

   void RefreshDay()
   {
      MqlDateTime dt;
      TimeToStruct(TimeCurrent(), dt);
      if(dt.day_of_year != m_day_of_year)
      {
         m_day_of_year = dt.day_of_year;
         m_day_start_equity = AccountInfoDouble(ACCOUNT_EQUITY);
      }
   }

   bool ValidateAccount(const double balance)
   {
      return balance > 0.0 && AccountInfoInteger(ACCOUNT_TRADE_ALLOWED);
   }

   bool IsInsideTradingWindow()
   {
      MqlDateTime dt;
      TimeToStruct(TimeCurrent(), dt);
      int now = dt.hour * 60 + dt.min;
      return now >= MinutesFromString(InpStartTime) && now <= MinutesFromString(InpEndTime);
   }

   bool IsCloseAllTime()
   {
      MqlDateTime dt;
      TimeToStruct(TimeCurrent(), dt);
      int now = dt.hour * 60 + dt.min;
      return now >= MinutesFromString(InpCloseAllTime);
   }

   bool CheckDailyStop()
   {
      RefreshDay();
      double equity = AccountInfoDouble(ACCOUNT_EQUITY);
      double dd_pct = 100.0 * (m_day_start_equity - equity) / m_day_start_equity;
      return dd_pct >= InpMaxDailyLossPercent;
   }

   bool CheckDailyTarget()
   {
      RefreshDay();
      double equity = AccountInfoDouble(ACCOUNT_EQUITY);
      double gain_pct = 100.0 * (equity - m_day_start_equity) / m_day_start_equity;
      return gain_pct >= InpTargetDailyProfit;
   }

   bool IsTradingAllowed()
   {
      return IsInsideTradingWindow() && !CheckDailyStop() && !CheckDailyTarget();
   }

   double CalculateLot(const string symbol, const double stop_points)
   {
      double equity = AccountInfoDouble(ACCOUNT_EQUITY);
      double risk_money = equity * (InpRiskPerTradePercent / 100.0);
      double denominator = MathMax(stop_points * InpPointValue, 1.0);
      double lots = MathFloor(risk_money / denominator);

      double min_lot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
      double max_lot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
      double step    = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);

      lots = MathMax(min_lot, MathMin(max_lot, lots));
      if(step > 0.0)
         lots = MathFloor(lots / step) * step;

      return NormalizeDouble(lots, 2);
   }
};

#endif

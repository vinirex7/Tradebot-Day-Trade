//+------------------------------------------------------------------+
//| regime_classifier.mqh                                            |
//+------------------------------------------------------------------+
#property strict

#ifndef __TRADEBOT_REGIME_CLASSIFIER_MQH__
#define __TRADEBOT_REGIME_CLASSIFIER_MQH__

#include "../config/config.mqh"

class CRegimeClassifier
{
private:
   int m_adx_period;
   double m_threshold;

public:
   void Init(const int adx_period, const double threshold)
   {
      m_adx_period = adx_period;
      m_threshold = threshold;
   }

   ENUM_MARKET_REGIME DetectRegime(const string symbol)
   {
      int handle = iADX(symbol, InpRegimeTF, m_adx_period);
      if(handle == INVALID_HANDLE)
         return REGIME_UNKNOWN;

      double adx[];
      ArraySetAsSeries(adx, true);

      if(CopyBuffer(handle, 0, 0, 3, adx) < 3)
      {
         IndicatorRelease(handle);
         return REGIME_UNKNOWN;
      }

      IndicatorRelease(handle);

      if(adx[0] >= m_threshold && adx[0] > adx[1])
         return REGIME_TREND;

      if(adx[0] < m_threshold)
         return REGIME_CONSOLIDATION;

      return REGIME_UNKNOWN;
   }
};

#endif

//+------------------------------------------------------------------+
//| config.mqh                                                       |
//| Global inputs and shared enums                                   |
//+------------------------------------------------------------------+
#property strict

#ifndef __TRADEBOT_CONFIG_MQH__
#define __TRADEBOT_CONFIG_MQH__

enum ENUM_MARKET_REGIME
{
   REGIME_CONSOLIDATION = 0,
   REGIME_TREND = 1,
   REGIME_UNKNOWN = 2
};

input group "--- Risco ---"
input double InpMaxDailyLossPercent   = 2.0;
input double InpRiskPerTradePercent   = 0.5;
input double InpTargetDailyProfit     = 4.0;
input double InpPointValue            = 0.20;  // Ajustar conforme WIN/WDO/corretora
input int    InpMagicNumber           = 26062026;

input group "--- Classificador de Regime ---"
input int    InpADXPeriod             = 14;
input double InpADXThreshold          = 25.0;
input ENUM_TIMEFRAMES InpRegimeTF     = PERIOD_M15;

input group "--- Motor A: Reversao ---"
input int    InpBBPeriod              = 20;
input double InpBBDeviation           = 2.5;
input int    InpRSIPeriod             = 2;
input double InpRSIOverbought         = 90.0;
input double InpRSIOversold           = 10.0;

input group "--- Motor B: Tendencia ---"
input int    InpEMAPeriod             = 20;
input int    InpATRPeriod             = 14;
input double InpATRStopMultiplier     = 2.0;
input double InpATRTrailMultiplier    = 1.5;

input group "--- Horarios ---"
input string InpStartTime             = "09:30";
input string InpEndTime               = "16:30";
input string InpCloseAllTime          = "17:00";

#endif

//+------------------------------------------------------------------+
//| main.mq5                                                         |
//| Tradebot Day Trade - WIN/WDO Regime Switching                    |
//+------------------------------------------------------------------+
#property copyright "Vinicius Alcantara"
#property version   "1.00"
#property strict

#include "../config/config.mqh"
#include "logger.mqh"
#include "risk_manager.mqh"
#include "order_executor.mqh"
#include "regime_classifier.mqh"
#include "motor_a_reversion.mqh"
#include "motor_b_trend.mqh"

CLogger            logger;
CRiskManager       riskManager;
COrderExecutor     executor;
CRegimeClassifier  classifier;
CMotorAReversion   motorA;
CMotorBTrend       motorB;

datetime lastBarTime = 0;

bool IsNewBar()
{
   datetime currentBar = iTime(_Symbol, PERIOD_CURRENT, 0);
   if(currentBar != lastBarTime)
   {
      lastBarTime = currentBar;
      return true;
   }
   return false;
}

int OnInit()
{
   logger.Init();
   logger.Info("Iniciando Tradebot Day Trade WIN/WDO...");

   riskManager.Init();
   executor.Init();
   classifier.Init(InpADXPeriod, InpADXThreshold);
   motorA.Init(InpBBPeriod, InpBBDeviation, InpRSIPeriod);
   motorB.Init(InpEMAPeriod);

   if(!riskManager.ValidateAccount(AccountInfoDouble(ACCOUNT_BALANCE)))
   {
      logger.Error("Falha na validacao da conta. Verifique permissao de trade e saldo.");
      return INIT_FAILED;
   }

   logger.Info("EA inicializado com sucesso.");
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   logger.Info("EA finalizado. reason=" + IntegerToString(reason));
}

void OnTick()
{
   riskManager.RefreshDay();

   if(riskManager.IsCloseAllTime())
   {
      executor.CloseAllPositions();
      return;
   }

   executor.ManageOpenPositions();

   if(!IsNewBar())
      return;

   if(!riskManager.IsTradingAllowed())
      return;

   ENUM_MARKET_REGIME regime = classifier.DetectRegime(_Symbol);

   if(regime == REGIME_CONSOLIDATION)
   {
      logger.Info("Regime: consolidacao. Executando Motor A.");
      motorA.Execute(_Symbol, riskManager, executor);
   }
   else if(regime == REGIME_TREND)
   {
      logger.Info("Regime: tendencia. Executando Motor B.");
      motorB.Execute(_Symbol, riskManager, executor);
   }
   else
   {
      logger.Info("Regime indefinido. Sem entrada.");
   }
}

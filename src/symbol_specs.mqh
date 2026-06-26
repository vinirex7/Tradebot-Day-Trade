//+------------------------------------------------------------------+
//| symbol_specs.mqh                                                 |
//| Auto detection of symbol, tick value, tick size and volume rules  |
//+------------------------------------------------------------------+
#property strict

#ifndef __TRADEBOT_SYMBOL_SPECS_MQH__
#define __TRADEBOT_SYMBOL_SPECS_MQH__

#include "../config/config.mqh"
#include "logger.mqh"

class CSymbolSpecs
{
private:
   string m_symbol;
   ENUM_TRADEBOT_ASSET m_asset_type;
   double m_tick_value;
   double m_tick_size;
   double m_point;
   double m_point_value;
   double m_volume_min;
   double m_volume_max;
   double m_volume_step;
   int    m_digits;

   bool Contains(const string text, const string pattern)
   {
      return StringFind(StringToUpper(text), pattern) >= 0;
   }

public:
   void Init(const string symbol)
   {
      m_symbol = symbol;
      m_asset_type = InpAssetType;

      if(m_asset_type == ASSET_AUTO)
      {
         if(Contains(symbol, "WIN"))
            m_asset_type = ASSET_WIN;
         else if(Contains(symbol, "WDO"))
            m_asset_type = ASSET_WDO;
         else
            m_asset_type = ASSET_OTHER;
      }

      m_tick_value  = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
      m_tick_size   = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
      m_point       = SymbolInfoDouble(symbol, SYMBOL_POINT);
      m_volume_min  = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
      m_volume_max  = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
      m_volume_step = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
      m_digits      = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

      if(InpAutoContractSpecs && m_tick_value > 0.0 && m_tick_size > 0.0 && m_point > 0.0)
         m_point_value = m_tick_value * (m_point / m_tick_size);
      else
         m_point_value = InpManualPointValue;

      if(m_volume_min <= 0.0)  m_volume_min = 1.0;
      if(m_volume_step <= 0.0) m_volume_step = 1.0;
      if(m_volume_max <= 0.0)  m_volume_max = 1000.0;
   }

   bool Validate(CLogger &logger)
   {
      if(!InpAllowAnySymbol && m_asset_type == ASSET_OTHER)
      {
         logger.Error("Simbolo nao reconhecido como WIN/WDO e InpAllowAnySymbol=false. Simbolo=" + m_symbol);
         return false;
      }

      if(m_point_value <= 0.0)
      {
         logger.Error("PointValue invalido. Ajuste InpManualPointValue ou verifique especificacoes do simbolo.");
         return false;
      }

      if(m_volume_min <= 0.0 || m_volume_step <= 0.0)
      {
         logger.Error("Volume minimo/step invalido no simbolo. Verifique se o ativo esta habilitado no Market Watch.");
         return false;
      }

      return true;
   }

   string AssetName()
   {
      if(m_asset_type == ASSET_WIN) return "WIN";
      if(m_asset_type == ASSET_WDO) return "WDO";
      if(m_asset_type == ASSET_OTHER) return "OTHER";
      return "AUTO";
   }

   void Log(CLogger &logger)
   {
      logger.Info("Simbolo=" + m_symbol +
                  " | AssetType=" + AssetName() +
                  " | TickValue=" + DoubleToString(m_tick_value, 6) +
                  " | TickSize=" + DoubleToString(m_tick_size, 6) +
                  " | Point=" + DoubleToString(m_point, 6) +
                  " | PointValue=" + DoubleToString(m_point_value, 6) +
                  " | VolMin=" + DoubleToString(m_volume_min, 2) +
                  " | VolStep=" + DoubleToString(m_volume_step, 2) +
                  " | VolMax=" + DoubleToString(m_volume_max, 2));

      if(InpLogServerTimeOnInit)
         logger.Info("Horario servidor corretora=" + TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS));
   }

   double PointValue()  { return m_point_value; }
   double VolumeMin()   { return m_volume_min; }
   double VolumeMax()   { return m_volume_max; }
   double VolumeStep()  { return m_volume_step; }
   double Point()       { return m_point; }
   int    Digits()      { return m_digits; }
};

#endif

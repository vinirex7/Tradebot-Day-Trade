//+------------------------------------------------------------------+
//| logger.mqh                                                       |
//+------------------------------------------------------------------+
#property strict

#ifndef __TRADEBOT_LOGGER_MQH__
#define __TRADEBOT_LOGGER_MQH__

class CLogger
{
private:
   string m_file;

   void Write(const string level, const string message)
   {
      string line = TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS) + " [" + level + "] " + message;
      Print(line);

      int handle = FileOpen(m_file, FILE_READ|FILE_WRITE|FILE_TXT|FILE_ANSI);
      if(handle == INVALID_HANDLE)
         handle = FileOpen(m_file, FILE_WRITE|FILE_TXT|FILE_ANSI);

      if(handle != INVALID_HANDLE)
      {
         FileSeek(handle, 0, SEEK_END);
         FileWrite(handle, line);
         FileClose(handle);
      }
   }

public:
   void Init(const string file_name = "Tradebot_Day_Trade_Log.txt")
   {
      m_file = file_name;
   }

   void Info(const string message)  { Write("INFO", message); }
   void Warn(const string message)  { Write("WARN", message); }
   void Error(const string message) { Write("ERROR", message); }
};

#endif

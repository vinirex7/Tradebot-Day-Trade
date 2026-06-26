# Tradebot Day Trade - WIN/WDO Regime Switching

Sistema de trading algorítmico em **MQL5** para MetaTrader 5, focado em day trade nos minicontratos brasileiros **WIN** e **WDO**.

O robô usa uma arquitetura de **Regime Switching**, alternando entre:

- **Motor A - Reversão à Média**: Bollinger Bands + RSI curto para operar exaustão em mercado lateral.
- **Motor B - Tendência**: pullback em EMA/VWAP simplificada com trailing stop por ATR em mercado direcional.
- **Classificador de Regime**: ADX para identificar consolidação, tendência ou regime indefinido.
- **Gestão de Risco**: risco percentual por trade, limite de perda diária e zeragem compulsória.
- **Execução**: wrapper com CTrade, Magic Number, logs e controle de posições abertas.

> Projeto educacional. Antes de operar em conta real, rode no testador de estratégia, conta demo e valide slippage, corretagem, margem, horários, símbolo e especificações do contrato na sua corretora.

## Estrutura

```text
Tradebot-Day-Trade/
├── README.md
├── LICENSE
├── .gitignore
├── config/
│   ├── config.mqh
│   └── parameters.json
├── src/
│   ├── main.mq5
│   ├── regime_classifier.mqh
│   ├── motor_a_reversion.mqh
│   ├── motor_b_trend.mqh
│   ├── risk_manager.mqh
│   ├── order_executor.mqh
│   └── logger.mqh
├── indicators/
│   └── README.md
├── utils/
│   └── README.md
└── docs/
    ├── STRATEGY.md
    └── INSTALLATION.md
```

## Instalação rápida

1. No MetaTrader 5, vá em **Arquivo > Abrir Pasta de Dados**.
2. Copie a pasta do projeto para `MQL5/Experts/Tradebot-Day-Trade`.
3. Abra o MetaEditor e compile `src/main.mq5`.
4. Arraste o EA para o gráfico do WIN ou WDO.
5. Timeframe inicial recomendado: **M5**.
6. Ative **Algo Trading**.

## Parâmetros principais

Os inputs ficam em `config/config.mqh`:

- `InpMaxDailyLossPercent`: perda máxima diária.
- `InpRiskPerTradePercent`: risco por operação.
- `InpADXPeriod` e `InpADXThreshold`: classificador de regime.
- `InpBBPeriod`, `InpBBDeviation`, `InpRSIPeriod`: Motor A.
- `InpEMAPeriod`, `InpATRPeriod`, `InpATRStopMultiplier`: Motor B e stops.
- `InpStartTime`, `InpEndTime`, `InpCloseAllTime`: horários operacionais.

## Lógica resumida

### Regime lateral

Quando o ADX está baixo, o EA ativa o Motor A.

- Compra: preço abaixo da Banda Inferior + RSI em sobrevenda.
- Venda: preço acima da Banda Superior + RSI em sobrecompra.
- Stop: ATR.
- Alvo: retorno à média.

### Regime de tendência

Quando o ADX está alto e subindo, o EA ativa o Motor B.

- Compra: preço acima da EMA e recuo próximo da média.
- Venda: preço abaixo da EMA e recuo próximo da média.
- Stop: ATR.
- Gestão: trailing stop.

## Aviso de risco

Day trade em WIN/WDO é altamente arriscado. Backtest não garante resultado futuro. Use conta demo antes de qualquer operação real.

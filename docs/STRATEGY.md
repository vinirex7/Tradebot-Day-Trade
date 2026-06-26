# Estratégia - Regime Switching WIN/WDO

A estratégia tenta resolver um problema clássico de robôs de day trade: o mercado muda de comportamento durante o pregão.

Um robô de reversão tende a performar melhor em mercado lateral, mas pode sofrer em tendência forte. Um robô seguidor de tendência pode ir bem em dias direcionais, mas tende a tomar stops em consolidação. Por isso, este projeto usa um classificador de regime.

## Classificador de regime

O classificador usa ADX:

- ADX abaixo do limite: consolidação.
- ADX acima do limite e subindo: tendência.
- Caso intermediário: sem operação.

Parâmetros iniciais:

- ADX: 14 períodos.
- Timeframe do regime: M15.
- Threshold: 25.

## Motor A - Reversão à Média

Ativado em consolidação.

Indicadores:

- Bollinger Bands.
- RSI curto.
- ATR para stop.

Compra:

- Preço toca ou rompe a banda inferior.
- RSI indica sobrevenda.

Venda:

- Preço toca ou rompe a banda superior.
- RSI indica sobrecompra.

## Motor B - Tendência

Ativado em tendência.

Indicadores:

- EMA.
- ATR.

Compra:

- Preço em contexto acima da EMA.
- Pullback próximo à EMA.

Venda:

- Preço em contexto abaixo da EMA.
- Pullback próximo à EMA.

## Gestão de risco

O lote é calculado por risco percentual:

```text
Contratos = Capital x RiscoPercentual / (StopLossPontos x ValorPorPonto)
```

Há limite de perda diária, meta diária e zeragem compulsória.

## Próximas melhorias recomendadas

- VWAP real intradiária.
- Filtro de horário por volatilidade.
- Filtro de spread/slippage.
- Controle de número máximo de trades por dia.
- Backtest separado para WIN e WDO.
- Otimização walk-forward.

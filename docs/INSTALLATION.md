# Instalação no MetaTrader 5

## 1. Copiar arquivos

No MetaTrader 5:

```text
Arquivo > Abrir Pasta de Dados
```

Depois copie a pasta do projeto para:

```text
MQL5/Experts/Tradebot-Day-Trade
```

## 2. Compilar

Abra o MetaEditor, localize:

```text
MQL5/Experts/Tradebot-Day-Trade/src/main.mq5
```

Clique em **Compilar**.

## 3. Rodar em demo

1. Abra o gráfico do WIN ou WDO.
2. Use timeframe M5 inicialmente.
3. Arraste o EA para o gráfico.
4. Ative Algo Trading.
5. Confira os inputs.

## 4. Ajustes obrigatórios antes de conta real

- Confirmar `InpPointValue`.
- Confirmar horário do servidor.
- Confirmar lote mínimo e step do símbolo.
- Rodar backtest.
- Rodar pelo menos alguns pregões em demo.

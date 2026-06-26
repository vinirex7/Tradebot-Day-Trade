# Instalação no MetaTrader 5

## 1. Fazer pull direto na pasta do MT5

No MetaTrader 5:

```text
Arquivo > Abrir Pasta de Dados
```

Entre em:

```text
MQL5/Experts
```

Depois rode:

```bash
git clone https://github.com/vinirex7/Tradebot-Day-Trade.git
```

Se já clonou antes:

```bash
cd Tradebot-Day-Trade
git pull origin main
```

## 2. Compilar

Abra o MetaEditor, localize:

```text
MQL5/Experts/Tradebot-Day-Trade/src/main.mq5
```

Clique em **Compilar**.

## 3. Rodar em demo/backtest

1. Abra o gráfico do WIN ou WDO.
2. Use timeframe M5 inicialmente.
3. Arraste o EA para o gráfico ou selecione no Testador de Estratégia.
4. Ative Algo Trading.
5. Carregue um preset da pasta `presets/`.

## 4. O que agora é automático

O EA detecta automaticamente:

- Nome do símbolo usado pela corretora, se contém WIN/WDO.
- Tick value.
- Tick size.
- Point.
- Lote mínimo.
- Lote máximo.
- Step de lote.

Essas informações são gravadas no log ao iniciar.

## 5. Ajustes manuais raros

Só mexa manualmente se o log mostrar valores errados ou zerados:

- `InpAutoContractSpecs=false`
- `InpManualPointValue`
- horários de operação, se o servidor da corretora estiver em outro fuso.

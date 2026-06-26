# Backtest no MetaTrader 5

Este repositório já está preparado para backtest pelo Testador de Estratégia do MT5.

## Fluxo recomendado

1. Copie/puxe o repo para `MQL5/Experts/Tradebot-Day-Trade`.
2. Compile `src/main.mq5` no MetaEditor.
3. Abra o Testador de Estratégia.
4. Selecione o EA `Tradebot-Day-Trade/src/main`.
5. Escolha o símbolo exato da sua corretora: exemplos `WINQ26`, `WIN$`, `WDOQ26`, `WDO$`.
6. Timeframe inicial: M5.
7. Use ticks reais se a corretora disponibilizar.
8. Carregue um preset de `presets/`.

## Presets

- `presets/WIN_M5_default.set`
- `presets/WDO_M5_default.set`

## O que ficou automático

O EA lê do próprio MT5:

- `SYMBOL_TRADE_TICK_VALUE`
- `SYMBOL_TRADE_TICK_SIZE`
- `SYMBOL_POINT`
- `SYMBOL_VOLUME_MIN`
- `SYMBOL_VOLUME_MAX`
- `SYMBOL_VOLUME_STEP`

Com isso, o `InpPointValue`, lote mínimo e step deixam de ser configuração manual na maior parte dos casos.

## Quando usar manual

Use `InpAutoContractSpecs=false` apenas se a corretora devolver especificações erradas ou zeradas.

Nesse caso ajuste:

- WIN: `InpManualPointValue=0.20`, geralmente.
- WDO: confira a especificação da corretora antes de usar em real.

## Horário do servidor

Os inputs de horário usam o horário do servidor da corretora, não necessariamente o horário local do computador.

Ao iniciar, o EA grava no log:

```text
Horario servidor corretora=YYYY.MM.DD HH:MM:SS
```

Se o servidor estiver diferente do horário de Brasília, ajuste:

- `InpStartTime`
- `InpEndTime`
- `InpCloseAllTime`

## Configuração conservadora inicial

Antes de pensar em real:

- Rodar 1 a 2 anos de backtest.
- Rodar por ativo separado: WIN e WDO.
- Rodar pelo menos alguns pregões em demo.
- Conferir log de inicialização com tick value, tick size, point, volume min e step.

## Checklist de validação

- O EA compila sem erro.
- O símbolo aparece no Market Watch.
- O backtest gera trades.
- O log mostra `PointValue` maior que zero.
- O lote calculado respeita mínimo e step.
- A zeragem ocorre no horário configurado.

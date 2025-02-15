# Trend-Observation-EA

## Overview
Trend-Observation-EA is an Expert Advisor (EA) for MetaTrader 5 that uses the AROON indicator to generate trading signals based on trend observations. The EA opens and closes trades based on the trend direction and other custom criteria.

## Features
- Uses the AROON indicator to detect trends
- Configurable input parameters for lot size, stop loss, take profit, and AROON settings
- Custom criteria for performance metrics, such as modified profit factor and CAGR over mean drawdown
- Utility functions for common tasks like checking for new bars, counting open positions, and normalizing prices

## Installation
1. Download the project files.
2. Copy the `.mq5` and `.mqh` files to the `MQL5/Experts` directory of your MetaTrader 5 installation.
3. Open MetaTrader 5 and navigate to the `Navigator` panel.
4. Right-click on `Expert Advisors` and select `Refresh` to see the newly added EA.

## Usage
1. Attach the `TrendObservationEA` to a chart.
2. Configure the input parameters as needed:
   - Lot size
   - Stop loss
   - Take profit
   - AROON indicator settings
3. Enable automated trading.

## Input Parameters
- `LotSize`: The size of the lot for each trade.
- `StopLoss`: The stop loss value in points.
- `TakeProfit`: The take profit value in points.
- `AroonPeriod`: The period for the AROON indicator.

## Files
- [`TrendObservationEA.mq5`](TrendObservationEA/TrendObservationEA.mq5): Main entry point for the EA.
- [`InpConfig.mqh`](TrendObservationEA/InpConfig.mqh): Contains input parameters and configuration settings.
- [`GlobalVar.mqh`](TrendObservationEA/GlobalVar.mqh): Defines global variables and enums.
- [`Helper.mqh`](TrendObservationEA/Helper.mqh): Provides utility functions.
- [`OnTickHelper.mqh`](TrendObservationEA/OnTickHelper.mqh): Functions called on each tick.
- [`TrendObservation.mqh`](TrendObservationEA/TrendObservation.mqh): Logic for observing trends using the AROON indicator.
- [`CustomCriteria.mqh`](TrendObservationEA/CustomCriteria.mqh): Custom criteria functions for performance metrics.
- [`TriggerFilterClose.mqh`](TrendObservationEA/TriggerFilterClose.mqh): Functions to trigger trades, apply filters, and close positions.

## Documentation
For detailed documentation of the project, please refer to the following file: [Algo_Trading_Project_Report.pdf](./Algo_Trading_Project_Report.pdf)

## Live Performance
To see the live performance and equity curve of the EA, please visit the following link: [www.darwinex.com/account/D.342474](https://www.darwinex.com/account/D.342474)

## Contributing
Contributions are welcome! Please fork the repository and submit a pull request with your changes.
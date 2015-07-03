__Clarity__ is a framework for quickly and professionally R&D new strategies
for equities and derivatives.

It is built on top of the powerful _R_ programming language, providing bindings
to _C_, _C++_ and the popular databases.

Beyond _R_'s standard functionalities (basic statistics, time series,
statistical mechanics, chaos, etc), __Clarity__ proposal offers a
handful of possibilities to leverage algotraders from portfolio theory to
arbitrage to high frequency trading.

## Description

As for the mechanics behind __Clarity__, it works alike

* Akin to _Meta Trader_, with the standard `begin()`, `start()`, and `end()`.

[begin-tick-end loop](./imgs/begin_tick_end.png)

* Handle multiple instruments, either equities or derivaties.

* ETL indicators and instruments/indicators pre-load/pre-calculation.

[]()

* _Event profiler_, for position evolution diagnose.

[Event profiler](./imgs/entry_positions.png)

### Reporting and journaling.

[Equity growth](./imgs/equity_growth.png)

[Returns distribution](./imgs/returns_distribution.png)

[Win vs Loss distribution](./imgs/win_vs_loss_positions.png)

* Position sizing: Kelly criteria, Optimal/Secure/Fractional F, Dynamic PS using

[Positions and position sizing](./imgs/report.png)

* Position management: S/L, T/P, trailing stop, dynamic trailing stop.

* Links to other technologies: _C_, _C++_. 
Data providers: _Quandl_. 
Databases: _Postgresql_, _MySQL_, _MariaDB_, etc. 
Further links will include _S-plus_, _Matlab_, and _Mathematica_.

* Parameter optimisation.

* Arbitrage spot: triangular arbitrage and extension.

[Arbitrage spot](./imgs/arbitrage_spot.png)

* Hurst coefficient, special indicators, and special models.

* Pulse continuous impact aggregator for news trading.

[Pulse continuous impact aggregator](./imgs/pulse_continuous_impact_aggregator.png)

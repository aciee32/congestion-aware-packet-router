

\# Congestion-Aware 1x3 Packet Router Using Verilog HDL



\## Project Overview

This project implements a 1x3 packet router using Verilog HDL.

It routes incoming 16-bit packets into one of three FIFO queues

based on the destination field.



The project compares two scheduling techniques:

\- Round Robin Arbitration

\- Least-Occupancy-Based Scheduling



\## Architecture

\- One input interface

\- Three FIFO queues

\- 16-bit packet format

\- Destination decoder

\- Round Robin arbiter

\- Least-occupancy scheduler

\- Router controller

\- Shared output transmission interface



\## Packet Format

| Bits | Description |

|---|---|

| \[15:14] | Destination |

| \[13:0] | Payload |



Destination mapping:

\- 00 - Queue 0

\- 01 - Queue 1

\- 10 - Queue 2

\- 11 - Invalid destination



\## Tools Used

\- Verilog HDL

\- Icarus Verilog

\- GTKWave

\- Yosys

\- Xilinx ISE



\## Repository Structure

\- `rtl/` - Verilog design modules

\- `tb/` - Testbenches

\- `sim/` - Simulation waveform files

\- `docs/` - Project report and screenshots



\## Simulation

Compile a testbench using Icarus Verilog:



```bash

iverilog -o sim/router\_top rtl/\*.v tb/router\_top\_tb.v

```



Run the simulation:



```bash

vvp sim/router\_top

```



Open the waveform:



```bash

gtkwave sim/router\_top.vcd

```



Run the performance test:



```bash

iverilog -o sim/performance rtl/\*.v tb/performance\_tb.v

vvp sim/performance

```



\## Performance Comparison

The design was evaluated using nine packets distributed equally

among the three queues.



| Metric | Round Robin | Least Occupancy |

|---|---:|---:|

| Packets transmitted | 9 | 9 |

| Average waiting time | 85 ns | 85 ns |

| Throughput | 1 packet/cycle | 1 packet/cycle |

| First-three-service fairness | 1.000 | 0.333 |



In the tested scenario, Round Robin provided better short-term

fairness. The least-occupancy scheduler selected Queue 0 repeatedly

during the first three service opportunities.



\## Verification

Individual modules and the complete router were tested using

Verilog testbenches. Simulation waveforms were viewed using GTKWave.






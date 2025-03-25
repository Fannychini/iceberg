## icebeRgPlot: Visualising treatment responses in oncology


### Overview

The `icebeRgPlot` package is the R implementation of a novel visualisation method described by Lythgoe et al., which is used for comparing current and prior treatment responses in oncology clinical research. 

The iceberg plot displays current therapy response above a 'waterline' and prior therapy response below, allowing direct visual comparison of treatment sequencing efficacy on a person-by-person basis.

<p align="center"> <img src="iceberg_mod.svg" width="600" alt="iceberg plot's idea"> </p>

This visualisation addresses a gap in oncology data display, where current graphical methods fail to adequately show prior treatment responses, focusing only on current treatments in isolation.

### Background

As described by Lythgoe et al., modern clinical cancer research increasingly relies on the visual communication of complex response and treatment sequencing data. The iceberg plot was developed to show what was previously 'hidden beneath the surface', i.e. the critical context of how individuals responded to prior treatments.
This code and its package implement the specific methodology described in the supplementary appendix of the original publication, including the distinctive person ordering algorithm that places individuals with maximum prior therapy response in the center, creating the characteristic 'iceberg' shape.

!! to check -- R code from 2022 did I include the von hoff criteria? should be in folder CHSR/previous_mac/R_work/iceberg_graph

### Structure and use

This repository consists of several R files:

| File | Description | Main functions |
|------|-------------|---------------|
| `R/data_prep.R` | person ordering | `prepare_iceberg_locations()` |
| `R/iceberg_plot.R` | core plotting | `iceberg_plot()`, `theme_iceberg()` |
| `R/example.R` | workflow code | includes all functions |


### Reseerch applications

The iceberg plot can be leveraged for:

1. **Treatment sequencing studies** -- comparing how current therapy performs against prior treatments
2. **Precision oncology trials** -- evaluating whether genomically-matched therapies outperform previous standard approaches
3. **Clinical decision support** -- helping clinicians visualise a therapy's efficacy in context
4. **Exceptional responder analysis** -- identifying individuals who experience substantial benefit from a new therapy


### License

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
This package is released under the GNU General Public License v3.0 (GPL-3.0).

This means:
- You are free to use, modify, and distribute this code
- If you distribute modified versions, you must also distribute them under GPL-3.0
- Any software that incorporates this code must also be released under GPL-3.0
- Full license details can be found in the LICENSE file or at https://www.gnu.org/licenses/gpl-3.0.html


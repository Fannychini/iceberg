## icebeRgPlot: Visualising treatment responses in oncology


### Overview

The `icebeRgPlot` package is the R implementation of a novel visualisation method described by Lythgoe et al., which is used for comparing current and prior treatment responses in oncology clinical research. 

The iceberg plot displays current therapy response above a 'waterline' and prior therapy response below, allowing direct visual comparison of treatment sequencing efficacy on a patient-by-patient basis.

<p align="center"> <img src="iceberg_mod.svg" width="600" alt="iceberg plot's idea"> </p>

This visualisation addresses a key gap in oncology data display, where current graphical methods fail to adequately show prior treatment responses, focusing only on current treatments in isolation.

### Background

As described by Lythgoe et al., modern clinical cancer research increasingly relies on the visual communication of complex response and treatment sequencing data. The iceberg plot was developed to show what was previously 'hidden beneath the surface', i.e. the critical context of how patients responded to prior treatments.
This code and its package implement the specific methodology described in the supplementary appendix of the original publication, including the distinctive patient ordering algorithm that places patients with maximum prior therapy response in the center, creating the characteristic 'iceberg' shape.

### How to cite

If you use this code or its package in your research, please cite:

1. This R implementation:
   ```
   Franchini F. (2025). icebeRgPlot: R Package for visualising treatment responses in oncology. 
   GitHub repository, https://github.com/fannychini/iceberg
   ```
   
2. The original paper that introduced the iceberg plot concept:
   ```
   Mark P. Lythgoe, Timothée Olivier, Vinay Prasad. The iceberg plot, improving the visualisation of therapy response in oncology in the era of sequence-directed therapy,
   European Journal of Cancer, Volume 159, 2021, Pages 56-59, ISSN 0959-8049, https://doi.org/10.1016/j.ejca.2021.09.034.
   ```

### License

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
This package is released under the GNU General Public License v3.0 (GPL-3.0).

This means:
- You are free to use, modify, and distribute this code
- If you distribute modified versions, you must also distribute them under GPL-3.0
- Any software that incorporates this code must also be released under GPL-3.0
- Full license details can be found in the LICENSE file or at https://www.gnu.org/licenses/gpl-3.0.html


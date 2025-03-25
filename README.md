# icebeRgPlot: Visualising treatment responses in oncology


## Overview

The `icebeRgPlot` package is the R implementation of a novel visualisation method described by Lythgoe et al., which is used for comparing current and prior treatment responses in oncology clinical research. 
The iceberg plot displays current therapy response above a 'waterline' and prior therapy response below, allowing direct visual comparison of treatment sequencing efficacy on a patient-by-patient basis.

This visualisation addresses a key gap in oncology data display, where current graphical methods fail to adequately show prior treatment responses, focusing only on current treatments in isolation.

## Background

As described by Lythgoe et al., modern clinical cancer research increasingly relies on the visual communication of complex response and treatment sequencing data. The iceberg plot was developed to show what was previously 'hidden beneath the surface', i.e. the critical context of how patients responded to prior treatments.
This code and its package implement the specific methodology described in the supplementary appendix of the original publication, including the distinctive patient ordering algorithm that places patients with maximum prior therapy response in the center, creating the characteristic 'iceberg' shape.


## License

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
This package is released under the GNU General Public License v3.0 (GPL-3.0).

This means:
- You are free to use, modify, and distribute this code
- If you distribute modified versions, you must also distribute them under GPL-3.0
- Any software that incorporates this code must also be released under GPL-3.0
- Full license details can be found in the LICENSE file or at https://www.gnu.org/licenses/gpl-3.0.html


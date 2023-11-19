# gma – Gamma Model Analysis for MATLAB
![gma_example](https://github.com/0xlevel/gma/assets/4135987/103e2d8e-a4c4-470b-9446-8b3bd2f52810)

## Purpose
Gamma Model Analysis for MATLAB is a set of functions to investigate empirical event-related potential (ERP) components by fitting a Gamma PDF on EEG data. The results provide specific shape-related and time-related parameters of an ERP component. GMA was originally developed by Kummer et al. (2020) and has been further improved since.
GMA was developed in the [Department of Individual Differences and Psychological Assessment](https://www.hf.uni-koeln.de/33219), [University of Cologne](https://portal.uni-koeln.de/en/uoc-home)

## Prerequisites

- **MATLAB** (R2023a (v9.14); likely supported by R2017a or higher)
- _(optional)_ Statistics and Machine Learning Toolbox (built with v12.5) to obtain median and iqr, which rely on the gaminv function.
- _(recommended)_ EEGLAB Toolbox to (pre-)process and structure EEG data

## Installation

The source code can simply be downoaded (see [latest release](https://github.com/0xlevel/gma/releases/latest)) and run in MATLAB.
To benefit from future updates in your MATLAB project, you may add it directly as (git) submodule in MATLAB.

## Usage

Examples are provided as MATLAB live code (see `examples/`) and the help texts of all major functions .

``` matlab
% To run the GMA on EEG data in channel 15, looking for a positive component:
gmaFCz = gmaFitEeg(EEG, 15);
```
```matlab
% Same channel, but looking for a negative component:
gmaFCz = gmaFitEeg(EEG, 15, invData=true);
```

Read more about the [implementation goals](https://github.com/0xlevel/gma/wiki/Implementation-goals) and the [implemented GMA procedure](https://github.com/0xlevel/gma/wiki/Overview-of-the-implemented-GMA-procedure).

## Contributing

If you want to contribute, report issues or request features, please do!
You can contribute using the [issues page](https://github.com/0xlevel/gma/issues).

## Author
Olaf C. Schmidtmann

- Github: [@0xlevel](https://github.com/0xlevel)

## 📝 License

Copyright © 2023 [Olaf C. Schmidtmann](https://github.com/0xlevel)
This project is [GPLv3](https://github.com/0xlevel/gma/blob/main/LICENSE) licensed.

%gmaFitErp Gamma Model Analysis fits a Gamma PDF for ERP data
%
%% Syntax
%
%   fitResult = gmaFitErp(ERP);
%   fitResult = gmaFitErp(ERP, 1);
%   fitResult = gmaFitErp(ERP, 1, 50);
%   fitResult = gmaFitErp(ERP, 1, 50, 100);
%   fitResult = gmaFitErp(ERP, 1, 50, 100, invData = true);
%   [fitResult, initialGuess, argsUsed] = gmaFitErp(ERP, 1);
%
%% Description
%   A comfort wrapper for <a href="matlab:help('gmaFit')">gmaFit</a> to faciliate the usage of ERP data in the
%   ERPLAB (struct) format.
%
%   The data can be selected from the ERP channels and bins. The data can also
%   be inverted prior before being submitted to the GMA. After the GMA is
%   fitted, the ERP sampling rate, name and other meta data will be added to the
%   GmaResults (via GmaResults.addEegInfo), as well as the arguments used by
%   gmaFit. This information can be retrieved from the fields of the result's
%   GmaResults.eegInfo.
%
%% Input
%   ERP             - [struct] A struct containing the data and meta information
%                   which must at least contain the fields 'data', 'setname' and
%                   'srate'. The channels in data will be accessed as rows.
%                   Ideally this should be an ERPLAB ERP struct or contain the
%                   same fields.
%   channel         - The index of the channel or the channel label. The channel
%                   index will be used to extract the 'bindata' which will be
%                   passed to gmaFit.
%   binIdx          - The index of the bin in 'bindata' which will be passed to 
%                   gmaFit.
%   winStart        - [numeric {integer}] Just passed to gmaFit: First data
%                   point of the search window for the component of interest
%                   (default = 1).
%   winLength       - [numeric {integer}] Just passed to gmaFit: Length of the
%                   search window for the component of interest.
%
%   [Optional] Name-value parameters
%   invData         - [logical] true: the polarity of the ERP data's selected 
%                   channel (chIdx) will be reversed (data * -1), before being 
%                   committed to gmaFit;
%                   false (default): the data will not be inverted.
%
%   The remaining optional parameters are passed unvalidated to <a href="matlab:help('gmaFit')">gmaFit</a>.
%
%% Output
%   result      - [<a href="matlab:help('GmaResults')">GmaResults</a>] Instance
%               containing the optimized results.
%   x0          - [double] parameters of the initial guess by the presearch as
%               shape, rate and y-scaling values in a vector.
%   argsUsed    - [struct]
%
%
%% See also
%   gmaFit, gmaFitEeg, iserpstruct, GmaResults, GmaResults.addEegInfo

%% Attribution
%	Last author: Olaf C. Schmidtmann, last edit: 02.04.2024
%   Source: https://github.com/0xlevel/gma
%	MATLAB version: 2023a
%
%	Copyright (c) 2024, Olaf C. Schmidtmann, University of Cologne
%   This program is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
% 
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.

function [results, x0, argsUsed] = gmaFitErp(ERP, channel, binIdx, winStart, winLength, args)

    arguments
        ERP(1, 1) struct
        channel
        binIdx(1, 1) {mustBeInteger, mustBePositive}
        winStart(1, 1) {mustBeInteger, mustBePositive} = 1
        winLength(1, 1) {mustBeInteger, mustBePositive} = max(1, size(ERP.data, 2))
        args.invData(1, 1) logical = false

        % The following are just passed to gmaFit (no checks here)
        args.optimizeFull
        args.segMinLength
        args.segPad
        args.segExtension
        args.maxSrcIt
        args.logEnabled
        args.logSrc
        args.logFn
        args.costFn
        args.psType
        args.psMaxIt
        args.xtol
        args.ftol
    end

    isERP = iserpstruct(ERP);

    % EARLY EXIT if no ERPLAB structure
    if ~isERP || ~numel(ERP.bindata)
        eidType = 'gmaFitErp:invalidStruct';
        msgType = ['Invalid ERP struct.\n', ...
            'Input must be a valid ERPLAB structure.\n'];
        throw(MException(eidType, msgType))
    end

    if isnumeric(channel)
        assert(channel > 0 && channel <= size(ERP.bindata, 1), ...
            "Channel index [%i] out of range.", channel);

        chIdx = channel;
        chLoc = ERP.chanlocs(channel);
        chLabel = chLoc.labels;
    else
        chLabel = channel;
        chIdx = eeg_getChanIdx(ERP, channel);

        assert(~isempty(chIdx), "Channel name not found: %s.", chLabel);
        chLoc = ERP.chanlocs(chIdx);
    end

    assert(binIdx <= size(ERP.bindata, 3), ...
        "Bin index [%i] out of range.", binIdx);

    data = ERP.bindata(chIdx, :, binIdx);
    if args.invData
        gdata = data * -1;
    end

    params = namedargs2cell(args);

    [results, x0, argsUsed] = gmaFit(gdata, winStart, winLength, params{:});

    try
        info = struct;
        info.type = GmaResults.EEG_INFO_TYPE;
        info.setname = ERP.erpname;
        info.srate = ERP.srate;
        info.xmin = ERP.xmin;
        info.filename = ERP.filename;
        info.filepath = ERP.filepath;
        info.data = data;
        info.binnum = binIdx;
        info.bindescr = ERP.bindescr(binIdx);
        info.chLabel = chLabel;
        info.chLoc = chLoc;
        info.argsUsed = argsUsed;
        info.x0 = x0;
        results.addEegInfo(info, chIdx);
    catch ME
        warning(ME.identifier, ...
            "Adding ERP info to GmaResults failed. Error: %s", ME.message);
    end
end

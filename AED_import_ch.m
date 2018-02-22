% -------------------------------------------------------------------------
% Function : read_AED_ch
%
% Description : read a specified .ch file(s) and return content.
%               returns structure with data from n channel files. n is 
%               derived from the number of file paths supplied.
%
% Created : 2017-04, F.Obersteiner, florian.obersteiner@kit.edu
%
% Modifications: 
%           170421 - changed data decoding from uint32 to int32.
%
% -------------------------------------------------------------------------
%

function [ ch_data ] = AED_import_ch( path_s, thresh )

% path_s=["D:\PROGRAMMING\debugging\AED_mergefile\Cal-MIX-2015_5ml_3.D\AED1A.ch",...
%         "D:\PROGRAMMING\debugging\AED_mergefile\Cal-MIX-2015_5ml_3.D\Background\AEX1A.ch"];
%     
    n_files = numel(path_s);

    ch_data = struct(... % create struct to contain merged data
        'info', {},...
        'ydata', []);

    hdr_encoding = 'uint8=>char'; % header encoding format

    offset = struct(...  % define offsets in file header
        'file', 24,...
        'timestamp', 178,...
        'method', 228,...
        'element', 596,...
        'gcmodel', 208,...
        'units', 580,...
        'experiment', 86,...
        'manufacturer', 344,...
        'data', 1024);

    inf_strct = struct(... % ref struct to hold header info
        'file_version', '',...
        'file', '',...
        'timestamp', '',...
        'method', '',...
        'element', '',...
        'element_id', '',...
        'gcmodel', '',...
        'units', '',...
        'experiment', '',...
        'manufacturer', '');


    for i=1:n_files

        file_id = fopen(char(path_s(i)), 'r', 'b');

        %
        % HEADER
        fseek(file_id, 0, 'eof'); % set pointer ...
        fsize = ftell(file_id); % ... and determine variable

        fseek(file_id, 0, 'bof');
        inf_strct.file_version = deblank(fread(file_id, fread(file_id, 1, 'uint8'), hdr_encoding)');

        fseek(file_id, offset.file, 'bof');
        inf_strct.file = strtrim(deblank(fread(file_id, fread(file_id, 1, 'uint8'), hdr_encoding, 'l')'));

        fseek(file_id, offset.timestamp, 'bof');
        inf_strct.timestamp = strtrim(deblank(fread(file_id, fread(file_id, 1, 'uint8'), hdr_encoding, 'l')'));

        fseek(file_id, offset.method, 'bof');
        inf_strct.method = strtrim(deblank(fread(file_id, fread(file_id, 1, 'uint8'), hdr_encoding, 'l')'));

        fseek(file_id, offset.element, 'bof');
        inf_strct.element = strtrim(deblank(fread(file_id, fread(file_id, 1, 'uint8'), hdr_encoding, 'l')'));

        inf_strct.element_id = char(AED_element_lookup(string(inf_strct.element), " " ));

        fseek(file_id, offset.gcmodel, 'bof');
        inf_strct.gcmodel = strtrim(deblank(fread(file_id, fread(file_id, 1, 'uint8'), hdr_encoding, 'l')'));

        fseek(file_id, offset.units, 'bof');
        inf_strct.units = strtrim(deblank(fread(file_id, fread(file_id, 1, 'uint8'), hdr_encoding, 'l')'));

        fseek(file_id, offset.experiment, 'bof');
        inf_strct.experiment = strtrim(deblank(fread(file_id, fread(file_id, 1, 'uint8'), hdr_encoding, 'l')'));

        fseek(file_id, offset.manufacturer, 'bof');
        inf_strct.manufacturer = strtrim(deblank(fread(file_id, fread(file_id, 1, 'uint8'), hdr_encoding, 'l')'));

        %
        % SIGNAL
        % signal data points determined by file size minus data offset in bytes.
        % each signal value = 4 bytes = 1 unsigned 32 bit integer
        signal = zeros((fsize-offset.data)/4, 1);

        fseek(file_id, offset.data, 'bof');

        for j=1:(fsize-offset.data)/4
            signal(j, 1) = fread(file_id, 1, 'int32', 'b');
        end

        % processing: only every second element is and actual value
        signal = signal(2 : 2 : end);

        % processing: replace values above threshold with NaN
    %     thresh = 4.0e+09;
        signal(signal > thresh)=NaN;

        % processing: remove offset
    %     signal=signal-min(signal);

        ch_data(i).info = inf_strct;
        ch_data(i).ydata = signal;

        fclose(file_id);

    end

end
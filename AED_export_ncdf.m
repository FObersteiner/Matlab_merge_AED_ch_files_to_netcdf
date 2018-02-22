% --------------------------------------------------------------------------------
% Function : AED_export_ncdf
%
% Description : write merged ch data to netcdf file.
%
% Created : 2017-04, F.Obersteiner, florian.obersteiner@kit.edu
%
% Modifications: 
%
% --------------------------------------------------------------------------------
%
function AED_export_ncdf( ch_data, dir_out_aed, merge_version )

% some checks...
    n_channels = numel(ch_data);

    % for i=2:n_channels
    %     if length(ch_data(i-1).ydata) ~= length(ch_data(i).ydata)
    %         disp('number of data points not equal!');
    %     end
    %     if strcmp(ch_data(i-1).info.file_version, ch_data(i).info.file_version) ~=1
    %         disp('file version not equal!');
    %     end
    %     if strcmp(ch_data(i-1).info.file, ch_data(i).info.file) ~=1
    %         disp('file name not equal!');
    %     end
    %     if strcmp(ch_data(i-1).info.timestamp, ch_data(i).info.timestamp) ~=1
    %         disp('timestamp not equal!');
    %     end
    %     if strcmp(ch_data(i-1).info.method, ch_data(i).info.method) ~=1
    %         disp('method not equal!');
    %     end
    %     if strcmp(ch_data(i-1).info.element, ch_data(i).info.element) ~=1
    %         disp('element not equal!');
    %     end
    %     if strcmp(ch_data(i-1).info.gcmodel, ch_data(i).info.gcmodel) ~=1
    %         disp('gcmodel not equal!');
    %     end
    %     if strcmp(ch_data(i-1).info.units, ch_data(i).info.units) ~=1
    %         disp('units not equal!');
    %     end
    %     if strcmp(ch_data(i-1).info.experiment, ch_data(i).info.experiment) ~=1
    %         disp('experiment not equal!');
    %     end
    %     if strcmp(ch_data(i-1).info.manufacturer, ch_data(i).info.manufacturer) ~=1
    %         disp('manufacturer not equal!');
    %     end
    % end

    % create filename
    fname = char(string(dir_out_aed) + "\" + string(ch_data(1).info.file) + ".nc");

    if exist(fname, 'file')
        t=timer('TimerFcn',@(~,~)disp('Output file duplicate.'),'StartDelay',1);
        start(t)
        formatOut = 'yymmddHHMMSS';
        fname = char(string(dir_out_aed) + "\" + string(ch_data(1).info.file)...
                     + "_" + string(datestr(now, formatOut)) + "_.nc");
    end

    % create netcdf id
    ncid = netcdf.create(char(fname), 'NOCLOBBER'); % create the file...


    % GLOBAL file info: variable definition
    vid_merge_created = netcdf.getConstant('GLOBAL');
    vid_merger_vers = netcdf.getConstant('GLOBAL');
    vid_n_channels = netcdf.getConstant('GLOBAL');
    vid_chfile_time = netcdf.getConstant('GLOBAL');
    vid_method = netcdf.getConstant('GLOBAL');
    vid_gc = netcdf.getConstant('GLOBAL');
    vid_aed = netcdf.getConstant('GLOBAL');
    vid_units = netcdf.getConstant('GLOBAL');
    vid_experiment = netcdf.getConstant('GLOBAL');


    % channel data and info: variable definition and dimensioning
    var_names = strings(n_channels,1);
    dimIDs = zeros(n_channels,1);
    dataIDs = zeros(n_channels,1);

    for i=1:n_channels % create arrays containing dimIDs, dataIDs and var_names   
        var_names(i,1) = "ch"+string(i);
        dimIDs(i,1) = netcdf.defDim(ncid, char(var_names(i,1)), numel(ch_data(i).ydata)); % Define the dimensions of ydata variable.
        dataIDs(i,1) = netcdf.defVar(ncid, char(var_names(i,1)), 'double', dimIDs(i,1));
    end

    netcdf.endDef(ncid); % Leave define mode and enter data mode to write data. 

    for i=1:n_channels % write data to ydata arrays
        netcdf.putVar(ncid, dataIDs(i,1), ch_data(i).ydata); % Write data to variable. 
    end

    netcdf.reDef(ncid); % Re-enter define mode.

    % YDATA specific info
    %     element_info
    %     element_id

    for i=1:n_channels
        netcdf.putAtt(ncid, dataIDs(i,1), 'element_info', ch_data(i).info.element); % Create an attribute element_info associated with ydata.
        netcdf.putAtt(ncid, dataIDs(i,1), 'element_id', ch_data(i).info.element_id); % same with id...
    end

    formatOut = 'dd.mm.yyyy HH:MM:SS';
    netcdf.putAtt(ncid, vid_merge_created, 'merge_created', datestr(now, formatOut)); % add more info...
    netcdf.putAtt(ncid, vid_merger_vers, 'merge_vers', merge_version);
    netcdf.putAtt(ncid, vid_n_channels, 'n_channels', n_channels);
    netcdf.putAtt(ncid, vid_chfile_time, 'chfile_time', ch_data(1).info.timestamp);
    netcdf.putAtt(ncid, vid_method, 'method', ch_data(1).info.method);
    netcdf.putAtt(ncid, vid_gc, 'gc', ch_data(1).info.gcmodel);
    netcdf.putAtt(ncid, vid_aed, 'aed', ch_data(1).info.manufacturer);
    netcdf.putAtt(ncid, vid_units, 'units', ch_data(1).info.units);
    netcdf.putAtt(ncid, vid_experiment, 'experiment', ch_data(1).info.experiment);

    netcdf.close(ncid); % Close the file. 

end
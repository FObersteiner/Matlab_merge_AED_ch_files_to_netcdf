% --------------------------------------------------------------------------------
% Method : ch_merge_wrapper
%
% Description : Wrapper to read in binary .ch files found in a .d folder, 
%               merge thier data and save it as netcdf.
%
% Created : 2017-04, F.Obersteiner, florian.obersteiner@kit.edu
%
% Modifications: 170427 code cleanup, compiled version for Einar
%
merge_version = 1.1; % housekeeping parameter... update if modify code.
% --------------------------------------------------------------------------------
%
% --------------------------------------------------------------------------------
% called subroutines(s): 
% 	read_AED_ch_file
%   export_AED_ncdf_file
%


% check directory and generate file paths
basepath = 'D:\PROGRAMMING\debugging';
dir_name = uigetdir(basepath, 'Please select folder containing GHG-GC data (.d folders)');

if dir_name ~= 0
    dir_content = dir(dir_name); % get directory information (files etc.)
else
    return % aborted
end
 
all_files = string({dir_content().name}); % convert cell array to string array
w_match = contains(all_files, '.d', 'IgnoreCase', true); % t/f array of matches, .d folders

w_ix = uint32(find(w_match)); % indices of matches
folder_basenames = all_files(w_ix);
data_paths = string(dir_name) + "\" +folder_basenames+ "\";
n_paths = numel(data_paths);


% determine .ch file paths, columns = channels, rows = data folders
extensions = ["AED1A.CH","AED1B.CH","AED1C.CH","AED1D.CH", ...
              "AED1E.CH","AED1F.CH","AED1G.CH","AED1H.CH"] ;
          
n_channels = numel(extensions);          

w_aed_data = zeros(n_paths, n_channels, 'uint32'); % n row . m col

fnames_aed = strings(n_paths, n_channels); 

for i = 1:n_channels
    fnames_aed(:,i) = data_paths + extensions(i);
end


% write an output logfile with info on missing data
dir_out_log = fullfile(dir_name, '__export_log');
mkdir (dir_out_log);
file = string(dir_out_log)+ "\merge_log.txt"; 
file_id = fopen(file, 'w');
fprintf(file_id, '%s\r\n', "beginning export: "+string(datetime('now')));

for i = 1:n_channels % check for .ch files
    for j = 1:n_paths
        if exist(char(fnames_aed(j,i)), 'file') > 0
            w_aed_data(j,i)=j; % set index, = found
        else
            fprintf(file_id, '%s\r\n', "missing: "+fnames_aed(j,i));
            fnames_aed(j,i) = ""; % delete path as file not exists
            w_aed_data(j,i)=0; % set index to -1 = not found
        end 
    end
end


% generate output folder
dir_out_aed = fullfile(dir_name, '__merged_aed_data');
mkdir (dir_out_aed);

% for each .d folder, give valid .ch file paths to read_AED_ch_file
thresh = 4.0e+09; % intensity threshold; hihger values will be replaced by NaN

for j=1:n_paths
    ix_vd_paths = uint32(find(w_aed_data(j,:)));
    pos_paths = fnames_aed(j,:);
    vd_paths = pos_paths(ix_vd_paths);
    ch_data = AED_import_ch(vd_paths, thresh);
    AED_export_ncdf(ch_data, dir_out_aed, merge_version);
end


fprintf(file_id, '%s\r\n', dir_out_aed);
fprintf(file_id, '%s\t%s\r\n', string(j), " .d folders merged.");
fprintf(file_id, '%s\r\n', "export done: "+string(datetime('now')));
fclose(file_id); % close file

msg = msgbox('.ch data merged.');
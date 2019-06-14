% Hydrolight_MFile_Converter
% Jesse Bausell
% August 4, 2017
%
% Updated: June 11, 2019
%
% Upon completing radaitive transfer, Hydrolight outputs data into ascii
% files. Each Hydrolight run is output into two types of files: M and S
% files. These ascii files can be ungainly due to their format. 
% Hydrolight_MFile_Converter.m converts ascii files to hdf5 files, which
% appear as .mat files in matlab. They can therefore be used in both matlab 
% and python. Hydrolight_MFile_Converter is designed to convert multiple
% m-files into .mat/hdf5 files. Once User selects a directory (labeled excel 
% by Hydrolight). It creates a new folder called "mat" which it places next
% to the user-selected folder. This folder will contain all of .mat files;
% they will have the same names as the ascii files.

% 1. Compile list of m-files to convert
clear all; close all; clc; % Clear existing variables
dir_name = uigetdir; % Choose a directory of m-files to process
file_list = dir(dir_name); % List files in the selected directory

% 2. Create a new, empty directory for .mat files
slash = sort([regexpi(dir_name,'/') regexpi(dir_name,'\')]); 
% Find folder dividers. Works for both mac and pc (above).
dirName_FINAL = [dir_name(1:slash(end)) 'mat']; % Name and path for new folder
mkdir(dirName_FINAL) % Create the new folder in computer directory

for ii = 1:length(file_list)
    % This for-loop Cycles through the list of Hydrolight (ascii) m-files
    % and converts them into hdf5/.mat files one at a time

    % select an object in directory and determine if it has "M" in the name.
    M = regexp(file_list(ii).name,'M');   
    
    if ~isempty(M)
        % If the file has "M" in it's name (initial filter)
       if isequal(M(1),1) && ~isempty(strfind(file_list(ii).name,'.txt'))
            % If the file has "M" as the first letter in its name and the
            % file is a .txt file (more specific filter)
            Hydrolight_MReader_func(dir_name,file_list(ii).name,dirName_FINAL)
            % For files that fit these if-statement criteria,
            % Hydrolight_MReader_func will format them into hdf5/.mat files
       end    
    end    
end

function [m_squarE] = TextUploader(fid_M,coL,roW)
% TextUploader
% Jesse Bausell
% May 11, 2016
%
% This function uploads sections of m-files into matlab using textscan. 
% It accepts varying dimensions. This function must be used with FLOATING 
% NUMBERS ONLY.
% Inputs:
% fiD = file identifier
% coL = number of columns (tells function when to stop)
% roW = number of rows in the funciton.
%
% Outputs
% m_squarE = uploaded matrix of values
%% Read m-file section data into matlab

foddER = []; % empty format specifier array 

for ii = 1:coL
    % this for-loop adds a "float" to the format specifier array for every
    % column
    foddER = [foddER '%f']; % Add float to the format specifier array
end

foddER = [foddER '\r\n']; % Add end-of-line specifier
m_squarE = textscan(fid_M,foddER,roW); % read data into matlab.
m_squarE = cell2mat(m_squarE); % Convert cell array into double array


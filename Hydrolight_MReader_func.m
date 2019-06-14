function Hydrolight_MReader_func(dirNAME,fileNAME,dirName_FINAL)
% Hydrolight_MReader_func
% Jesse Bausell
% May 11, 2016
%
%
% This matlab function is designed to take all data from a hydrolight M-file and
% put it into a matlab structure. It then saves it as a hdf5/.mat file.
% Within the hdf5/.mat file, data is placed into a matlab structure. If
% opening these files in python, data is arranged similarly to a
% dictionary.
%
% Requires TextUploader.m 
% Modified from Hydrolight_MReader
%
% Inputs: 
% dirNAME - folder containing m-files (ascii) 
% fileNAME - Hydrolight m-file for reformatting to .mat/hdf5
% dirName_FINAL - newly-made directory for repositing newly-created
% .mat/hdf5 files
%% 1. First, open the file and assign file identifier

fid_M = fopen([dirNAME '/' fileNAME]); % Open m-file and assign file identifier
Hydro_OUTPUT.name = fileNAME; 
%creates a structure and saves the original name of the file so it can be IDed later

for ii = 1:4 
    %for-loop to eliminate unimportant file headers (upper 4)   
    fgetl(fid_M); % Extract line of ascii file    
end

%% 2. Function cycles through m-file and collects Hydrolight outputs data 
% These data are given variable names based on their titles.

while 1 
    % This while-loop cycles through the ascii file section by section. It
    % detects the beginning of each section by identifying the header,
    % comprised of Roman characters (a-z). Upon identifying the variables
    % (by the section header), it reads the numerical matrices into matlab
    % and incorporates them into a matlab structure as "fields".
       
    titlE = cell(3,1); %creates a reusable empty cell array to store header lines
    for ii = 1:3 
        % Every time the while loop starts over again, remove the first
        % three headers (identifying data) and place them into the empty
        % cell array for safe keeping
        titlE{ii} = fgetl(fid_M); % Get header line of ascii file  
    end
        
    if ~isempty(regexpi(titlE{1},'backscat ratio bb/b')) 
    % break the while statement towards the end of the ascii file, as soon
    % as the header "backscat ratio bb/b" is reached. Program author does
    % not use these data, so he decided that it was a convenient place to
    % stop.        
        fclose(fid_M); % close the m-file
        % save Hydro_OUTPUT matlab structure as a .mat/hdf5 file (below)
        save([dirName_FINAL '/' fileNAME(1:end-4)],'Hydro_OUTPUT','-v7.3'); 
        break % break the while-loop    
    end
         
    % Part A: Assign reference variables. These will reset every time the
    % while-loop recycles:
    numBIND = regexpi(titlE{1},'[0-9]'); % Find array of numerical indices of integers in the title
    numBIND = flip(numBIND); % Flip the indices so that they are in reverse order
    tickER = 0; % Reference variable to switch between finding "columns" and "rows"
    coL = NaN; % NaN variable to represent the number of columns in the data matrix
    roW = NaN; % NaN variable to represent the number of rows in the data matrix
    anchOR = 1; % Stationary reference index used to find row and column values
    
    for jj = 1:length(numBIND)-1  
        % This for-loop cycles through the numbers in the header above each
        % section of data and determines the number of columns and the number
        % of rows in each of the 2D data matrices below the header. 
   
        % Find the relative locations of header integers by determining
        % the differences between adjacent numbers in numBIND. jj is the
        % integer of interest, and jj+1 is the one next to it (below). 
        diFF = numBIND(jj) - numBIND(jj+1); 
        
        if isequal(tickER,0) && ~isequal(diFF,1)
           % Number of columns (appearing first in header) has yet to be
           % determined and adjacent numbers in numBIND are NOT next to
           % each other in the section header of m-file.
            coL = titlE{1}(numBIND(jj):numBIND(anchOR)); % Extract column number as string     
            coL = str2double(coL); % Convert string to integer           
            % Re-calicbrate reference variables to search for row number
            % (below)
            tickER = tickER + 1; anchOR = jj+1; % Re-calibrate reference variables
            
        elseif isequal(tickER,1) && ~isequal(diFF,1)
            % Number of columns has been deciphered, number of rows has yet
            % to be determined. Indices are NOT right next to each other,
            % indicating that Hydrolight_MReader_func can stop searching
            % for the indices.       
            roW = titlE{1}(numBIND(jj):numBIND(anchOR)); % Extract row number as string          
            roW = str2double(roW); % Convert string to integer            
            break % Break the for-loop            
        end                  
    end
    
    % Part B: Now that the dimensions (rows and columns) of the data matrix (below
    % header) have been determined, the next task is to 'grab' the data
    % below the section header and load it into the matlab structure,
    % Hydro_OUTPUT.    
    if ~isempty(regexpi(titlE{1},'[^k]PAR'))
        % if the section header is for PAR...
        titlE{4} = fgetl(fid_M); %PAR header has four lines, instead of three.      
        m_squarE = TextUploader(fid_M,coL,roW); % Place section data (below header) into matrix      

        % removed 4th header is actually part of the data, but it has
        % quotations, making it incompatible with the function
        % TextUploader. Here, the fourth header is cleaned up, converted into a
        % numerical array and re-attached onto the data matrix
        quotES = regexpi(titlE{4},'"'); % Find the indices of all quotations in 4th header row
        firstLINE = titlE{4}(quotES(end)+1:end); % Remote quotations from the 4th header row
        firstLINE = str2num(firstLINE); % Convert 4th row into a numerical array
        firstLINE = [-1 firstLINE]; % Add -1 to the beginning of the numerical array. This represents above-water!
        m_squarE = [firstLINE; m_squarE]; % concatenate first row onto data matrix
    else
        % the section header is NOT for PAR and thus 'cleaning up' the 4th
        % header line is not necessary     
        m_squarE = TextUploader(fid_M,coL,roW); % Place section data (below header) into data matrix                  
    end
    
    % Part C: Now that the data for the given section has been placed into a
    % numerical data matrix, the data matrix is incorporated into the
    % matlab structure Hydro_OUTPUT as a field. This structure is also
    % compatible with python, where it behaves like a dictionary.
 
    if coL <= 5 
        % If the number of columns in the aforementioned data matrix is
        % less than or equal to 5. This primarily pertains to above-water
        % AOPs. This script was initially written to include many depths
        % (more than 5), but it actually works just fine with 5 depths.
        % Nevertheless, data sections that fall within this section are
        % assumed to have different variables in every column. Thus it is
        % still useful.
    
        fingeR = regexpi(titlE{1},'"'); % Index quotations in the first header line
        fielD_NAME = titlE{1}(fingeR(1)+1:fingeR(2)-1); % Make the header name a string variable. Use text between first two quotations
        field_spacES = regexpi(fielD_NAME,' '); % Index all spaces in the first header line
        fielD_NAME(field_spacES) = ''; % Remove all spaces from the string variable
        % fielD_NAME variable will be used to create the aforementioned field of the
        % current matlab structure Hydro_OUTPUT     
        parEN = regexpi(titlE{1},'[[()]]'); % Indexes parenthasis 
        
        % Locate string between parenthesis. Add it to Hydro_OUTPUT as
        % "units" and create structure field for data units. Uses fielD_NAME 
        % as root of name (below)
        Hydro_OUTPUT.([fielD_NAME '_units']) = titlE{1}(parEN(1)+1:parEN(end)-1); % Create structure field for units
        
        spacES = regexpi(titlE{3},' '); % Index spaces in third line of section header
        titlE{3}(spacES) = ''; % Eliminate indexed spaces in third line of section header
        fingeR3 = regexpi(titlE{3},'"'); % Index quotations in the third line of section header 
        keY = 1; % Create reference variable for upcoming for-loop.
    
        for kk = 3:2:length(fingeR3)
            % This for-loop subdivides different columns (assumed to be 
            % different variables into different fields using a combination
            % of first and third headers (second header previously used for
            % units. The loop extracts these one at a time.
            
            appeND = titlE{3}(fingeR3(kk)+1:fingeR3(kk+1)-1); % third header subtitle
            
            if regexpi(appeND,'K_PAR')
                % If the third header subtitle has K_PAR in it
                appeND = 'K_PAR'; % Rename the header subtitle ot K_PAR
            end
    
            % Create structure field by combining title (first header line)
            % and subtitle (third header section between quotations). Match
            % the header with the appropriate matrix column.
            Hydro_OUTPUT.([fielD_NAME '_' appeND]) = m_squarE(:,keY); 
            keY = keY+1; % Increase reference variable by 1 to move onto the next column      
        end
        
        
    else
        % If the header section represents a 2D matrix for which rows
        % represent wavelengths and columns represent depths. This is
        % primarily in-water AOPs.
        
        % Part A: Create wavelength array structure field
        Hydro_OUTPUT.lamda = m_squarE(:,1); % designates a structure field as wavelength array

        % Part B: Create in-water AOP matrix structure field
        % First, Create field name for Hydro_OUTPUT matlab structure
        fingeR = regexpi(titlE{1},'"'); % Index quotations in first line of section header
        fielD_NAME = titlE{1}(fingeR(1)+1:fingeR(2)-1); % Remove quotations from section header
        field_spacES = regexpi(fielD_NAME,' '); % Index spaces in section header
        fielD_NAME(field_spacES) = ''; % Remove spaces from section header
        % Next, Designate field of matlab structure as an in-water AOP matrix.
        % Columns = depth, rows = wavelengths (line below)
        Hydro_OUTPUT.(fielD_NAME) = m_squarE(:,2:end); 

        % Part C: Create units structure field for in-water AOP matrix
        parEN = regexpi(titlE{1},'[[()]]'); % Index parentheses in first row of section header. This is units.    
        if isempty(parEN)
            % Units section of header is empty
            Hydro_OUTPUT.([fielD_NAME '_units']) = 'ratio'; % List units in structure field as a ratio   
        else
            % Units section contains units of measurement
            Hydro_OUTPUT.([fielD_NAME '_units']) = titlE{1}(parEN(1)+1:parEN(end)-1); % List the units in the structure field                
        end
        
        % Part D: Create depth array for in-water AOP matrix
        fingeR3 = regexpi(titlE{3},'"'); % index quotations in the third row of section header
        keY = 1; % Reset reference variable for the for-loop on the next iteration (unrelated to finding depth)
        deptH = titlE{3}(fingeR3(end)+1:end); % Retrieve the character array of depth values
        deptH = str2num(deptH); % Convert the character array into numerical values

        if ~isempty(regexpi(titlE{3},'in air'));
            % If the first field of header line three is "in-air"
            deptH = [-1 deptH]; % concatenate -1 on the front of the depth array        
            Hydro_OUTPUT.([fielD_NAME '_depth']) = deptH; % create structure field for depth           
        else  
            % If the first field of header line three is NOT "in-air"
            Hydro_OUTPUT.([fielD_NAME '_depth']) = deptH; % create structure field 
            % (do not concatenate -1 to the beginning)
        end   
    end
end
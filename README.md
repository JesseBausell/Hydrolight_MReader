# Hydrolight_MReader
Re-configures data from Hydrolight m-files into MAT files (HDF5 based format). 
Language: Matlab

Description: Hydrolight is a radiative transfer numerical model that computes apparent optical properties (AOPs) for natural waterbodies. It is a common and important tool in the fields of biological oceanography, satellite oceanography, ocean optics, and remote sensing more generally. Hydrolight outputs data into two ascii file formats: m-files and s-files. Both contain the same data, but these data are configured differently. The former organizes data based on specific optical property (e.g. radiance, downwelling irradiance, etc.), while the latter orients data according to wavelength. 

Hydrolight_MReader takes data contained inside m-files and re-configures it into Matlab version 7.3 MAT files. These files use a HDF5-based format, which enables them to be treated as HDF5 files by other software packages and programing languages (e.g. Python). MAT files contain a matlab structure whose field names consitute Hydrolight-generated AOPs. Field names are derived from ascii data headers. These files can also be 

User Instructions:
Run Hydrolight_MReader. User will be prompted to select a FOLDER containing Hydrolight m-files. Hydrolight_MReader will then re-constitute ALL M-FILES CONTAINED IN THE SELECTED FOLDER. It will output MAT files into a newly-created folder (MAT) placed adjacent to user-selected folder; MAT files will have the same name as m-files. 

Required Matlab scripts and functions:
Hydrolight_MReader - primary scipt
Hydrolight_MReader_func - nested function that re-configures m-file data into MAT file
TextUploader - nested function that reads ascii data into matlab

Output Structure:
  Hydro_OUTPUT - matlab structure containing m-file data
    Hydro_OUTPUT Fields:
      lamda - wavelengths at which an AOP is modeled
      VARIABLE SUFFIXES:
        name - name of m-file
        AOP_depth - depths at which an AOP array or matrix is modeled
        AOP_unit - AOP units of measurement
        lamda - array of AOP wavelengths (not a suffix, but nevertheless important)
      ** - all 2D matrices are oriented by wavelength (rows) depth (columns) **
      ** - all 1D arrays are oriented by wavelengths OR depth 
      Eo - Solar irradiance 
      Eo_quantum - quantum solar irradiance 
      Eou - upwelling scalar irradiance
      Eod - downwelling scalar irradiance
      Ed - downwelling plane irradiance 
      Eu - upwelling plane irradiance
      Lu - upwelling radiance
      PAR_PAR_Eo - phytosynthetically available radiation
      Kd - diffuse attenuation coefficient (Ed)
      Ku - diffuse attenuation coefficient (Eu)
      KLu - diffuse attenuation coefficient (Lu)
      KPAR - diffuse attenuation coefficient (PAR)
      R - irradiance reflectance 
      Ed_in_air_Ed_diffuse - above-water downwelling plane irradiance (diffuse component)
      Ed_in_air_Ed_dirrect - above-water downwelling plane irradiance (dirrect component)
      Ed_in_air_Ed_total - Ed_in_air_Ed_diffuse + Ed_in_air_Ed_dirrect
      Rrs_Rrs - remote sensing reflectance
      Rrs_Ed - Ed_in_air_Ed_total
      Rrs_Lw - Water-leaving radiance
      Rrs_Lu - Lu above-water
      

      

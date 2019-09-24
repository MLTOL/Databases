%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Author: M.L.Tolhuisen (m.l.tolhuisen@amc.uva.nl)
%%  
%%  Function:   runs an inventory of all available scans within a dataset
%%
%%
%%  Input:
%%      pathname    : rootfolder (string)
%%      docName     : name that will be given to the output excel sheet (include .xls in the name)
%%  Output:  
%%      inventList  : struct with all obtained data 
%%      NB! also saves an excel sheet from all obtained data
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 function [inventList]=inventScans(pathname,docName)

% you can add any DICOM tag within the struct:
inventList = struct('PtNr',{},'dirScan',{},'dateScan',{},'acquisitionTime',{},'studyTime',{},'sliceThickness',{},'ManufacturerModelName',{},'Private_0029_10xx_Creator',{},'ConvolutionKernel',{},'kEV',{},'RescaleIntercept',{},'RescaleSlope',{},'ImageType',{},'Rows',{},'Columns',{});

% first obtain all patient numbers that are available
ptnrs = dir(pathname);
for i =size(ptnrs,1):-1:1
    if ~ptnrs(i).isdir
        ptnrs(i) = [];
        continue
    end
    % remove folders starting with .
    fname = ptnrs(i).name;
    if fname(1) == '.'
        ptnrs(i) = [ ];
    end
end

% % remove redundant info
ptnrs=rmfield(ptnrs,{'folder','date','bytes','isdir','datenum'});

tr =1; 
% walk through all patients
for i = 1:size(ptnrs,1)
    
     
    ptnr = ptnrs(i).name 
    folders = regexp(genpath(strcat(pathname,'\',ptnr)),['[^;]*'],'match');
    
    %%%%%%% specific for IVO%%%
    countBL_FU(i).ptnrs = ptnr;
    
    % walk through all foldernames
    for k = 1:size(folders,2)
        % check whether dicom files are present within folder
        if any(size(dir([folders{k}  '/*.dcm' ]),1))
            
            % save PtNr
            inventList(tr).PtNr = ptnr;
            
            % get all scan names within folder
            scans = dir(folders{k});
            
            if size(cellfun('isempty',{scans.name}),2)>3
                %       load dicom info of second slice
                [dcminf]=dicominfo(char(strcat(folders{k},'\',scans(4).name))); %was scans(3).name
            else
                %       load dicom info of first slice
                [dcminf]=dicominfo(char(strcat(folders{k},'\',scans(3).name))); %was scans(3).name
            end
            
            %% IF ISFIELD
            inventList(tr).dirScan  = folders{k};
                       
            % set study date
            if isfield(dcminf,'StudyDate') && ~isempty(dcminf.StudyDate)
                inventList(tr).dateScan={dcminf.StudyDate};
            end
            
            if isfield(dcminf,'AcquisitionTime') && ~isempty(dcminf.AcquisitionTime) 
                inventList(tr).acquisitionTime =str2double(dcminf.AcquisitionTime);
            end
            
            if isfield(dcminf,'StudyTime') && ~isempty(dcminf.StudyTime) 
                inventList(tr).studyTime =str2double(dcminf.StudyTime);
            end
          
            if isfield(dcminf,'SliceThickness') && ~isempty(dcminf.SliceThickness)
                 inventList(tr).sliceThickness =dcminf.SliceThickness;
            end
            
            if isfield(dcminf,'ManufacturerModelName') && ~isempty(dcminf.ManufacturerModelName)
                inventList(tr).ManufacturerModelName =dcminf.ManufacturerModelName;
            end
            
            if isfield(dcminf,'Private_0029_10xx_Creator') && ~isempty(dcminf.Private_0029_10xx_Creator)
                inventList(tr).Private_0029_10xx_Creator =dcminf.Private_0029_10xx_Creator;
            end
            
            if isfield(dcminf,'ConvolutionKernel') && ~isempty(dcminf.ConvolutionKernel)
                inventList(tr).ConvolutionKernel =dcminf.ConvolutionKernel;
            end
            
            if isfield(dcminf,'KVP') && ~isempty(dcminf.KVP)
                 inventList(tr).kEV =dcminf.KVP;
            end
            
            if isfield(dcminf,'RescaleIntercept') && ~isempty(dcminf.RescaleIntercept)
                inventList(tr).RescaleIntercept =dcminf.RescaleIntercept;
            end
            
            if isfield(dcminf,'RescaleSlope') && ~isempty(dcminf.RescaleSlope)
                inventList(tr).RescaleSlope =dcminf.RescaleSlope;
            end
            
            if isfield(dcminf,'ImageType') && ~isempty(dcminf.ImageType)
                inventList(tr).ImageType =dcminf.ImageType;
            end
            
            if isfield(dcminf,'Rows') && ~isempty(dcminf.Rows)
                inventList(tr).Rows =dcminf.Rows;
            end
            
            if isfield(dcminf,'Columns') && ~isempty(dcminf.Columns)
                inventList(tr).Columns =dcminf.Columns;
            end
            tr = tr+1;
            
            
        
            
        end
    end
end


data_t=struct2table(inventList);
writetable(data_t,docName);






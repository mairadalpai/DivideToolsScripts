% This script was made by Maira Oneda Dal Pai and uses
% https://github.com/amforte/DivideTools

%% 
Filename = 'MDEntrada\mdedivide.tif';
% The DEM must be in a projected coordinate system (preferably WGS84UTM)
% and the horizontal and vertical axis must have the same measurement unit
% (e.g meters).

DEMFillSink = 'fill';
% Possible Options for DEMFillSink:
%

% - 'laplace': (default): laplace interpolation as implemented in roifill.
% - 'fill': elevate all values in each connected region of missing values 
%           to the minimum value of the surrounding pixels (same as the
%           function nibble in ArcGIS Spatial Analyst).
% - 'nearest': nearest neighbor interpolation using bwdist.
% - 'neighbors': this option does not close all nan-regions. It adds a
%                one-pixel wide boundary to the valid values in the DEM and
%                derives values for these pixels by a distance-weighted
%                average from the valid neighbor pixels. This approach does
%                not support the third input argument k.

BaseLevel = 700;

FDPreprocess = 'carve';
% Possible Options for FDPreprocess:
% - carve
% - fill
%
% The preprocess option ?carve? works similarly to the ?fill? option. The
% difference, however, is that FLOWobj won?t seek the best path along the
% centerlines of flat sections. Instead it tries to find the path through
% sinks that runs along the deepest path, e.g. the valley bottom.

OutputFilename = 'Output.shp';

%%

% Load DEM
DEM = GRIDobj(Filename);
DEM=resample(DEM,round(DEM.cellsize),'bicubic');

disp('DEM loaded');

% Fill sink
DEM.Z(DEM.Z == -9999);
DEM = inpaintnans(DEM, DEMFillSink);

% Calculate flow direction
FD = FLOWobj(DEM,'preprocess',FDPreprocess);

disp('FD calculated');

% Run Divide Stability
[AREA_OUT] = DivideStability(DEM, FD, 'verbose', true, 'shape_name', OutputFilename, 'outlet_control', 'elevation', 'min_elevation', BaseLevel);
[channel_head_values]=AcrossDivide(DEM,FD,AREA_OUT);
[channel_head_values2]=AcrossDivide(DEM,FD,AREA_OUT);
AlongDividePlot(channel_head_values)
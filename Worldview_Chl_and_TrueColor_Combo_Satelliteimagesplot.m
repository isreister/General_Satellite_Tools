
close all 
clear all
%%%%%%%%


%these images can be obtained by going to NASA worldview site, setting the
%projection to geographic (the chorophyll-a layer cannot be added if the
%projection is set to arctic). I like to plot the corrected True Color color as a base (MODIS-Terra or MODIS-Aqua for example) 
% Then add whatever chlorophyll-a you want (VIIRS or PACE are good options).
% The result shows chlorophyll-a wherever there are not clouds or land, which is a nice combo in the cloudy coastal Alaska region
% Click 'Take snapshot', adjust box to your desired area using the
% WorldView and downloade the GeoTIFF format. Load that tiff file in to the filenames section below. 

%This matlab script will then place the image into an m_map projection of
%your choosing, allowing you to adjust everything with the usual m_map
%parameters. This script has a dependency on an image of the colorbar in
%WorldView, and uses that image to recreate the the correct colormap.

%Author: Isaac Reister 9/29/2026

%% Load files
fileneames=cell(1,7);
filenames{1} = 'C:\Users\funkb\Documents\MATLAB\Research\data\Chapter3\satellite\april2024bloom_satilliteimages\snapshot-2024-04-24.tiff';
filenames{2} = 'C:\Users\funkb\Documents\MATLAB\Research\data\Chapter3\satellite\april2024bloom_satilliteimages\snapshot-2024-04-25.tiff';
filenames{3} = 'C:\Users\funkb\Documents\MATLAB\Research\data\Chapter3\satellite\april2024bloom_satilliteimages\snapshot-2024-04-26.tiff';
filenames{4} = 'C:\Users\funkb\Documents\MATLAB\Research\data\Chapter3\satellite\april2024bloom_satilliteimages\snapshot-2024-04-27.tiff';
filenames{5} = 'C:\Users\funkb\Documents\MATLAB\Research\data\Chapter3\satellite\april2024bloom_satilliteimages\snapshot-2024-04-28.tiff';
filenames{6} = 'C:\Users\funkb\Documents\MATLAB\Research\data\Chapter3\satellite\april2024bloom_satilliteimages\snapshot-2024-04-29.tiff';
filenames{7} = 'C:\Users\funkb\Documents\MATLAB\Research\data\Chapter3\satellite\april2024bloom_satilliteimages\snapshot-2024-04-30.tiff';



%Fontsize for plots
myf=14;

%boundaries for what you want to plot on the map
latlim=[55, 61.86];
lonlim=[ -152 -144];

%% Load colorbar image
% read colorbar image and process it
Co = imread('C:\Users\funkb\Documents\MATLAB\Research\data\Chapter3\satellite\Oceancolorwebcolormap.png');
%this is a png of th color bar from the worldview chlorphyll-a colormap. 


CT0 = permute(mean(im2double(Co),1),[2 3 1]);
CT0 = CT0([true; ~all(diff(CT0,1,1)==0,2)],:); % remove duplicate rows
% CT0 is now a fixed-length color table
% make it whatever length we want
N = 100; % specify the number of colors in table
na = size(CT0,1);
CT = interp1(linspace(0,1,na),CT0,linspace(0,1,N));
%%


%% Plotting
m_proj('mercator', 'lon', lonlim, 'lat', latlim);

for ix = 1:7


[A, R] = readgeoraster(filenames{ix});


%These must be read directly from R
lat_image = R.LatitudeLimits;
lon_image = R.LongitudeLimits;

A = flipud(A);
fontsize(myf,"points")

m_image(lon_image, lat_image, A);  % Requires A to be 2D (grayscale) or 3D (RGB)

% Optionally, overlay coastlines
m_gshhs_h('patch',[ 1.0000    1.0000    0.8196]);%mellow yellow
%no ticks
%m_grid('tickdir', 'in','yticklabels', [],'xticklabels',[]);
%ticks
m_grid('tickdir', 'in');
if ix~=1
    set(gca, 'YTick', []);
end
colormap(CT);  % uses the worldview colormap for chlorphyll-a
caxis(log10([0.01 20]));  % Set color limits

%comment on/off to add colorbar
if ix == 5
set(gcf,'Position',[2291 567 560 544])
cb = colorbar;
cb.Ticks = log10([0.01 0.03 0.1 0.3 1 3 10 20]);  % adjust tick spacing.
cb.TickLabels = {'0.01','0.03','0.1','0.3','1','3','10','20'};
ylabel(cb, 'Chlorophyll-a (mg/m³)');
cb.FontSize=myf;
end

%extract date
%[mytextspot(1),mytextspot(2)]=ginput(1);
mytextspot=[-0.0030  ,  1.3741];
myfilepath = filenames{ix};
% Extract using built-in digit patterns
dateStr = extract(myfilepath, digitsPattern(4) + "-" + digitsPattern(2) + "-" + digitsPattern(2));
% Convert to a proper datetime object
dateObj = datetime(dateStr, 'InputFormat', 'yyyy-MM-dd');
text(mytextspot(1),mytextspot(2),char(dateObj),'FontWeight','bold')

exportgraphics(gcf,['C:\Users\funkb\Documents\MATLAB\Research\Figures\Chapter 3\Finals\satblooms_day',char(string(ix)),'.png'],'Resolution',300)
end
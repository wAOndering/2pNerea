% Objective: generate small ROI to analyze GCaMP imaging after manual
% segmentation of the cells / note that based on some of those strategy
% automatic segmentation could probably be performed / implemented

% selecting chunck of scripts and pressing F9 on windows will execute the
% scripts

% Strategy: generate a template mask of dimensions of interest and
% assign feature based on those dimensions

% SELECT THE FILES
% CAREFUL all the segmentation 
path='Z:\Nerea\2 photon imaging\20181120 347'
cd(path) % assign the working directory to the folder of interest
files=dir('**/Segmentation*.mat') % look at all the segementation files

for ii = 1:length(files)
myFile=files(ii);
fileName=fullfile(myFile.folder, myFile.name);
disp(fileName)
disp([num2str(ii) '/' num2str(length(files))])

% STEP1: create the template matrix
% set the dimensions of the image and the seed/roi within the image
sizeMat=512; % dimensions of the image
sizeSeed=64; % multiple of 2 / size of the region of interest
randN=1:3:sizeSeed % 5 // create a set number of mask with given position

%create the seed/roi matrix to enable building the template matrix
seed=zeros(sizeSeed:sizeSeed)+1; % create a matrix of sizeSeed by sizeSeed that is initially filled with 0 but is the then filled with one as use +1 
main=seed; % copy the seed matrix into the main matrix important for later operations (one matrix will be static the other will morph during the loop)
val=(sizeMat/sizeSeed)-1; % this will generate a value to be able to build the matrix

% build first row of the template matrix using the seed matrix
for j=1:val
	main=horzcat(main,seed+j); % horizontal concatenation of the seed matrix
end

% build the remaining 
matrix=main;
for j=1:val
	seed=main+j*sizeMat/sizeSeed;% fill the seed row with the proper value
	matrix=vertcat(matrix,seed); % vertical concatenation of the seed first row matrix
end

% optional random number to assign only specific number of ROI
% geneerate random integer between 1 and the size of seed for 1 row and 20 random number
tempRand=~ismember(matrix, randN); % look at all the values which are not member of the random number generated
matrix(tempRand)=matrix(tempRand)*0;
imagesc(matrix)

% STEP2: modify the manually traced mat file
% load the manual segmentation file and isolate cells vs the rest
manualMatrix=load(fileName); % load the manual segmentation file in the test variable

%Notes: the seed and the neuropil mask strategy are slightly different and
%could have been used interchangeably 

% extract the cell feature
seeds=manualMatrix.L; % extract the segmentation itself stored in L of the structured object
seeds(seeds<=1)=0; % keep only cells // replace neuropil value by 0
seeds(seeds>1)=1000; % assign all the cells the value of 1000 // 

% extract the neuropil feature
neuropil=manualMatrix.L; % extract the segmentation itself stored in L of the structured object
neuropil(neuropil>1)=0; % select only neuropil // replace all the cell value by 0
neuropil=logical(neuropil); % assign this a logical array to perform selection later on

% this is one strategy to create a mask 
mask= (seeds == 1000); % create a logical matrix which identify all the cells 
matrix(mask)=0; %matrix(mask)*0; % assign the value of 0 in the template matrix for all the cells so that they are note taken into consideration during the analysis

% find area that meet a certain criteria (area close to cell in this case)
freq=tabulate(matrix(:)); % this create a frequency table all the seed/roi %matix(:) convert matrix to vector
nearCell=freq(freq(:,2)<sizeSeed^2); % seed/roi which are less than sizeSeed^2 are the one which are close to a cell as the cell reduce the area of the roi/seed 

temp=ismember(matrix, nearCell); % generate a logical matrix finding all the are inside the matrix which are near a cell 
%matrix(temp)=matrix(temp)+(sizeMat/sizeSeed)^2; % assign a specific value of those area near cell to be able to identify them easily - this one is good for graphical representation without stretching the color scale too much
matrix(temp)=matrix(temp)+100; % assign a specific value of those area near cell to be able to identify them easily - this is good for easier identification

% find area that meet a certain criteria (area within the neuropil and
% assign value)
% matrix(neuropil)=matrix(neuropil)+(sizeMat/sizeSeed)^2*2; % assign a specific value of those area in the neuropil
matrix(neuropil)=matrix(neuropil)+50; % assign a specific value of those area in the neuropil
matrix(matrix == 100)=matrix(matrix == 100)*0;
 

%% CODE BLOCK update
% here the purpuse is to limit the analysis to area outside of the not
% determined area that may contain cell blood vessel etc
% take the latest generated matrix
matrix(~neuropil)= 0;
matrix=changem(matrix, 0:length(unique(matrix))-1, unique(matrix));

%%
% save the structure output
updatedMatrix.L=matrix; % save the updatedMatrix inside a structure
updatedMatrix.ica=0; % generate the ica required to obtain the same segmentation mat file
save([fileName],'-struct','updatedMatrix');

store=[]
for il=0:length(unique(matrix))-1
tmp=[il, length(find(matrix==il))]
store=[store;tmp]
end
store=array2table(store, 'VariableNames', {'segId', 'areaPx'})


imagesc(matrix) % plot the matrix
ax=gca; % assign the gca to the variable ax
ax.GridAlpha = 1; % change the alpha value of the grid
ax.LineWidth = 1; % change the line width of the grid
grid on % turn on the grid

set(gca,'xtick',[0:sizeSeed:sizeMat]) % reposition the grid to match the segmentation
set(gca,'ytick',[0:sizeSeed:sizeMat]) % reposition the grid to match the segmentation
[filepath,name,ext] = fileparts(myFile.name)

writetable(store, [myFile.folder filesep name '-area.csv'])
saveas(gcf, [myFile.folder filesep name '.png'])
close all

end

% to verify the saved outcome can load back the output file and generate an
% image
% testIn=load('testOut.mat'); 




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Graphic creation section commented out
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%imagesc(matrix) used to plot matrix can easily derive an image of any
%matrix using imagesc

%{
% generate a plot of the final matrix
imagesc(matrix) % plot the matrix
ax=gca; % assign the gca to the variable ax
ax.GridAlpha = 1; % change the alpha value of the grid
ax.LineWidth = 1; % change the line width of the grid
grid on % turn on the grid

set(gca,'xtick',[0:sizeSeed:sizeMat]) % reposition the grid to match the segmentation
set(gca,'ytick',[0:sizeSeed:sizeMat]) % reposition the grid to match the segmentation
%}


                                      
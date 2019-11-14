%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   This programe is used to segment cardiomyocyte from the monolayer and 
%   get the movement/displacement of each cell 
%   Reference: 
%   Copyright since 2019 by AMNL. All Rights Reserved.
%   E-mail: 
%   2019 Original Version by Qili Zhao
%   2019-10-07 Modified Version by Xingjian Liu, Wenkun Dou
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
clc;

% Set up the centers matrix to storage all the centers
all_centers_x = zeros(1,1500);
all_centers_y = zeros(1,1500);

% Set up the area matrix to storage all the area information
all_area = zeros(1,1500);

% Set up the threhold for center and area
threCenter = 4;
threArea = 1.3;

% Define the 

num = 0;
Size_0 = 0;

%% pre-processing to get the reference cell position

display('--------------------------------------------------------')
display('Start pre-processing for generating the reference image!')
display('--------------------------------------------------------')

match=0;
match_i = 0;
for K = 1 : 25 : 500
    num = 0;
    Match_i=[];
    % load the image 
    imagePath = strcat('PrepareImage/',num2str(K),'.jpg');
    imageData = imread(imagePath);
    % segmentation
    [center_x, center_y, area] = cellSegmentation(imageData);
    
    % all profiles are set as cells in the first image 
    if(K == 1)
        for i = 1 : size(center_x,2)
            all_centers_x(i) = center_x(i);
            all_centers_y(i) = center_y(i);
            all_area(i) = area(i);
        end
        Size_0 = size(center_x,2);
    else
    % Filters the profiles by matching with other images
        for i = 1 : Size_0
            match = 0;
            if(all_area(i) > 0)
                for j = 1 : size(center_x,2)
                    if (abs(center_x(j)-all_centers_x(i)) < threCenter && ...
                            abs(center_y(j)-all_centers_y(i)) < threCenter && ...
                            all_area(i) < threArea*area(j) && all_area(i)>area(j)/threArea)
                        match = 1;
                        match_i = j;
                        Match_i = [Match_i;j];
                    end
                end
                
                % if mismatched clear the area and position
                if (match < 1)
                    all_area(i) = 0;
                    all_centers_x(i) = 0;
                    all_centers_y(i) = 0;
                end
            end
        end
    end
    
    % record the matched number
    matched_number = 0;
    for i = 1 : Size_0
        if (all_area(i) > 0)
            matched_number = matched_number + 1;
        end
    end
end

% copy the macthed cell centers and area as reference
ref_center_x = [];
ref_center_y = [];
ref_area = [];

for i = 1:size(all_centers_x,2)
    if (all_area(i) > 0)
        ref_center_x = [ref_center_x,all_centers_x(i)];
        ref_center_y = [ref_center_y,all_centers_y(i)];
        ref_area = [ref_area,all_area(i)];
    end
end


display('--------------------------------------------------------')
display('Generating the reference image Done!')
display('--------------------------------------------------------')

%% Main loop

display('--------------------------------------------------------')
display('Start calculating the cell centers!')
display('--------------------------------------------------------')

Results_x = [];
Results_y = [];
for K = 1:1:500
    Match_i=[];
    % load the image 
    imagePath = strcat('PrepareImage/',num2str(K),'.jpg');
    display(strcat('Now, processing Image_',num2str(K)))
    imageData = imread(imagePath);
    % segmentation
    [center_x, center_y, area] = cellSegmentation(imageData);
    
    % compare with the reference data
    for i = 1 : size(ref_center_x,2)
        for j = 1 : size(center_x,2)
            if(abs(center_x(j)-ref_center_x(i)) < threCenter && ...
                    abs(center_y(j)-ref_center_y(i)) < threCenter && ...
                    ref_area(i) < threArea*area(j) && ...
                    ref_area(i) > area(j)/threArea)
                Results_x(i,K)=center_x(j);
                Results_y(i,K)=center_y(j);
                break;
            end
        end
    end
end

display('--------------------------------------------------------')
display('Calculating the cell centers Done!')
display('--------------------------------------------------------')

display('--------------------------------------------------------')
display('Save centers to file!')
display('--------------------------------------------------------')

% save the center and write into txt file
cellNum=size(Results_x,1);
imgNum=size(Results_x,2);
ResPos_x=Results_x;
ResPos_y=Results_y;

% filter the false positions
for m = 1 : cellNum
     for k = 2 : 1 : imgNum
         if(ResPos_x(m,k) == 0)
             ResPos_x(m,k) = ResPos_x(m,k-1);
             ResPos_y(m,k) = ResPos_y(m,k-1);
         end
     end
    text_i1 = strcat('testingresults\Res_x\',num2str(m),'.txt');
    text_i2 = strcat('testingresults\Res_y\',num2str(m),'.txt'); 
    
    fid1 = fopen(text_i1,'wt');
    fprintf(fid1,'%g\n',ResPos_x(m,:));
    fid2=fopen(text_i2,'wt');
    fprintf(fid2,'%g\n',ResPos_y(m,:));
    
    fclose(fid1);
    fclose(fid2);
end
 
%  calculate the average position as the static position
avePos_x = zeros(cellNum,1);
avePos_y = zeros(cellNum,1);

for m = 1 : cellNum
    ave_x = 0;
    ave_y = 0;
    % why 50?
    for k= 1 : 1 : 50
        ave_x = ave_x + ResPos_x(m,k);
        ave_y = ave_y + ResPos_y(m,k);
    end
    ave_x = ave_x/50;
    ave_y = ave_y/50;
    avePos_x(m,1) = ave_x;
    avePos_y(m,1) = ave_y;
end

% avePos_x_floor = floor(avePos_x);
% avePos_y_floor = floor(avePos_y);

% calculate the displacement of cell

display('--------------------------------------------------------')
display('Start calculating the displacements of loaded cell!')
display('--------------------------------------------------------')

deltaRes_x = zeros(cellNum,imgNum);
deltaRes_y = zeros(cellNum,imgNum);
Displacement = zeros(cellNum,imgNum);

for m = 1 : cellNum
    for k = 1 : 1 : imgNum
        Displacement(m,k) = sqrt((ResPos_x(m,k)-avePos_x(m,1))^2+(ResPos_y(m,k)-avePos_y(m,1))^2); % ??? Res_x Res_y where
        deltaRes_x(m,k) = ResPos_x(m,k)-avePos_x(m,1);
        deltaRes_y(m,k) = ResPos_y(m,k)-avePos_y(m,1);
        if( Displacement(m,k) > 4 && k > 1)
            Displacement(m,k) = Displacement(m,k-1);
            deltaRes_x(m,k) = deltaRes_x(m,k-1);
            deltaRes_y(m,k) = deltaRes_y(m,k-1);
        end
    end
    text_i3=strcat('testingresults\deltaPos_x\',num2str(m),'.txt');
    text_i4=strcat('testingresults\deltaPos_y\',num2str(m),'.txt');
    text_i5=strcat('testingresults\Displacement\',num2str(m),'.txt');
    
    fid3 = fopen(text_i3,'wt');
    fprintf(fid3,'%g\n',deltaRes_x(m,:));
    
    fid4=fopen(text_i4,'wt');
    fprintf(fid4,'%g\n',deltaRes_y(m,:));
    
    fid5=fopen(text_i5,'wt');
    fprintf(fid5,'%g\n',Displacement(m,:));
    
    fclose(fid3);
    fclose(fid4);
    fclose(fid5);
end

display('--------------------------------------------------------')
display('Saved deltaPos_x deltaPos_y and Displacement!')
display('--------------------------------------------------------')






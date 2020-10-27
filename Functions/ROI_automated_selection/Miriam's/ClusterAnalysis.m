function ValidClusters= ClusterAnalysis(Components,N_Pi_perROI,in)
% This function clusters the data into clusters of approximately size
% defined by N_Pi_perROI and removes pixel that do not belong to a group of
% at least two adjacent pixel 

% Input: 
% Components: mxn with m=number of pixel and n=number of observations(f.e.
% x, y position, and time of response 

% Output: 
% ValidClusters: mx3 matrix with m=number of pixel, column 1-x and 2-y position 
% and 3- cluster values assigning each pixel to a defined cluster number  


D=pdist(Components, 'euclidean'); %calculates a distance matrix between each Pixel
Z=linkage(D, 'average'); %calculates a tree of hierarchical clusters
% P=cluster(Z,'maxclust'c) uses the hierarchical tree information to group
% the data into clusters depending on the maximal amount of clusters defined
% by 'maxclust'
% --> Since we don' know how many ROIs we want to have at the end but we
% know how big one cluster size can maximal be (due to size of T4\T5 axons) 
% we calculate a suitable variable for maxclust that assigns clusterSizes based on
% the Number of Pixel per ROI that would appoximately fit the size of
% T4\T5 axons (~1micron)

maxclusti=length(Z);  %start with maximal number of clusters (=amount of pixel, so that each Pixel would descirbe one ROI)
N_Clusts=0;
N_Clusts_i=0;

%while N_Clusts <= N_Clusts_i  

N_Clusts=nan(1,maxclusti);

for ll=1:maxclusti;
   
    P=cluster(Z,'maxclust',ll); %calculates clusters
    
    ALL_N=nan(1,maxclusti);
    for i=1:maxclusti %calculates how many pixels are assigned to each cluster
        N=find(P==i);
        ALL_N(i)=length(N);
    end
    
    N_Clusts(ll)=length(find(ALL_N>N_Pi_perROI-6 & ALL_N<N_Pi_perROI))...
        -length(find(ALL_N>N_Pi_perROI)); % Number of clusters that have as many pixels as described 
        % by N_Pi_perROI (-1, -2)
    
end 
  
[M,Mpos]=find(N_Clusts==max(N_Clusts),1,'last');

maxclust=Mpos;
P=cluster(Z,'maxclust',maxclust);

figure('Color', [1 1 1]) 
subplot(1,2,1)

Try1=nan(size(in.ch1(:,:,1)));
for i=1:length(P)
    ClusterType=P(i);
    Try1(Components(i,1),Components(i,2))=ClusterType;
end 
imagesc(Try1)
colormap('Colorcube');

title('All clusters')
% Extracting ROIs that have a minimum size of 2 Pixels in y
% or z and a maximal distance between pixels of N_Pi_perROI/2+1

ValidClusterI=[];
ValidClusterX=[];
ValidClusterY=[];
ii=1;

for i=1:max(P)
Pos=find(P==i);

XPos=Components(Pos,1);
YPos=Components(Pos,2);
DistanceX=abs(max(XPos)-min(XPos));
DistanceY=abs(max(YPos)-min(YPos));
    
if DistanceX<N_Pi_perROI/2+1  && DistanceY<N_Pi_perROI/2+1 && length(Pos)>1 
    
ValidClusterI=[ValidClusterI; (ones(length(Pos),1)*ii)];
ValidClusterX=[ValidClusterX; XPos];
ValidClusterY=[ValidClusterY; YPos];

ii=ii+1;
end
end 

ValidClusters=[ValidClusterX,ValidClusterY,ValidClusterI];
subplot(1,2,2)
Try1=nan(size(in.ch1(:,:,1)));
if length(ValidClusters)>0
    for i=1:length(ValidClusters(:,1))
        ClusterType=ValidClusters(i,3);
        Try1(ValidClusters(i,1),ValidClusters(i,2))=ClusterType;
    end 
    imagesc(Try1)
    colormap('Colorcube');
    %scatter(ValidClusters(:,1),ValidClusters(:,2),100,ValidClusters(:,3),'filled')

    title('Valid clusters (Distance bw P <= N Pi perROI/2+1)')
else 
    disp('No valid clusters found')
end


end


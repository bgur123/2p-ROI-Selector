function ValidClusters= ClusterAnalysis(Components_L1_OFF)


D=pdist(Components_L1_OFF, 'euclidean'); 
Z=linkage(D, 'average')

% Calculate a suitable variable for maxclust that assigns clusterSizes based on
% the Number of Pixel per ROI that would appoximately fit the size of
% T4\T5 axons (~1micron)


maxclust=length(Z);

N_Clusts=0;
N_Clusts_i=0;


while N_Clusts <= N_Clusts_i
    
    N_Clusts=N_Clusts_i;
    maxclust=maxclust-1;
    
    P=cluster(Z,'maxclust',maxclust);
    ALL_N=nan(1,maxclust);
    for i=1:maxclust
        N=find(P==i);
        ALL_N(i)=length(N);
    end
    
    N_Clusts_i=length(find(ALL_N==N_Pi_perROI))+length(find(ALL_N==N_Pi_perROI-1))...
        +length(find(ALL_N==N_Pi_perROI-2));
    scatter(Components_L1_OFF(:,1),Components_L1_OFF(:,2)*-1,100,P,'filled')
N_Clusts_i
  
  
end 
  
maxclust=maxclust+1;

end


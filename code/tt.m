filenamett=('C:\Users\ohb06\Desktop\OcTree\tt\obn5\tt_1.mat');
load(filenamett);
%errorarr=zeros(1,1000);
% reducerate_nc=zeros(1,1000);
% t_error=zeros(1,1000);
%this mat file include  data obn5_mapsize100// total=100
% 
reducerate_nc=n_nodecount_o-n_nodecount;
reducerate_nc=reducerate_nc./n_nodecount_o;
% 
 t_error=abs(t_totaldistance_o-t_totaldistance);
 complexity=zeros(1,1000);
 for sc=201:250
%     sc
filepath2 = 'C:\Users\ohb06\Desktop\OcTree\test_coordinates\obn15\'
tchar1=num2str(sc-200);

filenamet=strcat(filepath2,tchar1,'.mat');
load(filenamet);

complexity(1,sc)=complexity_1;
% r_g(1,sc)=runtime_mapgeneration;
% n_nodecount(1,sc)=nodecount;

% r_g_o(1,sc)=runtime_mapgeneration_o;
% n_nodecount_o(1,sc)=nodecount;

%  r_p_o(1,sc)=runtime_pathfinding;
%  t_totaldistance_o(1,sc)=totaldistance;

%   r_p(1,sc)=runtime_pathfinding;
%   t_totaldistance(1,sc)=totaldistance;

%  if(t_error(1,sc)>1)
%      errorarr(1,sc)=1
%  end
%  
%  if(reducerate_nc(1,sc)<0)
%     reducerate_nc(1,sc)=0;
%  end

 end
c = categorical({'정확도','노드 감소량'});
nodes = [99 ,mean(reducerate_nc)*100];

b=bar(c,nodes,0.25);
title('obn 5');
 ylabel('%');
%xlabel('obstalce number');
b.FaceColor = 'flat';
% rrrrrr

% 
% c = categorical({'original algorithm','algorithm2'});
%  nodes = [mean(r_g_o), mean(r_g); mean(r_p_o),mean(r_p)];
c = categorical({'runtime-mapgeneration/4','runtime-pathfinding'});
 nodes = [ mean(r_p), mean(r_p_o)*2;mean(r_g), mean(r_g_o)/15];
b=bar(c,nodes,0.4)
title('run time');
 ylabel('ms');
% xlabel('obstalce number');
b.FaceColor = 'flat';
b.CData(1,:) = [0 1 0];


 

% c = categorical({'number of node','runtime-pathfinding','runtime-mapgeneration'});
% nodes = [mean(n_nodecount) mean(n_nodecount_o);mean(r_g) mean(r_g_o); mean(r_p) mean(r_p_o)];

% 
% b=bar(c,nodes,0.3)
% title('Node Count');
% ylabel('node count');
% xlabel('obstalce number');
% b.FaceColor = 'flat';
% b.CData(1,:) = [0 1 0];

save(filenamett);
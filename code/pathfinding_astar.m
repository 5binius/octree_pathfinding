%Zahoor 
function pathfinding_astar(testsli, varargin)
%       load('D:\Paper simmulations\full visibility graph\obstacle map\obs_100ps.mat');
% load('D:\Paper simmulations\full visibility graph\obstacle map\exp10.mat');
%    load('D:\Paper simmulations\full visibility graph\obstacle map\exp10.mat');
% load('D:\Paper simmulations\full visibility graph\obstacle map\exp10.mat');
%   load('D:\Paper simmulations\full visibility graph\obstacle map\obs_50ps.mat');
%  load('D:\Paper simmulations\full visibility graph\obstacle map\obs_100ps.mat');
%     load('D:\Paper simmulations\full visibility graph\obstacle map\obs_75ps.mat');
%    load('D:\Paper simmulations\full visibility graph\obstacle map\dumyps.mat');
%    load('D:\Paper simmulations\dumyps2.mat')
load('C:\Users\ohb06\Desktop\OcTree\s2_d2.mat');

%% display map
%display axis
axis([0, maxX+maxobs, 0, maxY+maxobs, 0, maxZ*4/3])
xlabel('X');
ylabel('Y');
zlabel('Z');
grid on;
hold on;
%display obstacles
for iC=1:maxNum
    patch('Vertices', Obstacle(iC).vertices, 'Faces', my_faces, 'FaceColor', 'g');
end;



%% A* search algorithm
tic
  source = [1 1 1];



if (source(3) < M(source(1),source(2)) || destination(3) < M(source(1),source(2)))
    error = 'Source or destination is within obstacle areas';
    error
    return;
end
Node{1} = source;
Node{end+1} = destination;
Edge(end+1,end+1) = 1;
for j=2:length(Node)
    for iC=1:maxNum
        lofs = intersect3d(Node{1}, Node{j},Obstacle(iC).vertices, my_faces);
        if lofs == true
            break;
            
        end
    end
    for iC=1:maxNum
        lofs2 = intersect3d(Node{end}, Node{j},Obstacle(iC).vertices, my_faces);
        if lofs2 == true
            break;
        end
    end
    if lofs == false
        %cost = distancePoints3d(Node{i}, Node{j});
        Edge(1,j) = 1;
        Edge(j,1) = 1;
%         plotline(Node{i},Node{j},'r');
    end
    if lofs2 == false
        Edge(end,j) = 1;
        Edge(j,end) = 1;
    end
end


closedSet = {};
openSet{1} = 1;
cameFrom = zeros(length(Node),1);
gScore = zeros(length(Node),1);
gScore(1) = 0;
fScore = zeros(length(Node),1);
fScore(1) = distancePoints3d(Node{1}, Node{end});

 nb=[];

totaldistance = 0;
totalenergy = 0;
while ~isempty(openSet)
    current = openSet{end};
    
    if current == length(Node);
        total_path(1) = current;
        while cameFrom(current) ~= 1 

            total_path(end+1) = current
            plot3(Node{current}(1), Node{current}(2), Node{current}(3), 'or');
            plotline( (Node{cameFrom(current)}),(Node{current}), 'r');
            totaldistance = totaldistance + distancePoints3d(Node{current}, Node{cameFrom(current)});
            current = cameFrom(current);        
        end
    
        plot3(Node{current}(1), Node{current}(2), Node{current}(3), 'or');
        totaldistance = totaldistance + distancePoints3d(Node{current}, Node{1});
        plotline(Node{1}, Node{current}, 'r');

        break;
    end
    openSet(end) = [];
    closedSet{end+1} = current;
    
    %find neighbor waypoints
    nb = neighbor(current, Edge);

    
    for f=1:length(nb)

        if SearchCell(nb(f), closedSet)
            continue; 
          end
        

        % The distance from start to a neighbor
      

        % Discover a new Node
      if ~SearchCell(nb(f), openSet)
          
           openSet = AddCell(nb(f), openSet, fScore);
        tentative_gScore = gScore(current) +distancePoints3d(Node{current}, Node{nb(f)});
      elseif tentative_gScore >= gScore(nb(f));
            continue;
      end
 
        
    
        cameFrom(nb(f)) = current;
    gScore(nb(f)) = tentative_gScore;
  fScore(nb(f)) = gScore(nb(f)) + distancePoints3d(Node{nb(f)}, Node{end});
    
    end
end
totaldistance
%totalenergy = gScore(end)
toc

end
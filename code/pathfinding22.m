%% A* search using constructed visibility roadmap
% Zahoor Ahmad

for ss=1:10
clear all
    prompt = 'What is the original value? ';
ss= input(prompt)


% load('C:\Users\ohb06\Desktop\OcTree\test_map_o\map_2.mat');
% filename='C:\Users\ohb06\Desktop\OcTree\test_o\map_2.mat';



filepath='C:\Users\ohb06\Desktop\Octree\test_map\obn10\mapsize100';

  fc1='\';
    fc2 = num2str(ss+40);
    fc3='.mat';
char1=strcat(fc1,fc2,fc3);  %'\i.mat' file index
 filename=strcat(filepath,char1); 
load(filename);

filepath2 = 'C:\Users\ohb06\Desktop\OcTree\test\obn';
char2=num2str(maxNum);
filename2=strcat(filepath2,char2,'\');

 figure;
%% display map

%display axis
axis([0, maxmapsize, 0, maxmapsize, 0, maxmapsize]);
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
toc
tic
closedSet = {};
openSet{1} = 1;
gScore = zeros(length(Node),1);
gScore(1) = 0;
fScore = zeros(length(Node),1);
fScore(1) = distancePoints3d(Node{1}, Node{end});
cameFrom = zeros(length(Node),1);
nb=[];
%normalxy = cross([1 0 0], [0 1 0]);
totaldistance = 0;
totalenergy = 0;
while ~isempty(openSet)
    current = openSet{end};
    
    if current == length(Node);
        total_path(1) = current
        while cameFrom(current) ~= 1
            total_path(end+1) = current;
            plot3(Node{current}(1), Node{current}(2), Node{current}(3), 'or');
            plotline(Node{current}, Node{cameFrom(current)}, 'r');
            totaldistance = totaldistance + distancePoints3d(Node{current}, Node{cameFrom(current)});
            current = cameFrom(current)        
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
    %random neighbor
    %nb = randomneighbor(current, Edge);
    
    for i=1:length(nb)
        %Adding maneuverability control
%         if (current ~= 1) && (AngleCalc(Node{current}, Node{cameFrom(current)}, Node{nb(i)}) < minAngle)
%             continue;
%         end
%         if (current ~=1) && (AngleCalc(Node{current}, Node{cameFrom(current)}, Node{nb(i)}) == pi)
%             gScore(nb(i)) = gScore(nb(i)) + mass*2*sqrt(A*B)*0.5*sqrt(sqrt(B/A))/Eefficiency;
%         end
        if SearchCell(nb(i), closedSet)
            continue; % Ignore the neighbor which is already evaluated
        end
%         currentvector = [(Node{nb(i)}(1) - Node{current}(1)) (Node{nb(i)}(2) - Node{current}(2)) (Node{nb(i)}(3) - Node{current}(3))];       
%         vectorproj = [currentvector(1) currentvector(2) 0];
%        gamma = 2 * atan(norm(vectorproj*norm([1 0 0]) - norm(vectorproj)*[1 0 0]) / norm(vectorproj * norm([1 0 0]) + norm(vectorproj) * [1 0 0]));
        gamma = 0;
        % The distance from start to a neighbor
        tentative_gScore = gScore(current) +...
            EnergyCalc(Node{current}(3), Node{nb(i)}(3),mass, Eefficiency,...
            Vmin,distancePoints3d(Node{current}, Node{nb(i)}), A, B, Beta, gamma, Vwind);
       fScore(nb(i)) = tentative_gScore + 5*distancePoints3d(Node{nb(i)}, Node{end});
       
        % Discover a new node
        if ~SearchCell(nb(i), openSet)
            openSet = AddCell(nb(i), openSet, fScore);
        elseif tentative_gScore >= gScore(nb(i))
                continue; % This is not a better path.
        end
        
        % This path is the best until now. Record it!
        cameFrom(nb(i)) = current;
 gScore(nb(i)) = tentative_gScore;
 fScore(nb(i)) = gScore(nb(i)) + distancePoints3d(Node{nb(i)}, Node{end});
        
    end
end
totaldistance
totalenergy = gScore(end)
runtime_pathfinding=toc
save(filename)
%% file name
filename2=strcat(filename2,fc2,fc3);
 char5='.fig';
 figfilename=strcat(filename2,char5);
 savefig(figfilename);
 
 char6='.jpg';
 jpgfilename=strcat(filename2,char6);
 saveas(gcf,jpgfilename);
%  

 save(filename2);


 end
%plot3(X,Y,Z,'s','markerface','b');
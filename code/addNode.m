function [Node,nodecount]=addNode(X,Y,Z,bordera,borderb,cutHeight,Node,borderDis,nodecount)
%ADDNODE 이 함수의 요약 설명 위치
%   자세한 설명 위치
for icc=1:round(Z/cutHeight)
    Node{end+1}=[X+bordera*borderDis,Y+borderb*borderDis,0];
    nodecount=nodecount+1;
    
    if (Z>cutHeight*icc)
        Node{end+1}=[X+bordera*borderDis,Y+borderb*borderDis,icc*cutHeight];
        nodecount=nodecount+1;
    else
        Node{end+1}=[X+bordera*borderDis,Y+borderb*borderDis,Z+1];
        nodecount=nodecount+1;
    end

end


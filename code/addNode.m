function [Node,nodecount]=addNode(X,Y,Z,bordera,borderb,cutHeight,Node,borderDis,nodecount)
%ADDNODE �� �Լ��� ��� ���� ��ġ
%   �ڼ��� ���� ��ġ
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


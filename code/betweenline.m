function [result]= betweebline(lineup,linedown,X,Y)
%BETWEENLINE �� �Լ��� ��� ���� ��ġ
%   �ڼ��� ���� ��ġ
result= false;
if(lineup*X>Y && linedown*X<Y)
result= true;
end
end


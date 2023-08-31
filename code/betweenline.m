function [result]= betweebline(lineup,linedown,X,Y)
%BETWEENLINE 이 함수의 요약 설명 위치
%   자세한 설명 위치
result= false;
if(lineup*X>Y && linedown*X<Y)
result= true;
end
end


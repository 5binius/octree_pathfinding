%%intersect 3d
%    Input: a 3D segment S from point P0 to point P1
%           a 3D convex polyhedron OMEGA with n faces F0,...,Fn-1 and
%                Vi = a vertex for each face Fi
%                ni = an outward normal vector for each face Fi

function b = intersect3d(startp, endp, points, face)
%%for testing purpose
%{
    startp = [0 9 1];
    endp = [10 1 1];
    points = [2 2 0;8 2 0;8 2 8;2 2 8;2 8 8;2 8 0;8 8 0;8 8 8];
    face = [3 2 1 4;5 6 7 8;4 1 6 5;8 7 2 3;4 5 8 3;1 2 7 6];
    figure
    hold on;
    axis([-60,60, -60,60, -60,60])
    xlabel('X');
    ylabel('Y');
    zlabel('Z');
    grid on;
    plot3(startp(1), startp(2), startp(3), 'or');
    plot3(endp(1), endp(2), endp(3), 'ob');
    for i=1:length(points)
        plot3(points(i,1), points(i,2), points(i,3), 'og');
        %if i ~= length(points)
        %    plot3([points(i,1) points(i+1,1)],[points(i,2) points(i+1,2)],[points(i,3) points(i+1,3)], 'g');
        %else
        %    plot3([points(8,1) points(1,1)],[points(8,2) points(1,2)],[points(8,3) points(1,3)], 'g');
        %end
     
    end
%}
%%end of test section
%%begin the algorithm
    smallnum = 0.000001;
    b = true;
    if startp == endp
        b = false;
        return;
    end
    %for i=1:size(points)
    %    if (isequal(startp,points(i,:)) || isequal(endp,points(i,:)))
    %        b = false;
    %        return;
    %    end
    %end
    %initialize
    tE = 0;
    tL = 1;
    ds = [(endp(1) - startp(1)) (endp(2) - startp(2)) (endp(3) - startp(3))];
    for i=1:length(face)
        ni = -normalcalc(points(face(i,1),:), points(face(i,2),:), points(face(i,3),:));
        niv = points(face(i,1),:) + ni;
        %test
        %quiver3(points(face(i,1),1), points(face(i,1),2), points(face(i,1),3), ...
        %    niv(1), niv(2), niv(3));
        %patch('Vertices', points, 'Faces', face(i,:), 'FaceColor', 'r');
        N = -dot((startp - points(face(i,1),:)),ni);
        D = dot(ds,ni);
        if D == 0
            if N < 0
                b = false;
            else
                continue;
            end
        end
        t = N/D;
        if D < 0
            tE = max(t,tE);
            if (tE > tL)
                b = false;
            end
        else
            tL = min(tL,t);
            if tL < tE
                b = false;
            end
        end
    end
    pin = startp + tE*ds;
    pout = startp + tL*ds;
%%test section 
%{
    if b == 1
        plot3(pin(1), pin(2), pin(3), 'ob');
        plot3(pout(1), pout(2), pout(3), 'ob');
    end 
%}
%%end of test section
end
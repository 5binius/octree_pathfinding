% dot(u,v)   ((u).x * (v).x + (u).y * (v).y + (u).z * (v).z)
% perp(u,v)  ((u).x * (v).y - (u).y * (v).x)
function b = intersect2d(startp, endp, points) 
    %%for testing purpose
    startp = [0 9];
    endp = [10 1];
    points = [2 2;8 2;8 8;2 8];
    smallnum = 0.000001;
    b = true;
    if startp == endp
        b = false;
    end
    tE = 0;
    tL = 1;
    ds = [(endp(1) - startp(1)) (endp(2) - startp(2))];
    for i=1:length(points)
        if i ~= length(points)
            e = [(points(i+1, 1) - points(i,1)) (points(i+1, 2) - points(i,2))];
            gradv = [(startp(1) - points(i+1, 1)) (startp(2) - points(i+1, 2))];
        else
            e = [(points(1, 1) - points(i,1)) (points(1, 2) - points(i,2))];
            gradv = [(startp(1) - points(1, 1)) (startp(2) - points(1, 2))];
        end
        
        N = e(1)*gradv(2) - e(2)*gradv(1);
        D = -(e(1)*ds(2) - e(2)*ds(1));
        if abs(D) < smallnum
            if N < 0
                b = false;
            else
                continue;
            end
        end
        t = N/D;
        if D < 0
            if t > tE
                tE = t;
                if tE > tL
                    b = false;
                end
            end
        else
            if t < tL
                tL = t;
                if tL < tE
                    b = false;
                end
            end
        end        
    end
    p0 = [(startp(1) + tE*ds(1)) (startp(2) + tE*ds(2))];
    p1 = [(startp(1) + tL*ds(1)) (startp(2) + tL*ds(2))];
    %b = true;
    figure
    hold on;
    axis([0,10, 0,10])
    xlabel('X');
    ylabel('Y');
    %ylabel('Z');
    grid on;
    plot(startp(1), startp(2), 'or');
    plot(endp(1), endp(2), 'ob');
    for i=1:4
        plot(points(i,1), points(i,2), 'og');
        if i ~= 4
            plot([points(i,1) points(i+1,1)],[points(i,2) points(i+1,2)], 'g');
        else
            plot([points(4,1) points(1,1)],[points(4,2) points(1,2)], 'g');
        end
    end
    if b == 1
        plot(p0(1), p0(2), 'or');
        plot(p1(1), p1(2), 'or');
    end
    
end
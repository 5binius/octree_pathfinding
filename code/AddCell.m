function newset = AddCell(cell, set, scoreset)
    newset = set;
    if isempty(set)
        newset{end+1} = cell;
        return;
    end
    for i=length(set):-1:1
        if (scoreset(set{i}) < scoreset(cell))
            set{i+1} = set{i};
            set{i} = cell;
        elseif i == length(set)
            set{end+1} = cell;
            newset = set;
            return;
        else
            break;
        end
    end
    newset = set;
    
end
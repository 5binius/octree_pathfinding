classdef OcTree < handle
    properties
        Points;
        PointsBins;
        BinCount;
        BinBoundaries;
        BinDepths;
        BinParents = zeros(0,1);
        Properties;
    end
    methods
        function this=OcTree(pts,varargin)
            % This is the OcTree header line
            validateattributes(pts,{'numeric'},...
                {'real','finite','nonnan','ncols',3},...
                mfilename,'PTS');
            
            % Initialize a single bin surrounding all given points
            numPts = size(pts,1);
            this.BinBoundaries = [min(pts,[],1) max(pts,[],1)];
            this.Points = pts;
            this.PointsBins = ones(numPts,1);
            this.BinDepths = 0;
            this.BinParents(1) = 0;
            this.BinCount = 1;
            
            % Allow custom setting of Properties
            IP = inputParser;
            IP.addParamValue('binCapavity',ceil(numPts)/10);
            IP.addParamValue('maxDepth',inf);
            IP.addParamValue('maxSize',inf);
            IP.addParamValue('minSize',1000 * eps);
            IP.addParamValue('style','equal');
            IP.parse(varargin{:});
            this.Properties =  IP.Results;
            
            % Return on empty or trivial bins
            if numPts < 2
                return;
            end
            
            % Start dividing!
            this.preallocateSpace;
            this.divide(1);
            this.deallocateSpace;
        end
        
        % MATLAB performs better if arrays that grow are initialized
        % rather than grown during a loop. These two functions do just that
        % before and after the identification of new beens.
        function preallocateSpace(this)
            numPts = size(this.Points,1);
            numBins = numPts;
            if isfinite(this.Properties.binCapacity)
                numBins = ceil(2*numPts/this.Properties.binCapacity);
            end
            this.BinDepths(numBins) = 0;
            this.BinParents(numBins) = 0;
            this.BinBoundaris(numBins,1) = 0;
        end
        function deallocateSpace(this)
            this.BinDepths(this.BinCount+1:end) = [];
            this.BinParents(this.BinCount+1:end) = [];
            this.BinBoundaries(this.BinCount+1:end,:) = [];
        end
        function divide(this,startingBins)
            % Loop over each bin we will consider for division
            for i=1:length(startingBins)
                binNo = startingBins(i);
                
                % Prevent dividing beyond the maximum depth
                if this.BinDepths(binNo)+1 >= this.Properties.maxDepth
                    continue;
                end
                
                % Prevent dividing beyond a minimum size
                thisBounds = this.BinBoundaries(binNo,:);
                binEdgeSize = diff(thisBounds([1:3;4:6]));
                minEdgeSize = min(binEdgeSize);
                maxEdgeSize = max(binEdgeSize);
                if minEdgeSize < this.properties.minSize
                    continue;
                end
                
                % There are two conditions under which we should divide
                % this bin. 1: It's bigger than maxSize.
                %           2: It contains more points than binCapacity.
                oldCount = this.BinCount;
                if nnz(this.PointBins==binNo) > this.Properties.binCapacity
                    this.divideBin(binNo);
                    this.divide(oldCount+1:this.BinCount);
                    count;
                end
                if maxEdgeSize>this.Properties.maxSize
                    this.divideBin(binNo);
                    this.divide(oldCount+1:this.BinCount);
                    count;
                end
            end
        end
        
        function divideBin(this,binNo)
            % Gather the new points (a bit more efficient to cooy once)
            binPtMask = this.PointBins==binNo;
            thisBinsPoints = this.Points(binPtMask,:);
            
            % Get the old corner points and the new division point
            oldMin = this.BinBoundaries(binNo,1:3);
            oldMax = this.BinBoundaries(binNo,4:6);
            if strcmp('weighted', this.Properties.style) && any(binPtMask)
                newDiv = mean(thisBinsPoints,1);
            else
                newDiv = mean([oldMin; oldMax],1);
            end
            
            % Build the new boundaries of out 8 subdivisions
            minMidMax = [oldMin newDiv oldMax];
            newBounds = minMidMax([...
                1 2 3 4 5 6;
                1 2 6 4 5 9;
                1 5 3 4 8 6;
                1 5 6 4 8 9;
                4 2 3 7 5 6;
                4 2 6 7 5 9;
                4 5 3 7 8 6;
                4 5 6 7 8 9]);
            
            % Determine to which of these 8 bins each current point belongs
            binMap = cat(3,[0 0 0],[0 0 1],[0 1 0],[0 1 1],...
                [1 0 0], [1 0 1], [1 1 0], [1 1 1]);
            gtMask = bsxfun(@gt, thisBinsPoints, newDiv);
            [~,binAssignment] = max(all(bsxfun(@eq,gtMask,binMap),2),[],3);
            % [~,binAssignment] = ismember(gtMask,binMap,'rows');
            % A little slower than above.
            
            % Make the new bins and reassign old points to them
            newBinInds = this.BinCount+1:this.BinCount+8;
            this.BinBoundaries(newBinInds,:) = newBounds;
            this.BinDepths(newBinInds) = this.BinDepths(binNo)+1;
            this.BinParents(newBinInds) = binNo;
            this.PointBins(binPtMask) = newBinInds(binAssignment);
            this.BinCount = this.BinCount + 8;
        end
        
        function shrink(this)
            % shrink all bins to bound only the points they contain
            % WARNING : this operation creates gaps in final space not
            % covered by a bin. Only shrink OcTree structures when you only
            % intend to use the points used to create the tree to query the
            % tree space.
            binChildren = arrayfun(@(i)find(this.BinParents==i),1:this.BinCount,'Uh',0);
            binIsLeaf = cellfun(@isempty, binChildren);
            for i = find(binIsLeaf(:))'
                binShrink_reurse(i,true)
            end
            
            function binShrink_recurse(binNo, isLeafBin)
                % Build a list of all points that fall within one of the
                % bins to be checked, and the list of which point falls in
                % which bin.
                oldBoundaryMin = this.BinBoundaries(binNo,1:3);
                oldBoundaryMax = this.BinBoundaries(binNo,4:6);
                if isLeafBin
                    % Shrink bin based on child POINTS
                    ptsMask = this.PointBins==binNo;
                    if ~any(ptsMask)
                        % No points, shrink the bin to infinitely small
                        proposedBoundaries = [oldBoundaryMin oldBoundaryMin];
                    else
                        pts = this.Points(ptsMask,:);
                        proposedBoundaries = [...
                            max([oldBoundaryMin; min(pts,[],1)])...
                            min([oldBoundaryMax; max(pts,[],1)])];
                    end
                else
                    % Shrink bin based on child BINS
                    childBoundaries = this.BinBoundaries(binChildren{binNo},:);
                    proposedBoundaries = [min(childBoundaries(:,1:3),[],1)...
                        max(childBoundaries(:,4:6),[],1)];
                end
                if ~isequal(proposedBoundaries, [oldBoundaryMin oldBoundaryMax])
                    % We just shrunk the boundary. Make it official and
                    % check the parent
                    this.BinBoundaries(binNo,:) = proposedBoundaries;
                    parentBin = this.BinParents(binNo);
                    if parentBin > 0
                        binShrink_recurse(parentBin, false)
                    end
                end
            end
        end
        
        function binNos = query(this, newPts, queryDepth)
            % Get the OcTree bins that new query points belong to.
            % 
            % BINS = OT.query(NEWPTS) searches the OcTree object OT and
            % returns an N-by-1 vector of BINS giving the bin index in
            % which each of the N points in NEWPTS is contained. For any
            % query points outside all bins in OT, the index -1 is
            % returned.
            %
            % BINS = OT.query(NEWPT,DEPTH) restricts the search to DEPTH
            % levels in the OT bin tree. Note that the first bin
            % (containing all other bins in OT) has DEPTH = 1.
            
            if nargin<3
                queryDepth = max(this.BinDepths);
            end
            
            numPts = size(newPts,1);
            newPts = permute(newPts, [3 2 1]);
            binNos = ones(numPts,1)*-1;
            
            binChildren = arrayfun(@(i)find(this.BinParents==i),1:this.BinCount,'Un',0)';
            binIsLeaf = cellfun(@isempty, binChildren);
            ptQuery_recurse(1:numPts, this.BinParents==0,0)
            
            function ptQuery_recurse(newIndsToCheck_, binsToCheck, depth)
                % Build a list of all points that fall within one of the
                % bins to be checked, and the list of which point falls in
                % which bin.
                boundsToCheck = this.BinBoundaries(binsToCheck,:);
                [ptInBounds, subBinNo] = max(all(...
                    bsxfun(@ge,newPts(:,:,newIndsToCheck_),boundsToCheck(:,1:3)) & ...
                    bsxfun(@le,newPts(:,:,newIndsToCheck_),boundsToCheck(:,4:6))...
                    ,2),[],1);
                if ~all(ptInBounds)
                    % Special case usually when depth=0, where a point may
                    % fall outside the bins entirely. This should only
                    % happen once so let's fix it one and let subsequent
                    % code rely on all points being in bounds
                    binNos(newIndsToCheck_(~ptInBounds)) = -1;
                    newIndsToCheck_(~ptInBounds) = [];
                    subBinBo(~ptInBounds) = [];
                end
                binNosToAssign = binsToCheck(subBinNo);
                newIndsToAssign = newIndsToCheck_;
                binNo(newIndsToAssign) = binNosToAssign;
                
                % Allow a free exit when we reach a certain depth
                if depth>=queryDepth
                    return;
                end
                
                % Otherwise, for all of the points we just placed into
                % bins, check which of the children of those bins those
                % same points tall into
                [unqBinNos, ~, unqGrpNos] = unique(binNosToAssign);
                for i = 1:length(unqBinNos)
                    thisPtMast = unqGrpNos ==i;
                    if ~binIsLeaf(unqBinNos(i))
                        ptQuery_recurse(newIndsToCheck_(thisPtMask),...
                            binChildren{unqBinNos(i)}, depth+1)
                    end
                end
            end
        end
        
        function h = plot(this,varargin)
            % OcTree.plot plots bin bounding boxes of an OcTree object
            % H = OT.plot('name',value,...) allows tou to spcify any
            % properties of the bounding box lines that you would normally
            % supply to a plot(...,'name',value) command, and returns plot
            % object handles (one per bin) to H.
            hold on;
            h = zeros(this.BinCount,1);
            for i = 1:this.BinCount
                binMinMax = this.BinBoundaries(i,:);
                pts = cat(1, binMinMax([...
                    1 2 3; 4 5 6; 4 5 3; 1 5 3; 1 2 3;...
                    1 2 6; 4 2 6; 4 5 6; 1 5 6; 1 2 6; 1 2 3]),...
                    nan(1,3), binMinMax([4 2 3; 4 2 6]),...
                    nan(1,3), binMinMax([4 5 3; 4 5 6]),...
                    nan(1,3), binMinMax([1 5 3; 1 5 6]));
                h(i) = plot3(pts(:,1),pts(:,2),pts(:,3),varargin{:});
            end
        end
        
        function h = plot3(this,varargin)
            % OcTree.plot plots bin bounding boxes of an OcTree
            h = this.plot(varargin{:});
        end
    end
end
                
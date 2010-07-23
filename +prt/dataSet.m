function DS = dataSet(varargin)
% A helper function to create the correct type of prtDataDet
% Labeled, Unlabeled, etc
%
% Labeled = prtDataSet(X,Y)
% Labeled = prtDataSet(X,Y,str1,val1,str2,val2,...)
% UnLabeled = prtDataSet(X)
% UnLabeled = prtDataSet(X,str1,val1,str2,val2,...)

if isa(varargin{1},'prtDataSetClass')
    DS = prtDataSetClass(varargin{:});
    return;
elseif isa(varargin{1},'prtDataSetUnLabeled')
    DS = prtDataSetUnLabeled(varargin{:});
    return;
elseif isa(varargin{1},'prtDataSetRegress')
    DS = prtDataSetRegress(varargin{:});
    return;
else
    % Find string inputs
    charBool = cellfun(@ischar,varargin);
    if ~any(charBool) % No string inputs
        % We can assume that we have either 1 or 2 inputs
        % 1.  Unlabeled, varargin{1}==X
        % 2.  Labeled, varargin{1}==X, varargin{2}==Y
        switch nargin
            case 1
                DS = prtDataSetUnLabeled(varargin{:});
            case 2
                if classificationDecision(varargin{1},varargin{2})
                    DS = prtDataSetClass(varargin{:});
                else
                    DS = prtDataSetRegress(varargin{:});
                end
            otherwise
                error('prt:prtDataSet:InvalidInput','Invalid input.');
        end
    else % Some string inputs (parm value pairs)
        % We find the first string input, if it is input # 3,
        % We can assume varargin{1}==X and varargin{2}==Y therfore labeled
        % If it input # 2 we can assume unlabeled varargin{1}==X otherwise
        % we error.
        firstCharLoc = find(charBool,1,'first');
        
        switch firstCharLoc
            case 2
                DS = prtDataSetUnLabeled(varargin{:});
            case 3
                if classificationDecision(varargin{1},varargin{2})
                    DS = prtDataSetClass(varargin{:});
                else
                    DS = prtDataSetRegress(varargin{:});
                end
            otherwise
                error('prt:prtDataSet:InvalidInput','Invalid input.');
        end
    end 
end

function isClassifier = classificationDecision(X,Y)

% Relatively arbitrarly determine if there are "a lot" of unique Ys
isClassifier = length(unique(Y)) < size(X,1)/3;
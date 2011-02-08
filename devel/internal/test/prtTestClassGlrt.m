function result = prtTestClassGlrt
result = true;

% BASELINE generation, uncomment to run to generate new baseline
% Run numIter times to get idea distribution of percentage
% Pick off the lowest % correct and use that as baseline
% numIter = 1000;
% percentCorr = zeros(1,numIter);
% for i = 1:numIter
%     TestDataSet = prtDataGenUnimodal;
%     TrainingDataSet = prtDataGenUnimodal;
% 
%     classifier = prtClassGlrt;
%     classifier = classifier.train(TrainingDataSet);
%     classified = run(classifier, TestDataSet);
%     classes  = classified.getX > .5;
%     percentCorr(i) = prtScorePercentCorrect(classes,TestDataSet.getTargets);
% end
% min(percentCorr)


%% Classification correctness test.
baselinePercentCorr = .9400;

TestDataSet = prtDataGenUnimodal;
TrainingDataSet = prtDataGenUnimodal;

classifier = prtClassGlrt;
classifier = classifier.train(TrainingDataSet);
classified = run(classifier, TestDataSet);

classes  = classified.getX > .5;

percentCorr = prtScorePercentCorrect(classes,TestDataSet.getTargets);

if (percentCorr < baselinePercentCorr)
    disp('prtClassGlrt below baseline')
    result = false;
end


%% Check that cross-val and k-folds work

TestDataSet = prtDataGenUnimodal;
classifier = prtClassGlrt;

% cross-val
keys = mod(1:400,2);
crossVal = classifier.crossValidate(TestDataSet,keys);
classes  = crossVal.getX > .5;
percentCorr = prtScorePercentCorrect(classes,TestDataSet.getTargets);

if (percentCorr < baselinePercentCorr)
    disp('prtClassGlrt cross-val below baseline')
    result = false;
end

% k-folds

crossVal = classifier.kfolds(TestDataSet,10);
classes  = crossVal.getX > .5;
percentCorr = prtScorePercentCorrect(classes,TestDataSet.getTargets);
if (percentCorr < baselinePercentCorr)
    disp('prtClassGlrt kfolds below baseline')
    result = false;
end

%% Error checks

error = true;  % We will want all these things to error

classifier = prtClassGlrt;

try
    classifier.rvH0 = 1;
    error = false;  % Set it to false if the preceding operation succeeded
    disp('Set rvH0 to non prt Rv')
catch
    % do nothing
    % We can potentially catch and check the error string here
    % For now, just be happy it is erroring out.
end


%% Object construction
% We want these to be non-errors
noerror = true;

try
    classifier = prtClassGlrt('rvH1', prtRvMvn);
catch
    noerror = false;
    disp('GLRT param/val constructor fail');
end

try 
    classifier = prtClassGlrt;
    classifier.rvH0 = prtRvMvn;
catch
    noerror = false;
    disp('GLRT set rvH0 fail')
end
%% 
result = result & error & noerror;
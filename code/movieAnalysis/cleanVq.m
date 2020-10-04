
%% Settings

% Do we wish to correct for scaling differences between subjects in gaze
% amplitude?
affineCorrectFlag = false;

% Do we wish to impute missing values using the mean measure?
imputeFlag = false;

dataType = 'MOVIE';
%dataType = 'RETINO';

% Load the gaze data file from my local disk
gazeDataSource = ['/Users/aguirre/Dropbox (Aguirre-Brainard Lab)/TOME_processing/session2_spatialStimuli/pupilDataQAPlots_eyePose_' dataType '_July2020/gazeData.mat'];
gazeDataSave = ['/Users/aguirre/Dropbox (Aguirre-Brainard Lab)/TOME_processing/session2_spatialStimuli/pupilDataQAPlots_eyePose_' dataType '_July2020/gazeData_cleaned.mat'];

switch dataType
    case 'MOVIE'
        fieldNames = {'tfMRI_MOVIE_AP_run01','tfMRI_MOVIE_AP_run02','tfMRI_MOVIE_PA_run03','tfMRI_MOVIE_PA_run04'};
    case'RETINO'
        fieldNames = {'tfMRI_RETINO_PA_run01','tfMRI_RETINO_PA_run02','tfMRI_RETINO_AP_run03','tfMRI_RETINO_AP_run04'};
end

load(gazeDataSource,'gazeData')

% Loop over the fieldNames
for ff = 1:length(fieldNames)
    
    % Extract the data for the first acquisition
    vq = gazeData.(fieldNames{ff}).vq;
    
    % How many subjects do we have
    nSubs = size(vq,1);
    
    % How many measures do we have?
    nMeasures = size(vq,2);
    
    % Store a record of the location of the nan values
    vqNaN = isnan(vq);
    
    % Create a vector of weights based upon the mean RMSE in a run
    w = 1./nanmean(gazeData.(fieldNames{ff}).RMSE,2);
    
    % This is the mean across all subjects / time points for each measure
    % during the scanning period, weighted by the data quality
    inScan = gazeData.timebase>=0;
    vqMeanValBySubject = nanmean(vq(:,:,inScan),3);
    vqMeanValByMeasure = squeeze(nanmean(wnanmean(vq(:,:,inScan),repmat(w,1,size(vq,2),size(vq,3)),1),3));
    
    % These are the mean centered vectors
    vqCentered = vq - nanmean(vq,3);
    
    % Convert the stop radius to proportion change
    for ii = 1:nSubs
        vqCentered(ii,nMeasures,:) = vqCentered(ii,nMeasures,:) ./ vqMeanValBySubject(ii,nMeasures);
    end
    
    % Find the phase shift in the first measure that best aligns all
    % vectors
    frameSearch = -20:20;
    cc = nan(nSubs,nSubs);
    cr = nan(nSubs,nSubs);
    corVals = [];
    for xx=1:nSubs
        for yy = 1:nSubs
            if xx==yy
                continue
            end
            vecA = squeeze(vqCentered(xx,1,:));
            vecB = squeeze(vqCentered(yy,1,:));
            for tt = 1:length(frameSearch)
                corVals(tt) = corr(vecA,circshift(vecB,frameSearch(tt)),'Rows','pairwise');
            end
            cr(xx,yy) = max(corVals);
            cc(xx,yy) = frameSearch(find(corVals==max(corVals),1));
        end
    end
    
    % Apply the shift to temporally align the subjects
    frameShifts = [];
    for xx=1:nSubs
        for mm=1:nMeasures
            vec = squeeze(vqCentered(xx,1,:));
            frameShifts(xx) = round(nanmean(cc(:,xx)));
            vqCentered(xx,1,:)=circshift(vec,frameShifts(xx));
        end
    end
    
    % Store the shift values
    gazeData.(fieldNames{ff}).frameShifts = frameShifts;
    
    % Correct for scaling gaze differences between subjects
    if affineCorrectFlag
        
        % This is the mean vector across all subjects for each measure,
        % weighted by the data quality
        vqMeanVec = squeeze(wnanmean(vqCentered,repmat(w,1,size(vq,2),size(vq,3)),1));
        
        % Create a variable to hold the slope data, indexed by subject ID
        % number
        slopeByID = nan(nMeasures,45);
        
        % Find the slope that relates each individual subject to the mean vector
        slopes = [];
        for mm = 1:nMeasures
            for ii = 1:nSubs
                goodIdx = ~isnan(vqCentered(ii,mm,:));
                p = polyfit(squeeze(vqCentered(ii,mm,goodIdx)),vqMeanVec(mm,goodIdx)', 1);
                slopes(mm,ii) = p(1);
            end
            % Adjust the mean vector to remove compression
            vqMeanVec(mm,:) = vqMeanVec(mm,:) ./ mean(slopes(mm,:));
        end
        
        % Now loop through and adjust each subject's gaze data (but not
        % stop radius)
        slopes = [];
        vqCenteredScaled = nan(size(vqCentered));
        for mm = 1:nMeasures
            for ii = 1:nSubs
                goodIdx = ~isnan(vqCentered(ii,mm,:));
                % Find the slope that relates each individual subject to the mean vector
                p = polyfit(squeeze(vqCentered(ii,mm,goodIdx)),vqMeanVec(mm,goodIdx)', 1);
                slopes(mm,ii) = p(1);
                slopeByID(mm,str2double(gazeData.(fieldNames{ff}).nameTags{ii}(1:2))) = p(1);
                if mm == nMeasures
                    vqCenteredScaled(ii,mm,goodIdx) = vqCentered(ii,mm,goodIdx).*1;
                else
                    vqCenteredScaled(ii,mm,goodIdx) = vqCentered(ii,mm,goodIdx).*p(1);
                end
            end
            vqCenteredScaledSD(mm,:) = squeeze(nanstd(vqCenteredScaled(:,mm,:)))';
        end
        
        % Store the slopes value
        gazeData.(fieldNames{ff}).slopes = slopes;
        gazeData.(fieldNames{ff}).slopeByID = slopeByID;
        
        % Update the vqCleaned variable
        vqCleaned = vqCenteredScaled;
        
    else
        vqCleaned = vqCentered;
    end
    
    % Create a cleaned vq matrix that might have "imputed" missing values
    % with the mean across subject value, and adds back in the mean
    for mm = 1:nMeasures
        for ii = 1:nSubs
            
            if imputeFlag
                badIdx = isnan(vqCleaned(ii,mm,:));
                vqCleaned(ii,mm,badIdx) = vqMeanVec(mm,badIdx);
            end
            
            % Handle the mean for the non-pupil measures.
            if mm~=nMeasures
                switch dataType
                    case 'RETINO'
                        % If we are dealing with the RETINO data mean
                        % center the vector, following the assumption that
                        % subjects on the whole fixated the center of the
                        % screen
                        vqCleaned(ii,mm,:) = vqCleaned(ii,mm,:) - nanmean(vqCleaned(ii,mm,:));
                    case 'MOVIE'
                        % For the MOVIE data, we assume that everyone tends
                        % to look in the same place
                        vqCleaned(ii,mm,:) = vqCleaned(ii,mm,:) + vqMeanValByMeasure(mm);
                end
            end
        end
    end
    
    % Store the vqCleaned matrix back in the gazeData structure
    gazeData.(fieldNames{ff}).vqCleaned = vqCleaned;
    
    % Find a set of high-agreement frames that may be used for gaze
    % calibration for other subjects
    [frameSet, gazeTargets, gazeDisagreement] = bestByBin(vqCleaned,w);
    gazeData.(fieldNames{ff}).synthTargets.frameSet = frameSet;
    gazeData.(fieldNames{ff}).synthTargets.gazeTargets = gazeTargets;
    gazeData.(fieldNames{ff}).synthTargets.gazeDisagreement = gazeDisagreement;
    
    % Create a display of the synthesized targets
    figure
    plot(gazeTargets(1,:),gazeTargets(2,:),'ok');
    
    % Create a display of the data
    figure
    titles={'x gaze','y gaze','stop radius','nans'};
    for mm = 1:size(vq,2)
        subplot(nMeasures+1,1,mm)
        imagesc(squeeze(vqCleaned(:,mm,:)));
        axis off
        title(titles{mm});
    end
    subplot(nMeasures+1,1,mm+1)
    imagesc(squeeze(vqNaN(:,1,:)));
    axis off
    title(titles{mm+1});
    
end

% Save the cleaned data
save(gazeDataSave,'gazeData')





function y = wnanmean(x,w,dim)
% Implements a weighted mean in the presence of nan values

% Check that dimensions of X match those of W.
if(~isequal(size(x), size(w)))
    error('Inputs x and w must be the same size.');
end
% Check that all of W are non-negative.
if (any(w(:)<0))
    error('All weights, W, must be non-negative.');
end
% Check that there is at least one non-zero weight.
if (all(w(:)==0))
    error('At least one weight must be non-zero.');
end
if nargin==2
    % Determine which dimension SUM will use
    dim = min(find(size(x)~=1));
    if isempty(dim), dim = 1; end
end

y = nansum(w.*x,dim)./sum(w,dim);

end


function [frameSet, gazeTargets, gazeDisagreement] = bestByBin(vqCleaned, w)

nBinsPerDimension = 9;
minFramesPerBin = 9;

% Find the degree of disagreement across subjects in gaze location for
% each frame
vqMeanCleanedVec = squeeze(wnanmean(vqCleaned,repmat(w,1,size(vqCleaned,2),size(vqCleaned,3)),1));
gazeDisagreement = nanmean(sqrt( ...
    (squeeze(vqCleaned(:,1,:)) - squeeze(vqMeanCleanedVec(1,:))).^2 + ...
    (squeeze(vqCleaned(:,2,:)) - squeeze(vqMeanCleanedVec(2,:))).^2 ));

% First we divide the ellipse centers amongst a set of 2D bins across
% image space.
[gazeCenterCounts,~,~,binXidx,binYidx] = ...
    histcounts2(vqMeanCleanedVec(1,:),vqMeanCleanedVec(2,:),nBinsPerDimension);

% Anonymous functions for row and column identity given array position
rowIdx = @(b) fix( (b-1) ./ (size(gazeCenterCounts,2)) ) +1;
colIdx = @(b) 1+mod(b-1,size(gazeCenterCounts,2));

% Create a cell array of index positions corresponding to each of the
% 2D bins
idxByBinPosition = ...
    arrayfun(@(b) find( (binXidx==rowIdx(b)) .* (binYidx==colIdx(b)) ),1:1:numel(gazeCenterCounts),'UniformOutput',false);

% Identify the bins that have a sufficient number of frames to bother with
% looking for the best one
filledBinIdx = find(cellfun(@(x) size(x,2)>minFramesPerBin, idxByBinPosition));

% Identify the frame in each bin with the lowest gazeDisagreement
[~, idxMinGazeDisagreementWithinBin] = arrayfun(@(x) nanmin(gazeDisagreement(idxByBinPosition{x})), filledBinIdx, 'UniformOutput', false);
returnTheMin = @(binContents, x)  binContents(idxMinGazeDisagreementWithinBin{x});
frameSet = cellfun(@(x) returnTheMin(idxByBinPosition{filledBinIdx(x)},x),num2cell(1:1:length(filledBinIdx)));

% Keep the 9 frames with the lowest gaze disagreement
[~, sortIdx] = sort(gazeDisagreement(frameSet));
frameSet = frameSet(sortIdx(1:9));

% Order the frameSet in time
frameSet = sort(frameSet);

% Create a set of gaze targets
gazeTargets = vqMeanCleanedVec(1:2,frameSet);

% Trim the disagreement down to just the frameSet
gazeDisagreement = gazeDisagreement(frameSet);

end
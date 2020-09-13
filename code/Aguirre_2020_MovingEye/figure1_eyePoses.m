
clear
close all
sceneGeometry=createSceneGeometry('sphericalAmetropia',-5,'spectacleLens',-5);

azi = [-15 0 15];
ele = [15 0 -15];
stop = 2;

modelEyeLabelNames = {'retina' 'pupilEllipse' 'cornea' 'glint_01'};
modelEyePlotColors = {'.w' '-g' '.y' 'Qr'};
for x=1:3
    for y=1:3
        eyePose = [azi(x),ele(y),0,stop];
        [figHandle, plotHandles] = renderEyePose(eyePose, sceneGeometry,...
            'newFigure',true,'visible',true, ...
            'modelEyeLabelNames',modelEyeLabelNames,...
            'modelEyePlotColors',modelEyePlotColors);
        plotHandles(1).MarkerFaceColor = [0.75 0.75 0.75];
        plotHandles(2).LineWidth=2;
        plotHandles(3).MarkerFaceColor = [0.75 0.75 0];
        fileName = ['~/Desktop/Figure1_pose_[' num2str(azi(x)) ',' num2str(ele(y)) '].pdf'];
        export_fig(figHandle,fileName,'-Painters');
        
        close(figHandle)
    end
end
function [rotArrowHandlesBit,rotArrowHandlesVec] = addRotArrow(c,d,r,color,lw)

% Constant the defines the number of segments used to create each 90° arc
% segment
n = 50;

% A sphere is placed at the center of the rotation arrow, and it's radius
% is set to 1/6 of the radius of the arrow.
sphereRadius = r/6;

% Initialize the handle vectors
rotArrowHandlesBit = gobjects(0);
rotArrowHandlesVec = gobjects(0);

S = quadric.scale(quadric.unitSphere,[sphereRadius sphereRadius sphereRadius]);
S = quadric.translate(S,c);
boundingBox = [c(1)-sphereRadius c(1)+sphereRadius c(2)-sphereRadius c(2)+sphereRadius c(3)-sphereRadius c(3)+sphereRadius];
rotArrowHandlesBit(end+1) = quadric.plotSurface(S, boundingBox, color, 1);

% Now add the three segments of the arc. Switch on the dimension around
% which the arrow rotates
centerPoint = [c(1), c(2), c(3)];
switch d
    case 3
        pointA = [c(1)-r, c(2), c(3)];
        pointB = [c(1), c(2)-r, c(3)];
        rotArrowHandlesVec(end+1) = plotArc3D(pointA, pointB, centerPoint, n,color,lw);
        pointB = [c(1), c(2)+r, c(3)];
        rotArrowHandlesVec(end+1) = plotArc3D(pointA, pointB, centerPoint, n,color,lw);
        pointA = [c(1)+r, c(2), c(3)];
        rotArrowHandlesVec(end+1) = plotArc3D(pointB, pointA, centerPoint, n,color,lw);
        pointB = [c(1)+r, c(2)-r, c(3)];
        rotArrowHandlesBit(end+1) = mArrow3(pointA,pointB,'stemWidth',lw,'tipWidth',lw*5,'color',color,'FaceAlpha',0.5);
    case 2
        pointA = [c(1), c(2), c(3)+r];
        pointB = [c(1)-r, c(2), c(3)];
        rotArrowHandlesVec(end+1) = plotArc3D(pointA, pointB, centerPoint, n,color,lw);
        pointB = [c(1)+r, c(2), c(3)];
        rotArrowHandlesVec(end+1) = plotArc3D(pointA, pointB, centerPoint, n,color,lw);
        pointA = [c(1), c(2), c(3)-r];
        rotArrowHandlesVec(end+1) = plotArc3D(pointB, pointA, centerPoint, n,color,lw);
        pointB = [c(1)-r, c(2), c(3)-r];
        rotArrowHandlesBit(end+1) = mArrow3(pointA,pointB,'stemWidth',lw,'tipWidth',lw*5,'color',color,'FaceAlpha',0.5);
    case 1
        pointA = [c(1), c(2)-r, c(3)];
        pointB = [c(1), c(2), c(3)+r];
        rotArrowHandlesVec(end+1) = plotArc3D(pointA, pointB, centerPoint, n,color,lw);
        pointA = pointB;
        pointB = [c(1), c(2)+r, c(3)];
        rotArrowHandlesVec(end+1) = plotArc3D(pointA, pointB, centerPoint, n,color,lw);
        pointA = pointB;
        pointB = [c(1), c(2), c(3)-r];
        rotArrowHandlesVec(end+1) = plotArc3D(pointB, pointA, centerPoint, n,color,lw);
        pointA = pointB;
        pointB = [c(1), c(2)-r, c(3)-r];
        rotArrowHandlesBit(end+1) = mArrow3(pointA,pointB,'stemWidth',lw,'tipWidth',lw*5,'color',color,'FaceAlpha',0.5);
        
end

end

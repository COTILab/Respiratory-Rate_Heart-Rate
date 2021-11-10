function KLT_out_struct=KLT_Tracking(pointTracker_in,new_img,oldPoints,oldBBox)
%% Written on 19OCT21
%% Steps through Point-tracker function to return detected points and new BBox
tic
%% Assumes Pointtracker is initialized already
[points_new, isFound_new] = step(pointTracker_in, new_img);

visiblePoints_new =points_new(isFound_new, :);
oldInliers =oldPoints(isFound_new, :);


if size(visiblePoints_new, 1) >= 2 % need at least 2 points
    [xform, inlierIdx] = estimateGeometricTransform2D(...
        oldInliers, visiblePoints_new, 'similarity', 'MaxDistance', 300);
    %% INCREASE MAX DISTANCE FOR increased acceptance of points with lower confidence+ higher computational complexity
    oldInliers    = oldInliers(inlierIdx, :);
    visiblePoints_new = visiblePoints_new(inlierIdx, :);
    
    % Apply the transformation to the bounding box points
    oldBBoxPoints=bbox2points(oldBBox);
    bboxPoints = transformPointsForward(xform, oldBBoxPoints);
    
    % Insert a bounding box around the object being tracked
    bboxPolygon = reshape(bboxPoints', 1, []);
    BBox=[min(bboxPoints(:,1)), min(bboxPoints(:,2)),max(bboxPoints(:,1))-min(bboxPoints(:,1)),max(bboxPoints(:,2))-min(bboxPoints(:,2))];
    
    
    % Reset the points
    %% Adding to struct and setting points
    KLT_out_struct.newPoints = visiblePoints_new;
    KLT_out_struct.newBBox= BBox;
    
    setPoints(pointTracker_in, visiblePoints_new); % setting new points
    
    
    KLT_out_struct.pointTracker=pointTracker_in;
    
    % Get Point Confidence-- Basically HOW GOOD IS OUR FIT
    BBoxpoints=bbox2points(KLT_out_struct.newBBox); % query points
    BBoxpoints_conf= inpolygon( KLT_out_struct.newPoints(:,1), KLT_out_struct.newPoints(:,2),BBoxpoints(:,1),BBoxpoints(:,2));
    KLT_out_struct.Bboxpoints_conf=nnz(BBoxpoints_conf)/size( KLT_out_struct.newPoints,1);
    
    KLT_out_struct.UsedCascade=0; % DID NOT USE CASCADE
    KLT_out_struct.time_taken= toc;
    
    
    
    
    
    
    
    
end

end
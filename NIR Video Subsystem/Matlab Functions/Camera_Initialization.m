%%Written on 14SEP21
function VideoStreams=Camera_Initialization(modpath)

if count(py.sys.path, '') == 0
  insert(py.sys.path, int32(0), '');
end

P = py.sys.path;
if count(P,modpath) == 0
    insert(P,int32(0),modpath);
end


Initialization=py.CameraFunctions.initialize_ST01(); % initializes camera 
VideoStreams=py.CameraFunctions.start_IR_and_color();% Starts video streams

end
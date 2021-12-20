function splined_struct=Thermal_Spline_Data(inp_struct, fs)
splined_struct=inp_struct;
f_length=size(inp_struct.images,3);
max_time=max(inp_struct.timings);
new_timings=[min(inp_struct.timings):(1/fs):max_time];

splined_struct.splined_oned=spline(inp_struct.timings,inp_struct.oned_signal,new_timings); % new signal
splined_struct.new_times=new_timings-new_timings(1); % translating it so we start at 0...makes fourier way easier.

end
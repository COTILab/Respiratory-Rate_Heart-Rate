function [time_out_response]=Filtering_Signals(inp_time_resp,time_entries,filter_in,title_strs)

% filtered_recon{rr}=filter(b{rr},1,recon_signal{rr}); % APPLYING FILTER
for i=1:length(inp_time_resp)
    try
    time_out_response{i}=filter(filter_in{i},1,inp_time_resp{i}); % APPLYING FILTER
    catch
    time_out_response{i}=filter(filter_in,1,inp_time_resp{i}{1}'); % APPLYING FILTER
    end
    
end
Plotting_Mult_Arrays(time_entries, time_out_response,title_strs)

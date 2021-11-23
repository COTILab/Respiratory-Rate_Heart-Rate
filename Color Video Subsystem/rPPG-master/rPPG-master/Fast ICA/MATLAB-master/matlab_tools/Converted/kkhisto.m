%kkhisto 'Compute Histogram for Data Object'
% This MatLab function was automatically generated by a converter (KhorosToMatLab) from the Khoros khisto.pane file
%
% Parameters: 
% InputFile: i 'Input ', required: 'Input data object'
% InputFile: igate 'Gating Input', optional: 'Gating input data object'
% Integer: bins 'Number of bins ', default: 256: 'number of histogram bins'
% Toggle: oob 'Append out-of-bounds bins', default: 0: 'append a pair of bins for out-of-bounds data'
% Toggle: map 'If map exists, pull the value data through it', default: 0: 'if map exists, pull the value data through it'
% Toggle: normalize 'Normalize integrated histogram to [0..1]', default: 0: 'normalize integrated histogram to [0..1]'
% OutputFile: o1 'Histogram output object', required: 'histogram output data object'
% OutputFile: o2 'Integrated histogram object', optional: 'integrated histogram output object'
% Toggle: whole 'Whole dataset', default: 0: 'histogram whole data set at one time'
% Toggle: w 'Width', default: 0: 'include width in histogram unit'
% Toggle: h 'Height', default: 0: 'include height in histogram unit'
% Toggle: d 'Depth', default: 0: 'include depth in histogram unit'
% Toggle: t 'Time', default: 0: 'include time in histogram unit'
% Toggle: e 'Elements', default: 0: 'include elements in histogram unit'
%
% Example: [o1, o2] = kkhisto({i, igate}, {'i','';'igate','';'bins',256;'oob',0;'map',0;'normalize',0;'o1','';'o2','';'whole',0;'w',0;'h',0;'d',0;'t',0;'e',0})
%
% Khoros helpfile follows below:
%
%  PROGRAM
% khisto - Compute Histogram for Data Object
%
%  DESCRIPTION
% .I khisto
% computes histograms from data objects and stores the histogram data in
% another data object. An independent histogram is computed and stored for each 
% "unit" of data in the value segment of the input data object. 
% 
% A unit is 
% defined by the settings of the -w,-h,-d,-t,-e and -whole options. For example,
% if it is desired to compute an independent histogram for each WxH plane of a
% WHDTE=(512,480,1,1,256) object, then the unit we want is specified by supplying
% -w and -h and there will be 256 columns in the output object, each column
% being the histogram of a WxH plane. If we want a single histogram for the 
% whole data object, then
% we can obtain that result by supplying -whole, or -w -h -e, or -w -h -d -t -e
% since these combinations all cause the histogram unit to span all of the data.
% In this case the output object will have only a single column representing the
% histogram of the whole data set.
% 
% Histograms are stored in the output
% data object as column vectors in the WxH plane, one column per histogram unit.
% The computed histograms are stored
% in the order in which the units are accessed in the index order
% assigned to the value segment of the input data object. For example, for a
% value segment with WHDTE=(512,126,48,1,1), with a HxD unit (specified by -h -d)
% and the default index order (WHDTE), then there will be 512 columns in the 
% output object. The histogram for the HxD plane at (0,x,x,0,0) will be stored
% in column #0; that for the HxD plane at (1,x,x,0,0) will be stored in column
% #1, and that for the HxD plane at (N,x,x,0,0) will be stored in column #N.
% 
% Within each column, the count computed for bin #M is stored in row #M.
% 
% The histogram structure is specified by three parameters:
% 
%  "min side of minimum bin (starting value)" 15
% This number specifies the most negative number that can be trapped in the
% histogram array. Another way to define it is as the lower edge of first
% histogram bin.
% 
%  "binwidth" 15
% This is the width of each histogram bin.
% 
%  "bins" 15
% This is the total number of bins to be used in the histogram.
% 
% Values are assigned to bin index [0...bins-1] using the following procedure:
% 
% 
%        bin_num =  (input_val - mina) / binwidth
% 
%        if (input_val == min + bins*binwidth) bin_num = bins - 1
% 
% 
% With this arrangement, a bin collects input values ranging from the value of the
% left edge inclusively up to the value of the right edge exclusively. The
% exception is the last bin which collects values between the left and right
% edges inclusively (for both edges). If the computed bin_num falls
% outside of the array, then that data point is ignored in the histogram unless
% the -oob (append out-of-bounds bins) flag is supplied (described below).
% 
% If the input data object has a mask, then data points marked as invalid
% by the mask are ignored in the histogram calculations.
% 
% If a gate object is supplied, then only those data points with a value
% corresponding to non-zero in the gate image will be histogrammed. If a
% a gate object is supplied and the input has a mask, then data points are 
% ignored if masked "or" marked for "ignore" by the gate object. The gate 
% object must have the same value segment dimensions as the input object.
% 
% If the input data object has a map, then the data can be optionally
% pulled through the map before histogramming depending on the setting
% of the -map flag. If the input object has a map and -map is supplied, then
% the data will be pulled through the map before histogramming, potentially
% greatly multiplying the size of the data set. If the input object has a map 
% and -map is "not" supplied, then the histogram operation will be carried
% out on the "map indices" since that is what is stored in the data (this
% may be useful for data that has been pseudocolored, for example).
% 
% If the out-of-bounds flag (-oob) is supplied, then two additional bins will
% be placed at the end of the histogram. The first one will contain the
% number of data values that fell outside of the histogram array on the
% low (more negative) side, and the second will contain the number of data values
% that fell outside the histogram array on the high (more positive) side.
% This option is useful when little is known about the range of the data
% and one is not sure if the specified range of the histogram array is
% capturing all of the data.
% 
% The optional integrated histogram output object conforms to the same size and
% structure as the histogram output object except that it is of data type KDOUBLE
% and each histogram has been integrated. The integrated histograms can optionally
% be normalized (each histogram independently) to the range [0..1].
% 
% .I khisto
% utilizes data services internally and can process large data sets.
% All internal calculations are done in double precision. All input data
% is converted to KDOUBLE by data services after being read from the input data
% object. The output histogram data object is of type KULONG.
% Complex input data is converted before histogramming by taking the real part.
% 
%
%  
%
%  EXAMPLES
% 
% % khisto -i clouds.seq -o h.clouds -w -h -min 0
%   -binwidth 1 -bins 256
% will construct an interesting histogram data set from the cloud sequence.
% This sequence is comprised of a set of 582 512x480 frames, taken 15 seconds 
% apart, stored as WHDTE=(512,480,1,582,1). Each frame views the same
% section of sky as a storm develops.  The output is best visualized using 
% editimage with the SA pseudocolor option turned on. Here, the columns of the
% output image are for the frames in time order, so it is easy to see how
% the storm phases develop, modulate, and peak during this period.
%
%  "SEE ALSO"
% khistops(1)
%
%  RESTRICTIONS 
% 
% If the input data is complex, then you may want to convert it yourself using
% whatever means you require; the default for complex input is to take only
% the real part.
%
%  REFERENCES 
%
%  COPYRIGHT
% Copyright (C) 1993 - 1997, Khoral Research, Inc. ("KRI")  All rights reserved.
% 


function varargout = kkhisto(varargin)
if nargin ==0
  Inputs={};arglist={'',''};
elseif nargin ==1
  Inputs=varargin{1};arglist={'',''};
elseif nargin ==2
  Inputs=varargin{1}; arglist=varargin{2};
else error('Usage: [out1,..] = kkhisto(Inputs,arglist).');
end
if size(arglist,2)~=2
  error('arglist must be of form {''ParameterTag1'',value1;''ParameterTag2'',value2}')
 end
narglist={'i', '__input';'igate', '__input';'bins', 256;'oob', 0;'map', 0;'normalize', 0;'o1', '__output';'o2', '__output';'whole', 0;'w', 0;'h', 0;'d', 0;'t', 0;'e', 0};
maxval={0,1,2,0,0,0,0,1,0,0,0,0,0,0};
minval={0,1,2,0,0,0,0,1,0,0,0,0,0,0};
istoggle=[0,1,1,1,1,1,0,1,1,1,1,1,1,1];
was_set=istoggle * 0;
paramtype={'InputFile','InputFile','Integer','Toggle','Toggle','Toggle','OutputFile','OutputFile','Toggle','Toggle','Toggle','Toggle','Toggle','Toggle'};
% identify the input arrays and assign them to the arguments as stated by the user
if ~iscell(Inputs)
Inputs = {Inputs};
end
NumReqOutputs=1; nextinput=1; nextoutput=1;
  for ii=1:size(arglist,1)
  wasmatched=0;
  for jj=1:size(narglist,1)
   if strcmp(arglist{ii,1},narglist{jj,1})  % a given argument was matched to the possible arguments
     wasmatched = 1;
     was_set(jj) = 1;
     if strcmp(narglist{jj,2}, '__input')
      if (nextinput > length(Inputs)) 
        error(['Input ' narglist{jj,1} ' has no corresponding input!']); 
      end
      narglist{jj,2} = 'OK_in';
      nextinput = nextinput + 1;
     elseif strcmp(narglist{jj,2}, '__output')
      if (nextoutput > nargout) 
        error(['Output nr. ' narglist{jj,1} ' is not present in the assignment list of outputs !']); 
      end
      if (isempty(arglist{ii,2}))
        narglist{jj,2} = 'OK_out';
      else
        narglist{jj,2} = arglist{ii,2};
      end

      nextoutput = nextoutput + 1;
      if (minval{jj} == 0)  
         NumReqOutputs = NumReqOutputs - 1;
      end
     elseif isstr(arglist{ii,2})
      narglist{jj,2} = arglist{ii,2};
     else
        if strcmp(paramtype{jj}, 'Integer') & (round(arglist{ii,2}) ~= arglist{ii,2})
            error(['Argument ' arglist{ii,1} ' is of integer type but non-integer number ' arglist{ii,2} ' was supplied']);
        end
        if (minval{jj} ~= 0 | maxval{jj} ~= 0)
          if (minval{jj} == 1 & maxval{jj} == 1 & arglist{ii,2} < 0)
            error(['Argument ' arglist{ii,1} ' must be bigger or equal to zero!']);
          elseif (minval{jj} == -1 & maxval{jj} == -1 & arglist{ii,2} > 0)
            error(['Argument ' arglist{ii,1} ' must be smaller or equal to zero!']);
          elseif (minval{jj} == 2 & maxval{jj} == 2 & arglist{ii,2} <= 0)
            error(['Argument ' arglist{ii,1} ' must be bigger than zero!']);
          elseif (minval{jj} == -2 & maxval{jj} == -2 & arglist{ii,2} >= 0)
            error(['Argument ' arglist{ii,1} ' must be smaller than zero!']);
          elseif (minval{jj} ~= maxval{jj} & arglist{ii,2} < minval{jj})
            error(['Argument ' arglist{ii,1} ' must be bigger than ' num2str(minval{jj})]);
          elseif (minval{jj} ~= maxval{jj} & arglist{ii,2} > maxval{jj})
            error(['Argument ' arglist{ii,1} ' must be smaller than ' num2str(maxval{jj})]);
          end
        end
     end
     if ~strcmp(narglist{jj,2},'OK_out') &  ~strcmp(narglist{jj,2},'OK_in') 
       narglist{jj,2} = arglist{ii,2};
     end
   end
   end
   if (wasmatched == 0 & ~strcmp(arglist{ii,1},''))
        error(['Argument ' arglist{ii,1} ' is not a valid argument for this function']);
   end
end
% match the remaining inputs/outputs to the unused arguments and test for missing required inputs
 for jj=1:size(narglist,1)
     if  strcmp(paramtype{jj}, 'Toggle')
        if (narglist{jj,2} ==0)
          narglist{jj,1} = ''; 
        end;
        narglist{jj,2} = ''; 
     end;
     if  ~strcmp(narglist{jj,2},'__input') && ~strcmp(narglist{jj,2},'__output') && istoggle(jj) && ~ was_set(jj)
          narglist{jj,1} = ''; 
          narglist{jj,2} = ''; 
     end;
     if strcmp(narglist{jj,2}, '__input')
      if (minval{jj} == 0)  % meaning this input is required
        if (nextinput > size(Inputs)) 
           error(['Required input ' narglist{jj,1} ' has no corresponding input in the list!']); 
        else
          narglist{jj,2} = 'OK_in';
          nextinput = nextinput + 1;
        end
      else  % this is an optional input
        if (nextinput <= length(Inputs)) 
          narglist{jj,2} = 'OK_in';
          nextinput = nextinput + 1;
        else 
          narglist{jj,1} = '';
          narglist{jj,2} = '';
        end;
      end;
     else 
     if strcmp(narglist{jj,2}, '__output')
      if (minval{jj} == 0) % this is a required output
        if (nextoutput > nargout & nargout > 1) 
           error(['Required output ' narglist{jj,1} ' is not stated in the assignment list!']); 
        else
          narglist{jj,2} = 'OK_out';
          nextoutput = nextoutput + 1;
          NumReqOutputs = NumReqOutputs-1;
        end
      else % this is an optional output
        if (nargout - nextoutput >= NumReqOutputs) 
          narglist{jj,2} = 'OK_out';
          nextoutput = nextoutput + 1;
        else 
          narglist{jj,1} = '';
          narglist{jj,2} = '';
        end;
      end
     end
  end
end
if nargout
   varargout = cell(1,nargout);
else
  varargout = cell(1,1);
end
global KhorosRoot
if exist('KhorosRoot') && ~isempty(KhorosRoot)
w=['"' KhorosRoot];
else
if ispc
  w='"C:\Program Files\dip\khorosBin\';
else
[s,w] = system('which cantata');
w=['"' w(1:end-8)];
end
end
[varargout{:}]=callKhoros([w 'khisto"  '],Inputs,narglist);
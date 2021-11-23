function [out, p]= psfgen(varargin)
% [OUT,p] = PSFGEN('lambda', 520, 'na', 1.2, 'pixelsize', 100, 'sizevec', [25 25], 'method', 'airy', 'nphot',1, 'verbose',1)
%
% computes 2D (in focus) point spread function from the parameters. PSF is 
% centered on a middle (odd 'sizevec') or lower-right-next-to-middle 
% (even 'sizevec') pixel.
%
% lambda - wavelength of emission light [nm]
% NA - numerical aperture
% pixelisze - size of the image pixel [nm]
% sizevec - vector with number of pixels in X and Y direction
% method    - 'airy' - airy disk (scalar approximation)
%           - 'gauss' - gaussian approximation [Zhang et al., 2007]
% nphot - number of photons emmited by source 
% verbose - print out the parameters
%
% output parameters: 
% p.sigma, p.sigmapix - standard deviation (in nm or pixels, respectively) of the gaussian approximation [Zhang et
% al., 2007]
% p.alpha - parameter of the Airy disk
% default values:
% lambda = 520; %nm
% na = 1.2;
% pixelsize = 100; %nm
% method = 'airy';
% sizevec = [25 25];
% nphot = 1; (normalised to 1)


% default values:
p.lambda = 520; %nm
p.na = 1.2;
p.pixelsize = 100; %nm
p.method = 'airy';
p.sizevec = [25 25];
p.verbose = 1;
p.nphot = 1;

osf = 10; %oversampling factor for approximationg the integral of hte funciton over a pixel

% reading parameters
if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        if ~ischar (varargin{i}),
            error (['Unknown type of optional parameter name (parameter' ...
                ' names must be strings).']);
        end
        % change the value of parameter
        switch lower (varargin{i})
            case 'lambda'
                p.lambda = varargin{i+1};
            case 'na'
                p.na = varargin{i+1};
            case 'pixelsize'
                p.pixelsize = varargin{i+1};
            case 'sizevec'
                p.sizevec = varargin{i+1};
            case 'method'
                p.method = lower (varargin{i+1});
            case 'verbose'
                p.verbose = varargin{i+1};
            case 'nphot'
                p.nphot = varargin{i+1};
            otherwise
                % Hmmm, something wrong with the parameter string
                error(['Unrecognized parameter: ''' varargin{i} '''']);
        end;
    end;
end

p.sizevecorig=p.sizevec; 
p.sizevec=osf*p.sizevec;
p.pixelsizeorig=p.pixelsize;
p.pixelsize=p.pixelsize/osf; 


centervec = ceil(p.sizevec/2);
[X,Y] = meshgrid(1:p.sizevec(1), 1:p.sizevec(2));
out = zeros(p.sizevec);

% This is sqrt(variance) of the Gaussian approximation [Zhang et al., 2007]
p.sigma = sqrt(2)/(2*pi) * p.lambda/p.na;
p.sigmapix = p.sigma/p.pixelsize;

if strcmp (p.method, 'gauss') %gaussian approximation    
    out = p.nphot/(2*pi*p.sigmapix^2) * exp(-((X-centervec(1)).^2 + (Y-centervec(2)).^2)/(2*p.sigmapix^2));
elseif strcmp (p.method, 'airy') %airy pattern
    p.alpha = 2*pi * p.na/p.lambda;
    z=sqrt((X-centervec(1)).^2+(Y-centervec(2)).^2)*p.pixelsize;
    out = (real(besselj(1,p.alpha*z))./(p.alpha*z+eps)).^2;
    out(centervec(2),centervec(1))=0.25; %limit for x-> 0....
    out=p.nphot*out/sum(out(:)); %normalization
end

out=binsumImage(out,[osf,osf]); % this is approximationg hte integration of the continuous psf over pixel area. Correctly should be err functions...

if p.verbose %printout the parameters
    fprintf('Parameters:\n')
    p
end
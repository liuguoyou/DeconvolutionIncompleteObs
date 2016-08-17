% This is a script file that exemplifies the use of the Proposed-AD method.
% See the file README for more information.
% 
% It builds the 'running time' graph corresponding to the 'Superresolution' 
% experiment given in [1], i.e., the RMSE of the estimated images as a 
% function of running time, for the various tested methods.
% 
%   [1] M. Simoes, J. Bioucas-Dias, L. Almeida, and J. Chanussot, 
%        �A Framework for Fast Image Deconvolution with
%        Incomplete Observations,� IEEE Trans. Image Process.,
%        to be publised.

% % % % % % % % % % % % % 
% 
% Version: 1
% 
% Can be obtained online from: 
%   https://github.com/alfaiate/DeconvolutionIncompleteObs
% 
% % % % % % % % % % % % % 
% 
% Copyright (C) 2016 Miguel Simoes
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, version 3 of the License.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program. If not, see <http://www.gnu.org/licenses/>.
% 
% % % % % % % % % % % % % 
addpath('../src', '../src/utils', '../data');
% % % % % % % % % % % % % 
%
% This script has three steps. 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% I. It starts by generating the observed images. 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % 

% The following parameters can be
% modified to change the data generation:
if ~exist('total_iter','var')
    total_iter = 1e6; % Total number of iterations
end
if ~exist('error_min','var')
    error_min = 1e-3; % Minimum RMSE to terminate the algorithms
end
BlurDim = 3; % Dimensions of the blur's support
image = 'pavia'; % Image. Can be 'cameraman', etc. Check 'data_generation.m'
blur = 'uniform'; % Blur type. Can be 'gaussian', etc. Check 'data_generation.m'
BSNR = 50; % Blurred-Signal-to-Noise Ratio

% Generates the observed image
[ original_image, blur_kernel, observed_image ] = data_generation(image, blur, BlurDim, sqrt(BlurDim), BSNR);

% Loads the estimated image generated by AM after 1e6 iterations (reference
% images)
load('AM_final_sr', 'final_image_full');

% Prepare image mask
mask = zeros(size(observed_image));
% Superresolution
mask(1:BlurDim:end, 1:BlurDim:end) = 1;
observed_image = observed_image .* mask;

% Regularization parameter
lambda = 2e-4;

% % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% II. Next, it will run the algos and compare them to the reference images.
% % % % % % % % % % % % % % % % % % % % % % % % % % % % 

fprintf('Running... AM\n');
miu_1 = 1;
miu_2 = 1;
[ rmse_final_AM, time_AM, ~, ~, ~, ~, ~ ] = deblur_AM( observed_image, blur_kernel, mask, total_iter, lambda, miu_1, miu_2, original_image, final_image_full, error_min, 0, 50, 0);

fprintf('Running... ADMM-CG\n');
miu_1 = 1;
[ rmse_final_ADMM_CG, time_ADMM_CG, ~, ~, ~, ~, ~ ] = deblur_ADMM_CG( observed_image, blur_kernel, mask, total_iter, lambda, miu_1, original_image, final_image_full, error_min, 0, 5, 0);

fprintf('Running... CM\n');
miu_2 = 1e-6;
miu_1 = 0.99/(0.5+8*miu_2);
[ rmse_final_CM, time_CM, ~, ~, ~, ~, ~ ] = deblur_CM( observed_image, blur_kernel, mask, total_iter, lambda, miu_1, miu_2, original_image, final_image_full, error_min, 0, 200, 0);

fprintf('Running... Proposed 1\n');
miu_1 = 1;
miu_2 = 1;
[ rmse_final_Proposed1, time_Proposed1, ~, ~, ~, ~, ~ ] = deblur_Proposed( observed_image, blur_kernel, mask, total_iter, lambda, miu_1, miu_2, original_image, final_image_full, error_min, 0, 50, 0);

fprintf('Running... Proposed AD\n');
miu_1 = 1;
miu_2 = (BlurDim-1)/2;
[ rmse_final_ProposedAD, time_ProposedAD, ~, ~, ~, ~, ~ ] = deblur_Proposed( observed_image, blur_kernel, mask, total_iter, lambda, miu_1, miu_2, original_image, final_image_full, error_min, 0, 50, 0);

% % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% II. Lastly, it generates the graphs.
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

figure,semilogx(time_AM, rmse_final_AM, time_ADMM_CG, rmse_final_ADMM_CG, '-*', time_CM, rmse_final_CM, ':', time_Proposed1, rmse_final_Proposed1, '--', time_ProposedAD, rmse_final_ProposedAD, '-.', 'LineWidth', 1.5)
set(gca, 'FontName', 'Arial')
set(gca, 'FontSize', 12)
set(gca, 'LineWidth', 1.5)
xlabel('Running time [s]')
ylabel('RMSE')
legend('AM', 'ADMM-CG', 'CM', 'Proposed 1', 'Proposed AD')
axis([min(time_CM) max(time_CM) 0 max(rmse_final_AM)])
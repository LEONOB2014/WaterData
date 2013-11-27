function weighted_mean = calc_grid_weighted_mean2(data_array, data_weights)

% CALC_GRID_WEIGHTED_MEAN2 calculates the weighted mean of the data in
% data_array using the weights in data_weights
%
% INPUTS
% data_array = [X x Y x N] array of data with N instances of X, Y data
% data_weights = [X x Y] array of data weights
%
% TC Moran UC Berkeley 2011


num_iterations = size(data_array,3);

num_cells_total = sum(data_weights(:));

for yy = 1:num_iterations
    weighted_grid_data_total_yr = data_array(:,:,yy).*data_weights;
    weighted_grid_data_total_yr = weighted_grid_data_total_yr(:);
    i_nan = isnan(weighted_grid_data_total_yr);
    val_sum(yy) = sum(weighted_grid_data_total_yr(~i_nan));
    weighted_mean(yy) = val_sum(yy) / num_cells_total;
end %for yy





function flat_data = preprocess_flatten_data(data)
    global DEBUG;
    global DEBUG_DRAW_EVERY;
    FUNCTION_DEBUG = 0;
    
    % Prepare flat data output by assigning certain size table.
    flat_data = cell(length(data), 1, 1);

    % Define neutral projection matrix.
    neutral_projection_matrix = eye(3, 3);
    % Define vector that converts normal vector into projection matrix
    % applicable form.
    normalizer = [1 / sqrt(3), 1 / sqrt(3), 1 / sqrt(3)];

    % Go through all the data points.
    for data_index = 1:length(data)
        entry = data{data_index};
        % Calculate plane parameters using least square method.
        % https://stackoverflow.com/questions/1400213/3d-least-squares-plane.
        x = entry(:, 1);
        y = entry(:, 2);
        z = entry(:, 3);
        sum_x_x = sum(x .* x);
        sum_x_y = sum(x .* y);
        sum_y_y = sum(y .* y);
        sum_x_z = sum(x .* z);
        sum_y_z = sum(y .* z);
        sum_x = sum(x);
        sum_y = sum(y);
        sum_z = sum(z);
        n = length(entry);
        
        % Form equation matrix.
        A = [sum_x_x, sum_x_y, sum_x;
             sum_x_y, sum_y_y, sum_y;
             sum_x, sum_y, n];
        
        % Form constants vector.
        b = [sum_x_z; sum_y_z; sum_z];
        
        % Solve linear equation.
        plane_parameters = A \ b;
        % Normalize results.
        plane_parameters_normal = plane_parameters / norm(plane_parameters)';
        
        % Calculate projection.
        % https://math.stackexchange.com/questions/1726534/calculate-the-matrix-for-the-projection-of-r3-onto-the-plane-xyz-0
        projection_matrix = neutral_projection_matrix - normalizer * plane_parameters_normal;
        points = [x, y, z];
        projected_points = points * projection_matrix;
        projected_points = projected_points(:, 1:2);
        
        % Save projection to outcome table.
        flat_data{data_index} = projected_points;
        
        % Draw outcome if debug flags are enabled.
        if (DEBUG == 1 && FUNCTION_DEBUG == 1 && ...
            mod(data_index, DEBUG_DRAW_EVERY) == 0)
            figure
            plot(projected_points(:, 1), projected_points(:, 2));
        end
    end
end
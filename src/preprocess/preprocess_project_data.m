function flat_data = preprocess_project_data(data, projection_matrix)
    global DEBUG;
    global DEBUG_DRAW_EVERY;
    FUNCTION_DEBUG = 0;
    
    % Prepare flat data output by assigning certain size table.
    flat_data = cell(length(data), 1, 1);

    % Go through all the data points.
    for data_index = 1:length(data)
        % Get one entry based on the data index.
        entry = data{data_index};
        
        % Calculate projected points based on the projection matrix.
        projected_points = entry * projection_matrix;
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
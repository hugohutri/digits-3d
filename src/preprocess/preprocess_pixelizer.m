function pixelized_data = preprocess_pixelizer(data, dimensions)
    % Dimensions should be 1 smaller.
    dimensions = dimensions - 1;

    % Prepare pixelized data output by assigning certain size table.
    pixelized_data = cell(length(data), 1, 1);

    % Helper function for rounding away from 0
    ceilfix = @(x)ceil(abs(x)).*sign(x);

    for data_index = 1:length(data)
        % Get one sample from data using index.
        entry = data{data_index};
        
        % Prepare pixelized matrix.
        pixel_matrix = zeros(dimensions, dimensions);
        
        % Go through every datapoint.
        for data_point = 1:length(entry)
            entry_point = entry(data_point, :);
            
            % % Calculate pixel coordinates.
            % x = round(entry_point(1) * dimensions) + 1;
            % y = round(entry_point(2) * dimensions) + 1;
            % pixel_matrix(x, y) = 1;

            % Calculate pixel coordinates.
            x_float = entry_point(1) * dimensions + 1;
            y_float = entry_point(2) * dimensions + 1;

            % x_mod = mod(x_float, 1);
            % y_mod = mod(y_float, 1);

            x = round(x_float);
            y = round(y_float);

            x_diff = x_float - x;
            y_diff = y_float - y;

            x_dir = ceilfix(x_diff);
            y_dir = ceilfix(y_diff);

            pixel_matrix(x, y) = 1; %min(1 - x_diff^2 - y_diff^2, 1);
            % try
            %     pixel_matrix(x+x_dir, y) = min(pixel_matrix(x+x_dir, y) + sqrt(abs(x_diff)), 1);
            % end
            % try
            %     pixel_matrix(x, y+y_dir) = min(pixel_matrix(x, y+y_dir) + sqrt(abs(y_diff)), 1);
            % end
            % try
            %     pixel_matrix(x+x_dir, y) = min(pixel_matrix(x+x_dir, y+y_dir) + sqrt(abs(x_diff)) + sqrt(abs(y_diff)), 1);
            % end
        end
        
        % Add pixel matrix to pixelized data table.
        pixelized_data{data_index} = pixel_matrix;
    end
end
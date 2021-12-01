function pixelized_data = preprocess_pixelizer(data, dimensions)
    % Dimensions should be 1 smaller.
    round_dimensions = dimensions - 1;

    % Prepare pixelized data output by assigning certain size table.
    pixelized_data = cell(length(data), 1, 1);
    
    for data_index = 1:length(data)
        % Get one sample from data using index.
        entry = data{data_index};
        
        % Prepare pixelized matrix.
        pixel_matrix = zeros(dimensions, dimensions);
        
        % Go through every datapoint.
        for data_point = 1:length(entry)
            entry_point = entry(data_point, :);
            
            % Calculate pixel coordinates.
            x = round(entry_point(1) * round_dimensions) + 1;
            y = round(entry_point(2) * round_dimensions) + 1;
            pixel_matrix(x, y) = pixel_matrix(x, y) + 1;
        end
        
        % Add pixel matrix to pixelized data table.
        pixelized_data{data_index} = pixel_matrix;
    end
end
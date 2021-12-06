function pixelized_data = preprocess_pixelizer(data, dimensions)
    % Dimensions should be 1 smaller.
    round_dimensions = dimensions - 1;

    % Prepare pixelized data output by assigning certain size table.
    pixelized_data = cell(length(data), 1, 1);

    % Helper function for rounding away from 0
    ceilfix = @(x)ceil(abs(x)).*sign(x);

    is_inside_image = @(x) 0 <= x && x <= round_dimensions;

    for data_index = 1:length(data)
        % Get one sample from data using index.
        entry = data{data_index};
        
        % Prepare pixelized matrix.
        pixel_matrix = zeros(round_dimensions, round_dimensions);
        
        % Go through every datapoint.
        for data_point = 1:length(entry)
            entry_point = entry(data_point, :);
            
            % Original way of calculating pixels
            % % Calculate pixel coordinates.
            % x = round(entry_point(1) * dimensions) + 1;
            % y = round(entry_point(2) * dimensions) + 1;
            % pixel_matrix(x, y) = 1;

            % Calculate pixel coordinates with anti-aliasing:
            %
            % Sorry about this mess
            %
            % Position of the pixel as floating point number
            x_float = entry_point(1) * round_dimensions + 1;
            y_float = entry_point(2) * round_dimensions + 1;
            % Actual coordinate of the main pixel
            x = round(x_float);
            y = round(y_float);
            % What is the rounding error when pixelasing? 0-0.5
            x_diff = x_float - x;
            y_diff = y_float - y;
            % x and y directions of the roundind error: -1 or 1
            x_dir = ceilfix(x_diff);
            y_dir = ceilfix(y_diff);
            % Set the main pixel to be 1 (The point was inside this pixel)
            pixel_matrix(x, y) = 1;
            % Set adjanced pixels to be gray based on the distance from the point.
            % The distance can be 0-0.5, we multiply that distance by 2 to be 0-1
            x_is_inside = is_inside_image(x+x_dir);
            y_is_inside = is_inside_image(y+y_dir);
            if (x_is_inside) 
                pixel_matrix(x+x_dir, y) = max(pixel_matrix(x+x_dir, y), 2*(abs(x_diff)));
            end
            if (y_is_inside)
                pixel_matrix(x, y+y_dir) = max(pixel_matrix(x, y+y_dir), 2*(abs(y_diff)));
            end
            if (x_is_inside && y_is_inside)
                pixel_matrix(x+x_dir, y+y_dir) = max(pixel_matrix(x+x_dir, y+y_dir), 2*hypot(x_diff, y_diff));
            end

            % % Anti-aliasing by roni
            % x = round(entry_point(1) * round_dimensions) + 1;
            % y = round(entry_point(2) * round_dimensions) + 1;
            % pixel_matrix(x, y) = pixel_matrix(x, y) + 1;
        end
        
        % Limit the values between 0 and 1
        pixel_matrix(pixel_matrix>1) = 1;

        % Add pixel matrix to pixelized data table.
        pixelized_data{data_index} = pixel_matrix;
    end
end
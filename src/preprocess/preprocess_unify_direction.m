% Unify direction of the data so that drawing always starts from the
% same direction.
function unified_data = preprocess_unify_direction(data)
    % Define sensitivity of the flip operation.
    flip_sensitivity = 0.3;

    % Prepare justified data output by assigning certain size table.
    unified_data = cell(length(data), 1, 1);
    
    % Go through all the data points.
    for data_index = 1:length(data)
        % Get one sample from the data using index.
        entry = data{data_index};
        
        % Move origo to center (currently 0.5, 0.5 due to normalization).
        % processed_entry = [entry(:, 1) - 0.5, entry(:, 2) - 0.5];
        processed_entry = entry;
        
        % Make sure that numbers are drawn from top to bottom, if not flip
        % the number. This is calculated using aproximated difference.
        if round_to_nearest(entry(1, 2), flip_sensitivity) < round_to_nearest(entry(end, 2), flip_sensitivity)
            processed_entry = flip(entry);
        else
            % If there is no significant difference in up down direction,
            % check still left right dimension.
            if round_to_nearest(entry(1, 1), flip_sensitivity) > round_to_nearest(entry(end, 1), flip_sensitivity)
                processed_entry = flip(entry);
            end
        end

        % Rotate data so that drawing will always start from the
        % center top.

        % Get angle compared to center top from element that is one tenth
        % of a vector.
        % position = floor(length(processed_entry) / 10);
        % theta = atan(processed_entry(position, 2) / processed_entry(position, 1));
        
        % Debug rotation.
        % figure
        % plot(processed_entry(:, 1), processed_entry(:, 2))

        % Rotate based on the found angle.
        % processed_entry = rotate(processed_entry, theta);
        
        % Debug rotation.
        % figure
        % plot(processed_entry(:, 1), processed_entry(:, 2))
        
        % Restore original origo.
        % processed_entry = [processed_entry(:, 1) + 0.5, processed_entry(:, 2) + 0.5];

        % Save results.
        unified_data{data_index} = processed_entry;
    end
end

function rounded = round_to_nearest(number, target)
    % Round toward target step.
    rounded = round(number) + round( (number-round(number))/target) * target;
end

% function rotated = rotate(data, theta)
%     % Change target angle by adjusting theta.
%     theta = theta + (pi / 4);
%     
%     % Define rotation matrix.
%     % https://en.wikipedia.org/wiki/Rotation_matrix#In_two_dimensions
%     rotation_matrix = [cos(theta), -sin(theta);
%                        sin(theta), cos(theta)];
%     
%     % Calculate rotation.
%     rotated = (rotation_matrix * data')';
% end






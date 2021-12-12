function justified_data = preprocess_justify_data(data, desired_length)
    % Justify the data vector to new size

    global DEBUG;
    global DEBUG_DRAW_EVERY;
    FUNCTION_DEBUG = 0;

    % Prepare justified data output by assigning certain size table.
    justified_data = cell(length(data), 1, 1);
    
    % Go through all the data points.
    for data_index = 1:length(data)
        % Get one sample from data using index.
        entry = data{data_index};
        
        % Calculate overall distance of the data.
        overall_data_distance = 0;
        % Initialize distances vector that will consists of distances.
        % between neighboring points.
        distances = zeros(length(entry) - 1, 1);
        % Initialize previous point by using first data point.
        previous_x = entry(1, 1);
        previous_y = entry(1, 2);
        % Go through every point inside entry.
        for entry_index = 2:length(entry)
            % Get current point data.
            current_x = entry(entry_index, 1);
            current_y = entry(entry_index, 2);
            % Calculate distance between current and previous point.
            distance = sqrt((previous_x - current_x) .^ 2 + (previous_y - current_y) .^ 2);
            % Save distance to distances vector.
            distances(entry_index - 1) = distance;
            % Accumalate distance to overall distances.
            overall_data_distance = overall_data_distance + distance;
            % Update previous point.
            previous_x = current_x;
            previous_y = current_y;
        end
        
        % Prepare variables.
        target_distance = 0;
        distance_index = 1;
        distance_accumulated = 0;
        justified_data_entry = zeros(desired_length, 2);
        % Go through all the points.
        for point_index = 1:desired_length
            % Accumalate distance (advance points) if needed.
            while 1
                % Calculate new accumalated distance candidate.
                candidate = distance_accumulated + distances(distance_index);
                % Calculate new candidate index.
                candidate_index = distance_index + 1;
                % If target distance is smaller than candidate stop here
                % (so final accumalated distance will be first point in the
                % segment.
                if (target_distance <= candidate)
                    break
                end
                
                % Update real values based on the candidates. This has to
                % be done after stopping rules, because otherwice algorithm
                % would give overly eager results.
                distance_accumulated = candidate;
                distance_index = candidate_index;
            end
            
            % Aproximate point.
            
            % Get current point and next point.
            p1 = entry(distance_index, :);
            p2 = entry(distance_index + 1, :);
            % Create vector between these two points.
            approximation_vector = p2 - p1;
            % Normalize the aproximation vector.
            approximation_norm_vector = approximation_vector / norm(approximation_vector);
            % Calculate the distance scaler (how far we should go from
            % point 1).
            distance_scaler = target_distance - distance_accumulated;
            % Calculate final direction vector with correct length.
            final_approximation_vector = approximation_norm_vector .* distance_scaler;
            % Get starting point.
            starting_point = entry(distance_index, :);
            % Calculate final point using starting point and final
            % approximation vector.
            justified_data_entry(point_index, :) = final_approximation_vector + starting_point;
            
            % Calculate new target distance.
            target_distance = target_distance + overall_data_distance ./ desired_length;
            
            % Save to main array.
            justified_data{data_index} = justified_data_entry;
            
            % Debug point aproximation.
            % if (point_index == 98)
            %     figure
            %     hold on
            %     plot(p1(1), p1(2), "r*")
            %     plot(p2(1), p2(2), "r*")
            %     plot(justified_data(point_index, 1), justified_data(point_index, 2), "b*")
            %     hold off
            % end
        end
        
        if (DEBUG == 1 && FUNCTION_DEBUG == 1 && ...
            mod(data_index, DEBUG_DRAW_EVERY) == 0)
            figure
            plot(justified_data_entry(:, 1), justified_data_entry(:, 2));
        end
    end
end
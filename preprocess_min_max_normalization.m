function min_maxed_data = preprocess_min_max_normalization(data)
    % Prepare justified data output by assigning certain size table.
    min_maxed_data = cell(length(data), 1, 1);
    
    % Go through all the data points.
    for data_index = 1:length(data)
        % Get one sample from data using index.
        entry = data{data_index};
        
        % Get row and column amount.
        [rows, columns] = size(entry);
        
        % Initialize min maxed data matrix.
        min_maxed_data_entry = zeros(rows, columns);

        % Go trough every row
        for column = 1:columns
            % Calculate min of the row
            column_min = min(entry(:,column));

            % Calculate max of the row
            column_max = max(entry(:,column));

            % Scale using min-max normalization, formula 3 in tips section
            min_maxed_data_entry(:,column) = (entry(:,column) - column_min) / (column_max - column_min);
        end
        
        % Save min maxed data set to array.
        min_maxed_data{data_index} = min_maxed_data_entry;
    end
end
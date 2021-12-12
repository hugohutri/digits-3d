function min_maxed_data = min_max_columns(data)
    
    % Get row and column amount.
    [~, columns] = size(data);

    % Initialize min maxed data matrix.
    min_maxed_data = zeros(size(data));

    % Go trough every row
    for column = 1:columns
        % Calculate min of the row
        column_min = min(data(:,column));

        % Calculate max of the row
        column_max = max(data(:,column));

        % Scale using min-max normalization, formula 3 in tips section
        min_maxed_data(:,column) = (data(:,column) - column_min) / (column_max - column_min);
    end
end
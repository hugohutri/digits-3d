function cleaned_data = preprocess_clean_zeros(data)
    % Clean completedly zero lines from the data.

    % Prepare cleaned data output by assigning certain size table.
    cleaned_data = cell(length(data), 1, 1);

    % Go through all the data points.
    for data_index = 1:length(data)
        % Get one sample from data using index.
        entry = data{data_index};
        
        % Create output table with maximum size.
        [rows, columns] = size(entry);
        output_entry = zeros(rows, columns);
        
        % Go through every datapoint.
        accepted = 0;
        for data_point = 1:length(entry)
            entry_point = entry(data_point, :);
            
            % Skip if vector is fully zero.
            if (all(entry_point == 0))
                continue
            end
            
            % Otherwice add to outcome.
            accepted = accepted + 1;
            output_entry(accepted, :) = entry_point;
        end
        
        cleaned_data{data_index} = output_entry(1:accepted, :);
    end
end
function flat_data = preprocess_three_d_to_two_d(data)
    % Prepare flat data output by assigning certain size table.
    flat_data = cell(length(data), 1, 1);
    
    for data_index = 1:length(data)
        flat_data{data_index} = data{data_index}(:, 1:2);
    end
end
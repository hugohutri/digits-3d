function flat_data = preprocess_3d_to_2d(data)
    % Prepare flat data output by assigning certain size table.
    flat_data = cell(length(data), 1, 1);
    
    for data_index = 1:length(data)
        flat_data{data_index} = data{data_index}(:, 1:2);
    end
end
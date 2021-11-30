function processed_data = preprocess(raw_data, justified_size, image_dimensions)
    % Remove completedly zero entries.
    zero_cleaned_data = preprocess_clean_zeros(raw_data);

    % Project 3D data to 2D space using least square method and projection.
    % flattened_data = flatten_data(zero_cleaned_data);

    % Do simple 3D to 2D conversion.
    flattened_data = preprocess_3d_to_2d(zero_cleaned_data);

    % Stretch data so that it has same time intervals.
    justified_data = preprocess_justify_data(flattened_data, justified_size);

    % Normalize data so every number has approximately same size.
    normalized_data = preprocess_min_max_normalization(justified_data);

    % Create pixels from vectors.
    pixelized_data = preprocess_pixelizer(normalized_data, image_dimensions);
    
    % Return pixelized data.
    processed_data = pixelized_data;
end
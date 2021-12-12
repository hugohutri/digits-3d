function [processed_data, projection_matrix] = preprocess(raw_data, justified_size, image_dimensions, projection_matrix)
    % Handle every preprocessing to be done to the data
    % USAGE:
    %   [processed_data, projection_matrix] = preprocess(raw_data, justified_size, image_dimensions, projection_matrix)
    % 
    % WHERE:
    %   raw_data: the actual data to be preprocessed
    %   justified_size: constant size to strech the data vector, for example. 2000
    %   image_dimensions: Dimensions of the output image. For example 32 (-> 32x32)
    %   projection_matrix: (Optional) Pre-determined projection matrix to be used. This should be left empty when dealing with new dataset, but can be included when testing the classificator

    % Remove completedly zero entries.
    zero_cleaned_data = preprocess_clean_zeros(raw_data);

    % Calculate projection matrix using least square method.
    % Projection matrix should be saved so it can also be used for the
    % samples that arrive for classification.
    if (~projection_matrix)
        projection_matrix = preprocess_calculate_projection_matrix(zero_cleaned_data);
    end

    % Flatten data using projection matrix.
    flattened_data = preprocess_project_data(zero_cleaned_data, projection_matrix);

    % Do simple 3D to 2D conversion.
    % flattened_data = preprocess_3d_to_2d(zero_cleaned_data);

    % Stretch data so that it has same time intervals.
    justified_data = preprocess_justify_data(flattened_data, justified_size);

    % Normalize data so every number has approximately same size.
    normalized_data = preprocess_min_max_normalization(justified_data);
    
    % Execute class specific preprocessing. Preprocessing requires
    % normalized data.
    % direction_unified_data = preprocess_unify_direction(normalized_data);
    
    % Direction unification may produce non normalized data so normalize
    % the data again.
    % normalized_data = preprocess_min_max_normalization(direction_unified_data);

    % Return preprocessed vector data.
    % processed_data = normalized_data;
    
    % Create pixels from vectors.
    pixelized_data = preprocess_pixelizer(normalized_data, image_dimensions);
    
    % Normalize pixelized data.
    normalized_pixelized_data = preprocess_min_max_normalization(pixelized_data);
    
    % Return pixelized data.
    processed_data = normalized_pixelized_data;
end
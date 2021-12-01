function projection_matrix = preprocess_calculate_projection_matrix(data)  
    % Define neutral projection matrix.
    neutral_projection_matrix = eye(3, 3);
    % Define vector that converts normal vector into projection matrix
    % applicable form.
    normalizer = [1 / sqrt(3), 1 / sqrt(3), 1 / sqrt(3)];
    
    % Combine all data points to gigantic matrix.
    
    % Form empty matrix based on the data sizes.
    data_length = 0;
    for data_index = 1:length(data)
        data_length = data_length + length(data{data_index});
    end
    
    % Initialize big matrix.
    giga_matrix = zeros(data_length, 3);
    
    % Combine data into giga matrix.
    head_index = 1;
    for data_index = 1:length(data)
        current_lenght = length(data{data_index});
        giga_matrix(head_index:head_index + current_lenght - 1, :) = data{data_index};
        head_index = head_index + current_lenght;
    end
    
    % Calculate plane parameters using least square method.
    % https://stackoverflow.com/questions/1400213/3d-least-squares-plane.
    x = giga_matrix(:, 1);
    y = giga_matrix(:, 2);
    z = giga_matrix(:, 3);
    sum_x_x = sum(x .* x);
    sum_x_y = sum(x .* y);
    sum_y_y = sum(y .* y);
    sum_x_z = sum(x .* z);
    sum_y_z = sum(y .* z);
    sum_x = sum(x);
    sum_y = sum(y);
    sum_z = sum(z);
    n = length(giga_matrix);

    % Form equation matrix.
    A = [sum_x_x, sum_x_y, sum_x;
         sum_x_y, sum_y_y, sum_y;
         sum_x, sum_y, n];

    % Form constants vector.
    b = [sum_x_z; sum_y_z; sum_z];

    % Solve linear equation.
    plane_parameters = A \ b;
    % Normalize results.
    plane_parameters_normal = plane_parameters / norm(plane_parameters)';
    % Calculate projection.
    % https://math.stackexchange.com/questions/1726534/calculate-the-matrix-for-the-projection-of-r3-onto-the-plane-xyz-0
    projection_matrix = neutral_projection_matrix - normalizer * plane_parameters_normal;
end
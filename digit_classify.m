function C = digit_classify(test_data)
    addpath(genpath("src"))

    % Load projection matrix

    DIMENSIONS = 32;
    data_cells = cell(1, 1, 1);
    data_cells{1} = test_data;

    % Preprosessing
    % test_data     param: projection matrix
    load("data/model/projection_matrix.mat");
    [preprocessed_data, ~] = preprocess(data_cells, 2000, DIMENSIONS, projection_matrix);
    preprocessed_data = preprocessed_data{1};


    preprocessed_data = preprocessed_data(:);

    % Load all models.
    models = cell(10, 1, 1);
    for model_number = 1:10
        load("data/model/NN_" + model_number + ".mat")
        models{model_number} = all_time_best_child;
    end

    % Model evaluation
    [pixels, samples] = size(preprocessed_data);
    scores = zeros(10, 1);    
    % Using all models.
    for model_index = 1:10
        model = models{model_index};
        all_results = evaluate_NN(model, preprocessed_data, 3);
        
        % Take only second output assuming it is higher than the first.
        if all_results(1) < all_results(2)
            scores(model_index) = all_results(2);
        else
            scores(model_index) = 0;
        end
    end

    % Lataa Min Max matriisi
    % [min_1 min_2 min_3 ... min_10;
    %  max_1 max_2 max_3 ... max_10]
    % load
    load("data/model/min_max_mat.mat")
    min_maxed_scores = zeros(10,1);

    for i = 1:10
        column_min = min_max_mat(1,i);
        column_max = min_max_mat(2,i);
        min_maxed_scores(i) = (scores(i) - column_min) / (column_max - column_min);
    end

    [~, I] = max(min_maxed_scores);
    C = mod(I,10);
end
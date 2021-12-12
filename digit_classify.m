function C = digit_classify(test_data)
    % Recognises a hand-written digit (0,1,2...9) and classifies it based on the 3-D location time series.
    %
    %   C = digit_classify(test_data)
    % 
    %   where test_data is N × 3 matrix testdata
    %   and C is integer between 0 and 9    

    % Add source files to the path
    addpath(genpath("src"))
    data_cells = cell(1, 1, 1);
    data_cells{1} = test_data; % This is our only data sample in this function

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Preprosessing
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    load("data/model/projection_matrix.mat");
    % Dimensions for the preprocessed image -> 32x32 pixels
    DIMENSIONS = 32; %px
    JUSTIFIED_SIZE = 2000; % Stretch data vector to this size
    [preprocessed_data, ~] = preprocess(data_cells, JUSTIFIED_SIZE, DIMENSIONS, projection_matrix);
    preprocessed_data = preprocessed_data{1}; % We only need this one sample in this function

    % Transform the preprosessed data to vector
    preprocessed_data = preprocessed_data(:);


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Load Neural networks
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Load all pre-trained models
    models = cell(10, 1, 1);
    for model_number = 1:10
        load("data/model/NN_" + model_number + ".mat")
        models{model_number} = all_time_best_child;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Evaluation
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Determine best quess
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    load("data/model/min_max_mat.mat")
    min_maxed_scores = zeros(10,1);

    % Scale the score based on previous min/max values
    for i = 1:10
        column_min = min_max_mat(1,i);
        column_max = min_max_mat(2,i);
        min_maxed_scores(i) = (scores(i) - column_min) / (column_max - column_min);
    end

    % Find the index of the best score
    [~, I] = max(min_maxed_scores);
    
    % We were using labels "1,2,3,4,5,6,7,8,9 and 10", so 10 instead of 0 because of matlab indexing...
    % -> replace 10 with 0
    C = mod(I,10);
end
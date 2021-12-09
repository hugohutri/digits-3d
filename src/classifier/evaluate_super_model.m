clc; clearvars; close all;

clc; clearvars; close all;

% Load preprocessed test data.
load("../../data/preprocessed/preprocessed_training_data.mat")

models = cell(10, 1, 1);

% Load all models.
for model_number = 1:10
    load("../../data/model/NN_" + model_number + ".mat")
    models{model_number} = best_child;
end

% Evaluate all data.
[pixels, samples] = size(data);
classification_results = zeros(1, length(classes));
models_constant = parallel.pool.Constant(models);
parfor data_index = 1:samples
    scores = zeros(10, 1);
    % Using all models.
    for model_index = 1:10
        model = models_constant.Value{model_index};
        all_results = evaluate_NN(model, data(:, data_index), 3);
        
        % Take only second output assuming it is higher than the first.
        if all_results(1) < all_results(2)
            scores(model_index) = all_results(2);
        else
            scores(model_index) = 0;
        end
    end
    
    % Pick largest score and assign it as the final class.
    [~, selected_class] = max(scores);
    
    % Add selected class to classification results.
    classification_results(data_index) = selected_class;
end

% Calculate overall classification error.
errors = sum(classes ~= classification_results);
fprintf("Overall classification accuracy: %0.1f%%\n", 100 - (errors / 1000 * 100))

% Calculate per class classification errors.
errors = sum((classes(1:100) == 10) ~= (classification_results(1:100) == 10));
fprintf("Classification accuracy #0: %0.1f%%\n", 100 - errors)
errors = sum((classes(100:200) == 1) ~= (classification_results(100:200) == 1));
fprintf("Classification accuracy #1: %0.1f%%\n", 100 - errors)
errors = sum((classes(200:300) == 2) ~= (classification_results(200:300) == 2));
fprintf("Classification accuracy #2: %0.1f%%\n", 100 - errors)
errors = sum((classes(300:400) == 3) ~= (classification_results(300:400) == 3));
fprintf("Classification accuracy #3: %0.1f%%\n", 100 - errors)
errors = sum((classes(400:500) == 4) ~= (classification_results(400:500) == 4));
fprintf("Classification accuracy #4: %0.1f%%\n", 100 - errors)
errors = sum((classes(500:600) == 5) ~= (classification_results(500:600) == 5));
fprintf("Classification accuracy #5: %0.1f%%\n", 100 - errors)
errors = sum((classes(600:700) == 6) ~= (classification_results(600:700) == 6));
fprintf("Classification accuracy #6: %0.1f%%\n", 100 - errors)
errors = sum((classes(700:800) == 7) ~= (classification_results(700:800) == 7));
fprintf("Classification accuracy #7: %0.1f%%\n", 100 - errors)
errors = sum((classes(800:900) == 8) ~= (classification_results(800:900) == 8));
fprintf("Classification accuracy #8: %0.1f%%\n", 100 - errors)
errors = sum((classes(900:1000) == 9) ~= (classification_results(900:1000) == 9));
fprintf("Classification accuracy #9: %0.1f%%\n", 100 - errors)

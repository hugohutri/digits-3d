clc; clearvars; close all;


% Test images found online
% load('usps_all');

% load("USPS.mat")
load("../../data/preprocessed/data_24.mat")

PIXEL_AMOUNT = height(data);
IMAGE_DIMENSIONS = sqrt(PIXEL_AMOUNT);

% This part of code is just using the 'usps_all' data. Will be removed in
% the future.



sample_of_each = 80; % 400
data_size = sample_of_each * 10;

sample_data  = [];
sample_class = [];

for cls = 1:10
    data_group = data(:,classes == cls);
    sample_data = [sample_data data_group(:,1:sample_of_each)];
    sample_class = [sample_class ones(1, sample_of_each) * cls];

end

%example = reshape(sample_data(:, sample_of_each * 9 -10), [16 16]);
%imshow(example)




%% The real training part begings here


number_of_train = 700;
number_of_test  = data_size - number_of_train; % 100 test when 700 train


% Suffling the data to train and test
r = [ones(1, number_of_train), zeros(1, number_of_test)];

suffle = logical(   r(randperm(length(r)))   );


train_data = sample_data(:, suffle);
train_class = sample_class(:, suffle);


test_data = sample_data(:, ~suffle);
test_class = sample_class(:, ~suffle);



% n = 799;
% example = reshape(train_data(:, n), [IMAGE_DIMENSIONS IMAGE_DIMENSIONS]);
% fprintf("Is number: %d\n", train_class(n))
% imshow(example)


% input_size = 625;
input_size = PIXEL_AMOUNT;

hidden_size = 220; % 256;
hidden_layers = 3; % 6;

output_size = 10;


base_NN = create_NN(input_size, hidden_size, hidden_layers, output_size);


max_iter = 6000;




trial_count = 1;
iter_count  = 1;


% For each trial, where each trial might be one number to train on (Roni)
for trial = 1:trial_count

    % Where each iteration might be on attempt at getting good accuracy %
    for iter = 1:iter_count

        % top_children = simple_model_train(base_NN, train_data, train_class, epoch_count, target_accuracy, verbal)
        top_children = simple_model_train(base_NN, train_data, train_class, 10);
        
        child_count = length(top_children);
        
        % Evaluate the children with test data
        % -> verifying the learning / Validation
        child_errors = zeros(1, child_count);

        child_count = length(top_children);
        for c = 1:child_count
            
            % Test each test data
            for m = 1:number_of_test

                result = evaluate_NN(top_children(c), test_data(:, m), ...
                                        hidden_layers);
                
                [~,I] = max(result);

                % If it's not correct
                child_errors(c) = child_errors(c) + (I ~= train_class(m));
            end
        end

        % Rank the children
        [B,I] = sort(child_errors);
        validation_accuracies = (1 - (B ./ number_of_test)) * 100;

        fprintf("Validation accuracy of the best child was %0.3f%%\n", validation_accuracies(1))

        % TODO: Plot the validation accuracies or something cool
    end
end


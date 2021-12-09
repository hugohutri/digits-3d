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

% Randomize the order of the data
random_order = randperm(length(data));
data = data(:,random_order);
classes = classes(random_order);

for cls = 1:10

    % data_group = [];
    % class_group = [];
    % for n = 1:sample_of_each
    %     data_group = [data_group, data(:, n)];
    %     class_group = [class_group, classes(n)];
    % end

        

    % sample_data = [sample_data, data_group];

    % sample_class = [sample_class, class_group];
    % sample_class = [sample_class, ones(1, sample_of_each) * cls];
    data_group = data(:,classes == cls);
    sample_data = [sample_data data_group(:,1:sample_of_each)];
    sample_class = [sample_class ones(1, sample_of_each) * cls];

end

%example = reshape(sample_data(:, sample_of_each * 9 -10), [16 16]);
%imshow(example)




%% The real training part begings here


number_of_train = 800; % 2000;


% Suffling the data to train and test
r = [ones(1, number_of_train), zeros(1, data_size - number_of_train)];

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

hidden_size = 220; %220; % 256;
hidden_layers = 3; % 6;

output_size = 10;


base_NN = create_NN(input_size, hidden_size, hidden_layers, output_size);


max_iter = 600;

child_count = 120;
num_top_child = child_count; % 50; %3;
top_children = Child.empty(num_top_child, 0);

% Overall best child ever created
best_child = NaN;
best_child_score = number_of_train;

% Initial value, will change during runtime
learn_rate = 100;
% Hat constant
learning_multiplier = 1;

% List for monitoring performance etc
average_accuracies = [];
average_top10_accuracies = [];
best_epoch_accuracies = [];
epoch_durations = [];


% Initialize data and variables that are needed for the execution.
train_data_constant = parallel.pool.Constant(train_data);
train_class_constant = parallel.pool.Constant(train_class);
child_scores = zeros(1, child_count);

% First epoch child list
child_list = create_children(base_NN, child_count, learn_rate, [-1e1, 1e1], true);
for epoch = 1:max_iter
    fprintf("Starting epoch\n")

    class_scores = zeros(child_count, number_of_train);

    % Start timer
    t_start = tic;

    % Evaluate each child
    % fprintf("Evaluating each children\n")
    % child_list_constant = parallel.pool.Constant(child_list);
    parfor n = 1:child_count
        child_scores(n) = 0;

        for m = 1:number_of_train

            % result = Evaluate_NN(child, input)
            result = evaluate_NN(child_list(n), ...
                        train_data(:, m), ...      % train_data_constant.Value(:, m),      
                        hidden_layers);

            [~,I] = max(result);

            % If it's not correct
            % child_scores(n) = child_scores(n) + (I ~= train_class_constant.Value(m)); % Select one of these lines
            C = train_class(m);
            child_scores(n) = child_scores(n) + (I ~= C);
            if (I == C)
                class_scores(n, m) = C;
            end 
        end
    end
    % fprintf("Children evaluated\n")




    % Rank the children
    [B,I] = sort(child_scores);

    top_children = child_list( I(1:num_top_child) );

    learn_rate = learning_multiplier * (B(1) ./ number_of_train);

    if B(1) < best_child_score

        best_child_score = B(1);
        best_child = child_list( I(1) );
    end
    
    % Next epoch child list.
    fprintf("Length of child list: %d \n", length(child_list));
    child_list = create_all_children(top_children, learn_rate, base_NN);

    % Stopping the timer
    t_delta = toc(t_start);

    save("best_child.mat", "best_child")

    if epoch == 1

        full_duration = seconds(t_delta * max_iter);
        full_duration.Format = 'hh:mm';

        fprintf("Training has been started with %d iterations\n", max_iter);
        fprintf("Estimated complete duration %s hh:mm\n\n", full_duration);
    end

    fprintf('[%s]\n', datestr(now,'hh:MM:ss'))
    fprintf("Epoch: %d/%d, with learn rate: %0.3f\n", epoch, max_iter, learn_rate)
    accuracies = (1 - (B ./ number_of_train)) * 100;
    average_accuracy = mean(accuracies);
    fprintf("Top accuracies: %0.1f%%, %0.1f%%, %0.1f%%\n",accuracies(1:3))
    fprintf("Average accuracy: %0.1f%% \n",average_accuracy)
    fprintf("Time taken: %0.3fs\n", t_delta)
    epoch_durations = [epoch_durations t_delta];
    average_epoch_duration = mean(epoch_durations);
    fprintf("Average epoch duration: %0.3fs\n", average_epoch_duration)

    fprintf("\n")

    for i = 1:10
        correcly_quessed_amount = nnz(class_scores == i);
        max_amount = nnz(train_class == i);
        percentage = correcly_quessed_amount / max_amount;
        fprintf("Correct quesses for class %d: %2.1f%%\n", mod(i,10), percentage);
    end


    fprintf("\n")
    
    % PLOTTING

    best_epoch_accuracies = [best_epoch_accuracies, accuracies(1)];
    average_accuracies = [average_accuracies average_accuracy];
    average_top10_accuracies = [average_top10_accuracies mean(accuracies(1:10))];
    hold on;
    
    % Plot accuracy
    subplot(2,1,1);
    plot(1:epoch, best_epoch_accuracies, "b"); hold on;
    plot(1:epoch, average_top10_accuracies, "m"); hold on;
    plot(1:epoch, average_accuracies, "r"); hold on;
    legend("Best accuracy", "Average top 10 accuracy", "Average accuracy", "Location", "southeast")
    title("Accuracy");
    ylabel("%");
    
    % Plot time taken per epoch
    subplot(2,1,2);
    plot(1:epoch, epoch_durations, "b");
    title("Epoch duration");
    ylabel("seconds");

    drawnow;
end


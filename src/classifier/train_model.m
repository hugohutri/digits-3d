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

hidden_size = 160; % 256;
hidden_layers = 3; % 6;

output_size = 10;


base_NN = create_NN(input_size, hidden_size, hidden_layers, output_size);


max_iter = 600;

child_count = 110;
num_top_child = 50; %3;
top_children = Child.empty(num_top_child, 0);

% Overall best child ever created
best_child = NaN;
best_child_score = number_of_train;

% Initial value, will change during runtime
learn_rate = 100;
min_learn_rate = 0.001;

% List for monitoring performance etc
best_epoch_accuracies = [];
epoch_durations = [];

for epoch = 1:max_iter
    fprintf("Starting epoch\n")

    % Start timer
    t_start = tic;

    child_list = NaN;
    child_scores = zeros(1, child_count);

    if epoch == 1
        % fprintf("Creating children\n")
        % Create_children(parent, child_count, learn_rate, limits, use_gauss)
        child_list = create_children(base_NN, child_count, learn_rate, [-1e1, 1e1], false);
        % fprintf("Children created\n")

    else
        child_list = create_all_children(top_children, best_child, learn_rate, base_NN);
        % fprintf("Creating children\n")
        % % Create_children(parent, child_count, learn_rate, limits, use_gauss)
        % % TODO: ratios are hard coded
        
        % child_list_1 = create_children(top_children(1), 50, learn_rate);
        % child_list_2 = create_children(top_children(2), 20, learn_rate);
        % child_list_3 = create_children(top_children(3), 10, learn_rate);
        % % Best child has 10 children
        % child_list_4 = create_children(best_child, 10, learn_rate * 0.1);
        % % 20 purely random children
        % child_list_5 = create_children(base_NN, 20, 100, [-1e1, 1e1], false);

        % child_list = [child_list_1, child_list_2, child_list_3, child_list_4, child_list_5];
        % fprintf("Children created\n")
    end



    % Evaluate each child
    % fprintf("Evaluating each children\n")
    parfor n = 1:child_count

        % fprintf("Evaluating child %d\n", n)
        child = child_list(n);
        error_sum = 0;

        for m = 1:number_of_train

            % result = Evaluate_NN(child, input)
            result = evaluate_NN(child, train_data(:, m));

            [M,I] = max(result);

            % If it's not correct
            if I ~= train_class(m)
               error_sum = error_sum + 1;
            % else

                % imshow(reshape(train_data(:, m), [16 16]))
                % fprintf("Is number: %d\n", train_class(m))
                % drawnow
            end
        end

        error_sum;
        child_scores(n) = error_sum;
    end
    % fprintf("Children evaluated\n")




    % Rank the children
    [B,I] = sort(child_scores);

    top_children = child_list( I(1:num_top_child) );

    learn_rate = min_learn_rate * B(1) * 2; % 0.1;

    if B(1) < best_child_score

        best_child_score = B(1);
        best_child = child_list( I(1) );
    end

    % Stopping the timer
    t_delta = toc(t_start);

    if epoch == 1

        full_duration = seconds(t_delta * max_iter);
        full_duration.Format = 'hh:mm';

        fprintf("Training has been started with %d iterations\n", max_iter);
        fprintf("Estimated complete duration %s hh:mm\n\n", full_duration);
    end

    fprintf('[%s]\n', datestr(now,'hh:MM:ss'))
    fprintf("Epoch: %d/%d, with learn rate: %0.3f\n", epoch, max_iter, learn_rate)
    top_accuracies = (1 - (B(1:3) ./ number_of_train)) * 100;
    fprintf("Top accuracies: %0.1f%%, %0.1f%%, %0.1f%%\n",top_accuracies)
    fprintf("Time taken: %0.3fs\n", t_delta)
    epoch_durations = [epoch_durations t_delta];
    average_epoch_duration = mean(epoch_durations);
    fprintf("Average epoch duration: %0.3fs\n", average_epoch_duration)

    fprintf("\n")

    save("best_child.mat", "best_child")

    % PLOTTING

    best_epoch_accuracies = [best_epoch_accuracies, top_accuracies(1)];
    hold on;
    
    % Plot accuracy
    subplot(2,1,1);
    plot(1:epoch, best_epoch_accuracies, "b");
    title("Accuracy");
    ylabel("%");
    
    % Plot time taken per epoch
    subplot(2,1,2);
    plot(1:epoch, epoch_durations, "b");
    title("Epoch duration");
    ylabel("seconds");

    drawnow;
end

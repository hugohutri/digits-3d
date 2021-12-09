clc; clearvars; close all;

% Load preprocessed test data.
load("../../data/preprocessed/preprocessed_training_data.mat")

% Train all specialist models.
% Note 0 is 10 in classes.
for number_to_specialize = 1:10
    % New figure for training.
    figure
    
    % Start training.
    train_model(data, classes, number_to_specialize);
end
close all
% clear all
clc

% Add all new files in src folder automatically to the path
addpath(genpath("src"))

% Config
global DEBUG;
global DEBUG_DRAW_EVERY;
global DEBUG_DRAW_CLASSES;
global TRAIN_DATA_SIZE;
global TRAIN_DATA_CLASS_INDEX;
DEBUG = 1;
TRAIN_DATA_DIRECTORY = "data/training_data";
TRAIN_DATA_SIZE = 1000;
TRAIN_DATA_CLASS_INDEX = 8; % This value should not be changed for the data set.
LOAD_DATA_ENABLED = true;

% Run data fetcher.
if LOAD_DATA_ENABLED
    [data, classes, max_length] = load_data(TRAIN_DATA_DIRECTORY);
end

for i = 100:150
    class = digit_classify(data{i})
end
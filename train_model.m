% close all
% clear all
clc

global DEBUG;
global DEBUG_DRAW_EVERY;
global TRAIN_DATA_DIRECTORY;
global TRAIN_DATA_SIZE;
global TRAIN_DATA_CLASS_INDEX;
global LOAD_DATA_ENABLED;
DEBUG = 1;
DEBUG_DRAW_EVERY = 11;
TRAIN_DATA_DIRECTORY = "training_data";
TRAIN_DATA_SIZE = 1000;
TRAIN_DATA_CLASS_INDEX = 8; % This value should not be changed for the data set.
LOAD_DATA_ENABLED = 1;



% Run data fetcher.
if LOAD_DATA_ENABLED == 1
    [data, classes, max_length] = load_data();
end

% Filter only specific number (used for testing).
% [data, classes] = debug_filter_data(data, classes, 9);

% Preprocess.
preprocessed_data = preprocess(data, 1000, 24);

% Draw output as pixels.
debug_draw_pixels(preprocessed_data, classes)

% Draw output as vectors.
% debug_draw_vectors(preprocessed_data, classes)
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
DEBUG_DRAW_EVERY = 4;
DEBUG_DRAW_CLASSES = 0:2;
TRAIN_DATA_DIRECTORY = "data/training_data";
TRAIN_DATA_SIZE = 1000;
TRAIN_DATA_CLASS_INDEX = 8; % This value should not be changed for the data set.
LOAD_DATA_ENABLED = true;

% Run data fetcher.
if LOAD_DATA_ENABLED
    [data, classes, max_length] = load_data(TRAIN_DATA_DIRECTORY);
end

% Filter only specific number (used for testing).
% [data, classes] = debug_filter_data(data, classes, 9);

% Preprocess.
DIMENSIONS = 16; % px
preprocessed_data = preprocess(data, 1000, DIMENSIONS);

% Draw output as pixels.
debug_draw_pixels(preprocessed_data, classes)

% Draw output as vectors.
% debug_draw_vectors(preprocessed_data, classes)

classes(classes == 0) = 10;

prompt = 'Give a name for this preprocessed data (press enter to discard): ';
str = input(prompt,'s');
if ~isempty(str)
    save_data(preprocessed_data, classes', "data/preprocessed", str+".mat")
end
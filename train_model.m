close all
%clear all
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
DEBUG_DRAW_EVERY = 50;
DEBUG_DRAW_CLASSES = [3];
TRAIN_DATA_DIRECTORY = "training_data";
TRAIN_DATA_SIZE = 1000;
TRAIN_DATA_CLASS_INDEX = 8;
LOAD_DATA_ENABLED = true;



% Run data fetcher.
if LOAD_DATA_ENABLED
    [data, classes, max_length] = load_data(TRAIN_DATA_DIRECTORY);
end

% Preprocess.
preprocessed_data = preprocess(data, 1000, 24);

% Draw output as pixels.
debug_draw_pixels(preprocessed_data, classes)

% Draw output as vectors.
% debug_draw_vectors(normalized_data)
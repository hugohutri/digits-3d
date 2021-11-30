close all
%clear all
clc

global DEBUG;
global DEBUG_DRAW_EVERY;
global TRAIN_DATA_DIRECTORY;
global TRAIN_DATA_SIZE;
global TRAIN_DATA_CLASS_INDEX;
DEBUG = 1;
DEBUG_DRAW_EVERY = 1;
TRAIN_DATA_DIRECTORY = "training_data";
TRAIN_DATA_SIZE = 1000;
TRAIN_DATA_CLASS_INDEX = 8;
LOAD_DATA_ENABLED = true;



% Run data fetcher.
if LOAD_DATA_ENABLED
    [data, classes, max_length] = load_data();
end

% Preprocess.
preprocessed_data = preprocess(data, 1000, 24);

% Draw output as pixels.
debug_draw_pixels(preprocessed_data, classes)

% Draw output as vectors.
% debug_draw_vectors(normalized_data)
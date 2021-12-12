function NN = create_NN(input_size, hidden_size, hidden_layers, output_size)
    
    % CHILD -class
    %
    % weights_in (:,:) double
    % bias_in (:,:) double
    %
    % weights_hidden (:,:) double
    % bias_hidden (:,:) double
    %
    % weights_out (:,:) double
    % bias_out (:,:) double


    NN = Child;
    
    NN.weights_in     = ones(input_size, hidden_size);
    NN.bias_in        = ones(1, hidden_size);
    
    NN.weights_hidden = ones(hidden_size, hidden_size, hidden_layers);
    NN.bias_hidden    = ones(1, hidden_size, hidden_layers);
    
    NN.weights_out    = ones(hidden_size, output_size);
    NN.bias_out       = ones(1, output_size);    
end
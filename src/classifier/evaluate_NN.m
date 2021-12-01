function result = evaluate_NN(child, input)

    arguments
       % child to be evaluated
       child Child = NaN
       % input values
       input (1,:) double = 0;
    end
    
    
    input_size = size(input);
    
    % Allowed input is 1xN
    if input_size(1) ~= 1 || input_size(2) < 2
        
        % TODO: replace with matlab exception / raise / error
        fprintf("\n\nAllowed input is 1xN in Evaluate_NN\n\n")
        result = NaN;
        return
    end
    
    % Activation function
    % activ_fun = @(X) tanh(X);
    
    % RELU
    % activ_fun = @(X) max(zeros(size(X)), X);
    activ_fun = @(X) max(zeros(size(X)), tanh(X));
    
    
    
    % CHILD -class
    %
    % weights_in (:,:) double
    % bias_in (:,:) double
    %
    % weights_hidden (:,:,:) double
    % bias_hidden (:,:,:) double
    %
    % weights_out (:,:) double
    % bias_out (:,:) double
    
    
    % INPUT
    current = input * child.weights_in;
    current = current + child.bias_in;
    current = activ_fun(current);
    
    layer_N = length(child.weights_hidden(1, 1, :));
    
    % HIDDEN LAYERS
    for layer = 1:layer_N
        
        current = current * child.weights_hidden(:, :, layer);
        current = current + child.bias_hidden(:, :, layer);
        current = activ_fun(current);
    end
    
    % OUTPUT
    current = current * child.weights_out;
    current = current + child.bias_out;
    current = activ_fun(current);
    
    result = current;
end
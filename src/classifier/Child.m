classdef Child
    properties
      weights_in (:,:) double
      bias_in (:,:) double

      weights_hidden (:,:,:) double
      bias_hidden (:,:,:) double

      weights_out (:,:) double
      bias_out (:,:) double
    end
end
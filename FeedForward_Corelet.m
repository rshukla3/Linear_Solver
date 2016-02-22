%% BootCamp Example 1: A simple identity corelet
%
%% Description
%  Pass any input spikes through
%
%% Parameters
%  None
%
%% Connectors
%  1                Name:                               Input
%                   I/O:                                Input
%                   Coding scheme:                      None
%                   Connector group size:               N/A
%                   Connector size:                     [parameter]
%
%  2                Name:                               Output 
%                   I/O:                                Output
%                   Coding scheme:                      None
%                   Connector group size:               N/A
%                   Connector size:                     (inputSize)

%% Detailed Description
%  None
%
classdef FeedForward_Corelet < corelet
     properties
         
         % The number of input pins (also the number of output pins)
         numInputPins = 9;
         numOutputPins = 9;
     end      
     
     methods

         %-----------------------------------------------------------------
         % The constructor - it has no arguments.
         %-----------------------------------------------------------------
         function  obj = FeedForward_Corelet()

             % Set my name (this property is inherited from the corelet
             % parent class)
             obj.name='Matrix_Mul';
             
             % Do the rest of the work associated with creating a corelet;
             % set up the neuron type, allocate/set up the cores we'll
             % need, and then do the internal/external connectivity
             obj.setupNeuronTypes();
             obj.setupCores();
             obj.setupIO();
         end
        
         %-----------------------------------------------------------------
         % Set up the neuron type we are going to be using.
         %-----------------------------------------------------------------
         function setupNeuronTypes( obj )
             
             % We only have a single neuron type.
             obj.addNeuronTypes( 3, 'linear' );

             % Set the parameters for this neuron. Its alpha (threshold) is
             % set to 1 so it spikes on any input; it's axon weights are
             % set also to 1.  The rest of the parameters are the default.
             obj.neuron( 1 ).alpha = 4;            % threshold
             obj.neuron( 1 ).S = [ 0 0 1 0 ];      % axon weights
             obj.neuron( 1 ).sigma = [ 1 1 1 1 ];  % signs of axon weights
             obj.neuron( 1 ).gamma = 1;
             obj.neuron(1).leak = 0;             % negative leak
             
             
             
             obj.neuron( 2 ).alpha = 4;            % threshold
             obj.neuron( 2 ).S = [ 0 0 1 0 ];      % axon weights
             obj.neuron( 2 ).sigma = [ 1 1 1 1 ];  % signs of axon weights
             obj.neuron( 2 ).gamma = 1;
             obj.neuron(2).leak = 0;             % negative leak
             
             
             obj.neuron( 3 ).alpha = 4;            % threshold
             obj.neuron( 3 ).S = [ 1 1 1 0 ];      % axon weights
             obj.neuron( 3 ).sigma = [ 1 1 1 1 ];  % signs of axon weights
             obj.neuron( 3 ).gamma = 1;
             obj.neuron(3).leak = 0;             % negative leak
         end
         
         %-----------------------------------------------------------------
         % Set up the core
         %-----------------------------------------------------------------
         function setupCores( obj )
             
             % Add the required number of cores.  We only need 1
             obj.addCores( 1 );
             
             % Set all of the  axon types to be 0
             axonTypes( 1 : 3: 256 ) = 0;
             axonTypes( 2 : 3: 256 ) = 1;
             axonTypes( 3 : 3: 256 ) = 2;
             % The crossbar is an identity matrix, each axon(X) is connected
             % to neuron(X)
             crossbar = zeros( 256, 256, 'uint8' ); 
             
             % Setting the crossbar connections for R1
             crossbar( 1:3 , 1 ) = 1;
             crossbar( 4:6 , 2 ) = 1;
             crossbar( 7:9 , 3 ) = 1;
             
             % Setting the crossbar connections for R2
             crossbar( 1:3 , 4 ) = 1;
             crossbar( 4:6 , 5 ) = 1;
             crossbar( 7:9 , 6 ) = 1;
             
             % Setting the crossbar connections for R2
             crossbar( 1:3 , 7 ) = 1;
             crossbar( 4:6 , 8 ) = 1;
             crossbar( 7:9 , 9 ) = 1;
             
             
             % All of the neurons are the same type as well
             % the ones that we are interested in.
             neuronTypes( 1:1:3 ) = obj.neuron( 1 ).nID;
             neuronTypes( 4:1:6 ) = obj.neuron( 2 ).nID;
             neuronTypes( 7:1:9 ) = obj.neuron( 3 ).nID;
             
             neuronTypes( 10:256 ) = obj.neuron( 1 ).nID*0;

             % Set the crossbar, axon types and neuron types for the core
             obj.core( 1 ).setW_ij( crossbar );
             obj.core( 1 ).setAllG_i( axonTypes );
             obj.core( 1 ).setAllNeurons( neuronTypes );
         end
         
         %-----------------------------------------------------------------
         % Set up all of the connectivity
         %-----------------------------------------------------------------
         function setupIO( obj )
             % Create the input and output connectors; each has
             % numInputPins
             obj.inputs( 1 ) = connector( obj.numInputPins, 'input' );
             obj.outputs( 1 ) = connector( obj.numOutputPins, 'output' );

             % For the input, we'll create two arrays of numInputPins; the
             % first is for the destination cores, which are all going to
             % be the core id of the first/only core.  The second is the
             % destination axons, which are simply 1 to 256
             destCores( 1 : 9 ) = obj.core( 1 ).coreID;
             destAxons = 1:9;
                          
             % Wire the pins of the input connector (1:256) to the
             % cores/axons that were set up above
             obj.inputs( 1 ).wireTgtCores( destCores, destAxons );
             
             % The output wiring is identical in this case, so we can just
             % reuse the destCores and destAxons arrays
             srcCores(1:9) = obj.core( 1 ).coreID;
             srcNeurons = 1:9;
             
             obj.core( 1 ).setDisconnected( 10 : 256 );
             
             obj.outputs( 1 ).wireSrcCores( srcCores, srcNeurons );
         end

         %-----------------------------------------------------------------
         % Corelet display method to display any relevant information
         %-----------------------------------------------------------------
         function dispThis( obj, depth )  
            fprintf( 'Corelet %s: \n',obj.name );
         end

         %-----------------------------------------------------------------
         % Verify method - check to see that any parameters/settings are
         % correct, return true if this is the case, false otherwise.
         %-----------------------------------------------------------------
        function verified = verifyThis( obj, depth )
            % always return true
            verified = true;
        end 
    end % methods
end % classdef

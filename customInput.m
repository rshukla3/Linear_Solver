% Simple function to generate a spike file consisting of a bunch of
% triangles 
function ok = customInput( spikeFilename, conn, ticksPerFrame, numTicks )
    ok = false;
    
    % Get the number of pins for the connector; it's used to compute the
    % size of the triangle generated.
    numPins = conn.csize();

    % Now create a one triangle worth of spikes (a numPins x numPins square
    % with everything from the diagonal down set to 1)
%     if( filled == 1 )
%         triangle = tril( ones( numPins, numPins, 'uint8' ), 0 );
%     else
%         triangle = eye( numPins, numPins, 'uint8' );
%         triangle( 1 : numPins, 1 ) = 1;
%         triangle( numPins, 1 : numPins ) = 1;
%     end
    
     I_11 = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
     I_12 = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
     I_13 = [1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0];
     
     I_21 = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
     I_22 = [1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0];
     I_23 = [1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0];
     
     I_31 = [1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0];
     I_32 = [1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0];
     I_33 = [1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0];
     
     InputMatrix = [I_11; I_12; I_13; I_21; I_22; I_23; I_31; I_32; I_33];
     
     %Complete_InputMatrix = repmat(InputMatrix, 3, 1);
     
     frameCount = numTicks/ticksPerFrame;

    % Replicate that shape across repCount times to create the spike table
    % spikes = repmat( triangle, 1, repCount );
    spikes = repmat(InputMatrix, 1, frameCount);
    % Create a structure containing the spikes and the connector - this is
    % then passed to the create_spike_file method.
    spikeTable.spikes = spikes;
    spikeTable.connector = conn;

    % Call the CPE function to create the spike file.
    create_spike_file( spikeFilename, spikeTable );

    ok = true;
end

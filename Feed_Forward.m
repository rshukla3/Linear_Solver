%-----------------------------------------------------------------------------
% BootCamp example 1 - script to instantiate a corelet and run it with
% with suitable input
%-----------------------------------------------------------------------------

%% TODO: Initialize the corelet environment.
corelet_init;

%% TODO: Create an instance of the corelet
% it takes no arguments; we also set its input and output connectors to be external
testCorelet = FeedForward_Corelet();

testCorelet.inputs( 1 ).setExternalInput('bootCampIn') ;
testCorelet.outputs( 1 ).setExternalOutput('bootCampOut') ;


%% TODO: Set up the information needed by makeRunModel functions
modelName = 'MatrixMul';         % The name of the model
outputFolder = 'test';      % Subdirectory for output
outputFormat = 'TEXT';      % The output spike file format (e.g. 'TEXT')
runTarget = 'NSCS';         % Run on the simulator or hardware (NSCS|TN)
prefsName = 'runPreferences.m';         % Run-related preferences
numTicks = 1024;           % Number of ticks to run the simulation

%% TODO: Generate a structure of all of the filenames that we'll be reading and writing
myFileNames = testCorelet.genMakeRunFilenames( modelName, outputFolder, runTarget, outputFormat );


%% TODO: Generate some input data for the simulation 
% Use the helper routine to create some input that will be recognizable as output.
% After the file is generated, it is displayed as well.
tickPerFrame = 16;
spikeInputFile = 'MatrixMulInput.sfti';

customInput( spikeInputFile, testCorelet.inputs( 1 ), tickPerFrame, numTicks );
read_spike_file( spikeInputFile );

%% TODO: Set up a parameter structure 
% It contains all of the properties that need to be set for makeAndRunModel - 
% in particular, it needs to know what mode to run in, how many ticks to run
% for, and what the name of the spike input file is going to be.
runParameters = struct (...
    'mode', 'NORMAL',...                 % Defaults to NORMAL if not set, can be set to DEBUG or NORMAL
    'tickCount', numTicks, ...           % Defaults to 100 if this isn't set
    'inputFileName', spikeInputFile ...  % Defaults to 'InputSpikes.sfti' if unset.
    );


%% TODO: Lastly, run the model using the simulator
% and then if things work correctly, visualize the output using the spike viewer.
try
    rc = makeAndRunModel( testCorelet, modelName, outputFolder, runTarget, prefsName, runParameters );
    if( strcmp( runTarget, 'NSCS' ) == 1 )
        sout = read_spike_file( myFileNames.outputSpikesLocal, myFileNames.outputMapLocal );
    else
        sftoName = myFileNames.outputSpikesLocal;
        tnsfName = myFileNames.outputSpikesTNLocal;
        linuxCmd = 'tnsf-fixup';
        cmd = [ linuxCmd, ' ', ...
                '-i', ' ', tnsfName, ' ', ...
                '-o', ' ', sftoName, ' ', ...
                '-O', ' ', myFileNames.outputMapLocal, ' ', ...
                '-s', ' ', myFileNames.outputMapLocal, ' ', ...
                '-e', ' ', 'TEXT' ];
        system( cmd );
        read_spike_file( sftoName, myFileNames.outputMapLocal );
    end
    fprintf( '\n\nCongratulations, your corelet ran successfully!\n' );
catch err
    fprintf( 'There was an error running the example.  The error information is as follows:\n' );
    fprintf( '\tIdentifier: %s\n', err.identifier );
    fprintf( '\tMessage: %s\n', err.message );
    rethrow( err );
end

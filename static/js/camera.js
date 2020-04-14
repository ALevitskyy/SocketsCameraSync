append_to_log = function(msg){
    var element = document.querySelector("#log");
    var child = document.createElement("P");
    child.innerHTML = msg;
    element.appendChild(child);
}

var cameraName
var mediaStream = null;

if (false /* for Microsoft Edge */) {
    var cameraPreview = document.getElementById('camera-preview');
    cameraPreview.parentNode.innerHTML = '<audio id="camera-preview" controls style="border: 1px solid rgb(15, 158, 238); width: 94%;"></audio> ';
}

var socketio = io.connect('http://' + document.domain + ':' + location.port + '/test');
socketio.on('name_assign', function(msg) {
    window.cameraName = msg.name
    append_to_log("The name "+window.cameraName+" was assigned")
});
socketio.on('start_recording', function(msg) {
    startRecording()
});
socketio.on('end_recording', function(msg) {
    endRecording()
});

startRecording = function() {
    startRecording.disabled = true;
    navigator.getUserMedia({
        audio: true,
        video: true
    }, function(stream) {
        mediaStream = stream;

        recordAudio = RecordRTC(stream, {
            type: 'audio',
            recorderType: StereoAudioRecorder,
            onAudioProcessStarted: function() {
                recordVideo.startRecording();
            }
        });

        var videoOnlyStream = new MediaStream();
        stream.getVideoTracks().forEach(function(track) {
            videoOnlyStream.addTrack(track);
        });

        recordVideo = RecordRTC(videoOnlyStream, {
            type: 'video',
            recorderType: !!navigator.mozGetUserMedia ? MediaStreamRecorder : WhammyRecorder
        });

        recordAudio.startRecording();

    }, function(error) {
        alert(JSON.stringify(error));
    });
};
endRecording = function() {

    // stop audio recorder
    recordAudio.stopRecording(function() {
        // stop video recorder
        recordVideo.stopRecording(function() {

            // get audio data-URL
            recordAudio.getDataURL(function(audioDataURL) {

                // get video data-URL
                recordVideo.getDataURL(function(videoDataURL) {
                    var files = {
                        audio: {
                            type: recordAudio.getBlob().type || 'audio/wav',
                            dataURL: audioDataURL
                        },
                        video: {
                            type: recordVideo.getBlob().type || 'video/webm',
                            dataURL: videoDataURL
                        },
                        name: window.cameraName
                    };

                    socketio.emit('files', files);

                    if (mediaStream) mediaStream.stop();
                });

            });
        });
    });
};
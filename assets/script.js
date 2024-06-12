import {
  PoseLandmarker,
  FilesetResolver,
  DrawingUtils
} from "/modules/tasks-vision-outer.js"

let poseLandmarker = undefined
let runningMode = "IMAGE"
let enableWebcamButton
let webcamRunning = false


// Check if webcam access is supported.
const hasGetUserMedia = () => !!navigator.mediaDevices?.getUserMedia

// Before we can use PoseLandmarker class we must wait for it to finish
// loading. Machine Learning models can be large and take a moment to
// get everything needed to run.
const createPoseLandmarker = async () => {
  const vision = await FilesetResolver.forVisionTasks("/wasm")

  poseLandmarker = await PoseLandmarker.createFromOptions(vision, {
    baseOptions: {
      modelAssetPath: `/models/pose_landmarker_full.task`,
      delegate: 'GPU',
    },
    runningMode: runningMode,
    numPoses: 1
  })

  if (hasGetUserMedia()) {
    enableCam()
  }
}
createPoseLandmarker()


/********************************************************************
// Demo 2: Continuously grab image from webcam stream and detect it.
********************************************************************/

const video = document.getElementById("webcam")
const canvasElement = document.getElementById("output_canvas")
const canvasCtx = canvasElement.getContext("2d")
const drawingUtils = new DrawingUtils(canvasCtx)

// Enable the live webcam view and start detection.
function enableCam() {
  if (!poseLandmarker) {
    console.log("Wait! poseLandmaker not loaded yet.")
    return
  }

  if (webcamRunning === true) {
    webcamRunning = false
  } else {
    webcamRunning = true
  }

  // getUsermedia parameters.
  const constraints = {
    video: true
  }

  // Activate the webcam stream.
  navigator.mediaDevices.getUserMedia(constraints).then(stream => {
    video.srcObject = stream
    video.addEventListener("loadeddata", predictWebcam)
  })
}

let lastVideoTime = -1

let loading = false;

async function predictWebcam() {
    if(!loading){

        loading = true;

        let videoHeight = video.videoHeight;
        let videoWidth = video.videoWidth;
        console.log(videoHeight, videoWidth);

        let aspectRatio = videoHeight / videoWidth;
        const liveView = document.getElementById("liveView");
        liveView.style.width = '100%';
        liveView.style.height = (liveView.offsetWidth * aspectRatio) + 'px';

        // Now let's start detecting the stream.
        if (runningMode === "IMAGE") {
        runningMode = "VIDEO"
        await poseLandmarker.setOptions({ runningMode: "VIDEO" })
        }
        let startTimeMs = performance.now()
        if (lastVideoTime !== video.currentTime) {
        lastVideoTime = video.currentTime
        poseLandmarker.detectForVideo(video, startTimeMs, result => {
          window.flutter_inappwebview.callHandler("sendPose", result.landmarks, aspectRatio);

          /*
          canvasCtx.save()
          canvasCtx.clearRect(0, 0, canvasElement.width, canvasElement.height)

          for (const landmark of result.landmarks) {
            drawingUtils.drawLandmarks(landmark, {
              radius: data => DrawingUtils.lerp(data.from.z, -0.15, 0.1, 5, 1)
            })
            drawingUtils.drawConnectors(landmark, PoseLandmarker.POSE_CONNECTIONS)
          }

          canvasCtx.restore()
          */

          loading = false;
        })
    }

    // Call this function again to keep predicting when the browser is ready.
    if (webcamRunning === true) {
      window.requestAnimationFrame(predictWebcam)
    }
  }
}

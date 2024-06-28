import {
  PoseLandmarker,
  FilesetResolver,
  DrawingUtils
} from "/modules/tasks-vision-outer.js"

console.log("Check2");

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

let lastVideoTime = 0

let lastFrameTime = performance.now();

let loading = false;

async function predictWebcam() {
    let currentTime = performance.now();
    let timeDiff = currentTime - lastFrameTime; // in ms

    // if less than 33.33ms has passed (which is roughly 30 FPS), skip this frame
    if (timeDiff < 33.33) {
      window.requestAnimationFrame(predictWebcam);
      return;
    }
    lastFrameTime = currentTime; // update last frame time

    if (loading) {
      window.requestAnimationFrame(predictWebcam);
      return;
    }
    loading = true;

    let videoHeight = video.videoHeight;
    let videoWidth = video.videoWidth;

    let aspectRatio = videoHeight / videoWidth;
    const liveView = document.getElementById("liveView");
    liveView.style.width = '100%';
    liveView.style.height = (liveView.offsetWidth * aspectRatio) + 'px';

    // Now let's start detecting the stream.
    if (runningMode === "IMAGE") {
        runningMode = "VIDEO"
        await poseLandmarker.setOptions({ runningMode: "VIDEO" })
    }

    let startTimeMs = performance.now();

    if (lastVideoTime === 0 || lastVideoTime !== video.currentTime) {
        if(lastVideoTime === 0) {
            lastVideoTime = video.currentTime;
        }
        let timeSinceLastFrame = video.currentTime - lastVideoTime;
        lastVideoTime = video.currentTime

        poseLandmarker.detectForVideo(video, startTimeMs, result => {
          if(result.landmarks.length > 0) {
              const landmarks = result.landmarks[0];
              const worldLandmarks = result.worldLandmarks[0];

              const poseData = landmarks.map(
                (landmark, index) => {
                    return {
                        imageX: landmark.x,
                        imageY: landmark.y,
                        worldX: worldLandmarks[index].x,
                        worldY: worldLandmarks[index].y,
                        worldZ: worldLandmarks[index].z,
                        visibility: landmark.visibility,
                    };
                }
              );

              window.flutter_inappwebview.callHandler("sendPose", poseData, timeSinceLastFrame, aspectRatio);
          }
          loading = false;
        });
      }
    // Call this function again to keep predicting when the browser is ready.
    if (webcamRunning === true) {
      window.requestAnimationFrame(predictWebcam)
    }
}

if("mediaDevices" in navigator && "getUserMedia" in navigator.mediaDevices){
  console.log("Let's get this party started")
}

// navigator.mediaDevices.getUserMedia({video: {facingMode: {ideal: "environment"}}})

async function getDevices() {
  const devices = await navigator.mediaDevices.enumerateDevices()
  const debug = document.querySelector("#DebugPre")
  debug.innerHTML = devices.map(st => `${st.kind}: ${st.deviceId}`).join("\n")
}

getDevices()

const video = document.querySelector("video")
// let streamStarted = false

const startCapture = async () => {
  const s = navigator.mediaDevices.getUserMedia({video: true})
  console.log("Have", s)
  const stream = await navigator.mediaDevices.getUserMedia({video: {facingMode: {ideal: "environment"}}})
  console.log("We got", stream)
  // video.srcObject = stream;
}

// startCapture()

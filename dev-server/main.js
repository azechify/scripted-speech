
const elem = document.createElement("audio");

elem.addEventListener("loadeddata", e => { 
  console.log(e, "メディアの最初のフレームが読み込み終わった。");
});

elem.addEventListener("loadedmetadata", e => {
  console.log(e, "メタデータを読み込んだ。");
});



let ctx;
let src;
let analyser;

const canvas = document.getElementById("canvas");
const canvasCtx = canvas.getContext("2d");

document.getElementById("form").addEventListener("submit", async e =>{
  e.preventDefault();
  const data = new FormData(e.target);
  const radio = data.get("radio");
  const input = encodeURIComponent(data.get(radio));
    
  const canplay = new Promise(resolve => {
    elem.addEventListener("canplaythrough", resolve, {once: true});
  });

  elem.src = `./speech?${radio}=${input}`;

  await canplay;

  ctx = ctx ?? new AudioContext();
  src = src ?? ctx.createMediaElementSource(elem);
  analyser = analyser ?? ctx.createAnalyser();

  // idempotent method call
  src.connect(analyser);
  analyser.connect(ctx.destination);

  visualize();

  elem.addEventListener("ended", ()=>{
    console.log("media ended");
    elem.src = "";
  }, {once: true})
  elem.play();
});

function visualize() {
  const w = canvas.width;
  const h = canvas.height;

  // sinewave
  analyser.fftSize = 2048;
  const buff = new Uint8Array(analyser.fftSize);

  canvasCtx.clearRect(0, 0, w, h);

  let draw = function() {
    requestAnimationFrame(draw);

    analyser.getByteTimeDomainData(buff);

    canvasCtx.fillStyle = 'rgb(200, 200, 200)';
    canvasCtx.fillRect(0, 0, w, h);
    canvasCtx.lineWidth = 2;
    canvasCtx.strokeStyle = 'rgb(0,0,0)';
    canvasCtx.beginPath();

    const size = buff.length;
    const sliceWidth = w * 1.0 / size;
    let x = 0;
    for(var i = 0; i < size; i++) {
      const v = buff[i] / 128.0;
      const y = v * h / 2;
      if(i === 0) {
        canvasCtx.moveTo(x, y);
      } else {
        canvasCtx.lineTo(x, y);
      }

      x += sliceWidth;
    }

    canvasCtx.lineTo(w, h / 2);
    canvasCtx.stroke();
  };

  draw();

  
}

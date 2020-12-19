
const elem = document.createElement("audio");

elem.addEventListener("loadeddata", e => { 
  console.log(e, "メディアの最初のフレームが読み込み終わった。");
});

elem.addEventListener("loadedmetadata", e => {
  console.log(e, "メタデータを読み込んだ。");
});



let ctx;
let src;

document.getElementById("button").addEventListener("click", async ()=>{

  const canplay = new Promise(resolve => {
    elem.addEventListener("canplaythrough", resolve, {once: true});
  });

  elem.src = "./sample.mp3";

  await canplay;

  ctx = ctx ?? new AudioContext();
  src = src ?? ctx.createMediaElementSource(elem);

  // idempotent method call
  src.connect(ctx.destination);

  elem.addEventListener("ended", ()=>{
    console.log("media ended");
    elem.src = "";
  }, {once: true})
  elem.play();
});


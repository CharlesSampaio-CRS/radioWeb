const radio = document.getElementById('radio');
const btn = document.getElementById('playPause');

btn.addEventListener('click', () => {
  if (radio.paused) {
    radio.play();
    btn.textContent = '⏸ Pause';
  } else {
    radio.pause();
    btn.textContent = '▶ Play';
  }
});

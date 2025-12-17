document.addEventListener("DOMContentLoaded", () => {
  const viewer = document.getElementById("sidebar-model");

  const modelos = [
    {
      src: "/assets/models3d/modelo-stitchmalo-1.glb",
      orbit: "100deg 75deg auto"
    },
    {
      src: "/assets/models3d/modelo-stitchmalo-2.gltf",
      orbit: "0deg 90deg auto"
    }
  ];

  let modeloActual = 0;
  let clickCount = 0;
  const clicksParaCambiar = 5; // Cambiar modelo tras 5 clicks

  viewer.addEventListener("click", () => {
    clickCount++;

    if (clickCount >= clicksParaCambiar) {
      modeloActual = (modeloActual + 1) % modelos.length;

      // Cambia el src del modelo
      viewer.src = modelos[modeloActual].src;

      // Cambia la cámara usando setAttribute
      viewer.setAttribute("camera-orbit", modelos[modeloActual].orbit);

      // Resetea la cámara para que el cambio se aplique
      viewer.jumpCameraToGoal();

      // Reinicia el contador
      clickCount = 0;
    }
  });
});

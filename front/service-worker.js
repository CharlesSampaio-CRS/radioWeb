self.addEventListener("install", (event) => {
    console.log("Service Worker instalado 🚀");
  });
  
  self.addEventListener("activate", (event) => {
    console.log("Service Worker ativo ✅");
  });
  
  self.addEventListener("fetch", (event) => {
    // deixa passar todas as requisições
  });
  
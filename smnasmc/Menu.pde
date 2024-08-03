class Menu {
  Boton[] botones;
  String estadoACambiar = ""; // Inicializa estadoACambiar con una cadena vacía

  void setupMenu() {
    botones = new Boton[9];

    String[][] estados = {
      {"Acoso", "Discriminacion", "Proteccion"},
      {"Soberbia", "Desamparo", "Desinteres"},
      {"Timidez", "Empatia", "Mediacion"}
    };

    int indBoton = 0; 
    float tamBoton = 100;

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        rectMode(CORNER);
        botones[indBoton] = new Boton(width/10+width/3 * j, height/3 * i, tamBoton, estados[i][j]);
        indBoton++;
      }
    }
  }

  void mostrarMenu() {
    for (Boton boton : botones) {
      boton.dibujar();

      if (mousePressed && boton.isMouseOver()) {
        estadoACambiar = boton.getEstado();
      }
    }
    
    // Puedes agregar una verificación para evitar problemas al usar estadoACambiar
    if (estadoACambiar != null) {
      println(estadoACambiar);
    }
  }
  
  String queEstado() {
    return estadoACambiar;
  }
}

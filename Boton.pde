class Boton {
  String estado;
  float posXBoton;
  float tamBoton;
  float posYBoton;
  
  Boton(float posX_, float posY_, float tam_, String estado_) {
    posXBoton = posX_;
    posYBoton = posY_;
    tamBoton = tam_;
    estado = estado_;
  }
  
  void dibujar() {
    rect(posXBoton, posYBoton, tamBoton, tamBoton);
    push();
    fill(0);
    textAlign(CENTER, CENTER);
    text(estado, posXBoton + tamBoton / 2, posYBoton + tamBoton / 2);
    pop();
  }

  boolean isMouseOver() {
    return mouseX > posXBoton && mouseX < posXBoton + tamBoton && mouseY > posYBoton && mouseY < posYBoton + tamBoton;
  }

  String getEstado() {
    return estado;
  }
}

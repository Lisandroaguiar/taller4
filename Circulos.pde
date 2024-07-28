class Circulos {
  float posXCirculo, posYCirculo, tamCirculo;
  color colorCirculo;

  Circulos(float posX_, float posY_ ) {
    posXCirculo = posX_;
    posYCirculo = posY_;
  }

  // Method to draw the circle
  void dibujarCirculos(color colorCirculo_, float tam_) {
    colorCirculo = colorCirculo_;
    tamCirculo = tam_;

    push();
    fill(colorCirculo);
    circle(posXCirculo, posYCirculo, tamCirculo);
    pop();
  }

  // Method to update circle position
  void actualizarComportamiento(float posX_, float posY_) {
    posXCirculo = posX_;
    posYCirculo = posY_;
  }
}

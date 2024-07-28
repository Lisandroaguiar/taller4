class Circulos {
  float x, y;
 boolean detener; 
  Circulos() {
    x = random(width-100);
    y = random(height-100);
        detener = false; // Inicialmente no detenido

  }

  void dibujarCirculos(color c, float tam, float x, float y) {
    fill(c);
    noStroke();
    ellipse(x, y, tam, tam);
  }
}

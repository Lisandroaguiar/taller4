class Circulos {
  float x, y, dx, dy;
  boolean detener;
  Circulos() {
    x = random(width);
    y = random(height);
    dx = random(-2, 2);
    dy = random(-2, 2);
  }

  void dibujarCirculos(color c, float tam, float x, float y) {
    fill(c);
    noStroke();
    ellipse(x, y, tam, tam);
  }
}

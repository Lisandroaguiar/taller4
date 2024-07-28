Menu menu;
String estado;
Circulos circulos[];
int cantidadCirculos=10;
color colorCirculo;
float baseX = 60;
float baseY = 60;
float tam = 40;
boolean[] desamparoCirculos;
float posXD = 100;
float posYD = 100;

void setup() {
  size(800, 400);
  menu = new Menu();
  menu.setupMenu();
  estado="menu";
  colorCirculo=color(255, 0, 0);
  desamparoCirculos = new boolean[6]; // Para los 6 círculos del estado "Desamparo"

  circulos=new Circulos[cantidadCirculos];
  for (int i = 0; i < cantidadCirculos; i++) {
    float posX = 20 + sin(frameCount / 5.0) * 100;
    float posY = 10 * i;
    circulos[i] = new Circulos(posX, posY);
  }
}

void draw() {
  if (estado=="menu") {
    background(255);
    menu.mostrarMenu();
    println(menu.queEstado(), estado);
  } else if (estado=="Acoso") {
    background(0);
    cantidadCirculos=8;
    for (int i=0; i<cantidadCirculos; i++) {
      for (int j=0; j<cantidadCirculos; j++) {
        float posX =  sin(frameCount / 5.0 )+400+40*i*sin(i); // Update position with frameCount and index
        float posY = 20+40 * i;

        if (mousePressed) {
          float angleStep = TWO_PI / cantidadCirculos;

          float angle = i* angleStep;
          float radius = 80; // Radius of the circle around the cursor
          posX = mouseX + cos(angle) * radius + sin(frameCount/3) ;
          posY = mouseY + sin(angle) * radius+ sin(frameCount/3) ;
        }
        circulos[i].actualizarComportamiento(posX, posY);
      }
      circulos[i].dibujarCirculos(colorCirculo, tam);
    }
  } else if (estado == "Discriminacion") {
    background(0);

    float angleStep = TWO_PI / cantidadCirculos;
    float radio = 80; // Radius of the circle around the base position

    for (int i = 0; i < cantidadCirculos; i++) {
      float angulo = i * angleStep;
      float posX = baseX + cos(angulo) * radio + sin(frameCount / 3.0);
      float posY = baseY + sin(angulo) * radio + sin(frameCount / 3.0);

      circulos[i].actualizarComportamiento(posX, posY);
      circulos[i].dibujarCirculos(colorCirculo, tam);
    }

    if (mousePressed) {
      float distancia = dist(mouseX, mouseY, baseX, baseY);
      if (distancia < 150 && distancia>100) {
        baseX=map(mouseX, 40, width, width, 0);
        baseY=map(mouseY, 40, height, height, 0);
      }
      if (distancia < 100) {
        baseX=random(width);
        baseY=random(height);
      }
      // println(distancia);
    }
  } else if (estado=="Defensa") {
    background(0);
    float greenX = width / 2;
    float greenY = height / 2;
    float moveSpeed = 1;

    // Dibujar el círculo verde
    colorCirculo = color(0, 255, 0);
    circulos[0].actualizarComportamiento(greenX, greenY);
    circulos[0].dibujarCirculos(colorCirculo, tam);

    for (int i = 1; i < 5; i++) {
      float redX = circulos[i].posXCirculo;
      float redY = circulos[i].posYCirculo;

      float distance = dist(redX, redY, greenX, greenY);
      float angle = atan2(greenY - redY, greenX - redX);

      // Movimiento hacia y desde el círculo verde
      if (frameCount % 2 < 30 && distance>30) {
        redX += cos(angle) * moveSpeed;
        redY += sin(angle) * moveSpeed;
      } else {
        redX -= cos(angle) * moveSpeed;
        redY -= sin(angle) * moveSpeed;
      }

      // Alejarse del mouse cuando está presionado
      if (mousePressed) {
        float mouseDist = dist(redX, redY, mouseX, mouseY);
        if (mouseDist < 100) {
          float mouseAngle = atan2(redY - mouseY, redX - mouseX);
          redX += cos(mouseAngle) * moveSpeed * 3;
          redY += sin(mouseAngle) * moveSpeed * 3;
        }
      }

      circulos[i].actualizarComportamiento(redX, redY);
      circulos[i].dibujarCirculos(color(255, 0, 0), tam);
    }
  } else if (estado=="Soberbia") {
    background(0);
    float posX=200;
    float posY=80;
    float tam=60;
    colorCirculo=color(255, 0, 0);
    if (mousePressed) {
      tam-=30;
    }

    for (int i=0; i<5; i++) {
      for (int j=0; j<5; j++) {
        circulos[i].actualizarComportamiento(posX+60*i, posY+60*j);
        if ((i+j)%2==0) {

          circulos[i].dibujarCirculos(colorCirculo, tam);
        }
      }
    }
  }

  if (estado=="Desamparo") {
    background(0);

    colorCirculo = color(255, 0, 0);
    if (mousePressed) {
      for (int i = 0; i < 6; i++) {
        desamparoCirculos[i] = true;
      }
    }
    for (int i = 0; i < 6; i++) {

      if (desamparoCirculos[i]) {
        // Mueve el círculo lentamente hacia afuera de la pantalla
        if (circulos[i].posXCirculo < width / 2) {
          posXD -= .5;
        } else {
          posXD+= .5;
        }
        if (circulos[i].posYCirculo < height / 2) {
          posYD -= .5;
        } else {
          posYD += .5;
        }
      }
      for(int j=0; j<6; j++){      circulos[i].actualizarComportamiento(posXD+tam*i, posYD+tam*j);

      if((i+j)%2==0){
      circulos[i].dibujarCirculos(colorCirculo, tam);
    }}}
  }

  if (estado=="Desinteres") {
    background(0);
  }

  if (estado=="Timidez") {
    background(0);
    float posX=200;
    float posY=80;
    float tam=60;
    colorCirculo=color(255, 0, 0);
    if (mousePressed) {
      tam+=40;
    }

    for (int i=0; i<5; i++) {
      for (int j=0; j<5; j++) {
        circulos[i].actualizarComportamiento(posX+tam/1.3*i, posY+tam/1.3*j);
        if ((i+j)%2==0) {

          circulos[i].dibujarCirculos(colorCirculo, tam);
        }
      }
    }
  }

  if (estado=="Empatia") {
    background(0);
  }

  if (estado=="Mediacion") {
    background(0);
  }
}

void mouseClicked() {
  estado=menu.queEstado();
}

void keyPressed() {

  estado="menu";
}

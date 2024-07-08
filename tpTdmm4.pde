Menu menu;
String estado;
Circulos circulos[];
int cantidadCirculos = 10;
color colorCirculo;
float tam = 40;
float tamVerde = 40; // Tamaño del círculo verde
float tamCirculoRojo = 40; // Tamaño inicial del círculo rojo
boolean moverse = false;
int aceleracion[];
int atacado = 1; // Índice del círculo rojo que será atacado
float tiempoPegado = 0; // Tiempo en segundos que los círculos rojos estarán pegados al verde
PImage circuloVerde, circuloRojo, circuloRojoPinchudo, circuloRojoSemiPinchudo;
boolean[] enPelea = new boolean[cantidadCirculos];
boolean[] peleando = new boolean[cantidadCirculos];

boolean[] atacando = new boolean[cantidadCirculos];
boolean[] discriminando = new boolean[cantidadCirculos];

void setup() {
  size(800, 400);
  menu = new Menu();
  aceleracion = new int[cantidadCirculos];
  menu.setupMenu();
  estado = "menu";
  colorCirculo = color(255, 0, 0);
  circulos = new Circulos[cantidadCirculos];
  for (int i = 0; i < cantidadCirculos; i++) {
    circulos[i] = new Circulos();
    aceleracion[i] = 2;
    enPelea[i] = false;
    peleando[i] = false;

    atacando[i] = false;
    discriminando[i]=false;
  }
  circuloVerde= loadImage("AmebaVerde_1.png");
  circuloRojo= loadImage("AmebaRoja_1.png");
  circuloRojoSemiPinchudo= loadImage("AmebaRoja_2.png");
  circuloRojoPinchudo= loadImage("AmebaRoja_3.png");
  noCursor();
}

void draw() {
  if (estado == "menu") {
    background(255);
    menu.mostrarMenu();
    println(menu.queEstado(), estado);
    resetCircles();
    push();
    cursor();
    pop();
  } else {
    background(255);
    noCursor();
    dibujarEnemigos();
    if (moverse) {
      moverCirculos();
      manejarColisiones();
      // Verificar si los círculos rojos deben pelear
    }
  }
}

void mouseClicked() {
  estado = menu.queEstado();
  moverse = true; // Comienza a moverse según el estado
}

void mousePressed() {
  if (estado == "Soberbia") {
    tamVerde = 80; // Agrandar círculo verde
  } else if (estado == "Timidez" || estado == "Desamparo") {
    tamVerde = 20; // Achicar círculo verde
  }
}

void keyPressed() {
  estado = "menu";
  tamVerde = 40; // Reiniciar tamaño del círculo verde al volver al menú
}

void dibujarEnemigos() {
  for (int i = 0; i < cantidadCirculos; i++) {
    if (i == 0) {
      image(circuloVerde, mouseX, mouseY, tamVerde, tamVerde); // Círculo verde
      manejarColisionesCirculoVerde(i); // Manejar colisiones con el círculo verde
    } else {
      float tamActual = (estado.equals("Desamparo") && i != 0) ? tamCirculoRojo : tam;
      PImage img = obtenerImagenRojo(i); // Obtener la imagen correcta para el círculo rojo
      image(img, circulos[i].x, circulos[i].y, tamCirculoRojo, tamCirculoRojo);
      manejarColisionesCirculosRojos(0, i); // Manejar colisiones entre el círculo verde y los rojos
    }
  }
}
PImage obtenerImagenRojo(int i) {
  println(enPelea[i]);
  if (atacando[i] && estado=="Proteccion" ||atacando[i] && estado=="Acoso") {
    return circuloRojoPinchudo;
  }
    else if (estado=="Mediacion"&&peleando[i]) {
    return circuloRojoPinchudo;
  } 
  
  else if (discriminando[i] && estado=="Discriminacion") {
    return circuloRojoSemiPinchudo;
  }
  // Puedes personalizar la lógica para elegir la imagen correcta
  else {
    return circuloRojo;
  }
}
void moverCirculos() {
  for (int i = 1; i < cantidadCirculos; i++) {
    if (estado == "Acoso") {
      moverAcoso(i);
    } else if (estado == "Discriminacion") {
      moverDiscriminacion(i);
    } else if (estado == "Proteccion") {
      moverProteccion(i);
    } else if (estado == "Soberbia") {
      moverLateral(i); // Sigue moviéndose lateralmente
    } else if (estado=="Desamparo") {
      moverProteccion(i);
    } else if (estado == "Empatía") {
      if (tiempoPegado > 0) {
        circulos[i].x = mouseX; // Stick the red circle to the green circle
        circulos[i].y = mouseY; // Update the remaining stuck time
        tiempoPegado -= (millis() / 1000) - tiempoPegado;
        if (tiempoPegado <= 0) { // If the stuck time has ended
          tiempoPegado = 0; // Reset the stuck time
        }
      }
    } else if (estado=="Mediacion") {
      moverMediacion(i);
    } else {
      moverLateral(i); // Movimiento lateral por defecto
    }
  }
}
void moverMediacion(int i) {
  boolean estaEnPelea = false;
  for (int j = i + 1; j < cantidadCirculos; j++) {
    if (distanciaEntreRojos(i, j) < 80) {
      pelear(i, j); // Activar la función de pelea entre los círculos i y j
      estaEnPelea = true;
      peleando[i]=true;
    }
  }

  if (!estaEnPelea) {
    moverLateral(i); // Movimiento lateral por defecto si no están en pelea
    peleando[i]=false;
  }
}
void moverAcoso(int i) {
  float dx = mouseX - circulos[i].x;
  float dy = mouseY - circulos[i].y;
  float dist = sqrt(dx * dx + dy * dy);
  if (dist < 80) {
    circulos[i].x += dx * 0.05; // Ajusta la velocidad de acercamiento
    circulos[i].y += dy * 0.05;
    atacando[i] = true;
  } else {
    moverLateral(i);
    atacando[i] = false;
  }
}

void moverDiscriminacion(int i) {
  float dx = mouseX - circulos[i].x;
  float dy = mouseY - circulos[i].y;
  float dist = sqrt(dx * dx + dy * dy);
  if (dist < 80) {
    circulos[i].x -= dx * 0.05; // Alejarse del círculo verde
    circulos[i].y -= dy * 0.05;
    discriminando[i]=true;
  } else {
    moverLateral(i);
    discriminando[i]=false;
  }
}

void moverProteccion(int i) {
  float dx = mouseX - circulos[i].x;
  float dy = mouseY - circulos[i].y;
  float dist = sqrt(dx * dx + dy * dy);
  if (estado == "Proteccion") {
    circulos[atacado].x=width/2;
    circulos[atacado].y=height/2;

    if (dist < 80 && i != atacado) {
      circulos[i].x -= dx * 0.05; // Alejarse del círculo verde
      circulos[i].y -= dy * 0.05;
    } else if (i != atacado) {
      // Los círculos atacan al círculo "atacado"
      dx = circulos[atacado].x - circulos[i].x;
      dy = circulos[atacado].y - circulos[i].y;
      circulos[i].x += dx * 0.02;
      circulos[i].y += dy * 0.02;
      atacando[i] = true;
    }
  } else if (estado == "Desamparo") {
    // Alejar los círculos rojos del círculo verde
    float dxCircVerde = mouseX - circulos[i].x;
    float dyCircVerde = mouseY - circulos[i].y;
    float distCircVerde = sqrt(dxCircVerde * dxCircVerde + dyCircVerde * dyCircVerde);
    if (distCircVerde < 150 && i != 0) { // Si el círculo rojo está cerca del círculo verde
      circulos[i].x -= dxCircVerde * 0.03; // Alejarse del círculo verde
      circulos[i].y -= dyCircVerde * 0.03;
      // Reducir el tamaño del círculo rojo gradualmente
      tamCirculoRojo -= 0.5;
      if (tamCirculoRojo < 0) {
        tamCirculoRojo = 0; // Evitar valores negativos
      }
    } else {
      moverLateral(i); // Movimiento lateral por defecto
    }
  } else {
    moverLateral(i); // Movimiento lateral por defecto
  }
}
void moverLateral(int i) {
  // Movimiento lateral con rebote en los límites de la pantalla
  if (!circulos[i].detener) {
    if (circulos[i].x > width - tam / 2 || circulos[i].x < tam / 2) {
      aceleracion[i] *= -1; // Invertir dirección en el eje x
    }
    circulos[i].x += aceleracion[i];

    if (circulos[i].y > height - tam / 2 || circulos[i].y < tam / 2) {
      aceleracion[i] *= -1; // Invertir dirección en el eje y
    }
    circulos[i].y += aceleracion[i];
  } else {
    // Verificar si el círculo verde pasa cerca para reactivar el movimiento
    float dx = circulos[i].x - mouseX;
    float dy = circulos[i].y - mouseY;
    float dist = sqrt(dx * dx + dy * dy);
    if (dist < 70) {
      circulos[i].detener = false; // Reactivar el movimiento
    }
  }
}


void manejarColisiones() {
  if (estado.equals("Desinteres")) {
    return; // No manejar colisiones si el estado es Desinteres
  }
  for (int i = 0; i < cantidadCirculos; i++) {
    for (int j = i + 1; j < cantidadCirculos; j++) {
      float dx = circulos[j].x - circulos[i].x;
      float dy = circulos[j].y - circulos[i].y;
      float dist = sqrt(dx * dx + dy * dy);
      float minDist = tam; // La distancia mínima para que ocurra una colisión
      if (i == 0) minDist = tamVerde; // Si es el círculo verde, usa su tamaño
      if (dist < minDist) { // Calcula la respuesta de colisión
        float angle = atan2(dy, dx);
        float targetX = circulos[i].x + cos(angle) * minDist;
        float targetY = circulos[i].y + sin(angle) * minDist;
        float ax = (targetX - circulos[j].x) * 0.05;
        float ay = (targetY - circulos[j].y) * 0.05;
        circulos[i].x -= ax;
        circulos[i].y -= ay;
        circulos[j].x += ax;
        circulos[j].y += ay;
      }
    }
  }
}

void manejarColisionesCirculoVerde(int i) {
  if (estado.equals("Desinteres")) {
    return; // No manejar colisiones si el estado es Desinteres
  }
  for (int j = 1; j < cantidadCirculos; j++) {
    float dx = mouseX - circulos[j].x;
    float dy = mouseY - circulos[j].y;
    float dist = sqrt(dx * dx + dy * dy);
    float minDist = tamVerde; // El tamaño del círculo verde
    if (dist < minDist) { // Calcula la respuesta de colisión
      float angle = atan2(dy, dx);
      float targetX = mouseX + cos(angle) * minDist;
      float targetY = mouseY + sin(angle) * minDist;
      float ax = (targetX - circulos[j].x) * 0.05;
      float ay = (targetY - circulos[j].y) * 0.05;
      circulos[j].x -= ax;
      circulos[j].y -= ay;
    }
  }
  if (estado.equals("Empatia")) {
    for (int j = 1; j < cantidadCirculos; j++) {
      float dx = mouseX - circulos[j].x;
      float dy = mouseY - circulos[j].y;
      float dist = sqrt(dx * dx + dy * dy);
      float minDist = tamVerde; // El tamaño del círculo verde
      if (dist < 45) { // Calcula la respuesta de colisión
        float angle = atan2(dy, dx);
        float targetX = mouseX + cos(angle) + 15;
        float targetY = mouseY + sin(angle) + 15;
        circulos[j].x = targetX; // Pegar el círculo rojo al verde
        circulos[j].y = targetY;
        tiempoPegado = millis() / 1000; // Establecer el tiempo de pegado
      }
    }
  }
}

void manejarColisionesCirculosRojos(int i, int j) {
  float dx = circulos[j].x - circulos[i].x;
  float dy = circulos[j].y - circulos[i].y;
  float dist = sqrt(dx * dx + dy * dy);
  float minDist = tam; // La distancia mínima para que ocurra una colisión
  if (dist < minDist) { // Calcula la respuesta de colisión
    float angle = atan2(dy, dx);
    float targetX = circulos[i].x + cos(angle) * minDist;
    float targetY = circulos[i].y + sin(angle) * minDist;
    float ax = (targetX - circulos[j].x) * 0.05;
    float ay = (targetY - circulos[j].y) * 0.05;
    circulos[i].x -= ax;
    circulos[i].y -= ay;
    circulos[j].x += ax;
    circulos[j].y += ay;
  }
}

void resetCircles() {
  for (int i = 0; i < cantidadCirculos; i++) {
    circulos[i].x = random(width);
    circulos[i].y = random(height);
    aceleracion[i] = 2;
    tamCirculoRojo = 40; // Restablecer el tamaño del círculo rojo
  }
}

// Función para verificar la distancia entre dos círculos rojos
float distanciaEntreRojos(int i, int j) {
  float dx = circulos[j].x - circulos[i].x;
  float dy = circulos[j].y - circulos[i].y;
  return sqrt(dx * dx + dy * dy);
}

// Función para simular la pelea entre dos círculos rojos
void pelear(int i, int j) {
  float dx = circulos[j].x - circulos[i].x;
  float dy = circulos[j].y - circulos[i].y;
  float dist = sqrt(dx * dx + dy * dy);
  if (dist < 60) {
    circulos[i].x -= dx * 0.01; // Mover hacia atrás
    circulos[j].x += dx * 0.01; // Mover hacia adelante
    enPelea[i] = true;
    enPelea[j] = true;
  } else {
    enPelea[i] = false;
    enPelea[j] = false;
  }
  circulos[i].detener = true;
  circulos[j].detener = true;
}

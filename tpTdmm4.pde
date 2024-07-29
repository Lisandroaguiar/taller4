import processing.sound.*;
SoundFile sonidos[];
//SONIDOS
//0-base
//1-acoso
//2-discriminacion
//3-proteccion
//4-soberbia
//5-desamparo
//6-desinteres
//7-timidez
//8-empatia
//9-mediacion
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
PImage circuloVerde, circuloRojo, circuloRojoPinchudo, circuloRojoSemiPinchudo, fondo;
boolean[] enPelea = new boolean[cantidadCirculos];
boolean[] peleando = new boolean[cantidadCirculos];

boolean[] atacando = new boolean[cantidadCirculos];
boolean[] discriminando = new boolean[cantidadCirculos];
boolean mouseAlMedio;

void setup() {
  size(900, 500);
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
  fondo=loadImage("Fondo 1.png");
  noCursor();
  sonidos=new SoundFile[10];

  for (int i=0; i<sonidos.length; i++) {
    sonidos[i]= new SoundFile(this, "/sonidos/sonido"+i+".wav");
    sonidos[i].amp(0.4);
  }

  // Reproducir sonido de fondo
  sonidos[0].loop();
}

void draw() {
  if (estado == "menu") {
    background(255);
    menu.mostrarMenu();
    println(menu.queEstado(), estado);
    push();
    cursor();
    pop();
    resetCircles();
  } else {
    background(fondo);
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
  reproducirSonidoEstado();
  if (estado.equals("Proteccion")) {
    atacando[atacado] = false; // Asegura que el círculo atacado no esté marcado como atacando
  }
}

void keyPressed() {
  estado = "menu";
  tamVerde = 40; // Reiniciar tamaño del círculo verde al volver al menú
  reproducirSonidoEstado();
}

void reproducirSonidoEstado() {
  // Detener todos los sonidos primero
  for (int i = 1; i < sonidos.length; i++) {
    sonidos[i].stop();
  }

  // Reproducir el sonido correspondiente al estado actual
  if (estado.equals("Acoso")) {
    sonidos[1].loop();
  } else if (estado.equals("Discriminacion")) {
    sonidos[2].loop();
  } else if (estado.equals("Proteccion")) {
    sonidos[3].loop();
  } else if (estado.equals("Soberbia")) {
    sonidos[4].loop();
  } else if (estado.equals("Desamparo")) {
    sonidos[5].loop();
  } else if (estado.equals("Desinteres")) {
    sonidos[6].loop();
  } else if (estado.equals("Timidez")) {
    sonidos[7].loop();
  } else if (estado.equals("Empatia")) {
    sonidos[8].loop();
  } else if (estado.equals("Mediacion")) {
    sonidos[9].loop();
  }
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
  float dx = mouseX - circulos[i].x;
  float dy = mouseY - circulos[i].y;
  float dist = sqrt(dx * dx + dy * dy);

  // Verificar si el círculo verde está entre los dos bandos
  boolean circuloVerdeEntreBandos = mouseY > height / 2 - 100 && mouseY < height / 2 + 100 && mouseX<width/2  && mouseX>200;

  if (estado.equals("Mediacion")) {
    if (circuloVerdeEntreBandos && circulos[i].detener) {
      return circuloRojo;
    } else if (peleando[i]) {
      return circuloRojoPinchudo;
    }
  } else if (atacando[i] && (estado.equals("Proteccion") || estado.equals("Acoso")) && dist < 120) {
    return circuloRojoPinchudo;
  } else if (discriminando[i] && estado.equals("Discriminacion")) {
    return circuloRojoSemiPinchudo;
  }
  
  return circuloRojo;
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
      moverSoberbia(i); // Nueva función para soberbia
    } else if (estado == "Timidez") {
      moverTimidez(i); // Nueva función para timidez
    } else if (estado == "Desamparo") {
      moverProteccion(i);
    } else if (estado == "Empatia") {
      moverLateral(i);

      if (tiempoPegado > 0) {
        if (tiempoPegado <= 0) {
          tiempoPegado -= (millis() / 1000) - tiempoPegado;
        }
      }
    } else if (estado == "Mediacion") {
      moverMediacion(i);
    } else {
      moverLateral(i);
    }
  }
}

void moverTimidez(int i) {
  float dx = mouseX - circulos[i].x;
  float dy = mouseY - circulos[i].y;
  float dist = sqrt(dx * dx + dy * dy);
  if (dist < 80) {
    tamVerde = lerp(tamVerde, 20, 0.5); // Reducir tamaño gradualmente
  } else {
    tamVerde = lerp(tamVerde, 40, 0.05); // Volver al tamaño normal gradualmente
    moverLateral(i);
  }
}

void moverSoberbia(int i) {
  float dx = mouseX - circulos[i].x;
  float dy = mouseY - circulos[i].y;
  float dist = sqrt(dx * dx + dy * dy);
  if (dist < 80) {
    tamVerde = lerp(tamVerde, 80, 0.5); // Aumentar tamaño gradualmente
  } else {
    tamVerde = lerp(tamVerde, 40, 0.05); // Volver al tamaño normal gradualmente
    moverLateral(i);
  }
}

void moverMediacion(int i) {
  // Verificar si el círculo verde está entre los dos bandos
  boolean circuloVerdeEntreBandos = mouseY > height / 2 - 100 && mouseY < height / 2 + 100 && mouseX<width/2 && mouseX>200;

  if (circuloVerdeEntreBandos) {
    // Si el círculo verde está entre los dos bandos, los círculos no deberían moverse
    circulos[i].detener = true;
  } else {
    circulos[i].detener = false;
    if (i < cantidadCirculos / 2) {
      // Círculos del bando superior
      moverBandoSuperior(i);
    } else {
      // Círculos del bando inferior
      moverBandoInferior(i);
    }
  }
}


void moverBandoSuperior(int i) {
  if (!enPelea[i]) {
    circulos[i].x = 200+10*i;
    circulos[i].y = height/2-100; // Mantener en la parte superior
    enPelea[i] = true;
  }

  // Movimiento agresivo hacia abajo
  circulos[i].y += aceleracion[i];
  if (circulos[i].y > height / 2 ) {
    circulos[i].y = height / 2; // Limitar al medio de la pantalla
    aceleracion[i] *= -1; // Invertir dirección
  }

  if (circulos[i].y<100) {
    aceleracion[i] *= -1; // Invertir dirección
  }
}

void moverBandoInferior(int i) {
  if (!enPelea[i]) {
    circulos[i].x = 200+10*i;
    circulos[i].y = height/2+100; // Mantener en la parte inferior
    enPelea[i] = true;
  }

  // Movimiento agresivo hacia arriba
  circulos[i].y -= aceleracion[i];
  if (circulos[i].y < height / 2 ) {
    circulos[i].y = height / 2; // Limitar al medio de la pantalla
    aceleracion[i] *= -1; // Invertir dirección
  }
  if (circulos[i].y>height-100) {
    aceleracion[i] *= -1; // Invertir dirección
  }
}
void moverAcoso(int i) {
  float dx = mouseX - circulos[i].x;
  float dy = mouseY - circulos[i].y;
  float dist = sqrt(dx * dx + dy * dy);
  if (dist < 700 || !moverse) { // Seguir aunque el usuario no se mueva
    circulos[i].x += dx * 0.02;
    circulos[i].y += dy * 0.02;
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
  if (dist < 180) { // Aumentar distancia de alejamiento
    circulos[i].x -= dx * 0.02;
    circulos[i].y -= dy * 0.02;
    discriminando[i] = true;
  } else {
    moverLateral(i);
    discriminando[i] = false;
  }
}


void moverProteccion(int i) {
  float dx = mouseX - circulos[i].x;
  float dy = mouseY - circulos[i].y;
  float dist = sqrt(dx * dx + dy * dy);

  if (estado == "Proteccion") {
    circulos[atacado].x = width / 2;
    circulos[atacado].y = height / 2;
    if (dist < 80 && i != atacado) {
      circulos[i].x -= dx * 0.2;
      circulos[i].y -= dy * 0.2;
    } else if (i != atacado) {
      dx = circulos[atacado].x - circulos[i].x;
      dy = circulos[atacado].y - circulos[i].y;
      circulos[i].x += dx * 0.01;
      circulos[i].y += dy * 0.01;
      atacando[i] = true;
    }
  } else if (estado == "Desamparo") {
    // Alejar los círculos rojos del círculo verde
    float dxCircVerde = mouseX - circulos[i].x;
    float dyCircVerde = mouseY - circulos[i].y;
    float distCircVerde = sqrt(dxCircVerde * dxCircVerde + dyCircVerde * dyCircVerde);
    if (distCircVerde < 150 && i != 0) { // Si el círculo rojo está cerca del círculo verde
      circulos[i].x -= dxCircVerde * 0.02; // Ralentizar la velocidad de alejamiento
      circulos[i].y -= dyCircVerde * 0.02;
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
    // Movimiento en el eje x con rebote
    if (circulos[i].x > width - tamCirculoRojo / 2) {
      circulos[i].x = width - tamCirculoRojo / 2; // Ajusta para mantener el círculo dentro de la pantalla
      aceleracion[i] *= -1; // Invertir dirección en el eje x
    } else if (circulos[i].x < tamCirculoRojo / 2) {
      circulos[i].x = tamCirculoRojo / 2; // Ajusta para mantener el círculo dentro de la pantalla
      aceleracion[i] *= -1; // Invertir dirección en el eje x
    }
    circulos[i].x += aceleracion[i] * 0.5; // Ralentizar el movimiento lateral

    // Movimiento en el eje y con rebote
    if (circulos[i].y > height - tamCirculoRojo / 2) {
      circulos[i].y = height - tamCirculoRojo / 2; // Ajusta para mantener el círculo dentro de la pantalla
      aceleracion[i] *= -1; // Invertir dirección en el eje y
    } else if (circulos[i].y < tamCirculoRojo / 2) {
      circulos[i].y = tamCirculoRojo / 2; // Ajusta para mantener el círculo dentro de la pantalla
      aceleracion[i] *= -1; // Invertir dirección en el eje y
    }
    circulos[i].y += aceleracion[i] * 0.5; // Ralentizar el movimiento lateral
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
  for (int i = 1; i < cantidadCirculos; i++) {
    for (int j = i + 1; j < cantidadCirculos; j++) {
      float dx = circulos[j].x - circulos[i].x;
      float dy = circulos[j].y - circulos[i].y;
      float dist = sqrt(dx * dx + dy * dy);
      float minDist = (tamCirculoRojo + tamCirculoRojo) / 2;

      if (dist < minDist) {
        float angle = atan2(dy, dx);
        float targetX = circulos[i].x + cos(angle) * minDist;
        float targetY = circulos[i].y + sin(angle) * minDist;
        float ax = (targetX - circulos[j].x) * 0.05;
        float ay = (targetY - circulos[j].y) * 0.05;
        circulos[i].x -= ax;
        circulos[i].y -= ay;
        circulos[j].x += ax;
        circulos[j].y += ay;
        peleando[i] = true; // Indicar que los círculos están peleando
        peleando[j] = true;
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
  float minDist = tam;
  if (dist < minDist) {
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
    circulos[i] = new Circulos();
    aceleracion[i] = 2;
    enPelea[i] = false;
    peleando[i] = false;
    atacando[i] = false;
    discriminando[i] = false;
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

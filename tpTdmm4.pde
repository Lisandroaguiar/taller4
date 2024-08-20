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
//10-acoso efecto
//11-discriminacion efecto
//12-proteccion efecto
//13-soberbia efecto
//14-desamparo efecto
//15-desinteres efecto
//16-timidez efecto
//17-empatia efecto
//18-mediacion efecto
Menu menu;
Boton boton;
int cantidadCirculos = 5;
int contadorSonar=0;
int queVerde=1;
boolean mover=false;
boolean moverNaranja=false;

boolean estaPegadoVerde=false;
float[] velocidadLateral = new float[cantidadCirculos]; // Array para la velocidad lateral
float[] desplazamientoLateral = new float[cantidadCirculos]; // Array para el desplazamiento lateral
float[] noiseOffsetX;
float[] noiseOffsetY;
PImage menuBoton, menuR, menuV, menuN;
String estado;
Circulos circulos[];
Circulos circulosNaranjas[];

color colorCirculo;
float tam = 40;
float tamVerde = 180; // Tamaño del círculo verde
float tamCirculoRojo = 200; // Tamaño inicial del círculo rojo
float tamCirculoNaranja=140;
boolean moverse = false;
float aceleracion[];
int atacado = 1; // Índice del círculo rojo que será atacado
float tiempoPegado = 0; // Tiempo en segundos que los círculos rojos estarán pegados al verde
PImage circuloRojo, circuloRojoPinchudo, circuloRojoSemiPinchudo, fondo, circuloNaranja, circuloNaranjaPinchudo, circuloNaranjaSemiPinchudo, circuloCombinado, invisible;
PImage []circuloVerde;
boolean[] enPelea = new boolean[cantidadCirculos];
boolean[] peleando = new boolean[cantidadCirculos];
boolean[] estaPegado= new boolean[cantidadCirculos];
boolean[] atacando = new boolean[cantidadCirculos];
boolean[] discriminando = new boolean[cantidadCirculos];
boolean[] discriminandoNaranjas = new boolean[cantidadCirculos];

boolean mouseAlMedio;
int contadorSonarTimidez=0;
int contadorSonarMediacion=0;

void setup() {
  //size(900, 500);

  fullScreen();
  orientation(LANDSCAPE);
  menu = new Menu();
  boton= new Boton(width-150, 150, 100, "menu", 4);
  boton= new Boton(width-200, 50, 150, "", 4);
  menuBoton=loadImage("Ameba_Menu.png");
  menuR=loadImage("Ameba_Rojo.png");
  menuV=loadImage("Ameba_Verde.png");
  menuN=loadImage("Ameba_Naranja.png");

  aceleracion = new float[cantidadCirculos];
  menu.setupMenu();
  estado = "menu";
  colorCirculo = color(255, 0, 0);
  circulos = new Circulos[cantidadCirculos];
  circulosNaranjas = new Circulos[cantidadCirculos];

  for (int i = 0; i < cantidadCirculos; i++) {
    circulos[i] = new Circulos();
    circulosNaranjas[i] = new Circulos();

    aceleracion[i] = .5;
    enPelea[i] = false;
    peleando[i] = false;
    atacando[i] = false;
    discriminando[i]=false;
    discriminandoNaranjas[i]=false;
  }
  circuloVerde = new PImage[2];
  circuloVerde[0]= loadImage("invisible.png");
  circuloVerde[1]= loadImage("AmebaVerde_1.png");
  circuloRojo= loadImage("AmebaRoja_1.png");
  circuloRojoSemiPinchudo= loadImage("AmebaRoja_2.png");
  circuloRojoPinchudo= loadImage("AmebaRoja_3.png");
  circuloNaranja= loadImage("AmebaNaranja_1.png");
  circuloNaranjaSemiPinchudo= loadImage("AmebaNaranja_2.png");
  circuloNaranjaPinchudo= loadImage("AmebaNaranja_3.png");
  circuloCombinado=loadImage("AmebaConjunto_1.png");
  invisible=loadImage("invisible.png");
  fondo=loadImage("Fondo 1.png");
  //no//cursor();
  sonidos=new SoundFile[19];

  for (int i=0; i<sonidos.length; i++) {

    if (i<=9) {
      sonidos[i]= new SoundFile(this, "sonido"+i+".wav");
      sonidos[i].amp(0.3);
    } else {
      sonidos[i]= new SoundFile(this, "sonido"+i+".wav");
      sonidos[i].amp(0.7);
    }
  }

  // Reproducir sonido de fondo
  sonidos[0].amp(0.1);
  sonidos[0].loop();

  for (int i = 0; i < cantidadCirculos; i++) {
    velocidadLateral[i] = random(.4); // Velocidad lateral aleatoria
    desplazamientoLateral[i] = 0; // Inicialmente sin desplazamiento
  }

  // Suponiendo que tienes un número fijo de círculos
  noiseOffsetX = new float[cantidadCirculos];
  noiseOffsetY = new float[cantidadCirculos];

  // Inicializar offsets
  for (int i = 0; i < cantidadCirculos; i++) {
    noiseOffsetX[i] = random(0, 1000);
    noiseOffsetY[i] = random(0, 1000);
  }
}

void draw() {
  reproducirSonidoEstado();


  if (!estado.equals("Empatia")) {
    queVerde=1;
  }

  if (estado == "menu") {
    image(fondo, 0, 0, width, height);
    menu.mostrarMenu();
    println(menu.queEstado(), estado);
    push();
    //cursor();
    pop();
    resetCircles();
  } else {
    //background(fondo);
    image(fondo, 0, 0, width, height);
    //no//cursor();
    dibujarEnemigos();
    if (moverse) {
      moverCirculos();
      manejarColisiones();

      // Verificar si los círculos rojos deben pelear
    }
  }
  if (!estado.equals("menu")) {
    boton.dibujar();
  }
}
void touchEnded() {

  estado = menu.queEstado();
  moverse = true; // Comienza a moverse según el estado
  if (estado.equals("Proteccion")) {
    atacando[atacado] = false; // Asegura que el círculo atacado no esté marcado como atacando
  }

  if (boton.isMouseOver()) {
    estado="menu";
    println("toco");
    tamVerde = 180; // Reiniciar tamaño del círculo verde al volver al menú
  }
}



void reproducirSonidoEstado() {

  // Detener todos los sonidos primero
  if (estado.equals("menu")) {
    for (int i = 1; i < sonidos.length; i++) {
      if (i<=9) {
        sonidos[i].stop();
      }
    }
  }

  // Reproducir el sonido correspondiente al estado actual
  if (estado.equals("Acoso") && !sonidos[1].isPlaying()) {
    sonidos[1].amp(0.4);

    sonidos[1].loop();
  } else if (estado.equals("Discriminacion")&& !sonidos[2].isPlaying()) {
    sonidos[2].amp(0.4);

    sonidos[2].loop();
  } else if (estado.equals("Proteccion") && !sonidos[3].isPlaying()) {
    sonidos[3].amp(0.4);

    sonidos[3].loop();
  } else if (estado.equals("Soberbia") && !sonidos[4].isPlaying()) {
    sonidos[4].amp(0.4);

    //sonidos[4].loop();
  } else if (estado.equals("Desamparo") && !sonidos[5].isPlaying()) {
    sonidos[5].amp(0.4);

    sonidos[5].loop();
  } else if (estado.equals("Desinteres") && !sonidos[6].isPlaying()) {
    sonidos[6].amp(0.4);

    sonidos[6].loop();
  } else if (estado.equals("Timidez") && !sonidos[7].isPlaying()) {
    sonidos[7].amp(0.4);

    sonidos[7].loop();
  } else if (estado.equals("Empatia") && !sonidos[8].isPlaying()) {
    sonidos[8].amp(0.4);

    sonidos[8].loop();
  } else if (estado.equals("Mediacion") && !sonidos[9].isPlaying()) {
    sonidos[9].amp(0.4);

    sonidos[9].loop();
  }
}

void dibujarEnemigos() {
  for (int i = 0; i < cantidadCirculos; i++) {
    if (i == 0) {
      manejarColisionesCirculoVerde(i); // Manejar colisiones con el círculo verde

      image(circuloVerde[queVerde], mouseX, mouseY, tamVerde, tamVerde); // Círculo verde
    } else {
      float tamActual = (estado.equals("Desamparo") && i != 0) ? tamCirculoRojo : tam;
      PImage img = obtenerImagenRojo(i); // Obtener la imagen correcta para el círculo rojo
      PImage imgNaranja = obtenerImagenNaranja(i); // Obtener la imagen correcta para el círculo rojo

      image(img, circulos[i].x, circulos[i].y, tamCirculoRojo, tamCirculoRojo);
      image(imgNaranja, circulosNaranjas[i].x, circulosNaranjas[i].y, tamCirculoNaranja, tamCirculoNaranja);

      manejarColisionesCirculosRojos(0, i); // Manejar colisiones entre el círculo verde y los rojos
      manejarColisionesEntreRojosYNaranjas(i);
    }
  }
}

PImage obtenerImagenRojo(int i) {
  float dx = mouseX - circulos[i].x;
  float dy = mouseY - circulos[i].y;
  float dist = sqrt(dx * dx + dy * dy);

  // Verificar si el círculo verde está entre los dos bandos
  boolean circuloVerdeEntreBandos = mouseY > height / 2 - 100 && mouseY < height / 2 + 100 && mouseX>400  ;

  if (estado.equals("Mediacion")) {
    if (circuloVerdeEntreBandos && circulos[i].detener ) {

      return circuloRojo;
    } else if (peleando[i]) {

      return circuloRojoPinchudo;
    }
  } else if (estado.equals("Proteccion")) {
    return circuloRojoPinchudo;
  } else if (discriminando[i] && estado.equals("Discriminacion")||discriminandoNaranjas[i] && estado.equals("Discriminacion")) {

    return circuloRojoSemiPinchudo;
  } else if (peleando[i] && !estado.equals("Discriminacion") && !estado.equals("Desamparo") && !estado.equals("Desinteres") && !estado.equals("Empatia") && !estado.equals("Soberbia") && !estado.equals("Timidez")) {

    return circuloRojoPinchudo;
  } else if (estado.equals("Acoso") && dist<230) {

    return circuloRojoPinchudo;
  }



  return circuloRojo;
}


PImage obtenerImagenNaranja(int i) {
  float dx = mouseX - circulosNaranjas[i].x;
  float dy = mouseY - circulosNaranjas[i].y;
  float dist = sqrt(dx * dx + dy * dy);

  // Verificar si el círculo verde está entre los dos bandos
  boolean circuloVerdeEntreBandos = mouseY > height / 2 - 100 && mouseY < height / 2 + 100 && mouseX>400;

  if (estado.equals("Mediacion")) {
    if (circuloVerdeEntreBandos && circulosNaranjas[i].detener ) {

      return circuloNaranja;
    } else if (peleando[i] &&  !estado.equals("Acoso")) {
      return circuloNaranjaPinchudo;
    }
  } else if (estado.equals("Proteccion")) {
    if (i==atacado) {
      return circuloNaranja;
    }
  } else if (peleando[i] && !estado.equals("Acoso") && !estado.equals("Discriminacion") && !estado.equals("Desamparo") && !estado.equals("Desinteres") && !estado.equals("Empatia") && !estado.equals("Soberbia") && !estado.equals("Timidez")) {
    return circuloNaranjaPinchudo;
  } else if (estado.equals("Empatia")&& estaPegado[i]) {
    return invisible;
  }
  return circuloNaranja;
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
    } else if (estado == "Desinteres") {
      moverProteccion(i);
    } else if (estado == "Empatia") {
      moverLateral(i);
      manejarColisionesCirculoVerde(i);
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

  float dxNaranja = mouseX - circulosNaranjas[i].x;
  float dyNaranja = mouseY - circulosNaranjas[i].y;
  float distNaranjas = sqrt(dx * dx + dy * dy);

  if (dist < 220) {
    tamVerde = lerp(tamVerde, 60, 0.5); // Reducir tamaño gradualmente
    if (!sonidos[16].isPlaying() && contadorSonarTimidez==0) {
      sonidos[16].amp(.7);
      sonidos[16].play();
      contadorSonarTimidez=1;
    }
  } else {
    tamVerde = lerp(tamVerde, 180, 0.05); // Volver al tamaño normal gradualmente
    moverLateral(i);
    contadorSonarTimidez=0;
  }
}

void moverSoberbia(int i) {
  float dx = mouseX - circulosNaranjas[i].x;
  float dy = mouseY - circulosNaranjas[i].y;
  float dist = sqrt(dx * dx + dy * dy);




  if (dist < 300) {
    tamVerde = lerp(tamVerde, 300, 0.5); // Aumentar tamaño gradualmente
    if (!sonidos[13].isPlaying() && contadorSonar==0) {
      contadorSonar=1;

      sonidos[13].play();
    }
  } else if (dist>300) {
    tamVerde = lerp(tamVerde, 180, 0.05); // Volver al tamaño normal gradualmente
    moverLateral(i);
    contadorSonar=0;
  }
}

void moverMediacion(int i) {
  boolean circuloVerdeEntreBandos = mouseY > height / 2 - 100 && mouseY < height / 2 + 100 && mouseX > 400;
  if (circuloVerdeEntreBandos) {
    circulos[i].detener = true;
    circulosNaranjas[i].detener = true;
    if (!sonidos[18].isPlaying()&&contadorSonarMediacion==0) {
      sonidos[18].play();
      contadorSonarMediacion=1;
    }
  } else {
    circulos[i].detener = false;
    circulosNaranjas[i].detener = false;
    contadorSonarMediacion=0;
    moverBandoSuperior(i);
    moverBandoInferior(i);
  }
}

void moverBandoSuperior(int i) {
  if (!enPelea[i]) {
    // Posicionar el círculo rojo al comienzo en la parte superior
    float offsetX = map(i, 0, cantidadCirculos - 1, width / 2 - 150, width / 2 + 150);
    circulos[i].x = offsetX;
    circulos[i].y = height / 2 - 50;
    enPelea[i] = true;
  }

  // Mover hacia el centro
  circulos[i].y += aceleracion[i];
  if (circulos[i].y >= height / 2 - 50) {
    circulos[i].y = height / 2 - 50;
  }

  // Movimiento lateral oscilante (si es necesario)
  desplazamientoLateral[i] += velocidadLateral[i];
  circulos[i].x += sin(desplazamientoLateral[i]) * 5;
}

void moverBandoInferior(int i) {
  if (!enPelea[i]) {
    // Posicionar el círculo naranja en la parte inferior
    circulosNaranjas[i].y = height / 2 + 50;
    enPelea[i] = true;
  }

  // Movimiento hacia el círculo rojo correspondiente
  circulosNaranjas[i].x += (circulos[i].x - circulosNaranjas[i].x) * 0.05; // Ajustar la velocidad según sea necesario

  // Mover hacia el centro en el eje Y
  circulosNaranjas[i].y -= aceleracion[i]*4;
  if (circulosNaranjas[i].y <= height / 2 + 50) {
    circulosNaranjas[i].y = height / 2 + 50;
  }

  // Movimiento lateral oscilante (si es necesario)
  desplazamientoLateral[i] += velocidadLateral[i];
  circulosNaranjas[i].x += sin(desplazamientoLateral[i]) * 5;
}


void moverAcoso(int i) {
  float dx = mouseX - circulos[i].x;
  float dy = mouseY - circulos[i].y;
  float dist = sqrt(dx * dx + dy * dy);

  float dxNaranja = mouseX - circulosNaranjas[i].x;
  float dyNaranja = mouseY - circulosNaranjas[i].y;
  float distNaranjas = sqrt(dx * dx + dy * dy);


  circulos[i].x += dx * 0.009;
  circulos[i].y += dy * 0.009;

  circulosNaranjas[i].x += dxNaranja * 0.009;
  circulosNaranjas[i].y += dyNaranja * 0.009;


  if (dist<240) {
    atacando[i] = true;

    if (!sonidos[10].isPlaying()) {
      sonidos[10].play();
    }
  }
  if (dist>340) {
    ajustarDistanciaEntreRojos();
  }
}


void moverDiscriminacion(int i) {
  float dx = mouseX - circulos[i].x;
  float dy = mouseY - circulos[i].y;
  float dist = sqrt(dx * dx + dy * dy);
  int contador=0;


  if (dist < 230) { // Aumentar distancia de alejamiento
    circulos[i].x -= dx * 0.02;
    circulos[i].y -= dy * 0.02;
    discriminando[i] = true;
    if (!sonidos[11].isPlaying() && contadorSonar==0) {
      sonidos[11].play();
      contadorSonar=1;
    }
  } else {
    moverLateral(i);
    discriminando[i] = false;
    contadorSonar=0;
  }

  for (int k=0; k<cantidadCirculos; k++) {
    float dxNaranja =circulos[i].x- circulosNaranjas[k].x ;
    float dyNaranja = circulos[i].y- circulosNaranjas[k].y ;
    float distNaranja = sqrt(dxNaranja * dxNaranja + dyNaranja * dyNaranja);
    float minDistNaranja = tamCirculoRojo; // El tamaño del círculo verde
    if (distNaranja < minDistNaranja+100) { // Calcula la respuesta de colisión
      discriminandoNaranjas[i] = true;
    }

    if (distNaranja < minDistNaranja) { // Calcula la respuesta de colisión
      discriminandoNaranjas[i] = true;

      circulos[i].x += dxNaranja * 0.02;
      circulos[i].y += dyNaranja * 0.02;
      circulosNaranjas[k].x -= dxNaranja * 0.2;
      circulosNaranjas[k].y -= dyNaranja * 0.2;

      circulos[i].y += dyNaranja * 0.02;
      if (!sonidos[11].isPlaying() && contadorSonar==0) {
        contadorSonar=1;
      }
    } else if (distNaranja>minDistNaranja+220) {
      discriminandoNaranjas[i] = false;
      contador=0;
    }
  }
}


void moverProteccion(int i) {
  float dx = mouseX - circulos[i].x;
  float dy = mouseY - circulos[i].y;
  float dist = sqrt(dx * dx + dy * dy);


  float dxNaranja = mouseX - circulosNaranjas[i].x;
  float dyNaranja = mouseY - circulosNaranjas[i].y;
  float distNaranjas = sqrt(dxNaranja * dxNaranja + dyNaranja * dyNaranja);
  if (estado == "Proteccion") {
    circulosNaranjas[atacado].x = width / 2;
    circulosNaranjas[atacado].y = height / 2;
    if (distNaranjas < 230 ) {

      circulosNaranjas[i].x -= dxNaranja * 0.2;
      circulosNaranjas[i].y -= dyNaranja * 0.2;
    }


    if (dist < 230 ) {
      circulos[i].x -= dx * 0.2;
      circulos[i].y -= dy * 0.2;

      if (!sonidos[12].isPlaying()) {
        sonidos[12].play();
      }
    } else {
      dx = circulosNaranjas[atacado].x - circulos[i].x;
      dy = circulosNaranjas[atacado].y - circulos[i].y;
      circulos[i].x += dx * 0.01;
      circulos[i].y += dy * 0.01;

      dxNaranja = circulosNaranjas[atacado].x - circulosNaranjas[i].x;
      dyNaranja = circulosNaranjas[atacado].y - circulosNaranjas[i].y;
      circulosNaranjas[i].x += dxNaranja * 0.01;
      circulosNaranjas[i].y += dyNaranja * 0.01;


      atacando[i] = true;
      contadorSonar=0;
    }
  } else if (estado == "Desamparo") {
    float dxD = mouseX - circulos[i].x;
    float dyD = mouseY - circulos[i].y;
    float distCircVerde = sqrt(dxD * dxD + dyD * dyD);

    float dxDNaranja = mouseX - circulosNaranjas[i].x;
    float dyDNaranja = mouseY - circulosNaranjas[i].y;
    float distCircVerdeNaranja = sqrt(dxDNaranja * dxDNaranja + dyDNaranja * dyDNaranja);


    if (distCircVerde<200) {
      mover=true;
      if (!sonidos[14].isPlaying()) {
        sonidos[14].play();
      }
    }

    if (distCircVerdeNaranja<200) {
      moverNaranja=true;
      if (!sonidos[14].isPlaying()) {
        sonidos[14].play();
      }
    }
    if (moverNaranja) {
      moverHaciaFueraDePantallaNaranja(i);
    }

    if (mover) {
      moverHaciaFueraDePantalla(i);
    }
  } else if (estado == "Desinteres") {
    float dxD = mouseX - circulos[i].x;
    float dyD = mouseY - circulos[i].y;
    float distCircVerde = sqrt(dxD * dxD + dyD * dyD);
    moverLateral(i); // Movimiento lateral por defecto

    if (distCircVerde<230) {
      if (!sonidos[15].isPlaying()) {
        sonidos[15].play();
      }
    }
  } else {
    moverLateral(i); // Movimiento lateral por defecto
  }
}

void moverLateral(int i) {
  // Usa Perlin noise para generar movimientos suaves
  float noiseValueX = noise(noiseOffsetX[i]);
  float noiseValueY = noise(noiseOffsetY[i]);

  // Mapear el valor de noise para generar un movimiento más amplio
  circulos[i].x += map(noiseValueX, 0, 1, -3, 3);
  circulos[i].y += map(noiseValueY, 0, 1, -3, 3);

  circulosNaranjas[i].x += map(noiseValueX, 0, 1, -3, 3);
  circulosNaranjas[i].y += map(noiseValueY, 0, 1, -3, 3);

  // Incrementa el offset para crear un movimiento continuo
  noiseOffsetX[i] += 0.01;  // Ajusta la velocidad del movimiento en X
  noiseOffsetY[i] += 0.01;  // Ajusta la velocidad del movimiento en Y

  // Comportamiento en los bordes
  if (circulos[i].x < 0 || circulos[i].x > width) noiseOffsetX[i] *= -1;
  if (circulos[i].y < 0 || circulos[i].y > height) noiseOffsetY[i] *= -1;

  if (circulosNaranjas[i].x < 0 || circulosNaranjas[i].x > width) noiseOffsetX[i] *= -1;
  if (circulosNaranjas[i].y < 0 || circulosNaranjas[i].y > height) noiseOffsetY[i] *= -1;
  // Mantenimiento de movimiento natural
  if (!circulos[i].detener) {
    // Restringe a los bordes pero permite rebote con curvatura
    if (circulos[i].x > width - tamCirculoRojo / 2) {
      circulos[i].x = width - tamCirculoRojo / 2;
      noiseOffsetX[i] += 0.5;  // Cambia la dirección en X
    } else if (circulos[i].x < tamCirculoRojo / 2) {
      circulos[i].x = tamCirculoRojo / 2;
      noiseOffsetX[i] += 0.5;  // Cambia la dirección en X
    }

    if (circulos[i].y > height - tamCirculoRojo / 2) {
      circulos[i].y = height - tamCirculoRojo / 2;
      noiseOffsetY[i] += 0.5;  // Cambia la dirección en Y
    } else if (circulos[i].y < tamCirculoRojo / 2) {
      circulos[i].y = tamCirculoRojo / 2;
      noiseOffsetY[i] += 0.5;  // Cambia la dirección en Y
    }
  }

  if (!circulosNaranjas[i].detener) {
    // Restringe a los bordes pero permite rebote con curvatura
    if (circulosNaranjas[i].x > width - tamCirculoNaranja / 2) {
      circulosNaranjas[i].x = width - tamCirculoNaranja / 2;
      noiseOffsetX[i] += 0.5;  // Cambia la dirección en X
    } else if (circulosNaranjas[i].x < tamCirculoNaranja / 2) {
      circulosNaranjas[i].x = tamCirculoNaranja / 2;
      noiseOffsetX[i] += 0.5;  // Cambia la dirección en X
    }

    if (circulosNaranjas[i].y > height - tamCirculoNaranja / 2) {
      circulosNaranjas[i].y = height - tamCirculoNaranja / 2;
      noiseOffsetY[i] += 0.5;  // Cambia la dirección en Y
    } else if (circulosNaranjas[i].y < tamCirculoNaranja / 2) {
      circulosNaranjas[i].y = tamCirculoNaranja / 2;
      noiseOffsetY[i] += 0.5;  // Cambia la dirección en Y
    }
  }
}



void moverHaciaFueraDePantalla(int i) {
  float dx = mouseX - circulos[i].x;
  float dy = mouseY - circulos[i].y;



  // Calcular la dirección en la que se moverá el círculo
  float angle = atan2(dy, dx);

  // Si el círculo está dentro de la pantalla, muévelo hacia afuera gradualmente
  if (circulos[i].x < 0 || circulos[i].x > width || circulos[i].y < 0 || circulos[i].y > height) {
    circulos[i].x -= cos(angle) * 4; // Mover hacia afuera
    circulos[i].y -= sin(angle) * 4;
  } else {
    // Mover lentamente hacia el borde de la pantalla
    circulos[i].x -= cos(angle) * 4;
    circulos[i].y -= sin(angle) * 4;
  }
}
void moverHaciaFueraDePantallaNaranja(int i) {


  float dxNaranja = mouseX - circulosNaranjas[i].x;
  float dyNaranja = mouseY - circulosNaranjas[i].y;


  // Calcular la dirección en la que se moverá el círculo
  float angleNaranja = atan2(dyNaranja, dxNaranja);


  if (circulosNaranjas[i].x < 0 || circulosNaranjas[i].x > width || circulosNaranjas[i].y < 0 || circulosNaranjas[i].y > height) {
    circulosNaranjas[i].x -= cos(angleNaranja)*2; // Mover hacia afuera
    circulosNaranjas[i].y -= sin(angleNaranja)*2;
  } else {
    // Mover lentamente hacia el borde de la pantalla
    circulosNaranjas[i].x -= cos(angleNaranja)*2;
    circulosNaranjas[i].y -= sin(angleNaranja)*2;
  }
}
void manejarColisiones() {
  for (int i = 1; i < cantidadCirculos; i++) {
    for (int j = i + 1; j < cantidadCirculos; j++) {
      if (estado != "Desamparo") {
        float dx = circulos[j].x - circulos[i].x;
        float dy = circulos[j].y - circulos[i].y;
        float dist = sqrt(dx * dx + dy * dy);
        float minDist = (tamCirculoRojo + tamCirculoRojo) / 2;

        float dxNaranja = circulosNaranjas[j].x - circulosNaranjas[i].x;
        float dyNaranja = circulosNaranjas[j].y - circulosNaranjas[i].y;
        float distNaranja = sqrt(dxNaranja * dxNaranja + dyNaranja * dyNaranja);
        float minDistNaranja = (tamCirculoNaranja + tamCirculoNaranja) / 2;



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

        if (distNaranja < minDistNaranja) {
          float angleNaranja = atan2(dyNaranja, dxNaranja);
          float targetXNaranja = circulosNaranjas[i].x + cos(angleNaranja) * minDistNaranja;
          float targetYNaranja = circulosNaranjas[i].y + sin(angleNaranja) * minDistNaranja;
          float axNaranja = (targetXNaranja - circulosNaranjas[j].x) * 0.05;
          float ayNaranja = (targetYNaranja - circulosNaranjas[j].y) * 0.05;
          circulosNaranjas[i].x -= axNaranja;
          circulosNaranjas[i].y -= ayNaranja;
          circulosNaranjas[j].x += axNaranja;
          circulosNaranjas[j].y += ayNaranja;
          peleando[i] = true; // Indicar que los círculos están peleando
          peleando[j] = true;
        }
      }
    }
  }
}
void manejarColisionesCirculoVerde(int i) {
  for (int j = 1; j < cantidadCirculos; j++) {
    float dx = mouseX - circulos[j].x;
    float dy = mouseY - circulos[j].y;
    float dist = sqrt(dx * dx + dy * dy);
    float minDist = tamVerde; // El tamaño del círculo verde

    float dxNaranja = mouseX - circulosNaranjas[j].x;
    float dyNaranja = mouseY - circulosNaranjas[j].y;
    float distNaranja = sqrt(dxNaranja * dxNaranja + dyNaranja * dyNaranja);

    if (dist < minDist) { // Calcula la respuesta de colisión
      float angle = atan2(dy, dx);
      float targetX = mouseX + cos(angle) * minDist;
      float targetY = mouseY + sin(angle) * minDist;
      float ax = (targetX - circulos[j].x) * 0.05;
      float ay = (targetY - circulos[j].y) * 0.05;
      circulos[j].x -= ax;
      circulos[j].y -= ay;
    }

    if (distNaranja < minDist) { // Calcula la respuesta de colisión
      float angleNaranja = atan2(dyNaranja, dxNaranja);
      float targetXNaranja = mouseX + cos(angleNaranja) * minDist;
      float targetYNaranja = mouseY + sin(angleNaranja) * minDist;
      float axNaranja = (targetXNaranja - circulosNaranjas[j].x) * 0.05;
      float ayNaranja = (targetYNaranja - circulosNaranjas[j].y) * 0.05;
      circulosNaranjas[j].x -= axNaranja;
      circulosNaranjas[j].y -= ayNaranja;
    }
  }
  if (estado.equals("Empatia")) {
    boolean algunaPegada = false; // Nueva variable para verificar si alguna está pegada

    for (int j = 1; j < cantidadCirculos; j++) {
      float dx = mouseX - circulosNaranjas[j].x;
      float dy = mouseY - circulosNaranjas[j].y;
      float dist = sqrt(dx * dx + dy * dy);
      float minDist = tamVerde; // El tamaño del círculo verde

      if (dist < minDist + 10 && !algunaPegada) { // Calcula la respuesta de colisión
        float angle = atan2(dy, dx);
        float targetX = mouseX + cos(angle) * 15; // Ajusta la distancia de pegado
        float targetY = mouseY + sin(angle) * 15;
        circulosNaranjas[j].x = targetX; // Pegar el círculo rojo al verde
        circulosNaranjas[j].y = targetY;
        tiempoPegado = millis() / 1000; // Establecer el tiempo de pegado
        estaPegado[j] = true;
        algunaPegada = true; // Al menos un círculo está pegado
      } else {
        estaPegado[j] = false;
      }

      if (estaPegado[j] ) {
        println(estaPegado[j]);
        image(circuloCombinado, mouseX, mouseY, tamVerde*1.5, tamVerde*1.5);
        // Círculo verde
        circulosNaranjas[j].x = mouseX;
        circulosNaranjas[j].y = mouseY;
      }
    }


    // Actualiza queVerde basado en cualquier pegado
    if (algunaPegada) {
      queVerde = 0;
      if (!sonidos[17].isPlaying() && contadorSonar==0) {
        sonidos[17].play();
        contadorSonar=1;
      }
    } else {
      queVerde = 1;
      contadorSonar=0;
    }
  }
}




void manejarColisionesCirculosRojos(int i, int j) {
  float dx = circulos[j].x - circulos[i].x;
  float dy = circulos[j].y - circulos[i].y;
  float dist = sqrt(dx * dx + dy * dy);
  float minDist = tamCirculoRojo;

  float dxNaranja = circulosNaranjas[j].x - circulosNaranjas[i].x;
  float dyNaranja = circulosNaranjas[j].y - circulosNaranjas[i].y;
  float distNaranja = sqrt(dxNaranja * dxNaranja + dyNaranja * dyNaranja);
  float minDistNaranja = tamCirculoNaranja;

  float dxNaranjaRojo = circulos[j].x - circulosNaranjas[i].x;
  float dyNaranjaRojo = circulos[j].y - circulosNaranjas[i].y;
  float distNaranjaRojo = sqrt(dxNaranjaRojo * dxNaranjaRojo + dyNaranjaRojo * dyNaranjaRojo);
  float minDistNaranjaRojo = tamCirculoNaranja;



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

  if (distanciaEntreRojos(i, j)<10) {
    circulos[i].x -= 10;
    circulos[i].y -= 10;
    circulos[j].x += 10;
    circulos[j].y += 10;
  }

  if (distNaranja < minDistNaranja) {
    float angle = atan2(dyNaranja, dxNaranja);
    float targetX = circulosNaranjas[i].x + cos(angle) * minDistNaranja;
    float targetY = circulosNaranjas[i].y + sin(angle) * minDistNaranja;
    float ax = (targetX - circulosNaranjas[j].x) * 0.05;
    float ay = (targetY - circulosNaranjas[j].y) * 0.05;
    circulosNaranjas[i].x -= ax;
    circulosNaranjas[i].y -= ay;
    circulosNaranjas[j].x += ax;
    circulosNaranjas[j].y += ay;
  }

  if (distanciaEntreNaranjas(i, j)<10) {
    circulosNaranjas[i].x -= 10;
    circulosNaranjas[i].y -= 10;
    circulosNaranjas[j].x += 10;
    circulosNaranjas[j].y += 10;
  }
}
void resetCircles() {
  for (int i = 0; i < cantidadCirculos; i++) {
    circulos[i] = new Circulos();
    circulosNaranjas[i] = new Circulos();

    aceleracion[i] = .5;
    enPelea[i] = false;
    peleando[i] = false;
    atacando[i] = false;
    discriminando[i] = false;
    discriminandoNaranjas[i] = false;

    tamCirculoRojo = 200; // Restablecer el tamaño del círculo rojo
    tamCirculoNaranja = 130; // Restablecer el tamaño del círculo rojo
  }
}
// Función para verificar la distancia entre dos círculos rojos
float distanciaEntreRojos(int i, int j) {
  float dx = circulos[j].x - circulos[i].x;
  float dy = circulos[j].y - circulos[i].y;
  return sqrt(dx * dx + dy * dy);
}
float distanciaEntreNaranjas(int i, int j) {
  float dx = circulosNaranjas[j].x - circulosNaranjas[i].x;
  float dy = circulosNaranjas[j].y - circulosNaranjas[i].y;
  return sqrt(dx * dx + dy * dy);
}


float distanciaEntreNaranjasYRojos(int i, int j) {
  float dx = circulos[j].x - circulosNaranjas[i].x;
  float dy = circulos[j].y - circulosNaranjas[i].y;
  return sqrt(dx * dx + dy * dy);
}


// Función para simular la pelea entre dos círculos rojos
void pelear(int i, int j) {


  float dx = circulos[j].x - circulosNaranjas[i].x;
  float dy = circulos[j].y - circulosNaranjas[i].y;
  float dist = sqrt(dx * dx + dy * dy);
  if (dist < 60) {
    circulos[i].x -= dx * 0.01; // Mover hacia atrás
    circulos[j].x += dx * 0.01; // Mover hacia adelante
    circulosNaranjas[i].x -= dx * 0.01; // Mover hacia atrás
    circulosNaranjas[j].x += dx * 0.01; // Mover hacia adelante
    enPelea[i] = true;
    enPelea[j] = true;
  } else {
    enPelea[i] = false;
    enPelea[j] = false;
  }
  circulos[i].detener = true;
  circulos[j].detener = true;
  circulosNaranjas[i].detener = true;
  circulosNaranjas[j].detener = true;
}
void ajustarDistanciaEntreRojos() {
  float distanciaMinima = tamCirculoRojo * 1.1; // Define la distancia mínima que deseas mantener entre los círculos rojos
  float distanciaMinimaNaranjas = tamCirculoNaranja * 1.1; // Define la distancia mínima que deseas mantener entre los círculos rojos

  for (int i = 1; i < cantidadCirculos; i++) {
    for (int j = i + 1; j < cantidadCirculos; j++) {
      if (i != j) {
        float dx = circulos[j].x - circulos[i].x;
        float dy = circulos[j].y - circulos[i].y;
        float dist = sqrt(dx * dx + dy * dy);

        float dxNaranja = circulosNaranjas[j].x - circulosNaranjas[i].x;
        float dyNaranja = circulosNaranjas[j].y - circulosNaranjas[i].y;
        float distNaranja = sqrt(dxNaranja * dxNaranja + dyNaranja * dyNaranja);



        if (dist < distanciaMinima) {
          float angle = atan2(dy, dx);
          float targetX = circulos[i].x + cos(angle) * distanciaMinima;
          float targetY = circulos[i].y + sin(angle) * distanciaMinima;

          // Ajusta las posiciones de los círculos para mantener la distancia mínima
          float ax = (targetX - circulos[j].x) * 0.5;
          float ay = (targetY - circulos[j].y) * 0.5;
          circulos[i].x -= ax;
          circulos[i].y -= ay;
          circulos[j].x += ax;
          circulos[j].y += ay;
        }

        if (distNaranja < distanciaMinimaNaranjas) {
          float angleNaranja = atan2(dyNaranja, dxNaranja);
          float targetXNaranja = circulosNaranjas[i].x + cos(angleNaranja) * distanciaMinimaNaranjas;
          float targetYNaranja = circulosNaranjas[i].y + sin(angleNaranja) * distanciaMinimaNaranjas;

          // Ajusta las posiciones de los círculos para mantener la distancia mínima
          float axNaranja = (targetXNaranja - circulosNaranjas[j].x) * 0.5;
          float ayNaranja = (targetYNaranja - circulosNaranjas[j].y) * 0.5;
          circulosNaranjas[i].x -= axNaranja;
          circulosNaranjas[i].y -= ayNaranja;
          circulosNaranjas[j].x += axNaranja;
          circulosNaranjas[j].y += ayNaranja;
        }
      }
    }
  }
}
void manejarColisionesEntreRojosYNaranjas(int i) {

  for (int j = 1; j < cantidadCirculos; j++) {
    for (int k=0; k<cantidadCirculos; k++) {
      float dx =circulos[j].x- circulosNaranjas[k].x ;
      float dy = circulos[j].y- circulosNaranjas[k].y ;
      float dist = sqrt(dx * dx + dy * dy);
      float minDist = tamCirculoRojo; // El tamaño del círculo verde


      if (dist < minDist) { // Calcula la respuesta de colisión
        float angle = atan2(dy, dx);
        float targetX = circulos[j].x + cos(angle) * minDist;
        float targetY = circulos[j].y + sin(angle) * minDist;
        float ax = (targetX - circulosNaranjas[k].x) * 0.05;
        float ay = (targetY - circulosNaranjas[k].y) * 0.05;
        circulosNaranjas[k].x -= ax;
        circulosNaranjas[k].y -= ay;
        if (estado.equals("Acoso")) {

          circulosNaranjas[k].x -= ax*4;
          circulosNaranjas[k].y -= ay*4;
        }
        if (estado.equals("Mediacion")) {

          circulosNaranjas[k].x -= ax*4;
          circulosNaranjas[k].y -= ay*4;
          circulos[j].x -= ax*4;
          circulos[j].y -= ay*4;
        }
      }
    }
  }
}

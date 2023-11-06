//Pantalla, musica y todo eso
import ddf.minim.*; //Librería de musica
PFont font; //Fuente(s de Ortiz)
int buttonWidth = 200;
int buttonHeight = 50;
int spacing = 20;
color[] buttonColors = new color[4];
String[] buttonText = {"Jugar", "Tutorial", "Créditos", "Salir"};
boolean[] buttonHover = new boolean[4];
PImage fondomenú; //Puro background 
PImage fondojuego;
PImage fondodespedida;
PImage fondocreditos; //Fin del background
Minim minim; //Librería que me permite poner musiquita
AudioPlayer backgroundMusic; //Musiquita
boolean showCredits = false; //Se muestra la pantalla o no?
boolean showTuto=false; //Se muestra o no?
int screenHeight; // Altura de la pantalla
int screenWidth;  // Ancho de la pantalla
//La propia navecita
PImage player; //La imagen de la navecita
float playerX; //Posicion en X de la navecita
float playerY; //Posicion en Y de la navecita
float playerSpeed = 8; //Velocidad del jugador
boolean isGameRunning = false; //Palanca de inicio del juego
boolean isGameOver = false; //Palanca de fin de juego
ArrayList<Missile> missiles; //Simulador de Robert Oppenheimer
int score = 0; //Puntaje
int scoreGoal = 500; //Puntaje para ganar
int lives = 3; //Vidas
int lastShotTime = 0;       // Tiempo del último disparo
int shotInterval = 500;    // Intervalo mínimo entre disparos (en milisegundos)
//Aliens (Chamacos)
PImage alienImage; //Imagen de los chamacos
Alien[][] aliens; //Matriz que maneja a los chamacos
int rows = 5; //Filas
int cols = 10; //Columnas
float alienWidth = 100; //Ancho de los chamacos
float alienHeight = 80; //Altura de los chamacos
float alienSpeed = 25; //Velocidad de los chamacos
//Mensajes y velocidades del juego
int lastSpeedIncreaseTime = 0; //Registra 
int timeInterval = 2000;
int lastTime = 0;
int gameStartTime;
int gameTimeLimit = 100000;
boolean gameOverMessageShown = false;
//Carga de condiguracion del juego
void setup() {
  fullScreen();
  minim = new Minim(this);
  backgroundMusic = minim.loadFile("duels of the fates 16 bits.mp3");
  backgroundMusic.loop();
  fondojuego= loadImage("GameBackground.jpg");
  fondomenú = loadImage("Background.png");
  fondodespedida= loadImage("BackgroundDespedida.jpg");
  fondocreditos=loadImage("BackgroundCredits.jpg");
  font = createFont("Arcadia.ttf", 32);
  player = loadImage("Player.png");
  screenHeight = height;
  screenWidth = width;
  playerX = width / 2;
  playerY = height - 50;
  alienImage = loadImage("Alien.png");
  aliens = new Alien[rows][cols];
  //Generar aliens 
  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      aliens[i][j] = new Alien(j * (alienWidth + 20), i * (alienHeight + 20));
    }
  }
//Los botoncitos
  for (int i = 0; i < buttonColors.length; i++) {
    buttonColors[i] = color(100, 100, 100);
  }

  gameStartTime = millis();
  
  missiles = new ArrayList<Missile>();
}

//Dibujo del juego
void draw() {
  //Variables para la mecanica de tiempo
  int currentTime = millis();
  int elapsedTime = currentTime - gameStartTime;
  int timeLeft = gameTimeLimit - elapsedTime;
  //Inicio del juego
  if (isGameRunning) {
    //Condicion de tiempo
    if (timeLeft <= 0) {
      isGameOver = true;
      displayGameOverMessage();
      //Condiciones de derrota y victoria
    } else if (lives <= 0 || score >= scoreGoal) {
      isGameOver = true;
      displayGameOverMessage();
    } else {
      //Juego 
      image(fondojuego, 0, 0);
      fondojuego.resize(width, height);
      //Aumento de Velocidad (me rompí el cráneo viendo donde encajar esto sin un ciclo iterativo)
      if (currentTime - lastSpeedIncreaseTime >= 20000) {
        playerSpeed += 5; // Aumentar la velocidad en 5
        lastSpeedIncreaseTime = currentTime; // Actualizar el tiempo del último aumento
        //Nada más para ver si sí funcionaba
        println(playerSpeed);
      }
      //Dibujo de los aliens
      for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
          aliens[i][j].show();
          aliens[i][j].move();
        }
      }
      //Dibujo de la nave
      image(player, playerX, 1000);
      //Dibujo de los misiles
      for (int i = missiles.size() - 1; i >= 0; i--) {
        Missile missile = missiles.get(i);
        missile.show();
        missile.move();
        //Mecanica de misiles
        for (int j = 0; j < rows; j++) {
          for (int k = 0; k < cols; k++) {
            if (missile.hits(aliens[j][k])) {
              missiles.remove(i);
              aliens[j][k].destroy();
              score += 10;
            }
          }
        }
      }
      //Letreritos (Quería hacerlos más bonitos pero sí le meto mano a eso, no sé si me alcance el plazo)
      fill(255);
      textSize(38);
      text("Tiempo: " + timeLeft / 1000, 125, 60);
      text("Puntaje: " + score, 125, 100);
      text("Vidas: " + lives, width - 150, 40);
      //Si los aliens llegan a la misma fila q la nave, se resta una vida
      //y se resetean los aliens
      for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
          if (aliens[i][j].y + alienHeight >= playerY && !aliens[i][j].isDestroyed) {
            lives--;
            aliens[i][j].destroy();
            resetAliens();
          }
        }
      }
    }
  } else {
    //El menú
    image(fondomenú, 0, 0);
    fondomenú.resize(width, height);
    fill(255);
    textFont(font);
    textSize(64);
    textAlign(CENTER);
    //Si el juego no está corriendo, 
    if (isGameOver) {
      if (!gameOverMessageShown) {
        //Si ya ganaste, el mensaje de gracias por jugar se muestra
        displayGameOverMessage();
      } else {
        //Botoncitos del menú
        for (int i = 0; i < buttonColors.length; i++) {
          if (buttonHover[i]) {
            buttonColors[i] = color(150, 150, 150);
          } else {
            buttonColors[i] = color(100, 100, 100);
          }
          fill(buttonColors[i]);
          rect((width - buttonWidth) / 2, height / 2 + i * (buttonHeight + spacing), buttonWidth, buttonHeight);
          fill(0);
          textSize(24);
          text(buttonText[i], width / 2, height / 2 + i * (buttonHeight + spacing) + buttonHeight / 1.5);
        }
      }
    } else {
      //Más menú
      text("Galaxy Fate", width / 2, height / 4);
      for (int i = 0; i < buttonColors.length; i++) {
        if (buttonHover[i]) {
          buttonColors[i] = color(150, 150, 150);
        } else {
          buttonColors[i] = color(100, 100, 100);
        }
        fill(buttonColors[i]);
        rect((width - buttonWidth) / 2, height / 2 + i * (buttonHeight + spacing), buttonWidth, buttonHeight);
        fill(0);
        textSize(24);
        text(buttonText[i], width / 2, height / 2 + i * (buttonHeight + spacing) + buttonHeight / 1.5);
      }
    }
    //Boton tutorial
    if (showTuto){
    image(fondodespedida, 0, 0);
      fondodespedida.resize(width, height);
      fill(255);
      textFont(font);
      textSize(64);
      textAlign(CENTER);
      text("Tutorial", width / 2, 150);
      textSize(38);
      textAlign(CENTER);
      textFont(font);
      text("Presiona A y D para moverte hacia la izquierda y la derecha" , width / 2, 250);
      text("Presiona Barra espaciadora para disparar" , width / 2, 350);
      text("Ganarás cuando alcances los 500 puntos" , width / 2, 450);
      text("Pierdes si se te acaba el tiempo o si te quedas sin vidas" , width / 2, 550);
      text("Que te diviertas jugando!" , width / 2, 650);
      // Botón para volver al menú
      fill(100, 100, 100);
      rect(width / 2 - buttonWidth / 2, height / 2 + 300, buttonWidth, buttonHeight);
      fill(255);
      textSize(24);
      text("Menú Principal", width / 2, height / 2 + 300 + buttonHeight / 1.5);

      // Verificar si se hizo clic en el botón
      if (mouseX > width / 2 - buttonWidth / 2 && mouseX < width / 2 + buttonWidth / 2 &&
          mouseY > height / 2 + 300 && mouseY < height / 2 + 300 + buttonHeight && mousePressed) {
          showTuto = false; // Cambia la variable showCredits a false para volver al menú
      }
    
    }
   //Boton creditos
    if (showCredits) {
      image(fondocreditos, 0, 0);
      fondocreditos.resize(width, height);
      fill(255);
      textFont(font);
      textSize(64);
      textAlign(CENTER);
      text("Creditos:", width / 2, 150);

      textSize(38);
      textAlign(CENTER);
      fill(0);
      textFont(font);
      text("Juego desarrollado por: Santiago Fernandez ", width / 2, 200);
      text("Con apoyo de: Aiker Acosta Cantillo ", width / 2, 250);
      text("Inspiración artistica en la franquicia de Star Wars", width / 2, 300);
      text("Agradecimientos al profesor: Daladier Jabba", width / 2, 350);
      text("Apartado artistico: ", width / 2, 400);
      text("Música: Duel of the fates 16 bits (https://www.youtube.com/watch?v=RLNV4lAsP98) ", width / 2, 450);
      text("Fondo del menú: https://wall.alphacoders.com/big.php?i=787215", width / 2, 500);
      text("Fondo del juego: https://co.pinterest.com/pin/download-hd-wallpapers-of-8816star-wars", width / 2, 550);
      text("Fondo de despedida y tutorial: https://camera.edu.vn/fondo-estrellas-star-wars-raezwrq9/ ", width / 2, 600);
      text("Nave: https://www.vhv.rs/viewpic/hJxhoJx_galaga-pixel-art-hd-png-download/", width / 2, 650);
      text("Enemigos: https://www.pngegg.com/en/search?q=space+Invaders", width / 2, 700);
      text("Fuente de texto: Arcadia ", width / 2, 750);
      // Botón para volver al menú
      fill(100, 100, 100);
      rect(width / 2 - buttonWidth / 2, height / 2 + 300, buttonWidth, buttonHeight);
      fill(255);
      textSize(24);
      text("Menú Principal", width / 2, height / 2 + 300 + buttonHeight / 1.5);

      // Verificar si se hizo clic en el botón
      if (mouseX > width / 2 - buttonWidth / 2 && mouseX < width / 2 + buttonWidth / 2 &&
          mouseY > height / 2 + 300 && mouseY < height / 2 + 300 + buttonHeight && mousePressed) {
        showCredits = false; // Cambia la variable showCredits a false para volver al menú
      }
    }
  }


  currentTime = millis();
  if (currentTime - lastTime >= timeInterval) {
    lastTime = currentTime;
  }
}

//Registra las teclas presionadas
void keyPressed() {
  if (isGameRunning) {
    //Movimiento en el juego
    if (key == 'a' || key == 'A') {
      playerX = constrain(playerX - playerSpeed, 0, screenWidth - player.width);
    } else if (key == 'd' || key == 'D') {
      playerX = constrain(playerX + playerSpeed, 0, screenWidth - player.width);
    } else if (key == ' ' && !isGameOver) {
      // Verifica si ha pasado suficiente tiempo desde el último disparo
      //Antes si mantenía presionado el espacio, salían infinitos misiles JSKAJSKA
      if (millis() - lastShotTime >= shotInterval) {
        Missile missile = new Missile(playerX + player.width / 2, playerY);
        missiles.add(missile);
        lastShotTime = millis(); // Actualiza el tiempo del último disparo
      }
    }
  }
}

//Funcion para resetear la posicion de los aliens
void resetAliens() {
  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      aliens[i][j].reset();
    }
  }
}
//Función para resetear el juego o iniciarlo en su defecto
void initGame() {
  isGameOver = false;
  score = 0;
  playerX = width / 2;
  playerY = height - 50;
  lives = 3;
  resetAliens();
  missiles.clear();
  gameStartTime = millis();
  gameOverMessageShown = false;
}
//Funcion q me muestra el letrerito de chau chau, gracias por jogar
void displayGameOverMessage() {
  image(fondodespedida, 0, 0);
  fondodespedida.resize(width, height);
  fill(255);
  textFont(font);
  textSize(64);
  textAlign(CENTER);
  text("¡Gracias por jugar!", width / 2, 500);
  text("Presiona el botón para volver al menú", width / 2, height / 2 + 50);
  // Botón para volver al menú
  fill(100, 100, 100);
  rect(width / 2 - buttonWidth / 2, height / 2 + 100, buttonWidth, buttonHeight);
  fill(255);
  textSize(24);
  text("Menú Principal", width / 2, height / 2 + 100 + buttonHeight / 1.5);

  gameOverMessageShown = true;

  // Verificar si se hizo clic en el botón
  if (mouseX > width / 2 - buttonWidth / 2 && mouseX < width / 2 + buttonWidth / 2 &&
      mouseY > height / 2 + 100 && mouseY < height / 2 + 100 + buttonHeight && mousePressed) {
    isGameOver = false;
    isGameRunning = false;
  }
}
//Clases
//Clase Alien o chamaco con sus respectivas funciones
class Alien {
  float x, y;
  float initialX, initialY;
  int direction = 1;
  boolean isDestroyed = false;

  Alien(float x, float y) {
    this.x = x;
    this.y = y;
    this.initialX = x;
    this.initialY = y;
  }

  void show() {
    if (!isDestroyed) {
      image(alienImage, x, y, alienWidth, alienHeight);
    }
  }

  void move() {
    if (!isDestroyed) {
      x += direction * alienSpeed;
      if (x > width - alienWidth || x < 0) {
        y += alienHeight;
        direction *= -1;
      }
    }
  }

  void reset() {
    x = initialX;
    y = initialY;
    direction = 1;
    isDestroyed = false;
  }

  void destroy() {
    isDestroyed = true;
  }
}
//Clase misil (Oppenheimer)
class Missile {
  float x, y;
  //No sé si va bien así o deberia hacer los misiles más rapidos, para mí está bien JSAKSA
  float speed = 5;

  Missile(float x, float y) {
    this.x = x;
    this.y = y;
  }

  void show() {
    fill(0, 255, 0);
    rect(x, y, 2, 10);
  }

  void move() {
    y -= speed;
  }

  boolean hits(Alien alien) {
    if (!alien.isDestroyed) {
      float d = dist(x, y, alien.x + alienWidth / 2, alien.y + alienHeight / 2);
      return d < (alienWidth / 2);
    }
    return false;
  }
}
//Funcion q alumbra el boton si pasa por encima 
void mouseMoved() {
  for (int i = 0; i < buttonColors.length; i++) {
    if (mouseX > (width - buttonWidth) / 2 && mouseX < (width - buttonWidth) / 2 + buttonWidth &&
        mouseY > height / 2 + i * (buttonHeight + spacing) && mouseY < height / 2 + i * (buttonHeight + spacing) + buttonHeight) {
      buttonHover[i] = true;
    } else {
      buttonHover[i] = false;
    }
  }
}
//Funcion q controla el click
void mouseClicked() {
  if (!isGameRunning) {
    for (int i = 0; i < buttonColors.length; i++) {
      if (buttonHover[i]) {
        if (i == 0) {
          isGameRunning = true;
          initGame();
          gameStartTime = millis();
        } else if (i == 1) {
          showTuto=true;
        } else if (i == 2) {
          showCredits = true;
        } else if (i == 3) {
          exit();
        }
      }
    }
  }
}
//Realmente no sabía si iba a poder cumplir con el desarrollo del juego dentro del plazo
//Pero despues de ver que tanto había avanzado el Domingo despues de haber empezado a trabajar en ello el sabado
//Me ayudó a ver realmente el esfuerzo y las ganas que soy capaz
//Si usted, profesor Daladier, lee ésto, quiero darle las gracias.
//Gracias por convencerme de que soy capaz sin necesidad de mirarme cara a cara.
//Juego desarrollado por Santiago Fernandez.

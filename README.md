# PingPong-8088-Assembly
# PingPong-8088-Assembly

A classic two-player **Ping Pong game** written in 8088 Assembly Language.  
This project demonstrates low-level game programming using screen manipulation, timer interrupts, and real-time user input.


## Features
- **Initial Screen Setup:**  
  - Black background with white paddles and ball.  
  - Player A paddle at row 0, Player B paddle at row 24.  
  - Ball starts near Player B's side.

- **Ball Movement:**  
  - Moves diagonally after every timer tick.  
  - Bounces off walls and paddles, reversing diagonal direction.

- **Player Turns:**  
  - Turn changes after ball hits the top or bottom row.  
  - Player controls are enabled only during their turn.

- **Paddle Movement:**  
  - Controlled via Left/Right keys depending on the player's turn.  
  - Moves one cell per key press.

- **Scoring System:**  
  - Missed ball increases opponent’s score.  
  - Game restarts with ball at the scoring player’s side.

- **Game Termination:**  
  - Ends when any player reaches 5 points.  
  - Command prompt remains functional after game ends.

---

## Controls
- **Player A (Top):** Left/Right Arrow keys during their turn.  
- **Player B (Bottom):** Left/Right Arrow keys during their turn.

---

## How to Run
1. Assemble the code:
   ```bash
   tasm pingpong.asm
   tlink pingpong.obj


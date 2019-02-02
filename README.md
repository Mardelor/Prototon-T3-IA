# T3-IA

A very simple Game to test some AI principles ! 

## The Game

This is a very simple Tic-Tac-Toe against an AI which learn automatically. You play cross,
AI plays circle. To restart a game, you nee to press ENTER. To save what AI learnt, press SPACE.

## The AI

The approach is as follow : the AI registers possible state of the game, and associates with each 
of them couples of datas : an available position to play and the probability to play this position 
at this game state. If it discovers a new state, it simply initializes uniform probabilities.
At the end of the game, the AI modify its probabilities regarding where did it plays and which 
position it choosed.

The probabilities change policy isn't always easy to determine, and that is why this repository 
exist ! To test some policies. 

/*
    Student Name:     Michael Maxwell
    Student Number:   101006277
    References:       Stroustrup, B. (2013). The C++ Programming Language.
*/

#include <sstream>
#include "Chess.h"

void checkMove(chessBoard board, int col, int row, int xdir, int ydir, std::stringstream &moves, std::stringstream &caps) {
    int x, y;

    for(x = col + xdir, y = row + ydir; 0 <= x && x < 8 && 0 <= y && y < 8; x += xdir, y += ydir) {
        chessPiece cp = board.square[y][x];
        if(cp.piece == "")
            moves << (char) (x + 'a') << y + 1 << ',';
        else {
            if(board.square[row][col].isWhite != cp.isWhite)
                caps << (char) (x + 'a') << y + 1 << ',';
            break;
        }
    }
}

std::string validMoves(chessBoard board, char column, short int row){
    std::stringstream moves, caps;
    const int ROW = row - 1;
    const int COL = column - 'a';
    chessPiece cp = board.square[ROW][COL];
    if(cp.piece == "Queen") {
        checkMove(board, COL, ROW, 1, 0, moves, caps); // up
        checkMove(board, COL, ROW, -1, 0, moves, caps); // down
        checkMove(board, COL, ROW, 0, -1, moves, caps); // left
        checkMove(board, COL, ROW, 0, 1, moves, caps); // right
        checkMove(board, COL, ROW, 1, -1, moves, caps); // up-left
        checkMove(board, COL, ROW, 1, 1, moves, caps); // up-right
        checkMove(board, COL, ROW, -1, -1, moves, caps); // down-left
        checkMove(board, COL, ROW, -1, 1, moves, caps); // down-right
    } else if(cp.piece == "Rook") {
        checkMove(board, COL, ROW, 1, 0, moves, caps); // up
        checkMove(board, COL, ROW, -1, 0, moves, caps); // down
        checkMove(board, COL, ROW, 0, -1, moves, caps); // left
        checkMove(board, COL, ROW, 0, 1, moves, caps); // right
    } else if(cp.piece == "Bishop") {
        checkMove(board, COL, ROW, 1, -1, moves, caps); // up-left
        checkMove(board, COL, ROW, 1, 1, moves, caps); // up-right
        checkMove(board, COL, ROW, -1, -1, moves, caps); // down-left
        checkMove(board, COL, ROW, -1, 1, moves, caps); // down-right
    }

    // if strings aren't empty, overwrite last char because it's an extra comma
    if(moves.str().length() > 0)
        moves.seekp(moves.str().length() - 1);
    moves << "}";
     if(caps.str().length() > 0)
        caps.seekp(caps.str().length() - 1);
    caps << "}";

    return "{" + moves.str() + "\n{" + caps.str();
}

/** setup up the chess board as in the assignment specification */

void chessDriver(){

    chessBoard board;

    for(int row=0; row<8; row++){
        for(int col=0; col<8; col++){
            board.square[row][col].piece = "";
        }
    }

    board.square[7][0].piece = "Rook";
    board.square[7][0].isWhite = false;

    board.square[7][1].piece = "Knight";
    board.square[7][1].isWhite = false;

    board.square[7][2].piece = "Bishop";
    board.square[7][2].isWhite = false;

    board.square[7][3].piece = "Queen";
    board.square[7][3].isWhite = false;

    board.square[7][4].piece = "King";
    board.square[7][4].isWhite = false;

    board.square[7][5].piece = "Bishop";
    board.square[7][5].isWhite = false;

    board.square[7][6].piece = "Knight";
    board.square[7][6].isWhite = false;

    board.square[7][7].piece = "Rook";
    board.square[7][7].isWhite = false;

    for(int col = 0; col<8; col++){
        board.square[6][col].piece = "Pawn";
        board.square[6][col].isWhite = false;
    }
    board.square[6][3].piece = "";       // remove the pawn in d7
    board.square[6][6].isWhite = true;   // pawn in g7 is white

    board.square[5][5].piece = "Queen";
    board.square[5][5].isWhite = true;

    std::cout << validMoves(board, 'f', 6) << std::endl;
    std::cout << validMoves(board, 'd', 2) << std::endl;
    std::cout << validMoves(board, 'a', 8) << std::endl;
    std::cout << validMoves(board, 'g', 8) << std::endl;
    std::cout << validMoves(board, 'f', 8) << std::endl;
}

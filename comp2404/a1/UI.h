/* * * * * * * * * * * * * * * * * * * * * * * * * */
/*                                                 */
/*  Program:  Simple Inventory System              */
/*  Author:   Christine Laurendeau                 */
/*  Date:     28-JUN-2016                          */
/*                                                 */
/*  (c) 2016 Christine Laurendeau                  */
/*  All rights reserved.  Distribution and         */
/*  reposting, in part or in whole, without the    */
/*  written consent of the author, is illegal.     */
/*                                                 */
/* * * * * * * * * * * * * * * * * * * * * * * * * */

/*
    User interface object to provide IO to the user of the program.
*/

#ifndef UI_H
#define UI_H

#include <string>
using namespace std;

#include "ProdArray.h"
#include "CustArray.h"

class UI
{
  public:
    void mainMenu(int&);
    void adminMenu(int&);
    void cashierMenu(int&);
    void promptForInt(string, int&);
    void promptForStr(string, string&);
    void promptForFloat(string, float&);
    void printError(string);
    void printUsageError();
    void printStock(ProdArray&);
    void printCustomers(CustArray&);
    void pause();

  private:
    int    readInt();
};

#endif

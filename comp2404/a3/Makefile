OBJ = main.o InvControl.o Store.o Product.o UI.o ProdList.o CustArray.o Customer.o Purchase.o PurchArray.o

cushop:	$(OBJ)
	g++ -o cushop $(OBJ) -Wall

main.o:	main.cc 
	g++ -c main.cc

InvControl.o:	InvControl.cc InvControl.h Store.h UI.h
	g++ -c InvControl.cc

UI.o:	UI.cc UI.h 
	g++ -c UI.cc

Store.o:	Store.cc Store.h ProdList.h  
	g++ -c Store.cc

Product.o:	Product.cc Product.h 
	g++ -c Product.cc

ProdList.o:	ProdList.cc ProdList.h Product.h defs.h
	g++ -c ProdList.cc

CustArray.o:	CustArray.cc CustArray.h Customer.h defs.h
	g++ -c CustArray.cc

Customer.o:	Customer.cc Customer.h PurchArray.h
	g++ -c Customer.cc

Purchase.o:	Purchase.cc Purchase.h
	g++ -c Purchase.cc

PurchArray.o:	PurchArray.cc PurchArray.h Purchase.h defs.h
	g++ -c PurchArray.cc

clean:
	rm -f $(OBJ) cushop
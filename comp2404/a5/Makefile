OBJ = main.o InvControl.o Store.o Product.o UI.o ProdList.o CustArray.o Customer.o Purchase.o PurchArray.o OrderServer.o OrderArray.o Order.o Perishable.o NonPerishable.o Dairy.o CoffeeTea.o Bakery.o Meat.o MiscGoods.o Date.o Taxable.o NonTaxable.o

cushop:	$(OBJ)
	g++ -o cushop $(OBJ) -Wall

main.o:	main.cc 
	g++ -c main.cc

InvControl.o:	InvControl.cc InvControl.h Store.h UI.h OrderServer.h
	g++ -c InvControl.cc

UI.o:	UI.cc UI.h 
	g++ -c UI.cc

Store.o:	Store.cc Store.h ProdList.h  
	g++ -c Store.cc

Product.o:	Product.cc Product.h Date.h
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

OrderServer.o:	OrderServer.h OrderArray.h
	g++ -c OrderServer.cc

OrderArray.o:	OrderArray.h Order.h
	g++ -c OrderArray.cc

Order.o:	Order.h
	g++ -c Order.cc

Perishable.o:	Perishable.h Perishable.cc Product.h
	g++ -c Perishable.cc

NonPerishable.o:	NonPerishable.h NonPerishable.cc Product.h
	g++ -c NonPerishable.cc

Taxable.o:	Taxable.cc Taxable.h Product.h
	g++ -c Taxable.cc

NonTaxable.o: NonTaxable.cc NonTaxable.h Product.h
	g++ -c NonTaxable.cc

Dairy.o:	Dairy.cc Dairy.h Perishable.h NonTaxable.h
	g++ -c Dairy.cc

CoffeeTea.o:	CoffeeTea.cc CoffeeTea.h NonPerishable.h Taxable.h
	g++ -c CoffeeTea.cc

Bakery.o:	Bakery.cc Bakery.h Perishable.h Taxable.h
	g++ -c Bakery.cc

Meat.o:	Meat.cc Meat.h Perishable.h NonTaxable.h
	g++ -c Meat.cc

MiscGoods.o:	MiscGoods.cc MiscGoods.h NonPerishable.h NonTaxable.h
	g++ -c MiscGoods.cc

Date.o:	Date.cc Date.h
	g++ -c Date.cc

clean:
	rm -f $(OBJ) cushop
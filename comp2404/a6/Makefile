PRODUCT = Product.o Bakery.o CoffeeTea.o Dairy.o Meat.o MiscGoods.o
BEHAVIOUR = Taxable.o NonTaxable.o Perishable.o NonPerishable.o

OBJ = $(PRODUCT) $(BEHAVIOUR) main.o InvControl.o Store.o UI.o ProdList.o Customer.o Purchase.o PurchArray.o OrderServer.o OrderArray.o Order.o Date.o

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

ProdList.o:	ProdList.cc ProdList.h Product.h defs.h
	g++ -c ProdList.cc

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

Date.o:	Date.cc Date.h
	g++ -c Date.cc

# PRODUCT
Product.o:	Product.cc Product.h Date.h ExpirationBehaviour.h TaxationBehaviour.h
	g++ -c Product.cc

Bakery.o:	Bakery.cc Bakery.h Product.h Perishable.h Taxable.h
	g++ -c Bakery.cc

CoffeeTea.o:	CoffeeTea.cc CoffeeTea.h Product.h NonPerishable.h Taxable.h
	g++ -c CoffeeTea.cc

Dairy.o:	Dairy.cc Dairy.h Product.h Perishable.h NonTaxable.h
	g++ -c Dairy.cc

Meat.o:	Meat.cc Meat.h Product.h Perishable.h NonTaxable.h
	g++ -c Meat.cc

MiscGoods.o:	MiscGoods.cc MiscGoods.h Product.h NonTaxable.h NonPerishable.h
	g++ -c MiscGoods.cc

# TAXATION
Taxable.o:	Taxable.cc Taxable.h TaxationBehaviour.h
	g++ -c Taxable.cc

NonTaxable.o:	NonTaxable.cc NonTaxable.h TaxationBehaviour.h
	g++ -c NonTaxable.cc

# EXPIRATION
Perishable.o:	Perishable.cc Perishable.h ExpirationBehaviour.h
	g++ -c Perishable.cc

NonPerishable.o:	NonPerishable.cc NonPerishable.h ExpirationBehaviour.h
	g++ -c NonPerishable.cc

# UTIL
clean:
	rm -f $(OBJ) cushop
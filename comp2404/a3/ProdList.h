#ifndef PRODLIST_H
#define PRODLIST_H

#include "Product.h"

class ProdList {

	class Node {
		friend class ProdList;
		private:
			Product* data;
			Node* next;
			Node* prev;
	};

	public:
		ProdList();
		~ProdList();
		void add(Product*);
		void remove(Product*);
		void reorg();
		bool find(int, Product**);
		void toString(string&);
	private:
		Node* head;
};

#endif
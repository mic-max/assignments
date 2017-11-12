#include "OrderServer.h"

void OrderServer::update(Order* order) {
	orders.add(order);
}

// TODO make a new OrderArray, copy elements from orders to it
void OrderServer::retrieve(OrderArray& arr) {
	arr = orders;
}
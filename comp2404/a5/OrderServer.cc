#include "OrderServer.h"

OrderServer::OrderServer() {
}

OrderServer::~OrderServer() {
}

void OrderServer::update(Order* order) {
	orders.add(order);
}

void OrderServer::retrieve(OrderArray& arr) {
	arr = orders;
}
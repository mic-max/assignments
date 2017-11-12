#include "Date.h"
#include <sstream>

Date::Date(int y, int m, int d) {
	year = y;
	month = m;
	day = d;
}

Date::Date(int days) { // 26,000
	year = days / 360; // 71
	month = days % 360 / 30; // 2
	day = days % 360 % 30; // 25
}

int Date::convertToDays() {
	return year * 360 + month * 30 + day;
}

int Date::getYear() const {
	return year;
}

int Date::getMonth() const {
	return month;
}

int Date::getDay() const {
	return day;
}


void Date::toString(string& strOut) const {
	stringstream ss;
	ss << year << "-" << month << "-" << day;
	strOut = ss.str();
}

Date& Date::operator+=(int numDays) {
	int totalDays = numDays + convertToDays();
	*this = Date(totalDays);
	return *this;
}

Date Date::operator+(int numDays) {
	Date d = Date(this->convertToDays());
	d += numDays;
	return d;
}

bool Date::operator<(const Date& other) {
	if(other.getYear() == year) {
		if(other.getMonth() == month)
			return (day - other.getDay() < 0) ? true : false;
		return (month - other.getMonth() < 0) ? true : false;
	}
	return (year - other.getYear() < 0) ? true : false;
}
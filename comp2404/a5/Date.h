#ifndef DATE_H
#define DATE_H

#include <string>
#include <iostream>

using namespace std;

// Assumes all months are 30 days for simplicity

class Date {
	public:
		Date(int, int, int);
		Date(int);
		~Date();
		void setDate(int = 0, int = 0, int = 0);

		int convertToDays();
		int getYear() const;
		int getMonth() const;
		int getDay() const;

		Date& operator+=(int);
		Date operator+(int);
		bool operator<(const Date&);
		void toString(string&) const;
	private:
		int year;
		int month;
		int day;
};

#endif
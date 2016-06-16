/*
	Student Name:		Michael Maxwell
	Student Number:		101006277
	References:			I did not use any reference material in developing this assignment.
*/

public class Weather {

	private float temp;
	private int day, month, year;
	private boolean celsius;

	public Weather(float temp, int day, int month, int year) {
		this.temp = temp;
		this.day = day;
		this.month = month;
		this.year = year;
		celsius = true;
	}

	public float getTemp() {
		return temp;
	}

	public boolean isCelsius() {
		return celsius;
	}

	public void setCelsius() {
		if(!celsius) {
			temp = (temp - 32) * 5 / 9;
			celsius = true;
		}
	}

	public void setFahrenheit() {
		if(celsius) {
			temp = temp * 9 / 5 + 32;
			celsius = false;
		}
	}

	public String toString() {
		String[] m = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"};
		return String.format("%s %d, %d. Temperature is %.2f %c.", m[month - 1], day, year, temp, celsius ? 'C' : 'F');
	}
}
public class Car {
	String plateNumber;
	boolean permit;
	Time enteringTime;
	int lotNumber;

	public Car(String plateNumber) {
		this.plateNumber = plateNumber;
		this.permit = false;
		this.enteringTime = null;
		this.lotNumber = -1;
	}

	public Car(String plateNumber, boolean permit) {
		this.plateNumber = plateNumber;
		this.permit = permit;
		this.enteringTime = null;
		this.lotNumber = -1;
	}

	public String toString() {
		if(permit)
			return "Car " + plateNumber + " with permit";
		return "Car " + plateNumber;
	}
}
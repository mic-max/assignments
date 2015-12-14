public class ParkingLot {
	int lotNumber, capacity, currentCarCount;
	double hourlyRate, maxCharge, revenue;

	public ParkingLot() {
		this.lotNumber = 0;
		this.capacity = 8;
		this.currentCarCount = 0;
		this.hourlyRate = 4;
		this.maxCharge = 24;
		this.revenue = 0;
	}

	public ParkingLot(int lotNumber, int capacity) {
		this.lotNumber = lotNumber;
		this.capacity = capacity;
		this.currentCarCount = 0;
		this.hourlyRate = 4;
		this.maxCharge = 24;
		this.revenue = 0;
	}

	public String toString() {
		return String.format("Parking Lot #%d - rate = $%.2f, capacity %d, current cars %d", lotNumber, hourlyRate, capacity, currentCarCount);
	}
}
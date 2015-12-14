public class ParkingLotSimulationProgram {

	public static void carEnters(ParkingLot p, Car c, Time t) {
		if(p.currentCarCount == p.capacity)
			System.out.printf("%s arrives at Lot %d at %s, but the lot is full.%n%s cannot get in.%n", c, p.lotNumber, t, c);
		else if(c.lotNumber >= 0)
			System.out.printf("Error: %s is in parking lot #%d.%n", c, c.lotNumber);
		else {
			c.enteringTime = t;
			c.lotNumber = p.lotNumber;
			p.currentCarCount++;
			System.out.printf("%s enters Lot %d at %s.%n", c, p.lotNumber, t);
		}
	}

	public static void carLeaves(ParkingLot p, Car c, Time t) {
		Time delta = Time.difference(c.enteringTime, t);
		if(c.lotNumber != p.lotNumber)
			System.out.printf("Error: %s isn't in Parking Lot #%d.%n", c, p.lotNumber);
		else if(delta.hours <= 0 && delta.minutes <= 0)
			System.out.printf("%s leaves Lot %d at %s.%n", c, p.lotNumber, t);
		else {	
			if(!c.permit) {
				double cost = Math.min(p.maxCharge, (delta.hours + 1) * p.hourlyRate);
				p.revenue += cost;
				System.out.printf("%s leaves Lot %d at %s paid $%.2f.%n", c, p.lotNumber, t, cost);
			} else
				System.out.printf("%s leaves Lot %d at %s.%n", c, p.lotNumber, t);
			c.lotNumber = -1;
			p.currentCarCount--;
		}
	}

	public static void main(String[] args) {
		Car car1 = new Car("ABC 123");
		Car car2 = new Car("ABC 124");
		Car car3 = new Car("ABD 314");
		Car car4 = new Car("ADE 901");
		Car car5 = new Car("AFR 304");
		Car car6 = new Car("AGD 888");
		Car car7 = new Car("AAA 111");
		Car car8 = new Car("ABB 001");
		Car car9 = new Car("XYZ 678", true);

		ParkingLot p1 = new ParkingLot(1, 4);
		ParkingLot p2 = new ParkingLot(2, 6);

		p1.hourlyRate = 5.5;
		p1.maxCharge = 20D;
		p2.hourlyRate = 3D;
		p2.maxCharge = 12D;

		System.out.println(p1);
		System.out.println(p2 + "\n");

		carEnters(p1, car1, new Time(7, 15));
		carEnters(p1, car2, new Time(7, 25));
		carEnters(p2, car3, new Time(8, 00));
		carEnters(p2, car4, new Time(8, 10));
		carEnters(p1, car5, new Time(8, 15));
		carEnters(p1, car6, new Time(8, 20));
		carEnters(p1, car7, new Time(8, 30));
		carEnters(p2, car7, new Time(8, 32));
		carEnters(p2, car8, new Time(8, 50));
		carEnters(p2, car9, new Time(8, 55));

		System.out.println("\n" + p1);
		System.out.println(p2 + "\n");

		carLeaves(p2, car4, new Time(9, 00));
		carLeaves(p1, car2, new Time(9, 05));
		carLeaves(p1, car6, new Time(10, 00));
		carLeaves(p1, car1, new Time(10, 30));
		carLeaves(p2, car8, new Time(13, 00));
		carLeaves(p2, car9, new Time(15, 15));
		carEnters(p1, car8, new Time(17, 10));
		carLeaves(p1, car5, new Time(17, 50));
		carLeaves(p2, car7, new Time(18, 00));
		carLeaves(p2, car3, new Time(18, 15));
		carLeaves(p1, car8, new Time(20, 55));

		System.out.println("\n" + p1);
		System.out.println(p2 + "\n");

		System.out.printf("Total revenue of Lot 1 is $%.2f.%n", p1.revenue);
		System.out.printf("Total revenue of Lot 2 is $%.2f.%n", p2.revenue);

		System.out.println("\n===============================================================");
		System.out.println("===============================================================\n");

		System.out.println("- A car tries to leave before it entered.");
		carLeaves(p1, car1, new Time(10, 30));
		System.out.println("- A car enters and leaves a lot at the same time.");
		carEnters(p1, car2, new Time(11, 20));
		carLeaves(p1, car2, new Time(11, 20));
		System.out.println("- A car enters a lot twice, without leaving in between.");
		carEnters(p1, car3, new Time(12, 00));
		carEnters(p1, car3, new Time(13, 00));
		System.out.println("- A car leaves a lot twice, without entering in between.");
		carEnters(p1, car5, new Time(13, 20));
		carLeaves(p1, car5, new Time(14, 10));
		carLeaves(p1, car5, new Time(14, 20));
		System.out.println("- A car enters one parking lot and tries to leave a different one.");
		carEnters(p1, car6, new Time(15, 30));
		carLeaves(p2, car6, new Time(17, 00));
	}
}
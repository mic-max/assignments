public class TimeTestProgram {
	
	public static void main(String[] args) {
		System.out.println(new Time(9, 30)); // 9:30
		System.out.println(new Time(21, 30)); // 21:30
		System.out.println(new Time(10, 93)); // 11:33
		System.out.println(new Time(9.5)); // 9:30
		System.out.println(new Time(21.5)); // 21:30
		System.out.println(new Time(0, 0)); // 0:00
		System.out.println(new Time(0)); // 0:00
		System.out.println(new Time(1, 1)); // 1:01
		System.out.println(Time.difference(new Time(1, 10), new Time(10, 10))); // 9:00
		System.out.println(Time.difference(new Time(7, 50), new Time(8, 10))); // 0:20
		System.out.println(Time.difference(new Time(12, 57), new Time(2, 10))); // -10:47 or -10:-47
	}
}
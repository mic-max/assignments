public class Time {
	int hours, minutes;

	public static Time difference(Time t1, Time t2) {
		return new Time(0, 60 * (t2.hours - t1.hours) + t2.minutes - t1.minutes);
	}

	public Time(int hours, int minutes) {
		this.hours = hours + minutes / 60;
		this.minutes = minutes % 60;
	}

	public Time(double t) {
		this.hours = (int) t;
		this.minutes = (int) (t % 1 * 60);
	}

	public String toString() {
		return String.format("%d:%02d", hours, minutes);
	}
}
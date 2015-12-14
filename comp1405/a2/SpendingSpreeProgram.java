import java.util.Scanner;

public class SpendingSpreeProgram {

	public static void main(String[] args) {
		Scanner sc = new Scanner(System.in);
		double money = 1000, cost;
		while(money > 0) {
			String debt = "";
			System.out.printf("%nYou have $%1.2f left to spend", money);
			System.out.print("Enter the cost of the item you want to buy: ");
			cost = sc.nextDouble();
			if(cost > money) {
				System.out.println("You don't have enough money to purchase that item.");
				debt = " & go into debt";
			}
			System.out.printf("Are you sure you want to purchase the $%1.2f item%s? [yes / no]", cost, debt);
			if(sc.next().equals("yes"))
				money -= cost;
		}
		if(money < 0)
			System.out.printf("You overspent & now owe: $%1.2f%n", -money);
		else
			System.out.println("You spent all your money");
	}
}
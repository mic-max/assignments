import javax.swing.JOptionPane;

public class BuggyProgram2 {

	public static void main(String[] args) {
		int year = 2015;
		int startUni = Integer.parseInt(JOptionPane.showInputDialog("What year did you start university?"));
		String output = "Something is wrong here.";
		if(startUni == year)
			output = "You started university this year!";
		else if(startUni < year)
			output = "You started university before this year.";
		JOptionPane.showMessageDialog(null, output);
	}
}
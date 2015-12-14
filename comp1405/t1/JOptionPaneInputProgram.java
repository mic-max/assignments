import javax.swing.JOptionPane;

public class JOptionPaneInputProgram {

	public static void main(String[] args) {
		JOptionPane.showMessageDialog(null, JOptionPane.showInputDialog("First").toUpperCase().charAt(0) + ". " + JOptionPane.showInputDialog("Middle").toUpperCase().charAt(0) + ". " + JOptionPane.showInputDialog("Last").toUpperCase().charAt(0) + '.');
	}
}
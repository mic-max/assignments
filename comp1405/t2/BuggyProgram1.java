import javax.swing.JOptionPane;

public class BuggyProgram1 {

	public static void main(String[] args) {
		int grade = Integer.parseInt(JOptionPane.showInputDialog("Grade"));
		int max = Integer.parseInt(JOptionPane.showInputDialog("Max Grade"));
		JOptionPane.showMessageDialog(null, grade + " / " + max + " is " + (int) ((double) grade / (double) max * 100D) + '%');
	}
}
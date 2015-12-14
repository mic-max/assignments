import javax.swing.JOptionPane;

public class BoxWrapperProgram {
	public static void main(String[] args) {
		int l = Integer.parseInt(JOptionPane.showInputDialog("Enter the dimensions of a box to be wrapped in cm\nLength"));
		int w = Integer.parseInt(JOptionPane.showInputDialog("Width"));
		int h = Integer.parseInt(JOptionPane.showInputDialog("Height"));
		JOptionPane.showMessageDialog(null, 2 * (l + h) + 1 + "cm x " + (2 * h + w + 1) + "cm piece of wrapping paper is needed");
	}
}
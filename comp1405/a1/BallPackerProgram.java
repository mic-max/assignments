import javax.swing.JOptionPane;

public class BallPackerProgram {
	public static void main(String[] args) {
		int l = Integer.parseInt(JOptionPane.showInputDialog("Enter the box's dimensions & balls' radius in cm\nLength"));
		int w = Integer.parseInt(JOptionPane.showInputDialog("Width"));
		int h = Integer.parseInt(JOptionPane.showInputDialog("Height"));
		float d = 2 * Float.parseFloat(JOptionPane.showInputDialog("Radius"));
		System.out.println((int)(l / d) * (int)(w / d) * (int)(h / d) + " balls fit in this box");
	}
}
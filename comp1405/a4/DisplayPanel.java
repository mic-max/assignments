import java.awt.*;
import javax.swing.JPanel;

public class DisplayPanel extends JPanel {
	private int[][] facesX, facesY;
	private int width, height;

	public DisplayPanel(int[][] fX, int[][] fY) {
		facesX = fX;
		facesY = fY;
		setPreferredSize(new Dimension(800, 800));
	}

	public void paintComponent(Graphics g) {
		super.paintComponent(g);
		for(int i = 0; i < facesX.length; i++) {
			g.setColor(Color.GRAY);
			g.fillPolygon(facesX[i], facesY[i], 3);
			g.setColor(Color.BLACK);
			g.drawPolygon(facesX[i], facesY[i], 3);
		}
	}
}
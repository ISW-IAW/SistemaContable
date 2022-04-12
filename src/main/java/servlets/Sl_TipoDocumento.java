package servlets;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import datos.Dt_tipoDocumento;
import entidades.Tbl_tipoDocumento;



@WebServlet("/Sl_TipoDocumento")
public class Sl_TipoDocumento extends HttpServlet {
	private static final long serialVersionUID = 1L;
       

    public Sl_TipoDocumento() {
        super();
       
    }

	
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		response.getWriter().append("Served at: ").append(request.getContextPath());
	}


	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		int opc = 0;
		opc = Integer.parseInt(request.getParameter("opcion"));
		
		Tbl_tipoDocumento tipoDoc = new Tbl_tipoDocumento();
		Dt_tipoDocumento dttd = new Dt_tipoDocumento();
		
		tipoDoc.setTipo(request.getParameter("txtTipo"));
		tipoDoc.setAcronimo(request.getParameter("txtAcronimo"));
		
		switch (opc) {
		case 1:
				try {
						if(dttd.guardarTipoDocumento(tipoDoc)) {
							response.sendRedirect("production/tbl_tipoDocumento.jsp?msj=1");
						} else {
							response.sendRedirect("production/tbl_tipoDocumento.jsp?msj=2");
						}
					
				} catch (Exception e) {
					System.out.println("ERROR Sl_TipoDocumento opc1: "+e.getMessage());
					e.printStackTrace();
				}
			
			break;

		default:
			break;
		}
				
	}

}
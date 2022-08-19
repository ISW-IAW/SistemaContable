<%@page import="datos.Dt_catalogocuenta"%>
<%@page import="entidades.Tbl_cuentaContable"%>
<%@page import="entidades.Vw_catalogocuenta_empresa"%>
<%@page import="datos.Dt_periodoContable"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"
	import="datos.Dt_moneda, entidades.Vw_usuariorol, entidades.Tbl_moneda, entidades.Vw_empresa, entidades.Tbl_periodoContable,
	entidades.Vw_rolopciones,entidades.Tbl_asientoContable, entidades.Tbl_tipoDocumento, entidades.Vw_tasaCambioDet,
	entidades.Vw_catalogo_tipo_cuentacontable, entidades.Vw_asientoContableDet, entidades.Tbl_empresa,
	datos.Dt_rolOpciones, datos.Dt_asientoContable, datos.Dt_tipoDocumento, datos.Dt_tasaCambio, datos.Dt_cuentaContable,
	datos.Dt_asientoContableDet, datos.Dt_tasacambio_det, java.sql.Timestamp, java.util.*, java.time.LocalDateTime, java.time.format.DateTimeFormatter,
	java.text.SimpleDateFormat,
	java.sql.Date,
	java.text.DateFormat;"%>

<%
// Placeholder para el mensaje
String codigoMensaje = "";

if (request.getParameter("msj") != null)
	codigoMensaje = request.getParameter("msj");

//Obteniendo fecha y hora actual del sistema 

//INVALIDA LA CACHE DEL NAVEGADOR //
response.setHeader("Pragma", "no-cache");
response.setHeader("Cache-Control", "no-store");
response.setDateHeader("Expires", 0);
response.setDateHeader("Expires", -1);

//DECLARACIONES
Tbl_moneda moneda = new Tbl_moneda();
Tbl_periodoContable pContable = new Tbl_periodoContable();
Dt_periodoContable periodoContable = new Dt_periodoContable();
Dt_tasacambio_det tipoCambio = new Dt_tasacambio_det();
Vw_usuariorol vwur = new Vw_usuariorol();
Dt_rolOpciones dtro = new Dt_rolOpciones();
Dt_moneda dtMoneda = new Dt_moneda();
Dt_asientoContable asientoContable = new Dt_asientoContable();
ArrayList<Vw_rolopciones> listOpc = new ArrayList<Vw_rolopciones>();
ArrayList<Integer> cuentas = new ArrayList<Integer>();
boolean permiso = false; //VARIABLE DE CONTROL
int numeroComprobante = 0;
Vw_tasaCambioDet tipoCambioSugerido = new Vw_tasaCambioDet();

DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy/MM/dd");
DateFormat df = new SimpleDateFormat("yyyy/MM/dd");

String fechaActual = dtf.format(LocalDateTime.now());
tipoCambioSugerido = tipoCambio.ObtenerTasaCambioPorFecha(fechaActual);

// Comparaci�n de la fecha actual del sistema con la que regresa el m�todo ObtenerTasaCambioPorFecha
String fechaDelCambioSugerido = df.format(tipoCambioSugerido.getFecha());

boolean fechaIgual = (fechaActual.equals(fechaDelCambioSugerido)) ? true : false;

//OBTENEMOS LA SESION
vwur = (Vw_usuariorol) session.getAttribute("acceso");
if (vwur != null) {
	//OBTENEMOS LA LISTA DE OPCIONES ASIGNADAS AL ROL

	listOpc = dtro.ObtenerRolOpcionPorIdLogin(vwur.getIdUsuarioRol());

	pContable = periodoContable.obtenerPContablePorId(vwur.getIdPeriodoContable());

	moneda = dtMoneda.getMonedaByID(vwur.getIdMoneda());

	numeroComprobante = asientoContable.comprobarNumeroComprobanteAC(vwur.getIdPeriodoContable());
	//RECUPERAMOS LA URL = MI OPCION ACTUAL
	int index = request.getRequestURL().lastIndexOf("/");
	String miPagina = request.getRequestURL().substring(index + 1);

	//VALIDAR SI EL ROL CONTIENE LA OPCION ACTUAL DENTRO DE LA MATRIZ DE OPCIONES
	for (Vw_rolopciones vrop : listOpc) {
		if (vrop.getOpciones().trim().equals(miPagina.trim())) {
	permiso = true; //ACCESO CONCEDIDO
	break;
		}
	}
} else {
	response.sendRedirect("../login.jsp?msj=401");
	return;
}

if (!permiso) {
	// response.sendRedirect("../login.jsp?msj=401");
	response.sendRedirect("../login.jsp?msj=403");
	return;
}
%>

<!DOCTYPE html>
<html lang="es">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
<!-- Meta, title, CSS, favicons, etc. -->
<meta charset="ISO-8859-1">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">

<title>Estado de resultados</title>

<!-- Bootstrap -->
<link href="../vendors/bootstrap/dist/css/bootstrap.min.css"
	rel="stylesheet">
<!-- Font Awesome -->
<link href="../vendors/font-awesome/css/font-awesome.min.css"
	rel="stylesheet">
<!-- NProgress -->
<link href="../vendors/nprogress/nprogress.css" rel="stylesheet">
<!-- iCheck -->
<link href="../vendors/iCheck/skins/flat/green.css" rel="stylesheet">
<!-- Datatables -->

<link
	href="../vendors/datatables.net-bs/css/dataTables.bootstrap.min.css"
	rel="stylesheet">
<link
	href="../vendors/datatables.net-buttons-bs/css/buttons.bootstrap.min.css"
	rel="stylesheet">
<link
	href="../vendors/datatables.net-fixedheader-bs/css/fixedHeader.bootstrap.min.css"
	rel="stylesheet">
<link
	href="../vendors/datatables.net-responsive-bs/css/responsive.bootstrap.min.css"
	rel="stylesheet">
<link
	href="../vendors/datatables.net-scroller-bs/css/scroller.bootstrap.min.css"
	rel="stylesheet">

<!-- Custom Theme Style -->
<link href="../build/css/custom.min.css" rel="stylesheet">

<!--Jquery Toast Plugin -->
<link href="../vendors/jquery.toast.min.css" rel="stylesheet">

<!-- Select2 -->
<link href="../vendors/select2/dist/css/select2.min.css"
	rel="stylesheet" />

</head>

<body class="nav-md">
	<div class="container body">
		<div class="main_container">
			<jsp:include page="navegacion.jsp"></jsp:include>
			<!-- /top navigation -->

			<!-- page content -->
			<div class="right_col" role="main">
				<div class="">
					<div class="page-title">
						<div class="title_left">
							<h3>Estado de resultados</h3>
						</div>
					</div>
					<div class="clearfix"></div>

					<div class="row">
						<div class="col-md-12 col-sm-12">
							<div class="x_panel">
								<div class="x_content">
									<form class="" action="../Sl_rptIncomesResult" method="post"
										data-parsley-validate>
										<input type="hidden" value="1" name="opcion" id="opcion" /> <input
											type="hidden" value="0" name="detalles" id="detalles" /> <input
											type="hidden" value="<%=vwur.getIdPeriodoContable()%>"
											name="periodoContable" id="periodoContable" /> <input
											type="hidden" value="<%=vwur.getIdEmpresa()%>"
											name="empresaActual" id="empresaActual" /> <input
											type="hidden" value="<%=vwur.getId_user()%>"
											name="usuarioCreacion" id="usuarioCreacion" /> <input
											type="hidden" value="<%=moneda.getIdMoneda()%>" name="moneda"
											id="moneda" />


										<div class="IngresosBrutos">

											<div style="display: inline-block;" class="left">
												<div>
													<div class="col-md-12 col-sm-12">
														<%
														ArrayList<Vw_catalogo_tipo_cuentacontable> listaCuentasIngresosMayor = new ArrayList<Vw_catalogo_tipo_cuentacontable>();
														Dt_cuentaContable dtCuentaIngresosMayor = new Dt_cuentaContable();
														listaCuentasIngresosMayor = dtCuentaIngresosMayor.getCuentaContableByIdEmpresaActivos(vwur.getIdEmpresa());
														%>
														<select class="form-control js-example-basic-single"
															name="cuenta_contable_IMayor" id="cuenta_contable_IMayor"
															required="required">
															<option value="" disabled selected>Seleccione
																cuenta para activo circulante...</option>
															<%
															for (Vw_catalogo_tipo_cuentacontable cuenta : listaCuentasIngresosMayor) {
															%>
															<option value="<%=cuenta.getIdCuenta()%>"><%=cuenta.getNombreCuenta()%></option>
															<%
															}
															%>
														</select>
													</div>
												</div>

												<div class="col-md-12">
													<div class="card-box table-responsive">
														<div class="text-muted font-13 col-md-12"
															style="text-align: right;"></div>
														<input type="hidden" value="" name="IngresosMayor_Total"
															id="IngresosMayor_Total" />
														<table class="table table-striped jambo_table bulk_action"
															style="width: 100%" id="tbldetIngresosMayor">
															<thead>
																<tr>
																	<th>Opci�n</th>
																	<th>ID Cuenta</th>
																	<th>Nombre cuenta</th>
																</tr>
															</thead>

															<tbody>

															</tbody>

														</table>
													</div>
												</div>

												<div class="ln_solid">
													<div class="form-group">
														<div class="col-md-6">
															<button id="btnAgregarIngresoMayor" type='button'
																class="btn btn-primary">Agregar</button>
														</div>
													</div>
												</div>
											</div>
											<div style="display: inline-block;" class="right">
												<div>
													<div class="col-md-12 col-sm-12">
														<%
														ArrayList<Vw_catalogo_tipo_cuentacontable> listaCuentasIngresosMenor = new ArrayList<Vw_catalogo_tipo_cuentacontable>();
														Dt_cuentaContable dtCuentaIngresosMenor = new Dt_cuentaContable();
														listaCuentasIngresosMenor = dtCuentaIngresosMenor.getCuentaContableByIdEmpresaActivos(vwur.getIdEmpresa());
														%>
														<select class="form-control js-example-basic-single"
															name="cuenta_contable_IngresosMenor" id="cuenta_contable_IngresosMenor"
															required="required">
															<option value="" disabled selected>Seleccione
																cuenta para activo circulante...</option>
															<%
															for (Vw_catalogo_tipo_cuentacontable cuenta : listaCuentasIngresosMenor) {
															%>
															<option value="<%=cuenta.getIdCuenta()%>"><%=cuenta.getNombreCuenta()%></option>
															<%
															}
															%>
														</select>
													</div>
												</div>

												<div class="col-md-12">
													<div class="card-box table-responsive">
														<div class="text-muted font-13 col-md-12"
															style="text-align: right;"></div>
														<input type="hidden" value="" name="IngresosMenor_Total"
															id="IngresosMenor_Total" />
														<table class="table table-striped jambo_table bulk_action"
															style="width: 100%" id="tbldetIngresosMenor">
															<thead>
																<tr>
																	<th>Opci�n</th>
																	<th>ID Cuenta</th>
																	<th>Nombre cuenta</th>
																</tr>
															</thead>

															<tbody>

															</tbody>

														</table>
													</div>
												</div>

												<div class="ln_solid">
													<div class="form-group">
														<div class="col-md-6">
															<button id="btnAgregarIngresosMenor" type='button'
																class="btn btn-primary">Agregar</button>
														</div>
													</div>
												</div>
											</div>
										</div>
										<div class="ln_solid">
											<div class="form-group">
												<div class="col-md-6 offset-md-3">
													<button id="btnGuardarTodo" type='submit'
														class="btn btn-danger">Guardar todo</button>
													<a href="tbl_asientoContable.jsp" type="button"
														class="btn btn-primary">Cancelar</a>
												</div>
											</div>
										</div>
									</form>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
	<!-- /page content -->
	<!-- jQuery -->
	<script src="../vendors/jquery/dist/jquery.min.js"></script>
	<!-- Bootstrap -->
	<script src="../vendors/bootstrap/dist/js/bootstrap.bundle.min.js"></script>
	<!-- FastClick -->
	<script src="../vendors/fastclick/lib/fastclick.js"></script>
	<!-- NProgress -->
	<script src="../vendors/nprogress/nprogress.js"></script>
	<!-- bootstrap-progressbar -->
	<script
		src="../vendors/bootstrap-progressbar/bootstrap-progressbar.min.js"></script>
	<!-- iCheck -->
	<script src="../vendors/iCheck/icheck.min.js"></script>
	<!-- bootstrap-daterangepicker -->
	<script src="../vendors/moment/min/moment.min.js"></script>
	<script src="../vendors/bootstrap-daterangepicker/daterangepicker.js"></script>
	<!-- bootstrap-wysiwyg -->
	<script src="../vendors/bootstrap-wysiwyg/js/bootstrap-wysiwyg.min.js"></script>
	<script src="../vendors/jquery.hotkeys/jquery.hotkeys.js"></script>
	<script src="../vendors/google-code-prettify/src/prettify.js"></script>
	<!-- jQuery Tags Input -->
	<script src="../vendors/jquery.tagsinput/src/jquery.tagsinput.js"></script>
	<!-- Switchery -->
	<script src="../vendors/switchery/dist/switchery.min.js"></script>
	<!-- Select2 -->
	<script src="../vendors/select2/dist/js/select2.full.min.js"></script>
	<!-- Parsley -->
	<script src="../vendors/parsleyjs/dist/parsley.min.js"></script>
	<!-- Autosize -->
	<script src="../vendors/autosize/dist/autosize.min.js"></script>
	<!-- jQuery autocomplete -->
	<script
		src="../vendors/devbridge-autocomplete/dist/jquery.autocomplete.min.js"></script>
	<!-- starrr -->
	<script src="../vendors/starrr/dist/starrr.js"></script>
	<!-- iCheck -->
	<script src="../vendors/iCheck/icheck.min.js"></script>
	<!-- Datatables -->
	<script src="../vendors/datatables.net/js/jquery.dataTables.min.js"></script>
	<script
		src="../vendors/datatables.net-bs/js/dataTables.bootstrap.min.js"></script>
	<script
		src="../vendors/datatables.net-buttons/js/dataTables.buttons.min.js"></script>
	<script
		src="../vendors/datatables.net-buttons-bs/js/buttons.bootstrap.min.js"></script>
	<script src="../vendors/datatables.net-buttons/js/buttons.flash.min.js"></script>
	<script src="../vendors/datatables.net-buttons/js/buttons.html5.min.js"></script>
	<script src="../vendors/datatables.net-buttons/js/buttons.print.min.js"></script>
	<script
		src="../vendors/datatables.net-fixedheader/js/dataTables.fixedHeader.min.js"></script>
	<script
		src="../vendors/datatables.net-keytable/js/dataTables.keyTable.min.js"></script>
	<script
		src="../vendors/datatables.net-responsive/js/dataTables.responsive.min.js"></script>
	<script
		src="../vendors/datatables.net-responsive-bs/js/responsive.bootstrap.js"></script>
	<script
		src="../vendors/datatables.net-scroller/js/dataTables.scroller.min.js"></script>
	<script src="../vendors/jszip/dist/jszip.min.js"></script>
	<script src="../vendors/pdfmake/build/pdfmake.min.js"></script>
	<script src="../vendors/pdfmake/build/vfs_fonts.js"></script>
	<!-- Custom Theme Scripts -->
	<script src="../build/js/custom.min.js"></script>

	<script src="../vendors/jquery.toast.min.js"></script>

	<script>
	$(document).ready(function() {
		$('.js-example-basic-single').select2();
	});
	
	var contadorIngresoMayor = 0; 
	var ingresoMayor = document.getElementById("IngresosMayor_Total");
		$("#btnAgregarIngresoMayor").click(
			function(){
				contadorIngresoMayor++; 
				$("#tbldetIngresosMayor tbody")
				.append(
						"<tr>"
								+ "<td>"
								+ '<input type="button" id="btnBorrarDetalleIngresoMayor" value="Borrar" />'
								+ "</td>"
								+ "<td>"
								+ '<input type="text"  id="IMayor'+contadorIngresoMayor+'" name="IMayor'+contadorIngresoMayor+'" class="form-control col-sm-3" value='
								+ $("#cuenta_contable_IMayor").val()
								+ ' readOnly>'
								+ "</td>"
								+ "<td>"
								+ '<input type="text" class="form-control col-sm-6" value='
								+ $('#cuenta_contable_IMayor option:selected').text()
								+ ' readOnly>'
								+ "</td>");	
				ingresoMayor.value = contadorIngresoMayor; 
			}	
		);
		
		$("#tbldetIngresosMayor").on('click', '#btnBorrarDetalleIngresoMayor', function() {
			var currentRow = $(this).closest("tr");
			$(this).parent().parent().remove();
		});
		
		var contadorIngresoMenor = 0; 
		var ingresoMenor = document.getElementById("IngresosMenor_Total");
			$("#btnAgregarIngresosMenor").click(
				function(){
					contadorIngresoMenor++; 
					$("#tbldetIngresosMenor tbody")
					.append(
							"<tr>"
									+ "<td>"
									+ '<input type="button" id="btnBorrarDetalleIngresoMenor" value="Borrar" />'
									+ "</td>"
									+ "<td>"
									+ '<input type="text"  id="IMenor'+contadorIngresoMenor+'" name="IMenor'+contadorIngresoMenor+'" class="form-control col-sm-3" value='
									+ $("#cuenta_contable_IngresosMenor").val()
									+ ' readOnly>'
									+ "</td>"
									+ "<td>"
									+ '<input type="text" class="form-control col-sm-6" value='
									+ $('#cuenta_contable_IngresosMenor option:selected').text()
									+ ' readOnly>'
									+ "</td>");	
					ingresoMenor.value = contadorIngresoMenor; 
				}	
			);
			
			$("#tbldetIngresosMenor").on('click', '#btnBorrarDetalleIngresoMenor', function() {
				var currentRow = $(this).closest("tr");
				$(this).parent().parent().remove();
			});
	</script>

	<script src="../vendors/select2/dist/js/select2.min.js"></script>


</body>
</html>
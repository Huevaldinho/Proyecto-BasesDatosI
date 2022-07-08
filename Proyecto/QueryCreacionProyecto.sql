

------------------------------------------------------------------------------
--CREACION DE BASE DE DATOS Y TABLAS
------------------------------------------------------------------------------
--CREATE DATABASE Proyecto;
--USE Proyecto;

CREATE TABLE Estado(
	idEstado int primary key not null,
	nombre varchar(30) not null,
	descripcion varchar(100) not null
);
CREATE TABLE Moneda(
	idMoneda int identity(1,1) primary key,
	nombre varchar(30) not null,
	estado int foreign key references Estado(idEstado) not null
);
--Pais
CREATE TABLE Pais(
	--El codigo del pais debera ser de acuerdo con ISO (International Organization for Standardization) 3166-1 numérico
	--Podria ser un identity (1,1) pero prefiero que sea con algo que sea usado a nivel mundial.
	idPais int primary key not null,
	nombre varchar(100) not null, --“The United Kingdom of Great Britain and Northern Ireland” tiene 56 caracteres,
	--si queremos expandir el software a Europa tenemos que pensar en posibles nombres largos.
	moneda int foreign key references Moneda(idMoneda) not null,
	porcentajeImpuestos float not null,
	estado int foreign key references Estado(idEstado) not null
);
--Tipo Evento
CREATE TABLE TipoEvento(
	idTipoEvento int identity(1,1) primary key,
	nombre varchar(20) not null,
	descripcion varchar(100) not null,
	estado int foreign key references Estado(idEstado) not null
);
--Evento
CREATE TABLE Evento(
	idEvento int identity(1,1) primary key,
	nombre varchar(100) not null,
	descripcion varchar (300) not null,
	estado int foreign key references Estado(idEstado) not null,
	idTipoEvento int foreign key references TipoEvento(idTipoEvento) not null
);
--Lugar Evento
CREATE TABLE LugarEvento(
	idLugar int identity(1,1) primary key,
	nombre varchar(50) not null,
	detalleUbicacion varchar(200) not null,
	maximaCantidadPersonas int not null,
	estado int foreign key references Estado(idEstado) not null
);
--Tipo Asiento del Lugar Evento
CREATE TABLE TipoAsiento(
	numeroAsiento int identity(1,1) primary key,
	idLugar int foreign key references LugarEvento(idLugar) not null,
	nombre varchar(30) not null,--VIP, Palco, etc.
	cantidad int not null,--esta cantidad va disminuyendo con forme se vendan
	estado int foreign key references Estado(idEstado) not null
	--al final, la cantidad vendida va a estar en los detalles de cada factura
	--y los que no se vendieron permanecen en esta tabla.
);
--Evento por Pais
CREATE TABLE EventoXPais(
	idLugar int foreign key references LugarEvento(idLugar) not null,
	idEvento int foreign key references Evento(idEvento) not null,
	idPais int foreign key references Pais(idPais) not null,
	primary key (idEvento,idPais)
);
--Fechas Eventos x Pais
--un evento se puede dar en 2 fechas diferentes, ejemplo picnic fue en 2 sabados diferentes.
CREATE TABLE FechaEvento(
	idFecha int identity (1,1) primary key,
	idEvento int foreign key references Evento(idEvento) not null,
	idPais int foreign key references Pais(idPais) not null,
	fechaHora smalldatetime not null, --YYYY-MM-DD hh:mm:ss
	estado int foreign key references Estado(idEstado) not null
);
--Artista/Grupo/Banda
CREATE TABLE Artista(
	idArtista int identity(1,1) primary key,
	nombre varchar(100) not null,
	genero varchar(50) not null,--rock, reggaeton,etc.
	estado int foreign key references Estado(idEstado) not null,
	--ISO 13616
	numeroCuenta varchar(34) not null--para pagarles
);
--Integrantes del Grupo
CREATE TABLE Integrante(
	idIntegrante int identity (1,1) primary key,
	idArtista int foreign key references Artista(idArtista) not null,
	nombre varchar (50) not null,
	primerApellido varchar(50) not null,
	segundoApellido varchar(50) not null,
	estado int foreign key references Estado(idEstado) not null
);
--Artista por Evento
CREATE TABLE ArtistaXEvento(
	fechaHoraIncio smalldatetime not null,--estas fechas y horas deben estar acuerde a la hora de inicio del evento.
	fechaHoraFinalizacion smalldatetime not null,
	idArtista int foreign key references Artista(idArtista) not null,
	idFecha int foreign key references FechaEvento(idFecha)	not null,
	estado int foreign key references Estado (idEstado) not null,
	primary key (idArtista,idFecha)
);
--Tipo de Entrada
CREATE TABLE TipoEntrada(
	idTipoEntrada int identity (1,1) primary key,
	idTipoAsiento int foreign key references TipoAsiento(numeroAsiento) not null,
	recargoTipoServicio float not null,
	precio float not null,--no falta el impuesto porque a todo el mundo se le va a borrar la misma cantidad de impuesto(segun pais).
	estado int foreign key references Estado(idEstado) not null
);
--Entrada
CREATE TABLE Entrada(
	idEntrada int identity(1,1) primary key,
	idFechaEvento int foreign key references FechaEvento(idFecha) not null,
	idTipoEntrada int foreign key references TipoEntrada(idTipoEntrada) not null,
	estado int foreign key references Estado(idEstado) not null
);
--Cliente
CREATE TABLE Cliente(
	idCliente int identity(1,1) primary key,
	nombre varchar(25) not null,
	primerApellido varchar(25) not null,
	segundoApellido varchar(25) not null,
	fechaNacimiento date not null,--algunos eventos son para mayores de edad
	correo varchar(50) not null,--se valida formato en front end.
	telefono int not null,--se valida formato en front end.
	contrasenna varchar(16) not null, --se valida formato en front end.
	estado int foreign key references Estado(idEstado) not null
	--con la direccion del cliente se saca de que pais es.
);
--Direccion de Clientes.
CREATE TABLE DireccionCliente(
	idDireccion int identity(1,1) primary key,
	idCliente int foreign key references Cliente(idCliente) not null,
	idPais int foreign key references Pais(idPais) not null,
	detalleDireccion varchar(200) not null,
	codigoPostal int not null,
	estado int foreign key references Estado(idEstado) not null
);
--Metodo de Pago
CREATE TABLE MetodoPago(
	idMetodoPago int identity(1,1) primary key,
	nombre varchar(25) not null,
	numeroTarjeta int not null,
	fechaVencimiento date not null,
	codigo int not null,
	estado int foreign key references Estado(idEstado) not null
);
--Compra
CREATE TABLE Compra(
	idCompra int identity(1,1) primary key,
	idCliente int foreign key references Cliente(idCliente) not null,
	idMetodoPago int foreign key references MetodoPago(idMetodoPago) not null,
	fecha smalldatetime not null,
	total money default 0 not null,--suma de todos los detalles de esta compra.
	estado int foreign key references Estado(idEstado) not null
);
--Detalle de Compra
CREATE TABLE Detalle(
	idDetalle int identity primary key,
	idCompra int foreign key references Compra(idCompra) not null,
	idEntrada int foreign key references Entrada(idEntrada) not null,
	subtotal money default 0 not null
	--el subtotal debe incluir el precio de la entrada + cargo por servicio + impuestos.
);
--Envio
CREATE TABLE Envio(
	idEnvio int identity(1,1) primary key,
	idCompra int foreign key references Compra(idCompra) not null,
	estado int foreign key references Estado(idEstado) not null,
	envioFisico int not null,--true o false, 0 digital(correo), 1 fisico.
	costoEnvio money default 0,--si es envio fisico debe tener costo envio.
);
--Departamento
CREATE TABLE Departamento (
	idDepartamento int identity (1,1) primary key,
	nombre varchar(25) not null,
	descripcion varchar(200) not null,
	estado int foreign key references Estado(idEstado) not null
);
--Tipo Empleado
CREATE TABLE TipoEmpleado(
	idTipoEmpleado int identity(1,1) primary key,
	nombreTipoEmpleado varchar(25) not null,
	descripcion varchar(200) not null
);
--Empleado
CREATE TABLE Empleado(
	idEmpleado int primary key not null,--#identidad
	idDepartamento int foreign key references Departamento(idDepartamento) not null,
	idJefe int foreign key references Empleado(idEmpleado),
	idTipoEmpleado int foreign key references TipoEmpleado(idTipoEmpleado) not null,
	nombre varchar(25) not null,
	primerApellido varchar(25) not null,
	segundoApellido varchar(25) not null,
	fechaNacimiento date not null,
	correo varchar(50) not null,
	telefono int not null,
	salario money not null,
	contrasenna varchar(16) not null,
	estado int foreign key references Estado(idEstado) not null,
	numeroCuenta varchar(34) not null--para pagarlesr ISO 13616
);
--Medio comunicacion
CREATE TABLE MedioComunicacion(--correo, llamada, pagina web.
	idMedio int identity(1,1) primary key,
	nombreMedio varchar(20) not null,
	estado int foreign key references Estado(idEstado) not null
);
--Solucion comentario cliente
CREATE TABLE Solucion(
	idSolucion int identity (1,1) primary key,
	estado int foreign key references Estado(idEstado) not null,
	reembolso int not null,--1 si y 0 no.
	reemplazo int not null,--1 si y 0 no.
);
--Tipo de Comentario del Cliente
CREATE TABLE TipoComentario(
	idTipoComentario int identity(1,1) primary key,
	nombreTipoComentario varchar(25) not null,
	estado int foreign key references Estado(idEstado) not null
);
--Comentario Cliente
CREATE TABLE Comentario(
	idComentario int identity(1,1) primary key,
	idEntrada int foreign key references Entrada(idEntrada) not null,--la compra tiene las entradas
	--y quien realizo al compra(cliente que hace la queja), tambien tiene el evento.
	idTipoComentario int foreign key references TipoComentario(idTipoComentario) not null,
	idMedio int foreign key references MedioComunicacion(idMedio) not null,
	comentario varchar(200) not null,
	fechaHora smalldatetime not null
);
--Atencion al Cliente
CREATE TABLE AtencionCliente(
	idTicket int identity(1,1) primary key,
	idEmpleado int foreign key references Empleado(idEmpleado) not null,
	idComentario int foreign key references Comentario(idComentario) not null,
	idSolucion int foreign key references Solucion(idSolucion) not null,
	fechaHora smalldatetime not null
);
------------------------------------------------------------------------------



------------------------------------------------------------------------------
--PROCEDIMIENTOS
------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------------------
--CRUD Estado
GO 
CREATE PROCEDURE spEstado @opcion int,@idEstado int, @nombre varchar(30), @descripcion varchar(100) with encryption AS
BEGIN
	declare @error int,@errorMsg varchar(100);
	if (@opcion is null)
		begin
			set @error=1;
			set @errorMsg='Error, debe ingresar el parametro @opcion.%s %d';
			RAISERROR (@errorMsg,16,1,N' Error numero',@error); 
		end
	else--si ingresaron opcion
		begin
			if (@opcion=1)--Insertar
				begin
					if (@idEstado is null)
						begin 
						set @error=3;
							set @errorMsg='Error, debe ingresar el parametro @idEstado.%s %d';
							RAISERROR (@errorMsg,16,1,N' Error numero',@error); 
						end
					
					else if (@nombre is null)
						begin
							set @error=4;
							set @errorMsg='Error, debe ingresar el parametro @nombre.%s %d';
							RAISERROR (@errorMsg,16,1,N' Error numero',@error); 
						end
					else if (@descripcion is null)
						begin
							set @error=5;
							set @errorMsg='Error, debe ingresar el parametro @descripcion.%s %d';
							RAISERROR (@errorMsg,16,1,N' Error numero',@error); 
						end
					else
						begin
							if (select count(*) from Estado where idEstado=@idEstado)>0
								begin--repetido
									set @error=6;
									set @errorMsg='Error, ya existe un estado con el @idEstado ingresado..%s %d';
									RAISERROR (@errorMsg,16,1,N' Error numero',@error); 
								end
							else
								begin
									begin transaction
										insert into Estado(idEstado,nombre,descripcion) values(@idEstado,@nombre,@descripcion);
									commit transaction
								end
						end
				end
			else if (@opcion=2)--consultar
				begin
					if (@idEstado is null)
						begin
							set @error=7;
							set @errorMsg='Error, debe ingresar el parametro @idEstado.%s %d';
							RAISERROR (@errorMsg,16,1,N' Error numero',@error); 
						end
					else
						begin
							if (select count(*) from Estado where idEstado=@idEstado)>0
								begin
									begin transaction
										select nombre, descripcion from Estado where idEstado=@idEstado;
									commit transaction
								end
							else
								begin
									set @error=8;
									set @errorMsg='Error, no existe estado con el @idEstado ingresado..%s %d';
									RAISERROR (@errorMsg,16,1,N' Error numero',@error); 
								end
						end
				end
			else if(@opcion=3)--modificar
				begin
					if (@idEstado is null)
						begin
							set @error=9;
							set @errorMsg='Error, debe ingresar parametro @idEstado.%s %d';
							RAISERROR (@errorMsg,16,1,N' Error numero',@error); 
						end
					else
						begin
							if (@descripcion is not null)
								begin
									if (select count(*) from Estado where idEstado=@idEstado)>0
									begin
										begin transaction
											update Estado set descripcion=@descripcion where idEstado=@idEstado;
										commit transaction
									end
								else
									begin
										set @error=10;
										set @errorMsg='Error, no existe estado con el @idEstado ingresado..%s %d';
										RAISERROR (@errorMsg,16,1,N' Error numero',@error); 
									end
								end
							else	
								begin
									set @error=11;
									set @errorMsg='Error, debe ingresar el parametro @descripcion.%s %d';
									RAISERROR (@errorMsg,16,1,N' Error numero',@error); 
								end
						end
				end
			else if (@opcion =4)--consultar todos los estado
				begin
					begin transaction
						select Estado.idEstado,Estado.nombre,Estado.descripcion from Estado;
					commit transaction
				end
			else
				begin
					set @error=2;
					set @errorMsg='Error, ha ingresado una @opcion invalida.%s %d';
					RAISERROR (@errorMsg,16,1,N' Error numero',@error); 
				end
		end

		--select @error,@errorMsg as message;
		/*
	--Insertar Estado
	exec spEstado null,null,null,null;--Error 1. opcion nula. FUNCIONA
	exec spEstado 54,null,null,null;--Error 2. opcion invalida. FUNCIONA
	exec spEstado 1,null,null,null;--Error 3. id estado nulo. FUNCIONA
	exec spEstado 1,-1,null,null;--Error 4. nombre nulo. FUNCIONA
	exec spEstado 1,-1,'Eliminado',null;--Error 5. descripcion nula. FUNCIONA
	exec spEstado 1,-1,'Eliminado','Se ha borrado de los registros de la base de datos.';--Error 6. estado repetido. FUNCIONA
	--Consultar
	exec spEstado 2,null,null,null;--Error 7. id estado nulo. FUNCIONA
	exec spEstado 2,9,null,null;--Error 8. no existe evento. FUNCIONA
	exec spEstado 2,0,null,null;--Consultar funciona
	--Modificar
	exec spEstado 3,null,null,null;--Error 9. id nulo. FUNCIONA
	exec spEstado 3,10,null,null;--Error 11. id no exsite. FUNCIONA
	exec spEstado 3,10,null,'Hola';--Error 10. no existe id estado.
	exec spEstado 3,0,null,'No se encuentra disponible en este momento.';
	select * from Estado;
	*/

END
GO
--------------------------------------------------------------------------------------------------------
--CRUD Moneda
GO
CREATE PROCEDURE spMoneda @opcion int,@idMoneda int, @nombre varchar(30),@estado int with encryption AS
BEGIN
	declare @error int, @errorMsg varchar(200);
	
	--Validar Opcion
	if (@opcion is null)--No ingresaron la opcion.
		begin
			set @error=1;
			set @errorMsg='Error, debe ingresar el parametro @opcion.%s %d';
			RAISERROR (@errorMsg,16,1,N' Error numero',@error); 

		end
	else--Si ingresaron la opcion.
		begin
		--Opcion 1. Ingresar moneda.
		if (@opcion=1)
			begin
				--Primero validar que el nombre no sea nulo.
				if (@nombre is not null)
					begin--Si insertaron el nombre.
						if(select count(*) from Moneda where nombre=@nombre)>0--Validar que no este repetido.
							begin--Esta repetido
								set @error=3;
								set @errorMsg='Error, ha ingresado un nombre de moneda que ya esta registrado.%s %d'
								RAISERROR (@errorMsg,16,1,N' Error numero',@error); 
							end
						else--NO esta repetido, se puede insertar.
							begin
								--valida que exista el estado activo
								if (select count(*) from Estado where idEstado=1)>0
									begin
										--Insertar.
										begin transaction
										--El id se genera automaticamente.
									
											insert into Moneda(nombre,estado) values(@nombre,1);--estado 1 (activo) por defecto

										commit transaction
									end
							end
					end
				else--El nombre es nulo.
					begin
						set @error=2;
						set @errorMsg='Error, debe ingresar el parametro @nombre.%s %d';
						RAISERROR (@errorMsg,16,1,N' Error numero',@error); 
					end
			end
		--Opcion 2. Consultar moneda.
		else if (@opcion=2)
			begin
				--Validar que el parametro id no sea nulo.
				if (@idMoneda is not null)
					begin--Si insertaron el id.
						if (select count(*) from Moneda where idMoneda=@idMoneda)>0
							begin--Si existe moneda con ese id.
								select Moneda.idMoneda, Moneda.nombre,Estado.nombre as estado from Moneda inner join 
								Estado on Estado.idEstado=Moneda.idMoneda where idMoneda=@idMoneda;
							end
						else--No existe moneda con el @idMoneda ingresado.
							begin
								set @error=5;
								set @errorMsg='Error, no existe moneda con el @idMoneda ingresado. %s %d';
								RAISERROR (@errorMsg,16,1,N' Error numero',@error); 
							end
					end
				else--Parametro id es nulo.
					begin
						set @error=4;
						set @errorMsg='Error, debe ingresar el parametro @idMoneda para consultar su nombre.%s %d';
						RAISERROR (@errorMsg,16,1,N' Error numero',@error); 
					end
			end
		--Opcion 3. Modificar moneda (no se puede modificar el id de la moneda).
		else if (@opcion=3)
			begin
				--Validar que el parametro @idMoneda y @nombre no sean nulos.
				--@nombre sera el nuevo nombre de la moneda.
				if (@idMoneda is not null)
					begin--Si ingresaron el @idMoneda.
						if (@nombre is not null)
							begin--Si ingresaron el nombre.

								--Validar que exista el @idMoneda
								if (select count(*) from Moneda where idMoneda=@idMoneda)>0
									begin--Si existe la moneda que se quiere modificar.

									if (@estado is not null)
										begin
											if (select count(*) from Estado where idEstado=@estado)>0
												begin
													update Moneda set estado=@estado where idMoneda=@idMoneda;
												end
											else
												begin
													set @error=13;
													set @errorMsg='Error, no existe estado con el @estado ingresado. %s %d';
													RAISERROR (@errorMsg,16,1,N' Error numero',@error); 
												end
										end
										--Validar que el nombre a modificar no este registrado.
										if (select count(*) from Moneda where nombre=@nombre)>0
											begin--Ya hay una moneda con ese nombre
												set @error=9;
												set @errorMsg='Error, ya existe una moneda con el @nombre ingresado. %s %d';
												RAISERROR (@errorMsg,16,1,N' Error numero',@error); 
											end
										else--No existe moneda con ese nombre. Se puede modificar.
											begin	
												update Moneda set nombre = @nombre where idMoneda=@idMoneda;
											end
									end
								else 
									begin
										set @error=8;
										set @errorMsg='Error, no existe moneda con el @idMoneda ingresado. %s %d';
										RAISERROR (@errorMsg,16,1,N' Error numero',@error); 
									end
							end
						else--No ingresaron el @nombre.
							begin
								set @error=7;
								set @errorMsg='Error, debe ingresar el parametro @nombre para modificar la moneda.%s %d';
								RAISERROR (@errorMsg,16,1,N' Error numero',@error); 
							end

					end
				else--No ingresaron el @idMoneda.
					begin
						set @error=6;
						set @errorMsg='Error, debe ingresar el parametro @idMoneda para modificar la moneda.%s %d';
						RAISERROR (@errorMsg,16,1,N' Error numero',@error); 
					end
			end
		--Opcion 4. Eliminar moneda (se cambia de estado.).
		else if (@opcion=4)
			begin

			--Validar que el parametro @id no sea nulo.
			if (@idMoneda is not null)
				begin--No es nulo
				--Validar que exista el @id.
				if (select count(*) from Moneda where idMoneda=@idMoneda)>0
					begin--Si existe moneda
						begin transaction
							update Moneda set estado=-1 where idMoneda=@idMoneda;
						commit transaction
					end
				else--No existe
					begin
						set @error=12;
						set @errorMsg='Error, no existe moneda con el @idMoneda ingresado. %s %d';
						RAISERROR (@errorMsg,16,1,N' Error numero',@error); 
					end
				end
			else--Parametro id moneda es nulo
				begin
					set @error=11;
					set @errorMsg='Error, debe ingresar el parametro @idMoneda %s %d';
					RAISERROR (@errorMsg,16,1,N'error numero',@error); 

				end
			end
		else if (@opcion=5)--consultar todas las monedas
			begin
				begin transaction
					select Moneda.idMoneda,Moneda.nombre,Estado.nombre as estado from Moneda inner join
					Estado on Estado.idEstado=Moneda.estado;
				commit transaction
			end
		else--Ingresaron un numero de opcion incorrecto.
			begin
				set @error=10;
				set @errorMsg='Error, ha ingresado una opcion incorrecta.%s %d';
				RAISERROR (@errorMsg,16,1,N' Error numero',@error); 
				
			end
		end
		/*
--Prueba insertar 
exec spMoneda null,null,'Dolar',null;--Error 1 - Opcion nula. FUNCIONA
exec spMoneda 1,null,null,null;--Error 2 - Nombre nulo. FUNCIONA
exec spMoneda 1,null,'Colón',null;--Error 3 - Nombre repetido. FUNCIONA
--Consultar
exec spMoneda 2,1,null,null;--Consulta colon -  FUNCIONA
exec spMoneda 2,2,null,null;--Consulta colon -  FUNCIONA
exec spMoneda 2,null,'Hola',null;--Error 4 - id nulo. FUNCIONA
exec spMoneda 2,15,'Hola',null;--Error 5 - id no existe.
--Modificar
exec spMoneda 3,null,'Hola',null;--Error 6 - id nulo. FUNCIONA
exec spMoneda 3,2,null,null;--Error 7 - nombre nulo. FUNCIONA
exec spMoneda 3,45,'hola',null;--Error 8 - no existe moneda con id 45. FUNCIONA
--Eliminar
exec spMoneda 4,null,'hola',null;--Error 11 - id nulo. FUNCIONA
exec spMoneda 4,45,'hola',null;--Error 12 - no existe moneda con id 45. FUNCIONA
--Todo bien

select * from Estado;
select Moneda.idMoneda,Moneda.nombre,Estado.nombre as estado from Moneda inner join Estado on Moneda.estado=Estado.idEstado;

*/
END
GO
------------------------------------------------------------------------------
--CRUD Pais
GO
CREATE PROCEDURE spPais @opcion int,@idPais int ,@idMoneda int, @nombre varchar(100), @porcentajeImpuestos float, @estado int with encryption AS
BEGIN
	declare @error int, @errorMsg varchar(100);
	--Validar opcion
	if (@opcion is null)
		begin
			set @error=1;
			set @errorMsg='Error, debe ingresar el parametro @opcion.%s %d';
			RAISERROR (@errorMsg,16,1,N' Error numero',@error); 
		end
	else--Si ingresaron opcion
		begin
			--Opcion 1. Ingresar Pais.
			if (@opcion=1)
				begin
					--Validar nulos.
					if (@idPais is null)begin
							set @error=2;
							set @errorMsg='Error, debe ingresar el parametro @idPais.%s %d';
							RAISERROR (@errorMsg,16,1,N' Error numero',@error); end
					else if (@idMoneda is null)begin
							set @error=3;
							set @errorMsg='Error, debe ingresar el parametro @idMoneda.%s %d';
							RAISERROR (@errorMsg,16,1,N' Error numero',@error); end
					else if (@nombre is null)begin
							set @error=4;
							set @errorMsg='Error, debe ingresar el parametro @nombre.%s %d';
							RAISERROR (@errorMsg,16,1,N' Error numero',@error); end
					else if (@porcentajeImpuestos is null)begin 
							set @error=5;
							set @errorMsg='Error, debe ingresar el parametro @porcentajeImpuestos.%s %d';
							RAISERROR (@errorMsg,16,1,N' Error numero',@error); end
					else--No hay nulos, han ingresado todo.
						begin
							--Validar que exista la moneda.
							if (select count(*) from Moneda where idMoneda=@idMoneda)>0
								begin--si existe la moneda

									--Validar si esta repetido.
									if (select count(*) from Pais where idPais=@idPais)>0
										begin--id pais repetido
											set @error=7;
											set @errorMsg='Error, ya existe un pais con el @idPais ingresado.%s %d';
											RAISERROR (@errorMsg,16,1,N' Error numero',@error); 
										end
									else--id disponible 
										begin
											--Validar que el porcentaje de impuestos sea mayor que 0.
											if (@porcentajeImpuestos>0)
												begin
													--Insertar
													begin transaction

														insert into Pais(idPais,nombre,moneda,porcentajeImpuestos,estado) values
																		(@idPais,@nombre,@idMoneda,@porcentajeImpuestos,1);

													commit transaction
												end
											else--porcentaje de impuestos menor que 0
												begin
													set @error=8;
													set @errorMsg='Error, debe ingresar un porcentaje de impuestos mayor que cero.%s %d';
													RAISERROR (@errorMsg,16,1,N' Error numero',@error); 		
												end
										end
								end
							else 
								begin
									set @error=6;
									set @errorMsg='Error, no existe moneda con el @idMoneda ingresado.%s %d';
									RAISERROR (@errorMsg,16,1,N' Error numero',@error); 
								end
						end
				end
			--Opcion 2. Consultar.
			else if (@opcion=2)
				begin
					--Validar nulos.
					if (@idPais is null)
						begin--id pais nulo.
							set @error=9;
							set @errorMsg='Error, debe ingresar @idPais para consultar.%s %d';
							RAISERROR (@errorMsg,16,1,N' Error numero',@error); 		
						end
					else--si ingresaron id pais.
						begin
							--Validar que exista el pais.
							if (select count(*) from Pais where idPais=@idPais)>0
								begin
									begin transaction
										--Consulta segun id pais.
										select Pais.idPais,Pais.nombre,Moneda.nombre as moneda, Pais.porcentajeImpuestos,
											Estado.nombre as estado from Pais inner join Moneda on Moneda.idMoneda=Pais.moneda inner join
											Estado on Estado.idEstado = Pais.estado
											where idPais=@idPais;
										
									commit transaction
								end
							else--no existe pais con ese id
								begin
									set @error=10;
									set @errorMsg='Error, no existe pais con el @idPais ingresado.%s %d';
									RAISERROR (@errorMsg,16,1,N' Error numero',@error); 		
								end
						end
				end
			--Opcion 3. Modificar.
			else if (@opcion=3)
				begin
					--Validar nulos.
					if (@idPais is null)begin
						set @error=11;
						set @errorMsg='Error, debe ingresar el parametro @idPais.%s %d';
						RAISERROR (@errorMsg,16,1,N' Error numero',@error); end
					else--Si ingresaron id pais y porcentaje.
						begin
							--Validar que existe el pais.
							if (select count(*) from Pais where idPais=@idPais)>0
								begin--si existe el pais
									--Validar que el porcentaje se mayor que 0.
									if (@porcentajeImpuestos is not null)
										begin
											if (@porcentajeImpuestos>0)
												begin
													begin transaction 
														update Pais set porcentajeImpuestos = @porcentajeImpuestos where idPais=@idPais;
													commit transaction
												end
											else
												begin
													set @error=20;
													set @errorMsg='Error, debe ingresar un @porcentajeImpuestos >0.%s %d';
													RAISERROR (@errorMsg,16,1,N' Error numero',@error); 
												end
										end
									if (@estado is not null)
										begin
											if (select count(*) from Estado where idEstado=@estado)>0
												begin
													begin transaction
													update Pais set estado=@estado where idPais=@idPais;
													commit transaction
												end
											else
												begin
													set @error=19;
													set @errorMsg='Error, no existe estado con el @estado ingresado.%s %d';
													RAISERROR (@errorMsg,16,1,N' Error numero',@error); 
												end
										end
								end
							else
								begin
									set @error=13;
									set @errorMsg='Error, no existe pais con el @idPais ingresado.%s %d';
									RAISERROR (@errorMsg,16,1,N' Error numero',@error);
								end
						end
				end
			--Opcion 4. Eliminar.
			else if (@opcion=4)
				begin
					--Validar nulos
					if (@idPais is null)begin
						set @error=14;
						set @errorMsg='Error, debe ingresar el parametro @idPais.%s %d';
						RAISERROR (@errorMsg,16,1,N' Error numero',@error); end
					else--Si ingresaron id pais.
						begin
							--Validar que exista el pais.
							if (select count(*) from Pais where idPais=@idPais)>0
								begin--Si existe
									begin transaction
										--No se elimina, se cambia el estado a inactivo.
										update Pais set estado=-1 where idPais=@idPais;
									commit transaction
								end
							else--no existe pais
								begin
									set @error=15;
									set @errorMsg='Error, no existe pais con el @idPais ingresado.%s %d';
									RAISERROR (@errorMsg,16,1,N' Error numero',@error); end
						end
				end
			--Opcion 5. Reactivar pais.
			else if (@opcion=5) 
				begin
					--Validar nulos.
					if (@idPais is null)begin
						set @error=16;
						set @errorMsg='Error, debe ingresar el parametro @idPais.%s %d';
						RAISERROR (@errorMsg,16,1,N' Error numero',@error); end
					else --si ingresaron id pais
						begin
							--Validar que exista el pais.
							if (select count(*) from Pais where idPais=@idPais)>0
								begin--si existe
									--Validar que este inactivo
									if (select count(*) from Pais where idPais=@idPais)>0
										begin--si esta inactivo
											begin transaction
												
												update Pais set estado=1 where idPais=@idPais;
												
											commit transaction
										end
									else--no esta inactivo.
										begin 
											set @error=18;
											set @errorMsg='Error, el pais con @idPais esta ACTIVO.%s %d';
											RAISERROR (@errorMsg,16,1,N' Error numero',@error); 
										end
								end
							else
								begin
									set @error=17;
									set @errorMsg='Error, no existe pais con el @idPais ingresado.%s %d';
									RAISERROR (@errorMsg,16,1,N' Error numero',@error); 
								end
						end

				end
			else if (@opcion=6)--consultar todos los paises.
				begin
					begin transaction
						select Pais.idPais,Pais.nombre,Pais.porcentajeImpuestos,Pais.moneda,Pais.estado	as estado from Pais;
					commit transaction
				end
			else --Ingresaron opcion invalida
				begin
					set @error=2;
					set @errorMsg='Error, debe ingresar una opcion valida.%s %d';
					RAISERROR (@errorMsg,16,1,N' Error numero',@error); 		
				end
		end
			/*
	--Insertar
	exec spPais null,null, null,null,null,null;--Error 1. Opcion nula. FUNCIONA
	exec spPais 1,null,1,'Costa Rica',13,null;--Error 2. id pais nulo. FUNCIONA
	exec spPais 1,188,null,'Costa Rica',13,null;--Error 3. id moneda nula. FUNCIONA
	exec spPais 1,188,1,null,13,null;--Error 4. nombre nulo. FUNCIONA
	exec spPais 1,188,1,'Costa Rica',null,null;--Error 5. porcentaje nulo. FUNCIONA
	exec spPais 1,188,15,'Costa Rica',13,null;--Error 6. no existe moneda con el id 15. FUNCIONA
	exec spPais 1,188,1,'Costa Rica',13,null;--Error 7. pais repetido.
	exec spPais 1,3,1,'Japon',0,null;--Error 8. porcentaje menor a 0
	--Consultar
	exec spPais 2,null,null,null,null,null;--Error 9. id pais nulo. FUNCIONA
	exec spPais 2,7,null,null,null,null;--Error 10. id pais no existe. FUNCIONA
	exec spPais 2,604,null,null,null,null;--Consultar funciona.
	exec spPais 2,484,null,null,null,null;--Consultar funciona.
	--Modificar
	exec spPais 3,null,null,null,null,null;--Error 11. id pais nulo. FUNCIONA
	exec spPais 3,7,null,null,5,null;--Error 13. id pais no existe. FUNCIONA
	exec spPais 3,604,null,null,null,-5;--Error 19. no existe estado con el -5. FUNCIONA.
	exec spPais 3,604,null,null,-250,2;--Error 20. porcentaje menor que 0. FUNCIONA
	exec spPais 3,604,null,null,5,2;--Modificar funciona
	exec spPais 3,604,null,null,15,1;--Modificar funciona
	--Eliminar
	exec spPais 4,null,null,null,null,null;--Error 14. id pais nulo. FUNCIONA
	exec spPais 4,7,null,null,null,null;--Error 15. no existe pais con id 7. FUNCIONA
	exec spPais 4,604,null,null,null,null;--Eliminar funciona
	--Reactivar
	exec spPais 5,null,null,null,null,null;--Error 16. id pais nulo. FUNCIONA
	exec spPais 5,7,null,null,null,null;--Error 17. no existe pais con id 7. FUNCIONA
	exec spPais 5,604,null,null,null,null;--Reactivar funciona

	select * from Pais;
	select * from Moneda;
	*/

END
GO
------------------------------------------------------------------------------
--CRUD Tipo Evento
GO
CREATE PROCEDURE spTipoEvento @opcion int, @idTipoEvento int,@nombre varchar(20), @descripcion varchar(100),@estado int with encryption AS
BEGIN
	declare @error int,@errorMsg varchar (100);

	--Validar opcion
	if (@opcion is null)
		begin
			set @error=1;
			set @errorMsg='Error, debe ingresar el parametro @opcion.%s %d';
			RAISERROR (@errorMsg,16,1,N' Error numero',@error); 
		end
	else--si ingresaron opcion
		begin
			--Opcion 1. Insertar
			if (@opcion=1)
				begin
					--Validar nulos
					if (@nombre is null)begin
						set @error=3;
						set @errorMsg='Error, debe ingresar el parametro @nombre.%s %d';
						RAISERROR (@errorMsg,16,1,N' Error numero',@error);end
					else if (@descripcion is null)begin
						set @error=4;
						set @errorMsg='Error, debe ingresar el parametro @descripcion.%s %d';
						RAISERROR (@errorMsg,16,1,N' Error numero',@error);end
					else--si ingresaron parametros
						begin
							--Validar repetidos
							if (select count(*) from TipoEvento where nombre=@nombre)>0
								begin--nombre repetido
									set @error=5;
									set @errorMsg='Error, ya existe un TipoEvento con el @nombre ingresado.%s %d';
									RAISERROR (@errorMsg,16,1,N' Error numero',@error);end
							else--nombre disponible
								begin
									if (select count(*) from Estado where idEstado=1)>0
										begin--si existe el estado activo
											begin transaction

												insert into TipoEvento(nombre,descripcion,estado) values
																		(@nombre,@descripcion,1);

											commit transaction
										end
										else	
											begin
												set @error=15;
												set @errorMsg='Error, no existe estado activo.%s %d';
												RAISERROR (@errorMsg,16,1,N' Error numero',@error);
											end
								end
						end
				end
			--Opcion 2. Consultar
			else if (@opcion=2)
				begin
					--Validar nulo
					if (@idTipoEvento is null)
						begin
							set @error=6;
							set @errorMsg='Error, debe ingresar el parametro @idTipoEvento.%s %d';
							RAISERROR (@errorMsg,16,1,N' Error numero',@error);
						end
					else
						begin
							--Validar que existe
							if (select count(*) from TipoEvento where idTipoEvento=@idTipoEvento)>0
								begin--si existe
									begin transaction

										select TipoEvento.idTipoEvento,TipoEvento.nombre,TipoEvento.descripcion,Estado.nombre as estado
										from TipoEvento inner join Estado on idEstado=TipoEvento.estado where idTipoEvento=@idTipoEvento;

									commit transaction
								end
							else
								begin
									set @error=7;
									set @errorMsg='Error, no existe TipoEvento con el @idTipoEvento ingresado.%s %d';
									RAISERROR (@errorMsg,16,1,N' Error numero',@error);
								end
						end
				end
			--Opcion 3. Modificar
			--solo se puede modificar la descripcion.
			else if (@opcion=3)
				begin
					--Validar nulos
					if (@idTipoEvento is null)
						begin
							set @error=8;
							set @errorMsg='Error, debe ingresar parametro @idTipoEvento.%s %d';
							RAISERROR (@errorMsg,16,1,N' Error numero',@error);
						end
					else--si ingresaron parametros
						begin
							--validar que exista el tipo de evento
							if (select count(*) from TipoEvento where idTipoEvento=@idTipoEvento)>0
								begin--si existe
									if (@descripcion is not null)
										begin
											begin transaction
										
												update TipoEvento set descripcion=@descripcion where idTipoEvento=@idTipoEvento;

											commit transaction
										end
								
								if (@estado is not null)
									begin
										if (select count(*) from Estado where idEstado=@estado)>0
											begin
												begin transaction
													update TipoEvento set estado=@estado where idTipoEvento=@idTipoEvento;
												commit transaction
											end
										else
											begin
												set @error=15;
												set @errorMsg='Error, estado con el @estado ingresado.%s %d';
												RAISERROR (@errorMsg,16,1,N' Error numero',@error);									
											end
									end
								end
							else--no existe
								begin
									set @error=10;
									set @errorMsg='Error, no existe TipoEvento con el @idTipoEvento ingresado.%s %d';
									RAISERROR (@errorMsg,16,1,N' Error numero',@error);
								end
						end
				end
			--Opcion 4. Eliminar
			else if (@opcion=4)
				begin
					--validar nulo
					if (@idTipoEvento is null)begin
							set @error=11;
							set @errorMsg='Error, debe ingresar el parametro @idTipoEvento.%s %d';
							RAISERROR (@errorMsg,16,1,N' Error numero',@error);end
					else--si ingresaron id tipo evento
						begin--validar que exista
							if (select count(*) from TipoEvento where idTipoEvento=@idTipoEvento)>0
								begin--si existe
									begin transaction
										
										update TipoEvento set estado=-1 where idTipoEvento=@idTipoEvento;

									commit transaction
								end
							else--no existe
								begin
									set @error=12;
									set @errorMsg='Error, no existe TipoEvento con el @idTipoEvento ingresado.%s %d';
									RAISERROR (@errorMsg,16,1,N' Error numero',@error);
								end
						end
				end
			--Opcion 5. Reactivar
			else if (@opcion=5)
				begin
					--validar nulo
					if (@idTipoEvento is null)begin
							set @error=13;
							set @errorMsg='Error, debe ingresar el parametro @idTipoEvento.%s %d';
							RAISERROR (@errorMsg,16,1,N' Error numero',@error);end
					else--si ingresaron id tipo evento
						begin--validar que exista
							if (select count(*) from TipoEvento where idTipoEvento=@idTipoEvento)>0
								begin--si existe
									begin transaction
										
										update TipoEvento set estado=1 where idTipoEvento=@idTipoEvento;

									commit transaction
								end
							else--no existe
								begin
									set @error=14;
									set @errorMsg='Error, no existe TipoEvento con el @idTipoEvento ingresado.%s %d';
									RAISERROR (@errorMsg,16,1,N' Error numero',@error);
								end
						end
				end
			else if (@opcion=6)--consultar todos los tipos de eventos
				begin
					begin transaction
					select idTipoEvento,nombre,descripcion,estado from TipoEvento;
					commit transaction
				end
			else--opcion invalida
				begin
					set @error=2;
					set @errorMsg='Error, no existe @opcion ingresada.%s %d';
					RAISERROR (@errorMsg,16,1,N' Error numero',@error); 
				end
		end

			/*
	--Insertar
	exec spTipoEvento null,null,null,null,null;--Error 1. opcion nula. FUNCIONA
	exec spTipoEvento 100,null,null,null,null;--Error 2. opcion invalida. FUNCIONA
	exec spTipoEvento 1,null,null,null,null;--Error 3. nombre nulo. FUNCIONA
	exec spTipoEvento 1,1,'Concierto',null,null;--Error 4. descripcion nula. FUNCIONA
	exec spTipoEvento 1,1,'Concierto','hola',null;--Error 5. nombre repetido. FUNCIONA

	--Consultar
	exec spTipoEvento 2,null,null,null,null;--Error 6. idTipoEvento nulo. FUNCIONA
	exec spTipoEvento 2,4,null,null,null;--Error 7. no existe tipo evento con id 4.
	exec spTipoEvento 2,1,null,null,null;--Consultar funciona
	--Modificar
	exec spTipoEvento 3,null,null,null,null;--Error 8. id tipo evento nulo. FUNCIONA
	exec spTipoEvento 3,1,null,null,20;--Error 15. no existe estado 20. FUNCIONA
	exec spTipoEvento 3,1,null,null,1;--Error 15. no existe estado 20. FUNCIONA
	--Eliminar 
	exec spTipoEvento 4,null,null,null,null;--Error 11. id tipo evento nulo. FUNCIONA
	exec spTipoEvento 4,7,null,null,null;--Error 12. no existe tipo evento con id 7. FUNCIONA
	exec spTipoEvento 4,1,null,null,null;--Eliminar funciona
	--Reactivar
	exec spTipoEvento 5,null,null,null,null;--Erro 13. id tipo evento nulo.
	exec spTipoEvento 5,7,null,null,null;--Error 14. no existe tipo evento con id 7
	exec spTipoEvento 5,1,null,null,null;--Reactivar funciona

	select * from TipoEvento;
	*/

END
GO
---------------------------------------------------------------------------------------
--CRUD Evento
GO
CREATE PROCEDURE spEvento @opcion int, @idEvento int, @idTipoEvento int,@nombre varchar(100),@descripcion varchar(300),@estado int
	with encryption AS
BEGIN
	declare @error int, @errorMsg varchar(100);
	--Validar opcion 
	if (@opcion is null)
		begin--opcion nula
			set @error=1;
			set @errorMsg='Error, debe ingresar el parametro @opcion.%s %d';
			RAISERROR (@errorMsg,16,1,N' Error numero',@error); 
		end
	else--si ingresaron opcion
		begin
			--Opcion 1. Insertar
			if (@opcion=1)
				begin
					--Validar nulos
					if (@idTipoEvento is null)begin
						set @error=3;
						set @errorMsg='Error, debe ingresar el parametro @idTipoEvento.%s %d';
						RAISERROR (@errorMsg,16,1,N' Error numero',@error); end
					else if (@nombre is null)begin
						set @error=4;
						set @errorMsg='Error, debe ingresar el parametro @nombre.%s %d';
						RAISERROR (@errorMsg,16,1,N' Error numero',@error);end
					else if (@descripcion is null)begin
						set @error=5;
						set @errorMsg='Error, debe ingresar el parametro @descripcion.%s %d';
						RAISERROR (@errorMsg,16,1,N' Error numero',@error);end
					else --Si ingresaron parametros necesarios
						begin
							--Validar que existan llaves foraneas
							if (select count(*) from TipoEvento where idTipoEvento=@idTipoEvento)>0
								begin--si existe llave foranea
									--Validar que no este repetido
									if (select count(*) from Evento where nombre=@nombre)>0
										begin--nombre evento repetido
											set @error=7;
											set @errorMsg='Error, ya existe un evento con el @nombre ingresado.%s %d';
											RAISERROR (@errorMsg,16,1,N' Error numero',@error);end		
									else--insertar
										begin
										begin transaction			

											insert into Evento(nombre,descripcion,estado,idTipoEvento) values
																(@nombre,@descripcion,1,@idTipoEvento);

										commit transaction
										end
								end
							else--no existe llave foranea
								begin
									set @error=6;
									set @errorMsg='Error, no existe TipoEvento con el @idTipoEvento ingresado.%s %d';
									RAISERROR (@errorMsg,16,1,N' Error numero',@error);end
						end
				end
			--Opcion 2. Consultar
			else if (@opcion=2)
				begin
					--Validar nulos
					if (@idEvento is null)
						begin
							set @error=8;
							set @errorMsg='Error, debe ingresar el parametro @idEvento.%s %d';
							RAISERROR (@errorMsg,16,1,N' Error numero',@error);
						end
					else--si ingresaron idEvento
						begin
							--Validar que exista
							if (select count(*) from Evento where idEvento=@idEvento)>0
								begin--si existe
									begin transaction

										select Evento.idEvento,Evento.nombre,Estado.nombre as estado,TipoEvento.nombre as tipoEvento,
											Evento.descripcion from Evento inner join Estado on Estado.idEstado=Evento.estado 
											inner join TipoEvento on TipoEvento.idTipoEvento=Evento.idTipoEvento
											where idEvento=@idEvento;

									commit transaction
								end
							else--no existe
								begin
									set @error=9;
									set @errorMsg='Error, no existe evento con el @idEvento ingresado.%s %d';
									RAISERROR (@errorMsg,16,1,N' Error numero',@error);		
								end
						end
				end
			--Opcion 3. Modificar
			else if (@opcion=3)
				begin
					--modificar estado y descripcion
					--Validar nulos
					if (@idEvento is null)
						begin
							set @error=10;
							set @errorMsg='Error, debe ingresar el parametro @idEvento.%s %d';
							RAISERROR (@errorMsg,16,1,N' Error numero',@error);		
						end
					else --si ingresaron id evento
						begin
							--validar que existe
							if (select count(*) from Evento where idEvento=@idEvento)>0
								begin--si existe
									--hacer cambios si no son nulos.
									begin transaction
										begin try
										if (@estado is not null)
											begin
												if (select count(*) from Estado where idEstado=@estado)>0
													begin
														begin transaction
															update Evento set estado=@estado where idEvento=@idEvento;
														commit transaction
													end
												else
													begin
														set @error=14;
														set @errorMsg='Error, estado con el @estado ingresado.%s %d';
														RAISERROR (@errorMsg,16,1,N' Error numero',@error);	
													end
											end
										if (@descripcion is not null)
											begin
												update Evento set descripcion=@descripcion where idEvento=@idEvento;
											end
									commit transaction
										end try
										begin catch
											rollback;
										end catch
								end
							else--no exsite
								begin
									set @error=11;
									set @errorMsg='Error,no existe evento con el @idEvento ingresado.%s %d';
									RAISERROR (@errorMsg,16,1,N' Error numero',@error);		
								end
						end
				end
			--Opcion 4. Eliminar, se podria hacer en modificar pero para mantener orden se hace la opcion como tal de eliminar.
			else if (@opcion=4)
				begin
					--Validar nulo
					if (@idEvento is null)
						begin
							set @error=12;
							set @errorMsg='Error, debe ingresar el parametro @idEvento.%s %d';
							RAISERROR (@errorMsg,16,1,N' Error numero',@error);		
						end
					else--si ingresaron id evento
						begin
							--Validar que existe
							if (select count(*) from Evento where idEvento=@idEvento)>0
								begin--si existe
									begin transaction 
										update Evento set estado=-1 where idEvento=@idEvento;
									commit transaction
								end
							else--no existe
								begin
									set @error=13;
									set @errorMsg='Error, no existe evento con el @idEvento ingresado.%s %d';
									RAISERROR (@errorMsg,16,1,N' Error numero',@error);	
								end
						end
				end
			else if (@opcion=5)--Consultar todos los eventos
				begin
					begin transaction
						select Evento.idEvento,Evento.nombre,Evento.descripcion,Evento.idTipoEvento,Evento.idTipoEvento from Evento;
					commit transaction
				end
			else
				begin
					set @error=2;
					set @errorMsg='Error, debe ingresar una opción válida.%s %d';
					RAISERROR (@errorMsg,16,1,N' Error número',@error); 
				end
		end

			/*
	--Insertar
	exec spEvento null,null,null,null,null,null;--Error 1. opcion nula. FUNCIONA
	exec spEvento 7,null,null,null,null,null;--Error 2. opcion invalida. FUNCIONA
	exec spEvento 1,null,null,null,null,null;--Error 3. idTipoEvento nulo. FUNCIONA
	exec spEvento 1,null,1,null,null,null;--Error 4. nombre nulo. FUNCIONA
	exec spEvento 1,null,1,'Bad Bunny',null,null;--Error 5. descripcion nula. FUNCIONA
	exec spEvento 1,null,5,'Bad Bunny','',null;--Error 6. no existe id tipo evento. FUNCIONA
	exec spEvento 1,null,1,'Bad Bunny','LAS ZONAS LA PLAYA Y LA FIESTA SOLO PARA MAYORES DE 18 AÑOS ',null;--Error 7. nombre repetido. FUNCIONA
	--Consultar
	exec spEvento 2,null,null,null,null,null;--Error 8. id evento nulo. FUNCIONA
	exec spEvento 2, 7,null,null,null,null;--Erro 9. evento no existe. FUNCIONA
	exec spEvento 2,1,null,null,null,null;--Consultar funciona
	--Modificar 
	exec spEvento 3,null,null,null,null,null;--Error 10. id evento nulo. FUNCIONA
	exec spEvento 3,6,null,null,null,null;--Error 11. evento no existe. FUNCIONA
	exec spEvento 3,1,null,null,'Evento del conojo malo',3;--Funciona con los dos parametros
	exec spEvento 3,1,null,null,'Evento del conojo malo 2',null;--Funciona con solo descripcion
	exec spEvento 3,1,null,null,null,1;--Funciona con solo estado
	exec spEvento 3,1,null,null,'LAS ZONAS LA PLAYA Y LA FIESTA SOLO PARA MAYORES DE 18 AÑOS ',null;--Funciona con solo descripcion
	--Eliminar
	exec spEvento 4,null,null,null,null,null;--Error 12. id evento nulo. FUNCIONA
	exec spEvento 4,6,null,null,null,null;--Error 13. evento no existe. FUNCIONA
	exec spEvento 4,1,null,null,null,null;--Elimiar funciona

	select * from TipoEvento;
	select * from Evento;
	*/

END
GO
---------------------------------------------------------------------------
--CRUD Artista
GO
CREATE PROCEDURE spArtista @opcion int,@idArtista int, @nombre varchar(100),@genero varchar(50),
						   @estado int, @numeroCuenta varchar(34) with encryption AS
BEGIN
	declare @error int, @errorMsg varchar(100);
	--Validar opcion 
	if (@opcion is null)
		begin
			set @error=1;
			set @errorMsg='Error, debe ingresar el parametro @opcion.%s %d';
			RAISERROR (@errorMsg,16,1,N' Error numero',@error); 
		end
	else--si ingresaron opcion
		begin
			--Opcion 1. Insertar
			if (@opcion=1)
				begin
					--Validar nulos
					if (@nombre is null)
						begin
							set @error=3;
							set @errorMsg='Error, debe ingresar el parametro @nombre.%s %d';
							RAISERROR (@errorMsg,16,1,N' Error numero',@error); 
						end
					else if (@genero is null)
						begin
							set @error=4;
							set @errorMsg='Error, debe ingresar el parametro @genero.%s %d';
							RAISERROR (@errorMsg,16,1,N' Error numero',@error); 
						end
					else if (@numeroCuenta is null)
						begin 
							set @error=5;
							set @errorMsg='Error, debe ingresar el parametro @numeroCuenta.%s %d';
							RAISERROR (@errorMsg,16,1,N' Error numero',@error); 
						end
					else --si ingresaron parametros
						begin
							--Validar que no este repetido							
							if (select count(*) from Artista where nombre=@nombre)>0
								begin
									set @error=6;
									set @errorMsg='Error, ya existe un artista con el @nombre ingresado.%s %d';
									RAISERROR (@errorMsg,16,1,N' Error numero',@error); 
								end
							else--insertar
								begin
									if (select count(*) from Estado where idEstado=1)>0
										begin
											begin transaction

												insert into Artista(nombre,genero,estado,numeroCuenta) values 
																	(@nombre,@genero,1,@numeroCuenta);

											commit transaction
										end
									else
										begin
											set @error=13;
											set @errorMsg='Error, no existe estado activo.%s %d';
											RAISERROR (@errorMsg,16,1,N' Error numero',@error); 
										end
								end
						end
				end
			--Opcion 2. Consultar
			else if (@opcion=2)
				begin
					--Validar nulos
					if (@idArtista is null)
						begin
							set @error=7;
							set @errorMsg='Error, debe ingresar el parametro @idArtista.%s %d';
							RAISERROR (@errorMsg,16,1,N' Error numero',@error); 
						end
					else--si ingresaron parametro
						begin
							--Validar que exista
							if (select count(*) from Artista where idArtista=@idArtista)>0
								begin--si existe
									begin transaction

										select Artista.nombre, genero, Estado.nombre as estado , numeroCuenta from Artista inner join
										Estado on Estado.idEstado=Artista.estado where idArtista=@idArtista;

									commit transaction
								end
							else--no existe
								begin
									set @error=8;
									set @errorMsg='Error,no existe artista con el @idArtista ingresado.%s %d';
									RAISERROR (@errorMsg,16,1,N' Error numero',@error); 
								end
						end
				end
			--Opcion 3. Modificar
			else if (@opcion=3)
				begin
					--Validar nulos
					if (@idArtista is null)
						begin
							set @error=9;
							set @errorMsg='Error, debe ingresar el parametro @idArtista.%s %d';
							RAISERROR (@errorMsg,16,1,N' Error numero',@error); 
						end
					else--si ingresaron parametro
						begin
							--Validar que exista
							if (select count(*) from Artista where idArtista=@idArtista)>0
								begin--si existe
									begin transaction
									begin try
										if (@genero is not null)
											begin
												begin transaction
													update Artista set genero=@genero where idArtista=@idArtista;
												commit transaction
											end
										if (@estado is not null)
											begin
												if (select count (*) from Estado where idEstado=@estado)>0
													begin
														begin transaction
															update Artista set estado=@estado where idArtista=@idArtista;
														commit transaction
													end
												else
													begin
														set @error=14;
														set @errorMsg='Error, no existe estado con el @estado ingresado.%s %d';
														RAISERROR (@errorMsg,16,1,N' Error numero',@error); 

													end
												
											end
									commit transaction
									end try
									begin catch--por esto no se ve el error 14.
										print 'Error 14, no existe estado con el @estado ingresado.';
										rollback;
									end catch
								end
							else--no existe
								begin
									set @error=10;
									set @errorMsg='Error,no existe artista con el @idArtista ingresado.%s %d';
									RAISERROR (@errorMsg,16,1,N' Error numero',@error); 
								end
						end
				end
			--Opcion 4. Eliminar
			else if (@opcion=4)
				begin
					--Validar nulos
					if (@idArtista is null)
						begin
							set @error=11;
							set @errorMsg='Error,debe ingresar el parametro @idArtista.%s %d';
							RAISERROR (@errorMsg,16,1,N' Error numero',@error); 
						end
					else --si ingresaron idArtista
						begin
							--Validar que exista
							if (select count(*) from Artista where idArtista=@idArtista)>0
								begin--si existe
									begin transaction
										
										update Artista set estado=-1 where idArtista=@idArtista;

									commit transaction
								end
							else--no existe
								begin
									set @error=12;
									set @errorMsg='Error,no existe artista con el @idArtista ingresado.%s %d';
									RAISERROR (@errorMsg,16,1,N' Error numero',@error); 
								end
						end
				end
			else if (@opcion=5)--consultar todos los artistas
				begin 
					begin transaction
						select idArtista,nombre,genero,Artista.numeroCuenta,Artista.estado from Artista;
					commit transaction
				end
			else
				begin
					set @error=2;
					set @errorMsg='Error, debe ingresar una opción válida.%s %d';
					RAISERROR (@errorMsg,16,1,N' Error número',@error); 
				end
		end

			/*
	--Insertar
		exec spArtista null,null,null,null,null,null;--Erro 1. opcion nula. FUNCIONA
		exec spArtista 50,null,null,null,null,null;--Errr 2. opcion invalida. FUNCIONA
		exec spArtista 1,null,null,null,null,null;--Error 3. nombre nulo. FUNCIONA
		exec spArtista 1,null,'Gandhi',null,null,null;--Error 4. genero nulo. FUNCIONA
		exec spArtista 1,null,'Gandhi','Rock',null,null;--Error 5. numero cuenta nulo. FUNCIONA
		exec spArtista 1,null,'Gandhi','Rock',null,'numero cuenta de gandhi';--Erro 6. artista repetido. FUNCIONA
		--Consultar
		exec spArtista 2,null,null,null,null,null;--Error 7 
		exec spArtista 2,45,null,null,null,null;--Error 8. id artista no existe. FUNCIONA
		exec spArtista 2,1,null,null,null,null;--Consultar funciona.
		--Modificar
		exec spArtista 3,null,null,null,null,null;--Error 9. idAritsta nulo. FUNCIONA
		exec spArtista 3,45,null,null,null,null;--Error 10. artista no existe. FUNCIONA
		exec spArtista 3,1,null,null,75,null;--Error 14. no existe estado 75. FUNCIONA
		exec spArtista 3,1,null,'Pop',null,null;--Modificar funciona
		exec spArtista 3,1,null,null,-1,null;--Modificar funciona
		exec spArtista 3,1,null,null,1,null;--Modificar funciona
		--Eliminar
		exec spArtista 4,null,null,null,null,null;--Error 11. id artista nulo. FUNCIONA
		exec spArtista 4,75,null,null,null,null;--Error 12. no existe artista. FUNCIONA
		exec spArtista 4,1,null,null,null,null;--Error 11. id artista nulo.

		*/
END
GO
-------------------------------------------------------------------------------------
--CRUD Integrante
GO
CREATE PROCEDURE spIntegrante @opcion int, @idIntegrante int,@idArtista int, @nombre varchar(50),
							@primerApellido varchar(50),@segundoApellido varchar(50),@estado int with encryption AS
BEGIN
	declare @error int, @errorMsg varchar(200);
	--Validar opcion
	begin
	begin try
	if (@opcion is null)begin
		set @error=1;
		set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar el parametro @opcion';
		RAISERROR ('Error interno',16,1); end
	else
		begin
			if (@opcion=1)begin--Insertar
				--Validar nulos
				if (@idArtista is null)	begin
					set @error=3;
					set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar el parametro @idArtista';
					RAISERROR ('Error interno',16,1); end
				else if (@nombre is null)begin
					set @error=4;
					set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar el parametro @nombre';
					RAISERROR ('Error interno',16,1); end
				else if (@primerApellido is null)begin
					set @error=5;
					set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar el parametro @primerApellido';
					RAISERROR ('Error interno',16,1); end
				else if (@segundoApellido is null)begin
					set @error=6;
					set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar el parametro @segundoApellido';
					RAISERROR ('Error interno',16,1); end
				else--si ingresaron los parametros 
					begin
						--Valida llaves foraneas
						if (select count(*) from Artista where idArtista = @idArtista)>0
							begin--si existe
								--Validar repetidos
								if (select count(*) from Integrante where nombre=@nombre and primerApellido = @primerApellido and
									segundoApellido=@segundoApellido)=0
									begin
										if (select count(*) from Estado where idEstado=1)>0
											begin
												begin transaction

													insert into Integrante(idArtista,nombre,primerApellido,segundoApellido,estado) values
													(@idArtista,@nombre,@primerApellido,@segundoApellido,1);

												commit transaction
											end
									end
								else
									begin
										set @error=14;
										set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
														'. Ese integrante ya esta registrado.';
										RAISERROR ('Error interno',16,1);

									end
							end
						else
							begin
								set @error=7;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
												'.No existe ningun artista con el @idArtista ingresado.';
								RAISERROR ('Error interno',16,1); end		
					end
			end
			else if (@opcion=2)begin--Consultar
				--Validar nulos
				if (@idIntegrante is null)begin
					set @error=8;
					set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
									'.Debe ingresar el parametro @idIngetrante.';
					RAISERROR ('Error interno',16,1); end	
				else
					begin
						--Validar que exista
						if (select count(*) from Integrante where idIntegrante = @idIntegrante)>0
							begin--si existe
								begin transaction
									
									select I.nombre, I.primerApellido,I.segundoApellido,A.nombre as artista,E.nombre as estadoArtista  
									from Integrante as I inner join Artista as A on A.idArtista=I.idArtista inner join
									Estado as E on E.idEstado=I.estado where I.idIntegrante=@idIntegrante;
									

								commit transaction
							end
						else
							begin
								set @error=9;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
												'.No existe ningun integrante con el @idIntegrante ingresado.';
								RAISERROR ('Error interno',16,1); end	
					end
			end
			else if(@opcion=3)begin--Modificar
				--Validar nulos
				if (@idIntegrante is null) begin
					set @error=10;
					set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
									'. Debe ingresar el parametro @idIntegrante.';
					RAISERROR ('Error interno',16,1); end	
				else --si ingresaron integrante
					begin
						--Validar que exista
						if (select count(*) from Integrante where idIntegrante=@idIntegrante)>0
							begin--si existe
								if (@estado is not null)
									begin
										if (select count(*) from Estado where idEstado=@estado)>0
											begin
												begin transaction
													
													update Integrante set estado=@estado where idIntegrante=@idIntegrante;

												commit transaction
											end
										else
											begin
												set @error=12;
												set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
														'.No existe ningun estado con el @estado ingresado.';
												RAISERROR ('Error interno',16,1); 
											end
									end
							end
						else
							begin
							set @error=11;
							set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
											'.No existe ningun integrante con el @idIntegrante ingresado.';
							RAISERROR ('Error interno',16,1); end	
					end
			end
			else if(@opcion=4)begin--Eliminar
				--Validar nulos
				if (@idIntegrante is null) begin
					set @error=13;
					set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
									'. Debe ingresar el parametro @idIntegrante.';
					RAISERROR ('Error interno',16,1); end	
				else --si ingresaron integrante
					begin
						--Validar que exista
						if (select count(*) from Integrante where idIntegrante=@idIntegrante)>0
							begin--si existe
								--validar que exista el estado
								if (select count (*) from Estado where idEstado=-1)>0
									begin--si existe
										begin transaction

											update Integrante set estado=-1 where idIntegrante=@idIntegrante;

										commit transaction
									end
								else
									begin
										set @error=15;
										set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
														'.No existe ningun estado con el @estado ingresado.';
										RAISERROR ('Error interno',16,1);
									end
							end
						else
							begin
							set @error=14;
							set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
											'.No existe ningun integrante con el @idIntegrante ingresado.';
							RAISERROR ('Error interno',16,1); end	
					end
			end
			else if (@opcion=5)--consultar todos los integrantes
				begin
					begin transaction
						select idIntegrante,nombre,primerApellido,segundoApellido,idArtista,estado from Integrante;
					commit transaction
				end
			else
				begin
					set @error=2;
					set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar una @opcion valida.';
					RAISERROR ('Error interno',16,1); 
				end
		end
	end try
	begin catch--Atrapa cualquier error en la transaccion.
			print @errorMsg;
	end catch
	end

	/*
--Insertar integrante
exec spIntegrante null,null,null,null,null,null,null;--Error 1. opcion nula. FUNCIONA
exec spIntegrante 56,null,null,null,null,null,null;--Error 2. opcion invalida. FUNCIONA
exec spIntegrante 1,null,null,null,null,null,null;--Error 3. id artista nulo. FUNCIONA
exec spIntegrante 1,1,1,null,null,null,null;--Error 4. nombre nulo. FUNCIONA
exec spIntegrante 1,1,1,'Luis',null,null,null;--Error 5. primer apellido nulo. FUNCIONA
exec spIntegrante 1,1,1,'Luis','Montalbert-Smith',null,null;--Error 6. segundo apellido nulo. FUNCIONA
exec spIntegrante 1,1,22,'Luis','Montalbert-Smith','',null;--Error 7. no existe artista. FUNCIONA
exec spIntegrante 1,1,1,'Luis','Montalbert-Smith','Desconocido',null;--Error 14. intengrante repetido. FUNCIONA
--Consultar
exec spIntegrante 2,null,null,null,null,null,null;--Erro 8. id integrante nulo. FUNCIONA
exec spIntegrante 2,45,null,null,null,null,null;--Erro 9. no existe integrante. FUNCIONA
exec spIntegrante 2,1,null,null,null,null,null;--Consultar funciona
--Modificar 
exec spIntegrante 3,null,null,null,null,null,null;--Erro 10. id integrante nulo. FUNCIONA
exec spIntegrante 3,45,null,null,null,null,null;--Erro 11. no existe integrante. FUNCIONA
exec spIntegrante 3,1,null,null,null,null,2;--Modificar funciona
exec spIntegrante 3,1,null,null,null,null,1;--Modificar funciona
--Eliminar
exec spIntegrante 4,null,null,null,null,null,null;--Erro 13. id integrante nulo. FUNCIONA
exec spIntegrante 4,45,null,null,null,null,null;--Erro 14. no existe integrante. FUNCIONA
exec spIntegrante 4,1,null,null,null,null,null;--Eliminar fuciona

select * from Artista;
select * from Integrante;
select * froM Estado;
*/


END
GO
-------------------------------------------------------------------------------------
--CRUD Evento X Pais
GO
CREATE PROCEDURE spEventoXPais @opcion int,@idEvento int, @idPais int, @idLugar int with encryption AS
BEGIN
	declare @error int, @errorMsg varchar(100);
	--Validar opcion
	begin
	begin try
	if (@opcion is null)begin
		set @error=1;
		set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar el parametro @opcion';
		RAISERROR ('Error interno',16,1); end
	else
		begin
			if (@opcion=1)begin--Insertar
				--Validar nulos
				if (@idEvento is null)begin
					set @error=3;
					set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar el parametro @idEvento';
					RAISERROR ('Error interno',16,1); end
				else if (@idPais is null)begin
					set @error=4;
					set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar el parametro @idPais';
					RAISERROR ('Error interno',16,1); end
				else if (@idLugar is null)begin
					set @error=5;
					set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar el parametro @idLugar';
					RAISERROR ('Error interno',16,1); end
				else
					begin
					--Validar que exista el evento
					if (select count(*) from Evento where idEvento=@idEvento)>0
					begin--si existe el evento
						--validar que exista el pais
						if (select count(*) from Pais where idPais=@idPais)>0
							begin
								--validar lugar evento
								if (select count(*) from LugarEvento where idLugar=@idLugar)>0
									begin
										--Validar repetidos
										--un evento x pais esta repetido
										--si es el mismo evento en el mismo pais en el mismo lugar.
										if (select count(*) from EventoXPais where idPais=@idPais and 
																idEvento=@idEvento and idLugar=@idLugar)=0
											begin
												--Insertar
												begin transaction

												insert into EventoXPais(idLugar,idEvento,idPais) values
																		(@idLugar,@idEvento,@idPais);

												commit transaction

											end
										else--repetido
											begin
												set @error=9;
												set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)
															+'. Ya existe ese evento X pais.';
												RAISERROR ('Error interno',16,1);
											end
									end
								else--no existe lugar
									begin
										set @error=8;
										set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)
													+'. No existe lugar de evento con el @lugarEvento ingresado.';
										RAISERROR ('Error interno',16,1);
									end
							end
						else--no existe pais
							begin
								set @error=7;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)
												+'. No existe pais con el @idPais ingresado.';
								RAISERROR ('Error interno',16,1);
							end
						end
					else --no existe evento
						begin
							set @error=6;
							set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
											'. No existe evento con el @idEvento ingresado.';
							RAISERROR ('Error interno',16,1);
						end
					end
			end
			else if (@opcion=2)begin
				--Validar nulos
				if (@idEvento is null)
				begin
					set @error=10;
					set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)
								+'. Debe ingresar el parametro @idEvento.';
					RAISERROR ('Error interno',16,1);
				end
				else if (@idPais is null)
				begin
					set @error=11;
					set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)
								+'. Debe ingresar el parametro @idPais';
					RAISERROR ('Error interno',16,1);
				end
				else--si ingresaron parametros
				begin
					--Validar que existan
					if (select count(*) from EventoXPais where idEvento=@idEvento and idPais=@idPais)>0
					begin--si existe
						begin transaction
							
					select E.nombre as nombreEvento, P.nombre as pais,LE.nombre as lugarEvento,FE.fechaHora as fecha from EventoXPais as EP
							inner join Evento as E on E.idEvento=EP.idEvento inner join Pais as P on P.idPais=EP.idPais
							inner join FechaEvento as FE on FE.idEvento=EP.idEvento and FE.idPais = EP.idPais
							inner join LugarEvento as LE on LE.idLugar=EP.idLugar		
							where EP.idPais=@idPais and EP.idEvento=@idEvento;

						commit transaction
					end
					else
					begin
						set @error=12;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)
									+'. No existe el evento en el pais con los parametros @evento y @pais.';
						RAISERROR ('Error interno',16,1);
					end

				end
			end
			else if(@opcion=3)begin--Modificar
				--Solo se puede modificar el lugar
				--Validar nulos
				if (@idPais is null)
				begin
					set @error=13;
					set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)
								+'. Debe ingresar el parametro @idPais.';
					RAISERROR ('Error interno',16,1);
				end
				else if (@idEvento is null)
				begin
					set @error=14;
					set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)
								+'. Debe ingresar el parametro @idEvento';
					RAISERROR ('Error interno',16,1);
				end
				else if (@idLugar is null)
				begin
					set @error=15;
					set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)
								+'. Debe ingresar el parametro @idLugar';
					RAISERROR ('Error interno',16,1);
				end
				else
				begin--si ingresaron parametros
					--Validar que existen
					if (select count(*) from EventoXPais where idEvento=@idEvento and idPais=@idPais)>0
					begin--si existe evento x pais
						--validar que exista lugar
						if (select count(*) from LugarEvento where idLugar=@idLugar)>0
							begin--si existe lugar
								begin transaction
										
										update EventoXPais set idLugar=@idLugar where idEvento=@idEvento and idPais=@idPais;

								commit transaction
							end
						else--no existe lugar
						begin
							set @error=17;
							set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
										'. No existe lugar de evento con el @idLugar ingresado.';
							RAISERROR ('Error interno',16,1); 
						end
					end
					else--no existe evento x pais
					begin
						set @error=16;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
									'. No existe evento x pais con los parametros @idEvento y @idPais ingresados.';
						RAISERROR ('Error interno',16,1); 
					end
				end
			end
			else if (@opcion=4)	--consultar todos los eventos x pais
				begin
					begin transaction
						select idEvento,idPais,idLugar from EventoXPais;
					commit transaction
				end
			else
				begin
					set @error=2;
					set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar una @opcion valida.';
					RAISERROR ('Error interno',16,1); end
		end
	end try
	begin catch--Atrapa cualquier error en la transaccion.
			print @errorMsg;
	end catch
	end

	/*
--Insertar 
exec spEventoXPais null,null,null,null;--Error 1. opcion nula. FUNCIONA
exec spEventoXPais 7,null,null,null;--Error 2. opcion invalida. FUNCIONA
exec spEventoXPais 1,null,null,null;--Error 3. id evento nulo. FUNCIONA
exec spEventoXPais 1,1,null,null;--Error 4. id pais nulo. FUNCIONA
exec spEventoXPais 1,1,188,null;--Error 5. id lugar nulo. FUNCIONA
exec spEventoXPais 1,100,188,1;--Error 6. no existe evento. FUNCIONA
exec spEventoXPais 1,1,7,1;--Error 7. no existe pais. FUNCIONA
exec spEventoXPais 1,1,188,45;--Error 8. no existe lugar evento con id 45. FUNCIONA
--Consultar
exec spEventoXPais 2,null,null,null;--Error 10. idEvento nulo. FUNCIONA
exec spEventoXPais 2,1,null,null;--Error 11. id pais nulo. FUNCIONA
exec spEventoXPais 2,1,1,null;--Error 12. no existe evento 1 en pais 1. FUNCIONA
exec spEventoXPais 2,184,188,null;--Error 12. no existe evento 184 en pais 188. FUNCIONA
exec spEventoXPais 2,1,188,null;--Consultar funciona
--Modificar
exec spEventoXPais 3,null,null,null;--Error 13. id pais nulo.FUNCIONA
exec spEventoXPais 3,null,1,null;--Error 14. id evento nulo. FUNCIONA
exec spEventoXPais 3,45,100,null;--Error 15. id lugar nulo. FUNCIONA
exec spEventoXPais 3,45,100,1;--Error 16. no existe evento 45 en pais 100. FUNCIONA
exec spEventoXPais 3,45,188,1;--Error 16. no existe evento 45 en pais 188. FUNCIONA
exec spEventoXPais 3,1,23,1;--Error 16. no existe evento 1 en pais 23. FUNCIONA
exec spEventoXPais 3,1,188,100;--Error 17. no existe lugar. FUNCIONA
exec spEventoXPais 3,1,188,2;--Modificar funciona
exec spEventoXPais 3,1,188,1;--Modificar funciona
*/
END
GO
-----------------------------------------------------------------------------------------------
--CRUD Lugar
GO
CREATE PROCEDURE spLugarEvento @opcion int,@idLugar int,@nombre varchar(50),@detalle varchar(200),
								@maxPersonas int,@estado int with encryption AS
BEGIN
	declare @error int, @errorMsg varchar(200);
	--Validar opcion
	begin
	begin try
	if (@opcion is null)begin
		set @error=1;
		set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar el parametro @opcion';
		RAISERROR ('Error interno',16,1); end
	else
		begin
			if (@opcion=1)--Insertar
				begin
					--Validar nulos
					if (@nombre is null)begin
						set @error=3;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar el parametro @nombre';
						RAISERROR ('Error interno',16,1); end
					else if (@detalle is null)begin
						set @error=4;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar el parametro @detalle';
						RAISERROR ('Error interno',16,1); end
					else if (@maxPersonas is null)begin
						set @error=5;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar el parametro @maxPersonas';
						RAISERROR ('Error interno',16,1); end
					else--Si ingresaron parametros
						begin
							--Validar repetidos
							if (select count(*) from LugarEvento where nombre=@nombre)>0
								begin
									set @error=6;
									set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
													'. Ya existe un lugar con ese @nombre.';
									RAISERROR ('Error interno',16,1); 
								end
							else--nombre disponible
								begin
									if (@maxPersonas>0)
									begin
										begin transaction

											insert into LugarEvento(nombre,detalleUbicacion,maximaCantidadPersonas,estado) values
																	(@nombre,@detalle,@maxPersonas,1);
											

										commit transaction
									end
									else
										begin 
											set @error=7;
											set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
													'. Debe ingresar @maxPersonas > 0 .';
											RAISERROR ('Error interno',16,1); 
										end

								end
						end
				end
			else if (@opcion=2)
				begin--Consultar
					--Validar nulos
					if (@idLugar is null)
						begin
							set @error=8;
							set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
													'. Debe ingresar el parametro @idLugar.';
							RAISERROR ('Error interno',16,1); 
						end
					else--si ingresaron id lugar
						begin
							--validar que existe
							if (select count(*) from LugarEvento where idLugar=@idLugar)>0
								begin
									begin transaction

										select L.idLugar,L.nombre,L.detalleUbicacion, L.maximaCantidadPersonas,
											E.nombre as estado from LugarEvento as L inner join Estado as E on E.idEstado=L.estado
											where idLugar=@idLugar;

									commit transaction
								end
							else--no existe
								begin
								set @error=9;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
													'. No existe lugar con el @idLugar ingresado.';
								RAISERROR ('Error interno',16,1); 
								end
						end
				end
			else if(@opcion=3)begin--Modificar
				--Validar nulos.
				if (@idLugar is null)
					begin
						set @error=10;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
									'. Debe ingresar parametro @idLugar.';
						RAISERROR ('Error interno',16,1); 
					end
				else--si ingresaron id lugar
					begin
						--validar que existe
						if (select count(*) from LugarEvento where idLugar=@idLugar)>0
							begin
								--si existe
								--modificar detalle, cantidad personas y estado. opciolamente
								if (@detalle is not null)
									begin try
										begin transaction
											update LugarEvento set detalleUbicacion=@detalle where idLugar=@idLugar;
										commit transaction
									end try
									begin catch
										rollback
									end catch
								if (@maxPersonas is not null)
									begin try
										begin transaction
											update LugarEvento set maximaCantidadPersonas=@maxPersonas where idLugar=@idLugar;
										commit transaction
									end try
									begin catch
										rollback
									end catch
								if (@estado is not null)
									begin try
										begin transaction
											update LugarEvento set estado=@estado where idLugar=@idLugar;
										commit transaction
									end try
									begin catch
										rollback
									end catch
							end
						else
							begin
								set @error=11;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
										'. No existe lugar con el @idLugar ingresado.';
								RAISERROR ('Error interno',16,1); 
							end	
					end
			end
			else if(@opcion=4)begin--Eliminar
				--Validar nulo
				if (@idLugar is null)
					begin
						set @error=12;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
								'. Debe ingresar parametro @idLugar.';
						RAISERROR ('Error interno',16,1); 
					end
				else--si ingresaron parametro
					begin
					--Validar que existe
						if (select count(*) from LugarEvento where idLugar=@idLugar)>0
							begin--si existe
								begin try
									update LugarEvento set estado=-1 where idLugar=@idLugar;
								end try
								begin catch--si cae en catch esporque no existe el estado -1.
									rollback
								end catch
							end
						else
							begin
								set @error=13;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
										'. No existe lugar con el @idLugar ingresado.';
								RAISERROR ('Error interno',16,1); 
							end
					end
			end
			else if (@opcion=5)
				begin
					begin transaction
						select idLugar,nombre,maximaCantidadPersonas,LugarEvento.detalleUbicacion,LugarEvento.estado from LugarEvento;
					commit transaction
				end
			else
				begin
					set @error=2;
					set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar una @opcion valida.';
					RAISERROR ('Error interno',16,1); end
		end
	end try
	begin catch--Atrapa cualquier error en la transaccion.
			print @errorMsg;
	end catch
	end

	/*
--Insertar Lugar
exec spLugarEvento null,null,null,null,null,null;--Error 1. opcion nula. FUNCIONA
exec spLugarEvento 88,null,null,null,null,null;--Error 2. opcion invalida. FUNCIONA
exec spLugarEvento 1,null,null,null,null,null;--Error 3. nombre nulo. FUNCIONA
exec spLugarEvento 1,null,'Sala de Fiestas La Finca',null,null,null;--Error 4. detalle nulo. FUNCIONA
exec spLugarEvento 1,null,'Sala de Fiestas La Finca','Heredia, San Joaquin',null,null;--Error 5. max personas nulos. FUNCIONA
exec spLugarEvento 1,null,'Sala de Fiestas La Finca','Heredia, San Joaquin',300,null;--Error 6. lugar repetido. FUNCIONA
exec spLugarEvento 1,null,'Salon','Heredia, San Joaquin',-54,null;--Error 7. max personas negativo. FUNCIONA
--Consultar
exec spLugarEvento 2,null,null,null,null,null;--Error 8. id lugar nulo. FUNCIONA
exec spLugarEvento 2,78,null,null,null,null;--Error 9. no existe lugar. FUNCIONA
exec spLugarEvento 2,3,null,null,null,null;--Consultar funciona
--Modificar 
exec spLugarEvento 3,null,null,null,null,null;--Error 10. id lugar nulo. FUNCIONA
exec spLugarEvento 3,78,null,null,null,null;--Error 11. no existe lugar. FUNCIONA
exec spLugarEvento 3,3,null,'Limon, Siquirres',null,null;--Modificar detalle funciona
exec spLugarEvento 3,3,null,null,150,null;--Modificar max personas funciona
exec spLugarEvento 3,3,null,null,null,-1;--Modificar estado funciona
exec spLugarEvento 3,3,null,'Heredia, San Joaquin',300,1;--Modificar todo funciona
--Eliminar
exec spLugarEvento 4,null,null,null,null,null;--Error 12. id lugar nulo. FUNCIONA
exec spLugarEvento 4,78,null,null,null,null;--Error 13. lugar no existe. FUNCIONA
exec spLugarEvento 4,3,null,null,null,null;--Eliminar funciona

select * from LugarEvento;
*/
END
GO
--------------------------------------------------------------------------------------------------------
--CRUD FechaEvento
GO
CREATE PROCEDURE spFechaEvento @opcion int, @idFecha int,@idEvento int,@idPais int,@fechaHora varchar(19),@estado int with encryption AS
BEGIN
	--El formato de la fecha es 'mm-dd-yyyy hh:mm:ss'. 19 caracteres exactos

	declare @error int, @errorMsg varchar(200);
	--Validar opcion
	begin
	begin try
	if (@opcion is null)begin
		set @error=1;
		set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar el parametro @opcion';
		RAISERROR ('Error interno',16,1); end
	else
		begin
			if (@opcion=1)begin--Insertar
				--Validar nulos
				if (@idEvento is null)
					begin
						set @error=3;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar el parametro @idEvento.';
						RAISERROR ('Error interno',16,1);
					end
				else if (@idPais is null)
					begin
						set @error=4;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar el parametro @idPais.';
						RAISERROR ('Error interno',16,1);
					end
				else if (@fechaHora is null)
					begin
						set @error=5;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar el parametro @fechaHora.';
						RAISERROR ('Error interno',16,1);
					end
				else--si ingresaron parametros
					begin
						--Validar que existen y el evento no esta eliminado.
						if (select count(*) from EventoXPais inner join Evento on Evento.idEvento=EventoXPais.idEvento 
								where EventoXPais.idEvento=@idEvento and EventoXPais.idPais=@idPais and Evento.idEvento!=-1)>0
							begin
								begin try
									--Validar fecha
									declare @fechaSmall smalldatetime = CONVERT(SMALLDATETIME, CAST(@fechaHora AS datetime));
									if (@fechaSmall > GETDATE())--fecha mayor que la actual
										begin 
											--ya me asegure de que trae el formato correcto y es una fecha posterior a la actual.
											--Validar repetidos
											if (select count(*) from FechaEvento where idEvento=@idEvento and idPais=@idPais 
																						and fechaHora=@fechaSmall)=0
												begin--no se repite
													begin transaction
														--Existe el evento, esta activo, la fecha es futura y no se repite.
														insert into FechaEvento(idEvento,idPais,fechaHora,estado) values
																				(@idEvento,@idPais,@fechaSmall,1);
													commit transaction
												end
											else--fecha repetida
												begin
													set @error=9;
													set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
															'. Ya existe un EventoXPais en la misma fecha.';
													RAISERROR ('Error interno',16,1);

												end
										end
									else--la fecha es previa a la actual
										begin
											set @error=8;
											set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
														'. Debe ingresar una fecha y hora del futuro.';
											RAISERROR ('Error interno',16,1);

										end
								end try
								begin catch
									print @errorMsg;
									if (@fechaSmall is null)
										print 'Ha ocurrido un error. Error 7. La fecha debe tener formato mm-dd-yyyy hh:mm:ss';
								end catch
							end
						else--no existe evento, ya sea porque nunca lo ingresaron o porque lo eliminaron
							begin
								set @error=6;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
												'.No existe evento en pais con los parametro @idEvento y @idPais ingresados.';
								RAISERROR ('Error interno',16,1);
							end
					end
				
				
			end
			else if (@opcion=2)begin--Consultar
				--validar nulos
				if (@idFecha is null)
					begin
						set @error=10;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
								'. Debe ingresar parametro @idFecha.';
						RAISERROR ('Error interno',16,1);
					end
				else--si ingresaron idFecha
					begin
						--Validar que exista
						if (select count(*) from FechaEvento where idFecha=@idFecha)>0
							begin
								begin transaction
									
									select FE.idFecha, FE.idEvento, E.nombre as nombreEvento,
									FE.idPais, P.nombre as nombrePais,FE.fechaHora, Estado.nombre from FechaEvento as FE inner join
									Evento as E on E.idEvento=FE.idEvento inner join Pais as P on P.idPais=FE.idPais inner join
									Estado on Estado.idEstado=FE.estado where idFecha=@idFecha;
									

								commit transaction
							end
						else
							begin
								set @error=11;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
								'. No existe fecha de evento con el @idEvento ingresado.';
								RAISERROR ('Error interno',16,1);
							end
					end
			end
			else if(@opcion=3)begin--Modificar
				--Validar nulos
				if (@idFecha is null)	
					begin
						set @error=12;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
								'. Debe ingresar el parametro @idFecha';
						RAISERROR ('Error interno',16,1);
					end
				else--si ingresaron parametro
					begin
						--Validar si existe
						if (select count(*) from FechaEvento where idFecha=@idFecha)>0
							begin
								if (@estado is not null)
									begin
										if (select count(*) from Estado where idEstado=@estado)>0
											begin--si existe el estado
												begin transaction

													update FechaEvento set estado=@estado where idFecha=@idFecha;

												commit transaction
											end
										else
											begin
												set @error=14;
												set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
													'. No existe estado con el @estado ingresado.';
												RAISERROR ('Error interno',16,1);
											end

									end
							end
						else
							begin
								set @error=13;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
										'. No existe fecha de evento con @idFecha.';
								RAISERROR ('Error interno',16,1);
							end
					end
			end
			else if(@opcion=4)begin--Eliminar
				--Validar nulos
				if (@idFecha is null)
					begin
						set @error=15;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
												'. Debe ingresar el parametro @idFecha.';
						RAISERROR ('Error interno',16,1);
					end
				else--si ingresaron id fecha
					begin
						--Validar que exista
						if (select count(*) from FechaEvento where idFecha=@idFecha)>0
							begin--si existe
								begin transaction
									
									update FechaEvento set estado=-1 where idFecha=@idFecha;

								commit transaction
							end
						else--no existe
							begin
								set @error=16;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
												'.  No existe fecha con el @idFecha ingresada.';
								RAISERROR ('Error interno',16,1);
							end
					end
			end
			else if (@opcion=5)
				begin 
					begin transaction
						select idFecha,idEvento,idPais,fechaHora,estado from FechaEvento;
					commit transaction
				end
			else
				begin
					set @error=2;
					set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar una @opcion valida.';
					RAISERROR ('Error interno',16,1); end
		end
	end try
	begin catch--Atrapa cualquier error en la transaccion.
			print @errorMsg;
	end catch
	end
	/*
--Insertar
 exec spFechaEvento null,null,null,null,null,null;--Error 1. opcion nula. FUNCIONA
 exec spFechaEvento 15,null,null,null,null,null;--Error 2. opcion invalida. FUNCIONA
 exec spFechaEvento 1,null,null,null,null,null;--Error 3. id evento nulo. FUNCIONA
 exec spFechaEvento 1,null,1,null,null,null;--Error 4. id pais nulo. FUNCIONA
 exec spFechaEvento 1,null,1,1,null,null;--Error 5. fecha nula. FUNCIONA
 exec spFechaEvento 1,null,1,1,'',null;--Error 6. fecha nula. FUNCIONA
 exec spFechaEvento 1,null,2,188,'20-20/2022 16:00:00',null;--Error 7. formato fecha malo. FUNCIONA
 exec spFechaEvento 1,null,2,188,'08-20-2021 16:00:00',null;--Error 8. fecha antigua. FUNCIONA
 exec spFechaEvento 1,null,2,188,'08-20-2022 16:00:00',null;--Error 9. fecha repetida. FUNCIONA
 --Consultar
 exec spFechaEvento 2,null,null,null,null,null;--Error 10. id fecha nulo. FUNCIONA
 exec spFechaEvento 2,78,null,null,null,null;--Error 11. fecha no existe. FUNCIONA
 exec spFechaEvento 2,5,null,null,null,null;--Consultar funciona
 --Modificar
 exec spFechaEvento 3,null,null,null,null,null;--Error 12. id fecha nulo. FUNCIONA
 exec spFechaEvento 3,45,null,null,null,null;--Error 13. no existe fecha. FUNCIONA
 exec spFechaEvento 3,5,null,null,null,null;--Error 13. no existe fecha. FUNCIONA
 exec spFechaEvento 3,5,null,null,null,2;--Modificar funciona
 exec spFechaEvento 2,5,null,null,null,null;--Consultar funciona
 exec spFechaEvento 3,5,null,null,null,1;--Modificar funciona
 exec spFechaEvento 2,5,null,null,null,null;--Consultar funciona
--Eliminar 
exec spFechaEvento 4,null,null,null,null,null;--Error 15. id fecha nulo. FUNCIONA
exec spFechaEvento 4,451,null,null,null,null;--Error 16. no existe id fecha. FUNCIONA
exec spFechaEvento 4,5,null,null,null,null;--Eliminar funciona
exec spFechaEvento 2,5,null,null,null,null;--Consultar funciona

select* from Evento;
select * from Pais;
select * from FechaEvento;
select * from EventoXPais;
select * from Evento;
*/

END
GO
---------------------------------------------------------------------------------------
--CRUD  Tipo Asiento
go
CREATE PROCEDURE spTipoAsiento @opcion int, @numeroAsiento int,@idLugar int,@nombre varchar(30),
								@cantidad int, @estado int with encryption AS
BEGIN
	declare @error int, @errorMsg varchar(200);
	--Validar opcion
	begin
	begin try
	if (@opcion is null)begin
		set @error=1;
		set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar el parametro @opcion';
		RAISERROR ('Error interno',16,1); end
	else
		begin
			if (@opcion=1)begin--Insertar
				--Validar nulos
				if (@idLugar is null)
					begin
						set @error=3;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
							'.Debe ingresar el parametro @idLugar.';
						RAISERROR ('Error interno',16,1); 
					end
				else if (@nombre is null)
					begin
						set @error=4;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
								'.Debe ingresar el parametro @nombre.';
						RAISERROR ('Error interno',16,1); 
					end
				else  if (@cantidad is null)
					begin
						set @error=5;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
								'.Debe ingresar el parametro @cantidad.';
						RAISERROR ('Error interno',16,1); 
					end
				else--si ingresaron los parametros
					begin
						--Validar que exista llave foranea y que no hayan eliminado el lugar
						if (select count(*) from LugarEvento where idLugar=@idLugar and estado!=-1)>0
							begin--si existe lugar
								--Validar repetidos
								if (select count(*) from TipoAsiento where nombre=@nombre)=0
									begin--no esta repetido
										if (@cantidad>0)--validar que la cantidad sea positiva
											begin
												
													--maxima cantidad de campos del lugar
													declare @cantidadMax int = (select maximaCantidadPersonas from LugarEvento where idLugar=@idLugar);
													--suma toda la cantidad de cada tipo de asiento de ese lugar
													declare @tablaSuma AS TABLE (maximo int,idLugar int) ;
													insert into @tablaSuma select sum (cantidad) as maximo,idLugar from TipoAsiento where
														TipoAsiento.idLugar=@idLugar group by idLugar;
													--compara si no sobrepasa el maximo
													if (select count(*) from @tablaSuma)>0
														begin			
															if ((select maximo from @tablaSuma)+@cantidad<=@cantidadMax)
															begin

																begin transaction

																insert into TipoAsiento(idLugar,nombre,cantidad,estado) values
																			(@idLugar,@nombre,@cantidad,1);

																commit transaction
															end
														else
															begin
																set @error=101;
																set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
																	'. La cantidad ingresada sobrepasa la maxima capacidad del lugar.';
																RAISERROR ('Error interno',16,1); 
															end
														end
													else--el registro estaba nulo
														begin
															begin transaction
															insert into TipoAsiento(idLugar,nombre,cantidad,estado) values
																			(@idLugar,@nombre,@cantidad,1);
															commit transaction
														end
													
												
	
											end
										else
											begin
												set @error=8;
												set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
													'. La @cantidad debe ser un numero positivo.';
												RAISERROR ('Error interno',16,1); 
											end
									end
								else--repetido
									begin
										set @error=7;
										set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
											'. Ya existe un tipo de asiento con el @nombre ingresado.';
										RAISERROR ('Error interno',16,1); 
									end
							end
						else--no existe lugar
							begin
							set @error=6;
							set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
									'. No existe lugar de evento con el @idLugar ingresado.';
							RAISERROR ('Error interno',16,1); 

							end
					end
			end
			else if (@opcion=2)begin--Consultar
				--Validar nulos
				 if (@numeroAsiento is null)
					begin
						set @error=9;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
							'. Debe ingresar el parametro @numeroAsiento.';
						RAISERROR ('Error interno',16,1); 
					end
				else
					begin
					--Validar que exista
						if (select count(*) from TipoAsiento where numeroAsiento=@numeroAsiento)>0
							begin
								begin transaction
									
									select TA.numeroAsiento,TA.nombre as tipoAsiento,TA.cantidad, E.nombre as estado, LE.nombre as lugar
										from TipoAsiento as TA inner join Estado as E on E.idEstado=TA.estado inner join
										LugarEvento as LE on LE.idLugar = TA.idLugar
										where TA.numeroAsiento=@numeroAsiento;

								commit transaction
							end
						else--no existe numero de asiento
							begin
								set @error=10;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
									'. No existe tipo de asiento con el @numeroAsiento ingresado.';
								RAISERROR ('Error interno',16,1); 
							end
					end
			end
			else if(@opcion=3)begin--Modificar
				if (@numeroAsiento is null)
					begin
						set @error=11;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
							'. Debe ingresar el parametro @numeroAsiento';
						RAISERROR ('Error interno',16,1); 	
					end
				else--si ingresaron parametro
					begin
						--validar si existe
						if (select count(*) from TipoAsiento where numeroAsiento=@numeroAsiento)>0
							begin
								if (@estado is not null)
									begin
									if (select count(*) from Estado where idEstado=@estado)>0
										begin
											begin transaction
												update TipoAsiento set estado=@estado where numeroAsiento=@numeroAsiento;
											commit transaction
										end
									else
										begin
											set @error=13;
											set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
												'. No existe estado con el @estado ingresado.';
											RAISERROR ('Error interno',16,1); 	
										end
										end
								if (@cantidad is not null)
									begin 
										if (@cantidad>0)
											begin
												declare @cantidadMax1 int = (select LugarEvento.maximaCantidadPersonas from TipoAsiento
																		inner join LugarEvento on LugarEvento.idLugar=TipoAsiento.idLugar
																		where TipoAsiento.numeroAsiento=@numeroAsiento);
												
												--suma toda la cantidad de cada tipo de asiento de ese lugar
												declare @tablaSuma1 AS TABLE (suma int,idLugar int) ;
												insert into @tablaSuma1 select sum (cantidad),idLugar from TipoAsiento where idLugar=1 group by idLugar;

												if ((select  suma from @tablaSuma1)+@cantidad<=@cantidadMax1)
													begin
														begin transaction 
															update TipoAsiento set cantidad=@cantidad where nombre=@nombre;
														commit transaction
													end
													else
														begin
															set @error=20;
															set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
																'. Con la @cantidad ingresada se sobrepasa el maximo de capacidad del lugar.';
															RAISERROR ('Error interno',16,1); 	
														end
											end
										else
											begin
												set @error=14;
												set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
														'. Debe ingresar una @cantidad >0.';
												RAISERROR ('Error interno',16,1); 	
											end
									end
							end
						else
							begin
								set @error=12;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
										'. No existe tipo de asiento con el @nombre ingresado.';
								RAISERROR ('Error interno',16,1); 	
							end
					end

			end
			else if(@opcion=4)begin--Eliminar
				if (@nombre is null)
					begin
						set @error=13;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
								'. Debe ingresar el parametro @nombre.';
						RAISERROR ('Error interno',16,1); 	
					end
				else--si ingresaron parametros
					begin

						if (select count(*) from TipoAsiento where nombre=@nombre)>0
							begin
								begin transaction
									update TipoAsiento set estado=-1 where nombre=@nombre;
									update TipoAsiento set cantidad=0 where nombre=@nombre;
								commit transaction
							end
						else--no existe tpo asiento
							begin
								set @error=14;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
										'. No existe tipo de asiento con el @nombre ingresado.';
								RAISERROR ('Error interno',16,1); 	
							end
					end
			end
			else if (@opcion=5)--consultar todos
				begin
					begin tran
						select numeroAsiento as tipoAsiento,idLugar,nombre,cantidad,estado from TipoAsiento;
					commit tran

				end
			else
				begin
					set @error=2;
					set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar una @opcion valida.';
					RAISERROR ('Error interno',16,1); end
		end
	end try
	begin catch--Atrapa cualquier error en la transaccion.
			print @errorMsg;
	end catch
	end

	/*
--Insertar
exec spTipoAsiento null,null,null,null,null,null;--Erro 1. opcion nula. FUNCIONA
exec spTipoAsiento 756,null,null,null,null,null;--Erro 2. opcion incorrecta. FUNCIONA
exec spTipoAsiento 1,null,null,null,null,null;--Erro 3. idLugar nulo. FUNCIONA
exec spTipoAsiento 1,null,1,null,null,null;--Erro 4. nombre nulo. FUNCIONA
exec spTipoAsiento 1,null,1,'VIP',null,null;--Erro 4. nombre nulo. FUNCIONA
exec spTipoAsiento 1,null,1,'VIP',null,null;--Erro 5. cantidad nula. FUNCIONA
exec spTipoAsiento 1,null,45,'VIP',1000,null;--Error 6. id lugar no existe. FUNCIONA
exec spTipoAsiento 1,null,1,'VIP',1000,null;--Error 7. nombre repetido. FUNCIONA
exec spTipoAsiento 1,null,1,'Otro asiento',1,null;--Error 100. maxima capacidad alcanzada. FUNCIONA
exec spTipoAsiento 1,null,1,'Otro asiento',1,null;--Error 100. maxima capacidad alcanzada. FUNCIONA

--Consultar
exec spTipoAsiento 2,null,null,null,null,null;--Error 9. nombre nulo. FUNCIONA
exec spTipoAsiento 2,null,null,'asiento magico',null,null;--Error 10. no existe nombre. FUNCIONA
exec spTipoAsiento 2,5,null,null,null,null;--Consultar funciona
exec spTipoAsiento 2,1,null,null,null,null;--Consultar funciona
--Modificar
exec spTipoAsiento 3,null,null,null,null,null;--Erro 11. nombre nulo. FUNCIONA
exec spTipoAsiento 3,null,null,'asiento',null,null;--Erro 12. nombre no existe. FUNCIONA
exec spTipoAsiento 3,null,null,'VIP',null,-5;--Error 13. estado no existe. FUNCIONA
exec spTipoAsiento 3,null,null,'VIP',5,null;--modificar con cantidad funciona
exec spTipoAsiento 2,null,null,'VIP',null,null;--Consultar funciona
exec spTipoAsiento 3,null,null,'VIP',null,1;--modificar con cantidad funciona
exec spTipoAsiento 3,null,null,'Preferencial',1000,1;--modificar con cantidad funciona
exec spTipoAsiento 3,5,null,'Otro asiento',8900,1;--modificar
exec spTipoAsiento 2,null,null,'Otro asiento',null,null;--Consultar funciona
exec spTipoAsiento 3,4,null,null,1000,null;--modificar

--Eliminar
exec spTipoAsiento 4,null,null,null,null,null;--Erro 13. nombre nulo. FUNCIONA
exec spTipoAsiento 4,null,null,'asiento',null,null;--Erro 14. nombre no existe. FUNCIONA
exec spTipoAsiento 4,null,null,'VIP',null,-5;--Eliminar funciona
exec spTipoAsiento 4,null,1,'Preferencial',1,null;--Eliminar funciona
select * from LugarEvento;
select * from TipoAsiento;
*/
END
GO
---------------------------------------------------------------------------------------
--CRUD Artista X Evento X Pais
GO
CREATE PROCEDURE spArtistaXEvento @opcion int,@idFecha int,@idArtista int,
								@fechaHoraInicio varchar(19),@fechaHoraFinal varchar(19),@estado int  with encryption AS
BEGIN--con idFecha saco idEvento, idPais y las fecha
	declare @error int, @errorMsg varchar(200);
	declare @fechaIni smalldatetime,@fechaFinal smalldatetime;
	--Validar opcion
	begin
	begin try
	if (@opcion is null)begin
		set @error=1;
		set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar el parametro @opcion';
		RAISERROR ('Error interno',16,1); end
	else
		begin
			if (@opcion=1)begin--Insertar
				--Validar nulos
				if (@idFecha is null)
					begin
						set @error=3;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
										'.Debe ingresar el parametro @idFecha para poder obtener el id del evento, pais y fecha.';
						RAISERROR ('Error interno',16,1);
					end
				else if (@idArtista is null)
					begin
						set @error=4;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
										'.Debe ingresar el parametro @idArtista.';
						RAISERROR ('Error interno',16,1);
					end
				else if (@fechaHoraInicio is null)
					begin
						set @error=5;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
										'.Debe ingresar el parametro @fechaHoraInicio.';
						RAISERROR ('Error interno',16,1);
					end
				else if (@fechaHoraFinal is null)
					begin
						set @error=6;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
										'.Debe ingresar el parametro @fechaHoraFinal.';
						RAISERROR ('Error interno',16,1);
					end
				else--ingresaron parametros
					begin
						--Validar que exista llaves foraneas
						if (select count(*) from Artista where idArtista=@idArtista)>0
							begin--si existe artista
								if (select count(*) from FechaEvento where idFecha=@idFecha and estado!=-1)>0
									begin--si existe evento
										--Validar fechas
										begin try
											set @fechaIni=CONVERT(SMALLDATETIME, CAST(@fechaHoraInicio AS datetime));
											set @fechaFinal=CONVERT(SMALLDATETIME, CAST(@fechaHoraFinal AS datetime));
												--si no se cae al cath es porque las fechas tienen buen formato
												--ahora hay que comprar si las fechas en las uqe se presentan los artista
												--estan de acuerdo con el dia del evento
												if ((select DATEDIFF(day,(select fechaHora from FechaEvento where idFecha=@idFecha),@fechaIni))=0 
												AND (select DATEDIFF(day,(select fechaHora from FechaEvento where idFecha=@idFecha),@fechaFinal))=0)
													begin
														begin transaction t1

														insert into ArtistaXEvento(fechaHoraIncio,fechaHoraFinalizacion,idArtista,idFecha,estado) values
																					(@fechaIni,@fechaFinal,@idArtista,@idFecha,1);

														commit transaction t1
													end
										end try
										begin catch
											IF @@tranCount > 0                        
												ROLLBACK TRANSACTION
											
											if (@fechaIni is null)
												begin
													print 'Ha ocurrido un error. Error 9. El formato de la fecha debe ser "mm-dd-yyyy hh:mm:ss".';
												end
											if (@fechaFinal is null)
												begin
													print 'Ha ocurrido un error. Error 10. El formato de la fecha debe ser "mm-dd-yyyy hh:mm:ss".';
												end
											RAISERROR ('Error interno',16,1);	
										end catch

									end
								else
									begin
										set @error=8;
										set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
											'. No existe fecha de evento con el @idFecha ingresada.';
										RAISERROR ('Error interno',16,1);
									end
							end
						else
							begin
								set @error=7;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
										'. No existe artista con el @idArtista ingresado..';
								RAISERROR ('Error interno',16,1);
							end
					end
			end
			else if (@opcion=2)begin--Consultar
				--Validarn ulos
				if (@idArtista is null)
					begin
						set @error=11;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
							'. Debe ingresar el paraemtro @idArtista.';
						RAISERROR ('Error interno',16,1);
					end
				else if (@idFecha is null)
					begin
						set @error=12;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
							'. Debe ingresar el paraemtro @idFecha.';
						RAISERROR ('Error interno',16,1);
					end

				else
					begin--si ingresaron parametros
						--validar que existen
						if (select count(*) from ArtistaXEvento where idArtista=@idArtista and idFecha=@idFecha)>0
							begin--si existe artista x evento
								begin transaction

									select Artista.nombre as artista,Evento.nombre as evento,Pais.nombre as pais, 
										ArtistaXEvento.fechaHoraIncio as inicio, ArtistaXEvento.fechaHoraFinalizacion as finalizacion,
										Estado.nombre as estado from ArtistaXEvento
										inner join Estado on Estado.idEstado=ArtistaXEvento.estado
										inner join Artista on Artista.idArtista=ArtistaXEvento.idArtista
										inner join FechaEvento on FechaEvento.idFecha=ArtistaXEvento.idFecha inner join
										Pais on Pais.idPais=FechaEvento.idPais inner join Evento on Evento.idEvento=FechaEvento.idEvento
										where ArtistaXEvento.idArtista=@idArtista and ArtistaXEvento.idFecha=@idFecha;

								commit transaction
							end
						else
							begin
								set @error=13;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
									'. No existe artista x evento con el @idArtista y @idFecha ingresadas.';
								RAISERROR ('Error interno',16,1);
							end

					end
			end
			else if(@opcion=3)begin--Modificar
				--Validar nulos
				if (@idArtista is null)
					begin
						set @error=14;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
							'. Debe ingresar el paraemtro @idArtista.';
						RAISERROR ('Error interno',16,1);
					end
				else if (@idFecha is null)
					begin
						set @error=15;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
							'. Debe ingresar el paraemtro @idFecha.';
						RAISERROR ('Error interno',16,1);
					end

				else--si ingresaron parametros
					begin
						--validar que existe 
						if (select count(*) from ArtistaXEvento where idArtista=@idArtista and idFecha=@idFecha)>0
							begin

								if (@fechaHoraInicio is not null)
									begin
										begin try
											--validar formato
											set @fechaIni = CONVERT(SMALLDATETIME, CAST(@fechaHoraInicio AS datetime));
											--Si pasa esporque esta bien
											--Validar que sea el dia del evento
											if (select DATEDIFF(day,(select fechaHora from FechaEvento where idFecha=@idFecha),@fechaIni))=0 
												begin
													begin transaction
														
														update ArtistaXEvento set fechaHoraIncio=@fechaIni where idArtista=@idArtista and idFecha=@idFecha;

													commit transaction
												end
										end try
										begin catch
											print 'Ha ocurrido un error. Error 17. El formato de la fecha debe ser "mm-dd-yyy hh:mm:ss".'
											rollback
										end catch


									end
								if (@fechaHoraFinal is not null)
									begin
										begin try
											--validar formato
											set @fechaFinal = CONVERT(SMALLDATETIME, CAST(@fechaHoraFinal AS datetime));
											--Si pasa esporque esta bien
											--Validar que sea el dia del evento
											if (select DATEDIFF(day,(select fechaHora from FechaEvento where idFecha=@idFecha),@fechaFinal))=0 
												begin
													begin transaction

														update ArtistaXEvento set fechaHoraFinalizacion=@fechaFinal where idArtista=@idArtista and idFecha=@idFecha;

													commit transaction
												end
										end try
										begin catch
											print 'Ha ocurrido un error. Error 18. El formato de la fecha debe ser "mm-dd-yyy hh:mm:ss".'
											rollback
										end catch
									end
								if (@estado is not null)
									begin
										if (select count (*) from Estado where idEstado=@estado)>0
											begin
												begin transaction
													
													update ArtistaXEvento set estado=@estado where idArtista=@idArtista and idFecha=@idFecha;

												commit transaction

											end
										else
										begin
											set @error=25;
											set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
												'. No existe estado con el @estado ingresado.';
											RAISERROR ('Error interno',16,1);
										end
									end
							end
						else--no existe
							begin
								set @error=16;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
									'. No existe artista x evento con el @idArtista y @idFecha ingresadas.';
								RAISERROR ('Error interno',16,1);
							end
					end
			end
			else if(@opcion=4)begin--Eliminar
				--Validar nulos
				if (@idArtista is null)
					begin
						set @error=19;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
							'. Debe ingresar el paraemtro @idArtista.';
						RAISERROR ('Error interno',16,1);
					end
				else if (@idFecha is null)
					begin
						set @error=20;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
							'. Debe ingresar el paraemtro @idFecha.';
						RAISERROR ('Error interno',16,1);
					end
				else--si ingresaron parametros
					begin
						--valiar que existe
						if(select count(*) from ArtistaXEvento where idArtista=@idArtista and idFecha=@idFecha)>0
							begin
								begin transaction

									update ArtistaXEvento set estado=-1 where idArtista=@idArtista and idFecha=@idFecha;

								commit transaction
							end
						else
							begin
								set @error=21;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
									'. No existe artista x evento con el @idArtista y @idFecha ingresadas.';
								RAISERROR ('Error interno',16,1);
							end
					end
			end
			else if (@opcion=5)
				begin
					begin transaction
						select idArtista,idFecha,fechaHoraIncio,fechaHoraFinalizacion,estado from ArtistaXEvento;
					commit transaction
				end
			else
				begin
					set @error=2;
					set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar una @opcion valida.';
					RAISERROR ('Error interno',16,1); end
		end
	end try
	begin catch--Atrapa cualquier error en la transaccion.
			print @errorMsg;
	end catch
	end

	/*
		--Insertar
		exec spArtistaXEvento null,null,null,null,null;--Error 1. opcion nula. FUNCIONA
		exec spArtistaXEvento 78,null,null,null,null;--Error 2. opcion invalida. FUNCIONA
		exec spArtistaXEvento 1,null,null,null,null;--Error 3. id fecha nula . FUNCIONA
		exec spArtistaXEvento 1,9,null,null,null;--Error 4. id artista nulo. FUNCIONA
		exec spArtistaXEvento 1,9,1,null,null;--Error 5. fecha inicio nula. FUNCIONA
		exec spArtistaXEvento 1,9,1,'2022-08-20 17:00:00',null;--Error 6. fecha final nula. FUNCIONA
		exec spArtistaXEvento 1,9,1,'202208-20 17:00:00','2022-08-20 18:00:00';--Error 9. formato malo. FUNCIONA

		exec spArtistaXEvento 1,9,1,'2022-08-20 17:00:00','2022-08-20 18:00:00';--Insertar funciona
		exec spArtistaXEvento 1,9,3,'2022-08-20 16:00:00','2022-08-20 17:00:00';--Insertar funciona
		--Consultar
		exec spArtistaXEvento 2,null,null,null,null,null;--Error 11. id artista nulo. FUNCIONA
		exec spArtistaXEvento 2,null,1,null,null,null;--Error 12. id fecha nula. FUNCIONA
		exec spArtistaXEvento 2,78,1,null,null,null;--Error 13. no existe artista x evento. FUNCIONA
		exec spArtistaXEvento 2,9,100,null,null,null;--Error 13. no existe artista x evento. FUNCIONA
		exec spArtistaXEvento 2,9,1,null,null,null;--Consultar funciona
		exec spArtistaXEvento 2,9,3,null,null,null;--Consultar funciona
		--Modificar
		exec spArtistaXEvento 3,null,null,null,null,null;--Error 14. id artista nulo. FUNCIONA
		exec spArtistaXEvento 3,null,3,null,null,null;--Error 15. id fecha nula. FUNCIONA
		exec spArtistaXEvento 3,9,3,null,null,null;--No modificar poruqe no se ignresaron las fechas.
		exec spArtistaXEvento 3,9,3,'2022-08-20 16:30:00',null,null;--Modificar funciona
		exec spArtistaXEvento 2,9,3,null,null,null;--Consultar funciona
		exec spArtistaXEvento 3,9,3,null,null,1;--Modificar funciona
		exec spArtistaXEvento 2,9,3,null,null,null;--Consultar funciona
		--Eliminar
		exec spArtistaXEvento 4,null,null,null,null,null;--Error 19. id artista nulo. FUNCIONA
		exec spArtistaXEvento 4,null,3,null,null,null;--Error 19. id fecha nula. FUNCIONA
		exec spArtistaXEvento 4,80,3,null,null,null;--Error 21. no existe artista x fecha . FUNCIONA
		exec spArtistaXEvento 4,9,3,null,null,null;--Eliminar funciona

		select * from ArtistaXEvento;
		select * from Artista;
		select * from FechaEvento;
		*/
END
GO
----------------------------------------------------------------------------------------
--CRUD Tipo Entrada
GO
CREATE PROCEDURE spTipoEntrada @opcion int,@idTipoEntrada int, @idTipoAsiento int,
								@recargoServicio float,@precio float,@estado int with encryption AS
BEGIN
	declare @error int, @errorMsg varchar(200);
	--Validar opcion
	begin
	begin try
	if (@opcion is null)begin
		set @error=1;
		set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar el parametro @opcion';
		RAISERROR ('Error interno',16,1); end
	else
		begin
			if (@opcion=1)begin--Insertar
				--Validar nulos
				if (@idTipoAsiento is null)
					begin
						set @error=3;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
									'. Debe ingresar el parametro @idTipoAsiento.';
						RAISERROR ('Error interno',16,1);
					end
				else if(@recargoServicio is null)
					begin
						set @error=4;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
										'.Debe ingresar el parametro @recargoServicio';
						RAISERROR ('Error interno',16,1);
					end
				else if (@precio is null)
					begin
						set @error=5;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
										'.Debe ingresar el parametro @precio';
						RAISERROR ('Error interno',16,1);
					end
				else 
					begin
						--Validar foraneas
						if (select count(*) from TipoAsiento where numeroAsiento=@idTipoAsiento)>0
							begin
								--Validar repetidos
								if (select count(*) from TipoEntrada where idTipoAsiento=@idTipoAsiento)=0
									begin--no hay tipo de entrada con ese tipo de asiento
										--validar recargo y precio.
										if (@recargoServicio<0)
											begin
												set @error=8;
												set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
														'. Debe ingresar un @recargoServicio > 0.';
												RAISERROR ('Error interno',16,1);
											end
										else
											begin
												if (@precio<0)
													begin
														set @error=9;
														set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
																'. Debe ingresar un @precio > 0.';
														RAISERROR ('Error interno',16,1);

													end
												else	
													begin
														begin transaction

															insert into TipoEntrada(idTipoAsiento,recargoTipoServicio,precio,estado) values
																				(@idTipoAsiento,@recargoServicio,@precio,1);

														commit transaction
													end
											end
									end
								else
									begin
										set @error=7;
										set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
												'. Ya existe una entrada con el @idTipoAsiento ingresado.';
										RAISERROR ('Error interno',16,1);
									end
							end
						else--no existe tipo asiento
							begin
								set @error=6;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
										'. No existe tipo de asiento con el @idTipoAsiento ingresado.';
								RAISERROR ('Error interno',16,1);
							end
					end
			end
			else if (@opcion=2)begin--Consultar
				--Validar nulos
				if (@idTipoEntrada is null)
					begin
						set @error=10;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
								'. Debe ingresar el parametro @idTipoEntrada.';
						RAISERROR ('Error interno',16,1);
					end
				else
					begin
					--validar que exista
						if (select count(*) from TipoEntrada where idTipoEntrada=@idTipoEntrada)>0
							begin
								begin transaction
									
									select TipoAsiento.nombre as tipoAsiento, TipoEntrada.precio as precio, 
									TipoEntrada.recargoTipoServicio as recargoServicio,Estado.nombre as estado from TipoEntrada inner join 
									TipoAsiento on TipoAsiento.numeroAsiento=TipoEntrada.idTipoAsiento inner join
									Estado on Estado.idEstado=TipoEntrada.estado 
									where idTipoEntrada=@idTipoEntrada;

								commit transaction

							end
						else
							begin
								set @error=11;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
										'. No existe tipo de entrada con el @idTipoEntrada ingresado.';
								RAISERROR ('Error interno',16,1);

							end

					end
			end
			else if(@opcion=3)begin--Modificar
				--Validar nulos
				if (@idTipoEntrada is null)
					begin
						set @error=12;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
								'. Debe ingresar parametro @idTipEntrada.';
						RAISERROR ('Error interno',16,1);
					end
				else--si ingresaron parametro
					begin
						if (select count(*) from TipoEntrada where idTipoEntrada=@idTipoEntrada)>0
						begin
							if (@recargoServicio is not null)
								begin
									if (@recargoServicio>0)
										begin
											begin transaction
											
												update TipoEntrada set recargoTipoServicio=@recargoServicio where TipoEntrada.idTipoEntrada=@idTipoEntrada;

											commit transaction

										end
									else
										begin
											set @error=13;
											set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
												'. Debe ingresar @recargoServicio > 0 .';
											RAISERROR ('Error interno',16,1);
										end
								end
							if (@estado is not null)
								begin
									if (select count(*) from Estado where idEstado=@estado)>0
										begin
											begin transaction

											update TipoEntrada set estado=@estado where TipoEntrada.idTipoEntrada=@idTipoEntrada;

											commit transaction

										end
									else 
										begin
											set @error=14;
											set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
												'. No existe @estado ingresado.';
											RAISERROR ('Error interno',16,1);

										end
								end
							if (@precio is not null)
								begin
									if (@precio>0)
										begin
											begin transaction
											
												update TipoEntrada set precio=@precio where TipoEntrada.idTipoEntrada=@idTipoEntrada;

											commit transaction

										end
									else
										begin
											set @error=15;
											set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
												'. Debe ingresar @precio > 0 .';
											RAISERROR ('Error interno',16,1);
										end
								end
						end
				else
					begin
						set @error=22;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
							'. No existe entrada con el @idEntrada ingresado.';
						RAISERROR ('Error interno',16,1);

					end
				end
			end
			else if(@opcion=4)begin--Eliminar
				if (@idTipoEntrada is null)
					begin
						set @error=16;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
							'. Debe ingresar el parametro @idTipoEntrada';
						RAISERROR ('Error interno',16,1);
					end
				else
					begin
						--validar que existe
						if (select count(*) from TipoEntrada where idTipoEntrada=@idTipoEntrada)>0
							begin
								begin transaction
									
									update TipoEntrada set estado=-1 where idTipoEntrada=@idTipoEntrada;

								commit  transaction
							end
						else
							begin
								set @error=17;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
									'. No existe tipo entrada con el @idTipoEntrada ingresado.';
								RAISERROR ('Error interno',16,1);
							end
					end
			end
			else if (@opcion=5)
				begin
					begin transaction
						select idTipoEntrada,idTipoAsiento as tipoAsiento,precio,recargoTipoServicio,TipoEntrada.estado from TipoEntrada;
					commit transaction
				end
			else
				begin
					set @error=2;
					set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar una @opcion valida.';
					RAISERROR ('Error interno',16,1); end
		end
	end try
	begin catch--Atrapa cualquier error en la transaccion.
			print @errorMsg;
	end catch
	end

			/*
		--Insertar
		exec spTipoEntrada null,null,null,null,null,null;--Erro 1. opcion nula. FUNCIONA
		exec spTipoEntrada 45,null,null,null,null,null;--Erro 2. opcion invalida. FUNCIONA
		exec spTipoEntrada 1,null,null,null,null,null;--Erro 3. id tipo asiento nulo. FUNCIONA
		exec spTipoEntrada 1,null,null,null,null,null;--Erro 3. id tipo asiento nulo. FUNCIONA
		exec spTipoEntrada 1,null,1,null,null,null;--Erro 4. recargo nulo. FUNCIONA
		exec spTipoEntrada 1,null,1,6500,null,null;--Erro 5. precio nulo. FUNCIONA
		exec spTipoEntrada 1,null,1,6500,60000,null;--Error 7. entrada repetida. FUNCIONA
		exec spTipoEntrada 1,null,2,-4,60000,null;--Error 8. recargo negativo. FUNCIONA
		exec spTipoEntrada 1,null,2,4000,-30000,null;--Error 9. precio negativo. FUNCIONA


		--Consultar
		exec spTipoEntrada 2,null,null,null,null,null;--Erro 10. id entrada nulo. FUNCIONA
		exec spTipoEntrada 2,44,null,null,null,null;--Erro 11. no existe. FUNCIONA
		exec spTipoEntrada 2,1,null,null,null,null;--Consultar funciona
		--Modificar
		exec spTipoEntrada 3,null,null,null,null,null;--Error 12. id entrada nulo. FUNCIONA
		exec spTipoEntrada 3,78,null,null,null,null;--Error 22. id entrada no existe. FUNCIONA
		exec spTipoEntrada 3,1,null,3000,null,null;--Modificar funciona
		exec spTipoEntrada 3,1,null,null,50000,null;--Modificar funciona
		exec spTipoEntrada 3,1,null,null,null,2;--Modificar funciona
		exec spTipoEntrada 3,1,null,null,null,1;--Modificar funciona
		exec spTipoEntrada 2,1,null,null,null,null;--Consultar funciona
		--Eliminar
		exec spTipoEntrada 4,null,null,null,null,null;--Error 16. id entrada nulo. FUNCIONA
		exec spTipoEntrada 4,78,null,null,null,null;--Error 27. id entrada no existe. FUNCIONA
		exec spTipoEntrada 4,1,null,null,null,null;--Eliminar funciona
		exec spTipoEntrada 2,1,null,null,null,null;--Consultar funciona
		select * from TipoEntrada;
		select* from TipoAsiento;
		*/
END
GO
----------------------------------------------------------------------------------------
--CRUD Entrada
GO
CREATE PROCEDURE spEntrada @opcion int, @idEntrada int,@idTipoEntrada int,@idFechaEvento int,@estado int with encryption AS
BEGIN
	declare @error int, @errorMsg varchar(200);
	--Validar opcion
	begin
	begin try
	if (@opcion is null)begin
		set @error=1;
		set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar el parametro @opcion';
		RAISERROR ('Error interno',16,1); end
	else
		begin
			if (@opcion=1)begin--Insertar entrada, se usa cuando se compra.
				--Validar nulos
				if (@idTipoEntrada is null)
					begin
						set @error=3;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
									'.Debe ingresar el parametro @idTipoEntrada';
						RAISERROR ('Error interno',16,1); 
					end
				else if (@idFechaEvento is null)
					begin
						set @error=4;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
									'.Debe ingresar el parametro @idFechaEvento';
						RAISERROR ('Error interno',16,1); 
					end
				else--si ingresaron parametros
					begin
						--validar que exista el tipo de entrada y este disponible
						if (select count(*) from TipoEntrada where idTipoEntrada=@idTipoEntrada and TipoEntrada.estado=1)>0
							begin--validar que el evento exista y este disponible
							if (select count(*) from FechaEvento where idFecha=@idFechaEvento and FechaEvento.estado=1)>0
								begin try
									begin transaction
										
										--Validar que hayan existencias
										if (select TipoAsiento.cantidad from TipoEntrada inner join
											TipoAsiento on TipoAsiento.numeroAsiento=TipoEntrada.idTipoAsiento
											where idTipoEntrada=@idTipoEntrada and TipoEntrada.estado=1)>0
											begin
												--Crea la entrada con el tipo de entrada que me pasaron para el evento que me pasaron
												insert into Entrada(idTipoEntrada,estado,idFechaEvento) values
														(@idTipoEntrada,4,@idFechaEvento);--4 porque es el id de Vendida.
												
												--Como acaba de crear una entrada (y si uno crea una entrada es porque la vendio) se 
												--actualiza la cantidad de tipo de asiento.
												update TipoAsiento set cantidad=(cantidad-1) from TipoAsiento
												inner join TipoEntrada on TipoEntrada.idTipoEntrada=TipoAsiento.numeroAsiento
												where TipoAsiento.numeroAsiento=TipoEntrada.idTipoAsiento and TipoEntrada.idTipoEntrada=@idTipoEntrada;
												
											end
										else
											begin 
												set @error=7;
												set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
														'. No hay suficientes entradas del tipo @idTipoEntrada.';
												RAISERROR ('Error interno',16,1); 
											end
									commit transaction
								end try
								begin catch
									--print @errorMsg;
									print 'Ha ocurrido un error.';
									rollback;
								end catch
							else
								begin
									set @error=6;
									set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
											'. No existe fecha de evento con el @idFechaEvento ingresada..';
									RAISERROR ('Error interno',16,1); 
								end
							end
						else
							begin
								set @error=5;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
										'. No existe tipo de entrada con @idTipoEntrada ingresado.';
								RAISERROR ('Error interno',16,1); 
							end
					end
			end
			else if (@opcion=2)begin--Consultar
				--Validar nulos
				if (@idEntrada is null)
					begin
						set @error=8;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
									'. Debe ingresar parametro @idEntrada.';
						RAISERROR ('Error interno',16,1); 
					end
				else--si ingresaron parametro
					begin--validar que exista
						if (select count(*) from Entrada where idEntrada=@idEntrada)>0
							begin--si existe
								begin transaction
									
									select Entrada.idEntrada as idEntrada,TipoAsiento.nombre as tipoEntrada, 
									Evento.nombre as nombreEvento,Pais.nombre as pais, LugarEvento.nombre as lugar,
									LugarEvento.detalleUbicacion as ubicacion, FechaEvento.fechaHora as fechaEvento, Estado.nombre as estado
									from Entrada inner join 
									FechaEvento on FechaEvento.idFecha=Entrada.idFechaEvento inner join
									EventoXPais on EventoXPais.idEvento=FechaEvento.idEvento and EventoXPais.idPais=FechaEvento.idPais inner join
									LugarEvento on LugarEvento.idLugar = EventoXPais.idLugar inner join
									Evento on Evento.idEvento=EventoXPais.idEvento inner join
									Pais on Pais.idPais=EventoXPais.idPais inner join
									Estado on Estado.idEstado=Entrada.estado inner join
									TipoEntrada on TipoEntrada.idTipoEntrada=Entrada.idTipoEntrada inner join
									TipoAsiento on TipoAsiento.numeroAsiento=TipoEntrada.idTipoAsiento
									where idEntrada=@idEntrada;

								commit transaction
							end
						else
							begin
								set @error=9;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
									'. No existe entrada con el @idEntrada ingresado.';
								RAISERROR ('Error interno',16,1); 

							end
					end
			end
			else if(@opcion=3)begin--Modificar
				if (@idEntrada is null)-- solo se puede modificar el estado.
					begin
						set @error=10;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
							'. Debe ingresar el parametro @idEntrada.';
						RAISERROR ('Error interno',16,1); 
					end
				else--si ingresaron parametro
					begin
					if (select count(*) from Entrada where idEntrada=@idEntrada)>0
						begin
						if (@estado is not null)
							begin
								if (select count(*) from Estado where idEstado=@estado)>0
									begin
										begin transaction

											update Entrada set estado=@estado where idEntrada=@idEntrada;

										commit transaction
									end
								else
									begin
										set @error=11;
										set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
											'. No existe estado con el @estado ingresado.';
										RAISERROR ('Error interno',16,1); 
									end
							end
						end
					else
						begin
							set @error=14;
							set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
								'. No existe entrada con el @idEntrada ingresado.';
							RAISERROR ('Error interno',16,1); 
						end
					end
			end
			else if(@opcion=4)begin--Eliminar
				--Valiar nulos
				if (@idEntrada is null)-- solo se puede modificar el estado.
					begin
						set @error=12;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
							'. Debe ingresar el parametro @idEntrada.';
						RAISERROR ('Error interno',16,1); 
					end
				else--ingresaron idEntrada
					begin
						--validar que existe
						if (select count(*) from Entrada where idEntrada=@idEntrada)>0
							begin
							begin try
								begin transaction
									--Elimina la entrada
									update Entrada set estado=-1 where idEntrada=@idEntrada;
									--Si el evento no ha sido eliminado se regresa el campo al tipo de asiento para que alguien mas lo pueda comprar.
									if (select FechaEvento.estado from Entrada inner join FechaEvento on FechaEvento.idFecha=Entrada.idFechaEvento
									where idEntrada=@idEntrada)!=-1
										begin
											update TipoAsiento set cantidad=(cantidad+1) from TipoAsiento
											inner join TipoEntrada on TipoEntrada.idTipoEntrada=TipoAsiento.numeroAsiento inner join
											Entrada on Entrada.idTipoEntrada=TipoEntrada.idTipoEntrada
											where TipoAsiento.numeroAsiento=TipoEntrada.idTipoAsiento and TipoEntrada.idTipoEntrada=Entrada.idTipoEntrada
											and Entrada.idEntrada=@idEntrada;
												
										end
								commit transaction
							end try
							begin catch
								print 'Ha ocurrido un error.'
								rollback
							end catch
							end
						else
							begin
								set @error=13;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
									'. No existe entrada con el @idEntrada.';
								RAISERROR ('Error interno',16,1); 
							end
					end
			end
			else if (@opcion=5)
				begin
					select Entrada.idEntrada,Entrada.idFechaEvento,Entrada.idTipoEntrada,Entrada.estado from Entrada;
				end
			else
				begin
					set @error=2;
					set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar una @opcion valida.';
					RAISERROR ('Error interno',16,1); end
		end
	end try
	begin catch--Atrapa cualquier error en la transaccion.
			print @errorMsg;
	end catch
	end


	/*
	--Insertar
	exec spEntrada null,null,null,null,null;--error 1. opcion nula. FUNCIONA
	exec spEntrada 45,null,null,null,null;--Erro 2. opcion no existe. FUNCIONA
	exec spEntrada 1,null,null,null,null;--Erro 3. id tipo entrada nulo. FUNCIONA
	exec spEntrada 1,null,1,null,null;--Erro 4. id fecha evento nula. FUNCIONA

	exec spEntrada 1,null,1,5,null;--Insertar funciona
	exec spEntrada 1,null,3,5,null;--
	--Consultar
	exec spEntrada 2,null,null,null,null;--Error 8.  id entrada nulo. FUNCIONA
	exec spEntrada 2,78,null,null,null;--Error 9. no existe id entrada. FUNCIONA
	exec spEntrada 2,1,null,null,null;--Consultar funciona
	--Modificar
	exec spEntrada 3,null,null,null,null;--Error 10. id entrada nulo. FUNCIONA
	exec spEntrada 3,17,null,null,null;--Error 14. no existe entrada. FUNCIONA
	exec spEntrada 3,1,null,null,4;--Modificar funciona
	exec spEntrada 2,1,null,null,null;--Consultar funciona
	--Eliminar
	exec spEntrada 4,null,null,null,null;--Error 12. id entrada nulo. FUNCIONA
	exec spEntrada 4,17,null,null,null;--Error 13. no existe entrada. FUNCIONA
	exec spEntrada 4,1,null,null,null;--Eliminar funciona
	exec spEntrada 2,1,null,null,null;--Consultar funciona

	select * from Entrada;
	select * from TipoEntrada;
	select * from TipoAsiento;
	select * from FechaEvento;
	*/

END
GO
---------------------------------------------------------------------------------------
--CRUD Cliente
GO
CREATE PROCEDURE spCliente @opcion int, @idCliente int, @nombre varchar(25), @primerApellido varchar(25),
						   @segundoApellido varchar(25),@fechaNacimiento varchar(10),@correo varchar(50),@telefono int,
						   @contrasenna varchar(16),@contraVieja varchar(16),@estado int with encryption AS
BEGIN
	declare @error int, @errorMsg varchar(200);
	declare @fechaDate date;
	--Validar opcion
	begin
	begin try
	if (@opcion is null)begin
		set @error=1;
		set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar el parametro @opcion';
		RAISERROR ('Error interno',16,1); end
	else
		begin
			if (@opcion=1)begin--Insertar
				--Validar nulos
				if (@nombre is null)
					begin
						set @error=3;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar el parametro @nombre.';
						RAISERROR ('Error interno',16,1);
					end
				else if(@primerApellido is null)
					begin
						set @error=4;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar el parametro @primerApellido.';
						RAISERROR ('Error interno',16,1);
					end
				else if(@segundoApellido is null)
					begin
						set @error=5;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar el parametro @segundoApellido.';
						RAISERROR ('Error interno',16,1);
					end
				else if(@fechaNacimiento is null)
					begin
						set @error=6;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar el parametro @fechaNacimiento';
						RAISERROR ('Error interno',16,1);
					end
				else if(@correo is null)
					begin
						set @error=7;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar el parametro @correo';
						RAISERROR ('Error interno',16,1);
					end
				else if(@telefono is null)
					begin
						set @error=8;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar el parametro @telefono';
						RAISERROR ('Error interno',16,1);
					end
				else if(@contrasenna is null)
					begin
						set @error=9;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar el parametro @cotnasenna';
						RAISERROR ('Error interno',16,1);
					end
				else--ingresaron parametros
					begin
						--Validar repetidos, el nombre y apellidos pueden repetirse.
						
						--validar telefono repetido
						if (select count(*) from Cliente where telefono=@telefono)>0
							begin
								set @error=11;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'. Ya existe un cliente
									con el @telefono ingresado.';
								RAISERROR ('Error interno',16,1);
							end
						else--telefono disponible
							begin--validar correo
								if (select count(*) from Cliente where correo=@correo)>0
									begin
										set @error=12;
										set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'. El @correo ingresado
											ya pertenece a un cliente registrado.';
											RAISERROR ('Error interno',16,1);
									end
								else--correo disponible
									begin
										--Todo disponible
										begin try
										set @fechaDate = CONVERT(DATE, CAST(@fechaNacimiento AS datetime));

										begin transaction

											insert into Cliente(nombre,primerApellido,segundoApellido,fechaNacimiento,
															correo,telefono,contrasenna,estado) values
															(@nombre,@primerApellido,@segundoApellido,@fechaDate,
															@correo,@telefono,@contrasenna,1);

										commit transaction
										end try
										begin catch
											print 'Error, la fecha debe tener el formato "mm-dd-yyyy".'
											--RAISERROR ('Error interno',16,1);
										end catch
									end
							end
					end
			end
			else if (@opcion=2)begin--Consultar
				--para consultar un cliente si no se tiene el id se creo otra funcion de inicio de sesion para usar el correo y contrasenna
				--para entrar a la app entonces eso retornaria el id del cliente que se utilizara para todo lo demas relacionado con el cliente.
				--Validar nulos
				if (@idCliente is null)
					begin
						set @error=13;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'. Debe ingresar el parametro @idCliente.';
							RAISERROR ('Error interno',16,1);
					end
				else
					begin
						--Validar que exista
						if (select count(*) from Cliente where idCliente=@idCliente)>0
							begin--si existe
								begin transaction
									
									select C.nombre,C.primerApellido,C.segundoApellido,C.fechaNacimiento,C.correo,C.telefono,
									Estado.nombre as estado from Cliente as C inner join Estado
									on Estado.idEstado=C.estado where idCliente=@idCliente;

								commit transaction
							end
						else--no existe
							begin
								set @error=14;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'. No existe
									 cliente con el @idCliente ingresado.';
								RAISERROR ('Error interno',16,1);
							end
					end
			end
			else if(@opcion=3)begin--Modificar
				if (@idCliente is null)
					begin
						set @error=15;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'. Debe ingresar el parametro @idCliente.';
							RAISERROR ('Error interno',16,1);
					end
				else--si ingresaron id cliente
					begin
						--validar que existe
						if (select count(*) from Cliente where idCliente=@idCliente)>0
							begin--si existe
							--El cliente puede cambiar toda su informacion menos el id
							if (@nombre is not null) begin
								begin  transaction
									update Cliente set nombre=@nombre where idCliente=@idCliente;
								commit transaction end
							if (@primerApellido is not null) begin
								begin  transaction
									update Cliente set primerApellido=@primerApellido where idCliente=@idCliente;
								commit transaction end
							if (@segundoApellido is not null)begin
								begin  transaction
									update Cliente set segundoApellido=@segundoApellido where idCliente=@idCliente;
								commit transaction end
							if (@fechaNacimiento is not null)begin
								begin try

								set @fechaDate=CONVERT(DATE, CAST(@fechaNacimiento AS datetime));


								begin  transaction
									update Cliente set fechaNacimiento=@fechaDate where idCliente=@idCliente;
								commit transaction 

								end try
								begin catch
									print 'Error, la fecha debe tener formato "mm-dd-yyyy".'
									--RAISERROR ('Error interno',16,1);end
								end catch
								end

							if (@correo is not null) begin
								if (select count(*) from Cliente where correo=@correo)>0 begin
										set @error=16;
										set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
										'. El @correo ingresado ya esta registrado.'; 
											RAISERROR ('Error interno',16,1);end
								else begin
									begin  transaction
									update Cliente set correo=@correo where idCliente=@idCliente;
									commit transaction end
								end
							if (@telefono is not null) begin
								if (select count(*) from Cliente where telefono=@telefono)>0 begin
										set @error=17;
										set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
												'. El @telefono ingresado ya esta registrado.';
										RAISERROR ('Error interno',16,1); end
								else begin
									begin  transaction
									update Cliente set telefono=@telefono where idCliente=@idCliente;
									commit transaction end
								end
							if (@contraVieja is not null and @contrasenna is not null) begin
								if ((select contrasenna from Cliente where idCliente=@idCliente)=@contraVieja) begin
									begin  transaction
									update Cliente set contrasenna=@contrasenna where idCliente=@idCliente;
									commit transaction end
								else begin
										set @error=18;
										set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
												'. La @contraVieja no coincide con la registrada.';
										RAISERROR ('Error interno',16,1); end
								end
							end
							if (@estado is not null)
								begin
								if (select count(*) from Estado where idEstado=@estado)>0
									begin
										begin transaction

										update Cliente set estado=@estado where idCliente=@idCliente;

										commit transaction

									end
								else	
									begin
									set @error=24;
										set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
												'.  No existe estado con el @estado ingresado.';
										RAISERROR ('Error interno',16,1); 
									end
								end
						else--no existe
							begin
								set @error=19;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'. No existe cliente con el @idCliente ingresado.';
								RAISERROR ('Error interno',16,1);
							end
					end
			end
			else if(@opcion=4)begin--Eliminar
				--Validar nulos
				if (@idCliente is null)
					begin
						set @error=13;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'. Debe ingresar el parametro @idCliente.';
							RAISERROR ('Error interno',16,1);
					end
				else
					begin
						--Validar que exista
						if (select count(*) from Cliente where idCliente=@idCliente)>0
							begin--si existe
								begin transaction
									
									update Cliente set estado=-1 where idCliente=@idCliente;

								commit transaction
							end
						else--no existe
							begin
								set @error=20;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'. No existe
									 cliente con el @idCliente ingresado.';
								RAISERROR ('Error interno',16,1);
							end
					end
			end
			else if (@opcion=5)
				begin
					begin transaction
						select Cliente.idCliente,Cliente.nombre,Cliente.primerApellido,Cliente.segundoApellido,Cliente.fechaNacimiento,
						Cliente.correo,Cliente.telefono,Cliente.estado from Cliente;
					commit transaction
				end
			else
				begin
					set @error=2;
					set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar una @opcion valida.';
					RAISERROR ('Error interno',16,1); end
		end
	end try
	begin catch--Atrapa cualquier error en la transaccion.
			print @errorMsg;
	end catch
	end
	/*
	--Insertar
	exec spCliente null,null,null,null,null,null,null,null,null,null,null;--Error 1. opcion nula. FUNCIONA
	exec spCliente 8,null,null,null,null,null,null,null,null,null,null;--Error 2. opcion invalida. FUNCIONA
	exec spCliente 1,null,null,null,null,null,null,null,null,null,null;--Error 3. nombre nulo. FUNCIONA
	exec spCliente 1,null,'Felipe',null,null,null,null,null,null,null,null;--Error 4. primer apellido nulo. FUNCIONA
	exec spCliente 1,null,'Felipe','Obando',null,null,null,null,null,null,null;--Error 5. segundo apellido nulo. FUNCIONA
	exec spCliente 1,null,'Felipe','Obando','Arrieta',null,null,null,null,null,null;--Error 6. fecha nula. FUNCIONA
	exec spCliente 1,null,'Felipe','Obando','Arrieta','10-31-2001',null,null,null,null,null;--Error 7. correo nulo. FUNCIONA
	exec spCliente 1,null,'Felipe','Obando','Arrieta','10-31-2001','felipeobando2001@gmail.com',null,null,null,null;--Error 8. telefono nulo. FUNCIONA
	exec spCliente 1,null,'Felipe','Obando','Arrieta','10-31-2001','felipeobando2001@gmail.com',70130686,'contra',null,null;--Error 11. telefono repetido. FUNCIONA
	exec spCliente 1,null,'Felipe','Obando','Arrieta','10-31-2001','felipeobando2001@gmail.com',70130681,'contra',null,null;--Error 12. correo repetido. FUNCIONA
	exec spCliente 1,null,'Felipe','Obando','Arrieta','1031-2001','felipeobando@hotmail.com',70130682,'contra',null,null;--Error formtato fecha. FUNCIONA

	--Consultar
	exec spCliente 2,null,null,null,null,null,null,null,null,null,null;--Error 13. id cliente nulo. FUNCIONA
	exec spCliente 2,78,null,null,null,null,null,null,null,null,null;--Error 14. no existe clisnte. FUNCIONA
	exec spCliente 2,1,null,null,null,null,null,null,null,null,null;--Consultar funciona
	--Modificar 
	exec spCliente 3,null,null,null,null,null,null,null,null,null,null;--Error 15. id cliente nulo. FUNCIONA
	exec spCliente 3,1,null,null,null,null,null,null,null,null,null;--Error 15. id cliente nulo. FUNCIONA
	exec spCliente 3,1,null,null,null,'0102-1990',null,null,null,null,2;--Error formato fecha malo. FUNCIONA
	exec spCliente 3,1,null,null,null,null,null,null,'otraContrasenna','contraASD',2;--Error 18. contra vieja mala. FUNCIONA
	exec spCliente 3,1,null,null,null,null,null,null,null,null,2;--Modificar funciona
	exec spCliente 3,1,'Juan',null,null,null,null,null,null,null,2;--Modificar funciona
	exec spCliente 3,1,null,'Piedra',null,null,null,null,null,null,2;--Modificar funciona
	exec spCliente 3,1,null,null,'Berrocal',null,null,null,null,null,2;--Modificar funciona
	exec spCliente 3,1,null,null,null,'01-02-1990',null,null,null,null,2;--Modificar funciona
	exec spCliente 3,1,null,null,null,null,null,10101010,null,null,2;--Modificar funciona
	exec spCliente 3,1,null,null,null,null,null,null,'otraContrasenna','contra',2;--Modificar funciona
	exec spCliente 3,1,null,null,null,null,null,null,'otraContrasenna','contra',2;--Modificar funciona
	exec spCliente 3,1,'Felipe','Obando','Arrieta','10-31-2001','felipeobando2001@gmail.com',70130686,'contra','otraContrasenna',1;
	--Eliminar
	exec spCliente 4,null,null,null,null,null,null,null,null,null,null;--Error 13. id cliente nulo. FUNCIONA
	exec spCliente 4,64,null,null,null,null,null,null,null,null,null;--Error 20. cliente no existe. FUNCIONA
	exec spCliente 4,1,null,null,null,null,null,null,null,null,null;--Eliminar funciona
	select * from Cliente;
	*/

END
GO
---------------------------------------------------------------------------------------
--CRUD Metodo Pago
GO
CREATE PROCEDURE spMetodoPago @opcion int, @idMetodoPago int, @nombre varchar(25),@numeroTarjeta int,
								@fechaVencimiento varchar(10),@codigo int with encryption AS
BEGIN
	declare @error int, @errorMsg varchar(200);
	declare @fechaDate date;
	--Validar opcion
	begin
	begin try
	if (@opcion is null)begin
		set @error=1;
		set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar el parametro @opcion';
		RAISERROR ('Error interno',16,1); end
	else
		begin
			if (@opcion=1)begin--Insertar
				--Validar nulos
				if (@nombre is null)
					begin
						set @error=3;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'. Debe ingresar el parametro @nombre.';
						RAISERROR ('Error interno',16,1);
					end
				else if (@numeroTarjeta is null)
					begin
						set @error=4;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'. Debe ingresar el parametro @numeroTarjeta.';
						RAISERROR ('Error interno',16,1);
					end
				else if (@fechaVencimiento is null)
					begin
						set @error=5;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'. Debe ingresar el parametro @fechaVencimiento.';
						RAISERROR ('Error interno',16,1);
					end
				else if (@codigo is null)
					begin
						set @error=6;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'. Debe ingresar el parametro @codigo.';
						RAISERROR ('Error interno',16,1);
					end
				else--si ingresaron parametros
					begin
						--no tiene sentido que valide duplicados porque los clientes siempre tienen que ingresar la tarjeta
						--no es buena idea guardar las tarjetas de cada cliente.
						--validar fecha
						begin try 
							set @fechaDate=CONVERT(DATE, CAST(@fechaVencimiento AS datetime));
						end try
						begin catch
							print 'Error 7. El formato de fecha debe ser "01-dd-yyy".';--El 01 es porque las fechas solo contemplan mes y anno
							--entonces para guardar la fecha se guarda el primer dia del mes y anno que se ingresa.
						end catch
						--el numero se valida en el front end.
						begin transaction

							insert into MetodoPago(nombre,numeroTarjeta,fechaVencimiento,codigo,estado) values
										(@nombre,@numeroTarjeta,@fechaVencimiento,@codigo,1);
							
						commit transaction
						
					end
			end
			else if (@opcion=2)begin--Consultar
				--Valiar nulos
				if (@idMetodoPago is null)	
					begin
						set @error=8;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'. Debe ingresar el parametro @idMetodoPago.';
						RAISERROR ('Error interno',16,1);
					end
				else--si ingreso parametros
					begin
						--validar que existe
						if (select count(*) from MetodoPago where idMetodoPago=@idMetodoPago)>0
							begin
								begin transaction
									select idMetodoPago,nombre,numeroTarjeta,fechaVencimiento,codigo from MetodoPago where idMetodoPago=@idMetodoPago;
								commit transaction
							end
						else
							begin
								set @error=6;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'. No existe metodo de pago con @idMetodoPago ingresado..';
								RAISERROR ('Error interno',16,1);
							end
					end
			end
			else if (@opcion=3)
				begin
					begin transaction
						select MetodoPago.idMetodoPago,MetodoPago.nombre,MetodoPago.numeroTarjeta from MetodoPago;
					commit transaction
				end
			else
				begin
					set @error=2;
					set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'. No existe la @opcion ingresada.';
					RAISERROR ('Error interno',16,1);
				end
		end
	end try
	begin catch--Atrapa cualquier error en la transaccion.
			print @errorMsg;
	end catch
	end
	/*	
		--Insertar
		exec spMetodoPago null,null,null,null,null,null;--Erro 1. opcion nula . FUCIONA
		exec spMetodoPago 78,null,null,null,null,null;--Erro 2. opcion invalida. FUNCIONA
		exec spMetodoPago 1,null,null,null,null,null;--Erro 3. nombre nulo. FUNCIONA
		exec spMetodoPago 1,null,'Felipe Obando A.',null,null,null;--Erro 4. numero tarjeta nulo. FUNCIONA
		exec spMetodoPago 1,null,'Felipe Obando A.',1111111111,null,null;--Erro 5. fecha vencimiento nula. FUNCIONA
		exec spMetodoPago 1,null,'Felipe Obando A.',1111111111,'05-01-2024',null;--Error 6. codigo nulo FUNCIONA
		--Consultar
		exec spMetodoPago 2,null,null,null,null,null;--Error 8. idMetodo nulo.
		exec spMetodoPago 2,45,null,null,null,null;--Error 6. no existe metodo pago ingresado. FUNCIONA
		exec spMetodoPago 2,1,null,null,null,null;--Consultar funciona. si el codigo tiene un 0 de primer digito lo ignora.
	*/
END
GO
---------------------------------------------------------------------------------------
--CRUD Compra
GO
CREATE PROCEDURE spCompra @opcion int,@idCompra int,@idCliente int,@idMetodoPago int,@total float,@estado int with encryption AS
BEGIN
	/*
		Suponiendo que el cliente selecciono todo en la pagina web, se tiene el precio total que debe pagar,
		de esta manera puedo hacer la compra sin tener que buscar en todas los detalles que tengan el idCompra 
		porque en teoria aun la compra no se ha hecho, por tanto, no existe detalle con el idCompra.

		Primero se debe crear la compra y despues los detalles, la compra no se finaliza o termina (el estado no cambia) 
		hasta que el ultimo detalle termine de ingresarse. Como se que el ultimo detalle se realizo? Porque cada vez que inserte un detalle 
		se suma la de plata que llevan, entonces, hasta que la suma no sea igual al total de la compra, no se ha finalizado.
		
		Una vez se crea la compra, desde el otro lado van a tener que usar el idCompra que acabo de hacer para fabricar los 
		detalles y terminar el proceso de la compra.
	*/

	declare @error int, @errorMsg varchar(200);
	declare @fechaDate smalldatetime;
	declare @numeroCompra int=-1;
	--Validar opcion
	begin
	begin try
	if (@opcion is null)begin
		set @error=1;
		set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar el parametro @opcion';
		RAISERROR ('Error interno',16,1); end
	else
		begin
			if (@opcion=1)begin--Insertar
				--Codigo
				if (@idCliente is null)
					begin
						set @error=3;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar el parametro @idCliente.';
						RAISERROR ('Error interno',16,1);
					end
				else if (@idMetodoPago is null)
					begin
						set @error=4;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar el parametro @idMetodoPago.';
						RAISERROR ('Error interno',16,1);
					end
				else if (@total is null)
					begin
						set @error=6;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar el parametro @total.';
						RAISERROR ('Error interno',16,1);
					end
				else--si ingresaron parametros
					begin
						--Validar que existen
						if (select count(*) from Cliente where idCliente=@idCliente)>0
							begin--si existe el cliente
								if (select count(*) from MetodoPago where idMetodoPago=@idMetodoPago)>0
									begin
										if (@total>0)
											begin
												begin transaction--inserta
													insert into Compra(idCliente,idMetodoPago,fecha,total,estado) values
																	(@idCliente,@idMetodoPago,GETDATE(),@total,5);
													set @numeroCompra=@@IDENTITY;
												commit transaction
												--selecciona el idCompra para los detalles
												select @numeroCompra as idCompra;

											end
										else
											begin
												set @error=9;
												set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
													'.El @total debe ser > 0.';
												RAISERROR ('Error interno',16,1);
											end
									end
								else
									begin
										set @error=8;
										set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
											'.No existe metodo de pago con el @idMetodoPago ingresado..';
										RAISERROR ('Error interno',16,1);
									end
							end
						else--no existe cliente
							begin
								set @error=7;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.No existe cliente con el @idCliente ingresado..';
								RAISERROR ('Error interno',16,1);
							end
					end
			end
			else if (@opcion=2)begin--Consultar
				--validar nulos
				if (@idCompra is null)
					begin
						set @error=10;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
											'. Debe ingresar parametro @idCompra.';
						RAISERROR ('Error interno',16,1);
					end
				else
					begin
						if (select count(*) from Compra where idCompra=@idCompra)>0
							begin
								begin transaction

									select Compra.idCompra,Compra.idCliente,Compra.idMetodoPago,Compra.total,Compra.fecha,Estado.nombre
									from Compra inner join Estado on Estado.idEstado=Compra.estado where idCompra=@idCompra;

								commit transaction
							end
						else
							begin
								set @error=11;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
												'. No existe compra con el @idCompra ingresado.';
								RAISERROR ('Error interno',16,1);
							end
					end
			end
			else if(@opcion=3)begin--Modificar
				--validar nulos
				if (@idCompra is null)
					begin
						set @error=12;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
											'. Debe ingresar parametro @idCompra.';
						RAISERROR ('Error interno',16,1);
					end
				else
					begin
						if (select count(*) from Compra where idCompra=@idCompra)>0
							begin
								if (@estado is not null)
									begin
										if (select count(*) from Estado where idEstado=@estado)>0
											begin

												begin transaction
													
													update Compra set estado=@estado where idCompra=@idCompra;

												commit transaction

											end
										else
											begin
												set @error=13;
												set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
												'. No existe estado con el @estado ingresado..';
												RAISERROR ('Error interno',16,1);
											end
									end
							end
						else
							begin
								set @error=11;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
												'. No existe compra con el @idCompra ingresado.';
								RAISERROR ('Error interno',16,1);
							end
					end


			end
			else if (@opcion=4)--consultar todas las compras.
				begin
					begin transaction
						select Compra.idCompra,Compra.fecha,Compra.total,Compra.estado from Compra;	
					commit transaction
				end
			else
				begin
					set @error=2;
					set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar una @opcion valida.';
					RAISERROR ('Error interno',16,1); end
		end
	end try
	begin catch--Atrapa cualquier error en la transaccion.
			print @errorMsg;
	end catch
	end
	/*
	--Insertar
	exec spCompra null,null,null,null,null,null;--Erro 1. opcion nula. FUNCIONA
	exec spCompra 78,null,null,null,null,null;--Error 2. opcion invalida. FUNCIONA
	exec spCompra 1,null,null,null,null,null;--Error 3. id cliente nulo. FUNCIONA
	exec spCompra 1,null,1,null,null,null;--Error 4. id metodo pago nulo. FUNCIONA
	exec spCompra 1,null,1,1,null,null;--Error 6. total nulo. FUNCIONA

	--id compra = 1 -> Hacer detalles de las entradas con este idCompra.

	--Consultar
	exec spCompra 2,1,null,null,null,null;--Consultar funciona
	--Modificar
	exec spCompra 3,1,null,null,null,6;--Modificar funciona
	exec spCompra 2,1,null,null,null,null;--Consultar funciona
	exec spCompra 3,1,null,null,null,5;--Modificar funciona
	exec spCompra 2,1,null,null,null,null;--Consultar funciona


	select * from Estado;
	select * from Entrada;
	select * from TipoEntrada;
	select * from TipoAsiento;
	select * from FechaEvento;
	select * from Evento;
	select * from Compra;
	select * from Cliente;
	select * from MetodoPago;
	*/
END
GO
---------------------------------------------------------------------------------------
--CRUD Detalle
GO
CREATE PROCEDURE spDetalle @opcion int, @idDetalle int,@idCompra int,@idEntrada int with encryption AS
BEGIN
	declare @error int, @errorMsg varchar(200),@sumaSubtotal float;
	--Validar opcion
	begin
	begin try
	if (@opcion is null)begin
		set @error=1;
		set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar el parametro @opcion';
		RAISERROR ('Error interno',16,1); end
	else
		begin
			if (@opcion=1)begin--Insertar
				--Validar nulos
				if (@idCompra is null)
					begin
						set @error=2;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar el parametro @idCompra';
						RAISERROR ('Error interno',16,1); 
					end
				else if (@idEntrada is null)
					begin
						set @error=3;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar el parametro @idEntrada';
						RAISERROR ('Error interno',16,1); 
					end
				else--si ingresaron parametros
					begin--validar compra que exista y no este finalizada
						if (select count(*) from Compra where idCompra=@idCompra and estado!=6)>0
							begin
								--validar entrada
								if (select count(*) from Entrada where idEntrada=@idEntrada)>0
									begin
										--suma el precio del tipo entrada + recargo servicio
										set @sumaSubtotal = (select TipoEntrada.precio from Entrada inner join 
										TipoEntrada on TipoEntrada.idTipoEntrada=Entrada.idTipoEntrada where Entrada.idEntrada=@idEntrada) + 
										(select TipoEntrada.recargoTipoServicio from Entrada inner join 
										TipoEntrada on TipoEntrada.idTipoEntrada=Entrada.idTipoEntrada where Entrada.idEntrada=@idEntrada);
										--Le suma el impuesto al subtotal
										set @sumaSubtotal=@sumaSubtotal+
											@sumaSubtotal*
											(select Pais.porcentajeImpuestos from Pais inner join
											Entrada on Entrada.idEntrada=@idEntrada inner join
											FechaEvento on FechaEvento.idFecha=Entrada.idFechaEvento 
											where Pais.idPais=FechaEvento.idPais);
										
										begin transaction
											--Inserta el detalle
											insert into Detalle(idCompra,idEntrada,subtotal) values 
																(@idCompra,@idEntrada,@sumaSubtotal);		
											--Verifica que se haya completado la compra
										commit transaction
										begin transaction
										declare @sumaDetatalles table (suma float,idCompra int);
										insert into @sumaDetatalles select sum(subtotal) as suma,idCompra from Detalle 
											where idCompra=@idCompra group by idCompra;
										commit transaction
										if ((select suma from @sumaDetatalles)=(select total from Compra where idCompra=@idCompra))
											begin
												begin transaction 
													
													update Compra set estado=6 where idCompra=@idCompra;

												commit transaction
											end
									end
								else
									begin
										set @error=5;
										set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.No exite entrada con el @idEntrada ingresado.';
										RAISERROR ('Error interno',16,1); 
									end
							end
						else
							begin
								set @error=4;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.No existe compra con el @idCompra ingresado.';
								RAISERROR ('Error interno',16,1); 
							end
					end
			end
			else if (@opcion=2)begin--Consultar
				begin
					if (@idDetalle is null and @idCompra is null)
					begin
						set @error=6;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'. Debe ingresar @idDetalle o @idCompra o ambos para consultar.';
						RAISERROR ('Error interno',16,1); 
					end
					if (@idDetalle is not null)
					begin
						if (select count(*) from Detalle where idDetalle=@idDetalle)>0
							begin
								begin transaction
									
									select Detalle.idDetalle,Detalle.idCompra,Detalle.idEntrada,Detalle.subtotal from Detalle where idDetalle=@idDetalle;

								commit transaction

							end
						else
							begin
								set @error=7;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.No existe detalle con el @idDetalle ingresado.';
								RAISERROR ('Error interno',16,1); 

							end
					end
				end
				if (@idCompra is not null)--consulta los detalles de una compra
					begin 
						if (select count(*) from Compra where idCompra=@idCompra)>0
							begin

							begin transaction

								select idCompra, idDetalle,idEntrada,subtotal from Detalle where idCompra=@idCompra;


							commit transaction

							end
						else
							begin
								set @error=8;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.No existe compra con el @idCompra ingresado.';
								RAISERROR ('Error interno',16,1); 

							end
					end

			end
			else if (@opcion=3)
				begin 
					begin transaction
						select Detalle.idDetalle,Detalle.idCompra,Detalle.idEntrada,Detalle.subtotal from Detalle;
					commit transaction
				end
			else
				begin
					set @error=2;
					set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar una @opcion valida.';
					RAISERROR ('Error interno',16,1); 
				end
		end
	end try
	begin catch--Atrapa cualquier error en la transaccion.
			print @errorMsg;
	end catch
	end

	/*
	--Insertar
	exec spDetalle null,null,null,null;--Erro 1. opcion nula. FUNCIONA
	exec spDetalle 78,null,null,null;--Erro 2. opcion invalida. FUNCIONA
	exec spDetalle 1,null,null,null;--Erro 2. parametro id compra nulo. FUNCIONA
	exec spDetalle 1,null,1,null;--Erro 3. parametro id entrada nulo. FUNCIONA
	exec spDetalle 1,null,100,1;--Error 4. no existe compra. FUNCIONA
	exec spDetalle 1,null,1,100;--Error 5. no existe entrada. FUNCIONA



	--Consultar
	exec spDetalle 2,null,null,null;--Error 7. id detalle nulo. FUNCIONA
	exec spDetalle 2,78,null,null;--Error 8. no existe detalle. FUNCIONA
	exec spDetalle 2,1,null,null;--Consultar funciona por id detalle
	exec spDetalle 2,null,1,null;--Consultar funciona por id compra
	exec spDetalle 2,1,1,null;--Consultar funciona con las dos.

	select * from Compra;
	select * from Estado;
	select * from Detalle;
	select * from Entrada;

	*/
END
GO
---------------------------------------------------------------------------------------
--CRUD Direccion Cliente
GO
CREATE PROCEDURE spDireccionCliente @opcion int,@idDireccion int,@idCliente int,@idPais int,@detalleDireccion varchar(200),
									@codigoPostal int,@estado int with encryption AS
BEGIN
	declare @error int, @errorMsg varchar(200);
	--Validar opcion
	begin
	begin try
	if (@opcion is null)begin
		set @error=1;
		set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar el parametro @opcion';
		RAISERROR ('Error interno',16,1); end
	else
		begin
			if (@opcion=1)begin--Insertar
				--Validarn nulos
				if (@idCliente is null)
					begin
						set @error=3;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'. Debe ingresar el parametro @idCliente.';
						RAISERROR ('Error interno',16,1); 
					end
				else if (@idPais is null)
					begin
						set @error=4;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'. Debe ingresar el parametro @idPais';
						RAISERROR ('Error interno',16,1); 
					end
				else if (@detalleDireccion is null)
					begin
						set @error=5;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'. Debe ingresar el parametro @detalleDireccion.';
						RAISERROR ('Error interno',16,1); 
					end
				else if (@codigoPostal is null)
					begin
						set @error=6;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'. Debe ingresar el parametro @codigoPostal.';
						RAISERROR ('Error interno',16,1); 
					end
				else
					begin
					--si ingresaron parametros
						--validar que existe
						if (select count(*) from Cliente where idCliente=@idCliente)>0
							begin	--si existe cliente
								if (select count(*) from Pais where idPais=@idPais)>0
									begin
										begin transaction
											insert into DireccionCliente(idCliente,idPais,detalleDireccion,codigoPostal,estado) values
												(@idCliente,@idPais,@detalleDireccion,@codigoPostal,1);
										commit transaction
									end
								else--no existe pais
									begin
										set @error=8;
										set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'. No existe pais con el @idPais ingresado.';
										RAISERROR ('Error interno',16,1); 
									end
							end
						else
							begin
								set @error=7;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'. No existe cliente con el @idCliente ingresado.';
								RAISERROR ('Error interno',16,1);
							end
					end
			end
			else if (@opcion=2)begin--Consultar
				if (@idDireccion is null and @idCliente is null)
					begin
						set @error=10;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'. Debe ingresar @idDirecccion o @idCliente para consultar.';
						RAISERROR ('Error interno',16,1); 
					end
				if (@idDireccion is not null)
					begin
						if (select count(*) from DireccionCliente where idDireccion=@idDireccion)>0
							begin--si existe
								begin transaction
									
									select DireccionCliente.idDireccion,codigoPostal,detalleDireccion,Estado.nombre,Cliente.idCliente
										from DireccionCliente inner join Cliente on Cliente.idCliente=DireccionCliente.idCliente
										inner join Estado on Estado.idEstado=DireccionCliente.estado
										inner join Pais on Pais.idPais=DireccionCliente.idPais
										where idDireccion=@idDireccion;

								commit transaction
							end
						else
							begin
								set @error=11;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'. No existe direccion con @idDireccion ingresada..';
								RAISERROR ('Error interno',16,1); 
							end
					end
				if (@idCliente is not null)
					begin
						if (select count(*) from DireccionCliente where idCliente=@idCliente)>0
							begin
								begin transaction

										select DireccionCliente.idDireccion,codigoPostal,detalleDireccion,Estado.nombre,Cliente.idCliente
										from DireccionCliente inner join Cliente on Cliente.idCliente=DireccionCliente.idCliente
										inner join Estado on Estado.idEstado=DireccionCliente.estado
										inner join Pais on Pais.idPais=DireccionCliente.idPais
										where DireccionCliente.idCliente=@idCliente;

								commit transaction
							end
						else
							begin
								set @error=11;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'. No existe direcciones del cliente @idCliente ingresado.';
								RAISERROR ('Error interno',16,1); 

							end
					end
			end
			else if(@opcion=3)begin--Modificar
				--Codigo
				if (@idDireccion is null)
					begin
						set @error=12;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'. Debe ingresar parametro @idDireccion.';
						RAISERROR ('Error interno',16,1); 
					end
				else
					begin
						if (select count(*) from DireccionCliente where idDireccion=@idDireccion)>0
							begin

								if (@estado is not null)	
									begin
										if (select count(*) from Estado where idEstado=@estado)>0
											begin
												begin transaction
													
													update DireccionCliente set estado=@estado where idDireccion=@idDireccion;

												commit transaction
											end
										else
											begin
												set @error=14;
												set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'. No existe estado con @estado ingresado..';
												RAISERROR ('Error interno',16,1); 
											end

									end
								if (@detalleDireccion is not null)
									begin
									begin transaction			
										update DireccionCliente set detalleDireccion=@detalleDireccion where idDireccion=@idDireccion;
									commit transaction
									end
								if (@codigoPostal is not null)
									begin
									begin transaction			
										update DireccionCliente set codigoPostal=@codigoPostal where idDireccion=@idDireccion;
									commit transaction
									end
							end
						else
							begin
								set @error=15;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'. No existe direccion con @idDireccion ingresada..';
								RAISERROR ('Error interno',16,1); 
							end
					end
			end
			else if(@opcion=4)begin--Eliminar
				--Codigo
				if (@idDireccion is null)
					begin
						set @error=15;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'. Debe ingresar parametro @diDireccion.';
						RAISERROR ('Error interno',16,1); 
					end
				else
					begin
						if (select count(*) from DireccionCliente where idDireccion=@idDireccion)>0	
							begin
								begin transaction
									update DireccionCliente set estado=-1 where idDireccion=@idDireccion;
								commit transaction
							end
						else
							begin
								set @error=16;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.No existe direccion con el @idDireccion ingresado.';
								RAISERROR ('Error interno',16,1); 
							end
					end
			end
			else if (@opcion=5)--consultar todas las direcciones
				begin
					begin transaction
						select idDireccion,idPais,detalleDireccion,codigoPostal from DireccionCliente;
					commit transaction
				end
			else
				begin
					set @error=2;
					set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar una @opcion valida.';
					RAISERROR ('Error interno',16,1); end
		end
	end try
	begin catch--Atrapa cualquier error en la transaccion.
			print @errorMsg;
	end catch
	end


	/*
	--Insertar
	exec spDireccionCliente null,null,null,null,null,null,null;--Error 1. opcion nula. FUNCIONA
	exec spDireccionCliente 78,null,null,null,null,null,null;--Error 2. opcion invalida. FUCIONA
	exec spDireccionCliente 1,null,null,null,null,null,null;--Error 3. id cliente nulo. FUNCIONA
	exec spDireccionCliente 1,null,1,null,null,null,null;--Erro 4. id pais nulo. FUNCIONA
	exec spDireccionCliente 1,null,1,188,null,null,null;--Erro 5. detalle direccion nula. FUNCIONA
	exec spDireccionCliente 1,null,1,188,'Cartago,La Union',null,null;--Erro 6. codigo postal nulo. FUNCIONA
	--Consultar
	exec spDireccionCliente 2,null,null,null,null,null,null;--Error 10. id direccion nula y idCliente nulo. FUNCIONA
	exec spDireccionCliente 2,789,null,null,null,null,null;--Error 11. direccion no existe. FUCIONA
	exec spDireccionCliente 2,1,null,null,null,null,null;--Consultar con id direccion funciona
	exec spDireccionCliente 2,null,1,null,null,null,null;--Consultar con id cliente funciona
	--Modificar
	exec spDireccionCliente 3,null,null,null,null,null,null;--Erro 12. id direccion nula. FUNCIONA
	exec spDireccionCliente 3,45,null,null,null,null,null;--Erro 15. no existe direccion. FUNCIONA
	exec spDireccionCliente 3,1,null,null,'Cartago, La Union, San Juan',null,null;--Modificar funcion
	exec spDireccionCliente 3,1,null,null,null,null,2;--Modificar funcion
	exec spDireccionCliente 2,1,null,null,null,null,null;--Consultar con id direccion funciona
	exec spDireccionCliente 3,1,null,null,null,null,1;--Modificar funcion
	exec spDireccionCliente 2,1,null,null,null,null,null;--Consultar con id direccion funciona
	--Eliminar
	exec spDireccionCliente 4,100,null,null,null,null,null;--Error 16. id direccion no existe. FUNCIONA
	exec spDireccionCliente 4,1,null,null,null,null,null;--Eliminar funciona
	exec spDireccionCliente 2,1,null,null,null,null,null;--Consultar con id direccion funciona
	*/
END
GO
---------------------------------------------------------------------------------------
--CRUD Envio
GO
CREATE PROCEDURE spEnvio @opcion int, @idEnvio int,@idCompra int,@envioFisico int,@costoEnvio float,@estado int with encryption AS
BEGIN
	declare @error int, @errorMsg varchar(200);
	--Validar opcion
	begin
	begin try
	if (@opcion is null)begin
		set @error=1;
		set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar el parametro @opcion';
		RAISERROR ('Error interno',16,1); end
	else
		begin
			if (@opcion=1)begin--Insertar
				--Validar nulos
				if (@idCompra is null)
					begin
						set @error=3;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'. Debe ingresar parametro @idCompra.';
						RAISERROR ('Error interno',16,1);
					end
				else if (@envioFisico is null)
					begin
						set @error=4;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'. Debe ingresar parametro @envioFisico.';
						RAISERROR ('Error interno',16,1);
					end
				else if (@costoEnvio is null)
					begin
						set @error=5;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'. Debe ingresar parametro @costoEnvio.';
						RAISERROR ('Error interno',16,1);
					end
				else
					begin
						if (select count(*) from Envio where idCompra=@idCompra)>0
							begin
								set @error=20;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'. Ya existe un envio con el @idCompra ingresada.';
								RAISERROR ('Error interno',16,1);

							end
						--validar existe
						if (select count(*) from Compra where idCompra=@idCompra)>0
							begin
								if (@envioFisico=0)--envio digital (correo) ->costo=0
									begin
										begin transaction

											insert into Envio(idCompra,envioFisico,costoEnvio,estado) values 
														(@idCompra,@envioFisico,@costoEnvio,1);

										commit transaction
									end
								else if (@envioFisico=1)--envio fisico ->costo!=0
									begin
										if (@costoEnvio>0)
											begin
												begin transaction

													insert into Envio(idCompra,envioFisico,costoEnvio,estado) values
																		(@idCompra,@envioFisico,@costoEnvio,1);

												commit transaction
											end
										else
											begin
												set @error=8;
												set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
													'. El @costoEnvio fisico debe ser > 0.';
												RAISERROR ('Error interno',16,1);
											end
									end
								else
									begin
										set @error=7;
										set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
													'. Debe ingresar 0 para envio digital o 1 para envio fisico en @envioFisico.';
										RAISERROR ('Error interno',16,1);
									end
									
							end
						else--no existe
							begin
								set @error=6;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'. No existe compra con el @idCompra ingresada.';
								RAISERROR ('Error interno',16,1);
							end
					end
			end
			else if (@opcion=2)begin--Consultar
				if (@idEnvio is null and @idCompra is null)
					begin
						set @error=21;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'. Debe ingresar @idEnvio o @idCompra para consultar.';
						RAISERROR ('Error interno',16,1);
					end

				if (@idEnvio is not null)
					begin
						if (select count(*) from Envio where idEnvio=@idEnvio)>0--consultar por id envio
							begin
								begin transaction

									select Envio.idEnvio,Envio.idCompra,Envio.envioFisico,Envio.costoEnvio,Estado.nombre as estado from Envio
									inner join Estado on Estado.idEstado=Envio.estado where idEnvio=@idEnvio;
									
								commit transaction
							end
						else
							begin
								set @error=9;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'. No existe envio con el @idEnvio ingresado.';
								RAISERROR ('Error interno',16,1);
							end
					end
				if (@idCompra is not null)--consultar por id Compra
					begin
					if (select count(*) from Compra where idCompra=@idCompra)>0
							begin
								begin transaction
									
									select Envio.idEnvio,Envio.idCompra,Envio.envioFisico,Envio.costoEnvio,Estado.nombre as estado from Envio
									inner join Estado on Estado.idEstado=Envio.estado where idCompra=@idCompra;


								commit transaction
							end
						else
							begin
								set @error=10;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'. No existe envio con el @idCompra ingresado.';
								RAISERROR ('Error interno',16,1);
							end
					end
			end
			else if(@opcion=3)begin--Modificar
				if (@idEnvio is null and @idCompra is null)
					begin
						set @error=11;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'. Debe ingresar @idEnvio o @idCompra para modificar.';
						RAISERROR ('Error interno',16,1);
					end
				else if (@idEnvio is not null)
					begin
						if (select count(*) from Envio where idEnvio=@idEnvio)>0
							begin
								if (@estado is not null)
									begin
										if (select count(*) from Estado where idEstado=@estado)>0
											begin
												begin transaction

														update Envio set estado=@estado where idEnvio=@idEnvio;

												commit transaction
											end
										else
											begin
												set @error=13;
												set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
													'. No existe estado con el @estado ingresado.';
												RAISERROR ('Error interno',16,1);
											end
									end
							end
						else
							begin
								set @error=12;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
											'. No existe envio con el @idEnvio ingresado.';
								RAISERROR ('Error interno',16,1);
							end
					end
			end
			else if (@idCompra is not null)
					begin
						if (select count(*) from Envio where idCompra=@idCompra)>0
							begin
								if (@estado is not null)
									begin
										if (select count(*) from Estado where idEstado=@estado)>0
											begin
												begin transaction

														update Envio set estado=@estado where idEnvio=@idEnvio;

												commit transaction
											end
										else
											begin
												set @error=13;
												set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
													'. No existe estado con el @estado ingresado.';
												RAISERROR ('Error interno',16,1);
											end
									end
							end
						else
							begin
								set @error=12;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
											'. No existe envio con el @idCompra ingresada.';
								RAISERROR ('Error interno',16,1);
							end
					end
			else if (@opcion=4)--consultar todos los envios
				begin
					begin transaction
						select Envio.idEnvio,Envio.idCompra,Envio.envioFisico,Envio.costoEnvio,Envio.estado from Envio;
					commit transaction
				end
			else
				begin
					set @error=2;
					set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar una @opcion valida.';
					RAISERROR ('Error interno',16,1); end
		end
	end try
	begin catch--Atrapa cualquier error en la transaccion.
			print @errorMsg;
	end catch
	end

	/*
	--Insertar 
	exec spEnvio null,null,null,null,null,null;--Erro 1. opcion nula. FUNCIONA
	exec spEnvio 78,null,null,null,null,null;--Erro 2. opcion invalida. FUNCIONA
	exec spEnvio 1,null,null,null,null,null;--Erro 3. id compra nula. FUNCIONA
	exec spEnvio 1,null,1,null,null,null;--Erro 4. envio fisico nulo. FUNCIONA
	exec spEnvio 1,null,1,0,null,null;--Erro 5. costo nulo. FUNCIONA
	exec spEnvio 1,null,1,0,0,null;--Error 20. envio repetido. FUNCIONA

	--Consultar 
	exec spEnvio 2,null,null,null,null,null;--Erro 21. no ingresaron parametros. FUNCIONA
	exec spEnvio 2,99,null,null,null,null;--Erro 9. no existe envio. FUNCIONA
	exec spEnvio 2,null,99,null,null,null;--Erro 10 existe envio. FUNCIONA
	exec spEnvio 2,null,1,null,null,null;--Consultar con id compra funciona
	exec spEnvio 2,1,null,null,null,null;--Consultar con id envio funciona
	--Modificar
	exec spEnvio 3,null,null,null,null,null;--Error 11. parametros nulos.
	exec spEnvio 3,1,null,null,null,null;--No modificar porque estado es nulo.
	exec spEnvio 3,1,null,null,null,2;--Modificar funciona
	exec spEnvio 2,1,null,null,null,null;--Consultar con id envio funciona
	exec spEnvio 3,1,null,null,null,1;--Modificar funciona
	exec spEnvio 2,1,null,null,null,null;--Consultar con id envio funciona

	select * from Envio
	select * from Estado;
	select * from Compra;

	*/
END
GO
---------------------------------------------------------------------------------------
--CRUD Tipo Comentario
GO
CREATE PROCEDURE spTipoComentario @opcion int, @idTipoComentario int,@nombreTipoComentario varchar(25),@estado int with encryption AS
BEGIN
	declare @error int, @errorMsg varchar(200);
	--Validar opcion
	begin
	begin try
	if (@opcion is null)begin
		set @error=1;
		set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar el parametro @opcion';
		RAISERROR ('Error interno',16,1); end
	else
		begin
			if (@opcion=1)begin--Insertar
				if (@nombreTipoComentario is null)
					begin
						set @error=3;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'. Debe ingresar parametro @nombreTipoComentario.';
						RAISERROR ('Error interno',16,1); 
					end
				else
					begin
						if (select count(*) from TipoComentario where nombreTipoComentario=@nombreTipoComentario)>0
							begin
								set @error=4;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
										'. Ya existe un tipo comentario con el @nombreTipoComentario ingresado.';
								RAISERROR ('Error interno',16,1); 
							end
						else
							begin
								begin transaction

										insert into TipoComentario(nombreTipoComentario,estado) values (@nombreTipoComentario,1);

								commit transaction
							end
					end
			end
			else if (@opcion=2)begin--Consultar
				if (@idTipoComentario is null)
					begin		
						set @error=5;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'. Debe ingresar parametro @idTipoComentario.';
						RAISERROR ('Error interno',16,1); 
					end
				else
					begin
 					if (select count(*) from TipoComentario where idTipoComentario=@idTipoComentario)>0
						begin
						begin transaction

							select idTipoComentario,nombreTipoComentario,Estado.nombre from TipoComentario
							inner join Estado on Estado.idEstado=TipoComentario.estado where idTipoComentario=@idTipoComentario;

						commit transaction
						end
					else
						begin
							set @error=6;
							set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'. No existe tipo comentario con @idTipoComentario ingresado.';
							RAISERROR ('Error interno',16,1); 
						end
					end
			end
			else if(@opcion=3)begin--Modificar y eliminar
				if (@idTipoComentario is null)
					begin		
						set @error=5;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'. Debe ingresar parametro @idTipoComentario.';
						RAISERROR ('Error interno',16,1); 
					end
				else
					begin
 					if (select count(*) from TipoComentario where idTipoComentario=@idTipoComentario)>0
						begin
						if (@estado is not null)
							begin
								if (select count(*) from Estado where idEstado=@estado)>0
									begin
										
										update TipoComentario set estado=@estado where idTipoComentario=@idTipoComentario;

									end
								else
									begin
										set @error=6;
										set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
													'. No existe estado con @idEstado ingresado.';
										RAISERROR ('Error interno',16,1); 
									end
							end
						end
					else
						begin
							set @error=6;
							set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'. No existe tipo comentario con @idTipoComentario ingresado.';
							RAISERROR ('Error interno',16,1); 
						end
					end
			end
			else if (@opcion=4)
				begin
				begin transaction
					select TipoComentario.idTipoComentario,TipoComentario.nombreTipoComentario,TipoComentario.estado from TipoComentario;
				commit transaction
				end
			else
				begin
					set @error=2;
					set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'. Opcion invalida.';
					RAISERROR ('Error interno',16,1); 

				end
		end
	end try
	begin catch--Atrapa cualquier error en la transaccion.
			print @errorMsg;
	end catch
	end

	/*
	--Insertar 
	exec spTipoComentario null,null,null,null;--Error 1. opcion nula. FUNCIONA
	exec spTipoComentario 78,null,null,null;--Error. opcion invalida. FUNCIONA
	exec spTipoComentario 1,null,null,null;--Error 3. nombre nulo. FUNCIONA
	exec spTipoComentario 1,null,'Queja',null;--Error 4. nombre repetido. FUNCIONA
	--Consultar
	exec spTipoComentario 2,null,null,null;--Error 5. id tipo comentario nulo. FUNCIONA
	exec spTipoComentario 2,45,null,null;--Error 6. tipo comentario no existe. FUNCIONA
	exec spTipoComentario 2,1,null,null;--Consultar funciona
	--Modificar - Eliminar
	exec spTipoComentario 3,18,null,null;--Error 6. no existe id tipo comentario. FUNCIONA
	exec spTipoComentario 3,1,null,2;--Modificar funciona
	exec spTipoComentario 2,1,null,null;--Consultar funciona
	exec spTipoComentario 3,1,null,1;--Modificar funciona
	exec spTipoComentario 2,1,null,null;--Consultar funciona
	select * from TipoComentario;
	*/
END
GO
---------------------------------------------------------------------------------------
--CRUD Medio Comunicacion
GO
CREATE PROCEDURE spMedioComunicacion @opcion int, @idMedio int,@nombre varchar(25),@estado int with encryption AS
BEGIN
	declare @error int, @errorMsg varchar(200);
	--Validar opcion
	begin
	begin try
	if (@opcion is null)begin
		set @error=1;
		set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar el parametro @opcion';
		RAISERROR ('Error interno',16,1); end
	else
		begin
			if (@opcion=1)begin--Insertar
				if (@nombre is null)
					begin
						set @error=3;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'. Debe ingresar parametro @nombre.';
						RAISERROR ('Error interno',16,1); 
					end
				else
					begin
						if (select count(*) from MedioComunicacion where nombreMedio=@nombre)>0
							begin
								set @error=4;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
										'. Ya existe un medio de comunicacion con el @nombre ingresado.';
								RAISERROR ('Error interno',16,1); 
							end
						else
							begin
								begin transaction

										insert into MedioComunicacion(nombreMedio,estado) values (@nombre,1);

								commit transaction
							end
					end
			end
			else if (@opcion=2)begin--Consultar
				if (@idMedio is null)
					begin		
						set @error=5;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'. Debe ingresar parametro @idMedio.';
						RAISERROR ('Error interno',16,1); 
					end
				else
					begin
 					if (select count(*) from MedioComunicacion where idMedio=@idMedio)>0
						begin
						begin transaction

							select idMedio,nombreMedio,nombre,Estado.nombre from MedioComunicacion
							inner join Estado on Estado.idEstado=MedioComunicacion.estado where idMedio=@idMedio;

						commit transaction
						end
					else
						begin
							set @error=6;
							set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
									'. No existe medio de comunicacion con @idMedio ingresado.';
							RAISERROR ('Error interno',16,1); 
						end
					end
			end
			else if(@opcion=3)begin--Modificar y eliminar
				if (@idMedio is null)
					begin		
						set @error=5;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'. Debe ingresar parametro @idMedio.';
						RAISERROR ('Error interno',16,1); 
					end
				else
					begin
 					if (select count(*) from MedioComunicacion where idMedio=@idMedio)>0
						begin
						if (@estado is not null)
							begin
								if (select count(*) from Estado where idEstado=@estado)>0
									begin
										
										update MedioComunicacion set estado=@estado where idMedio=@idMedio;

									end
								else
									begin
										set @error=6;
										set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
													'. No existe estado con @idEstado ingresado.';
										RAISERROR ('Error interno',16,1); 
									end
							end
						end
					else
						begin
							set @error=6;
							set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
									'. No existe medio de comunicacion con @idMedio ingresado.';
							RAISERROR ('Error interno',16,1); 
						end
					end
			end
			else if (@opcion=4)
				begin
				begin transaction
					select MedioComunicacion.idMedio,MedioComunicacion.nombreMedio,MedioComunicacion.estado from MedioComunicacion;
				commit transaction
				end
			else
				begin
					set @error=2;
					set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'. Opcion invalida.';
					RAISERROR ('Error interno',16,1); 

				end
		end
	end try
	begin catch--Atrapa cualquier error en la transaccion.
			print @errorMsg;
	end catch
	end
	/*
	--Insertar 
	exec spMedioComunicacion null,null,null,null;--Error 1. opcion nula. FUNCIONA
	exec spMedioComunicacion 78,null,null,null;--Error. opcion invalida. FUNCIONA
	exec spMedioComunicacion 1,null,null,null;--Error 3. nombre nulo. FUNCIONA
	exec spMedioComunicacion 1,null,'Llamada',null;--Error 4. nombre repetido. FUNCIONA
	--Consultar
	exec spMedioComunicacion 2,null,null,null;--Error 5. id medio nulo. FUNCIONA
	exec spMedioComunicacion 2,45,null,null;--Error 6. id medio no existe. FUNCIONA
	exec spMedioComunicacion 2,1,null,null;--Consultar funciona
	--Modificar - Eliminar
	exec spMedioComunicacion 3,18,null,null;--Error 6. no existe id medio. FUNCIONA
	exec spMedioComunicacion 3,1,null,2;--Modificar funciona
	exec spMedioComunicacion 2,1,null,null;--Consultar funciona
	exec spMedioComunicacion 3,1,null,1;--Modificar funciona
	exec spMedioComunicacion 2,1,null,null;--Consultar funciona
	select * from MedioComunicacion;
	*/
END
GO
---------------------------------------------------------------------------------------
--CRUD Comentario
GO
CREATE PROCEDURE spComentario @opcion int,@idComentario int,@idEntrada int,@idTipoComentario int,
								@idMedio int,@comentario varchar(200) with encryption AS
BEGIN
	declare @error int, @errorMsg varchar(200);
	--Validar opcion
	begin
	begin try
	if (@opcion is null)begin
		set @error=1;
		set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar el parametro @opcion';
		RAISERROR ('Error interno',16,1); end
	else
		begin
			if (@opcion=1)begin--Insertar
				--Validar nulos
				if (@idEntrada is null)
					begin
					set @error=3;
					set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
								'.Debe ingresar el parametro @idEntrada';
					RAISERROR ('Error interno',16,1); 
					end
				else if (@idTipoComentario is null)
					begin
					set @error=4;
					set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
								'.Debe ingresar el parametro @idTipoComentario';
					RAISERROR ('Error interno',16,1); 
					end
				else if (@idMedio is null)
					begin
					set @error=5;
					set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
								'.Debe ingresar el parametro @idMedio';
					RAISERROR ('Error interno',16,1); 
					end
				else if (@comentario is null)
					begin
					set @error=6;
					set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
								'.Debe ingresar el parametro @comentario';
					RAISERROR ('Error interno',16,1); 
					end
				else
					begin
						--Si ingresaron parametros
						if (select count(*) from Entrada where idEntrada=@idEntrada)>0--valida entrada
							begin
							if (select count(*) from TipoComentario where idTipoComentario=@idTipoComentario)>0--valida tipo comentario
								begin
								if (select count(*) from MedioComunicacion where idMedio=@idMedio)>0--validar medio comunicacion
									begin
									begin transaction
										insert into Comentario(idEntrada,idTipoComentario,idMedio,comentario,fechaHora) values
														(@idEntrada,@idTipoComentario,@idMedio,@comentario,GETDATE());
									commit transaction
									end
								else
									begin
										set @error=9;
										set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
											'. No existe medio comunicacion con @idMedio ingresada.';
										RAISERROR ('Error interno',16,1); 
									end
								end
								else
								begin
									set @error=8;
									set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
												'. No existe tipo comentario con @idTipoComentario ingresada.';
									RAISERROR ('Error interno',16,1); 
								end
							end
						else
							begin
								set @error=7;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
										'. No existe entrada con @idEntrada ingresada.';
								RAISERROR ('Error interno',16,1); 

							end
					end
			end
			else if (@opcion=2)begin--Consultar
				if (@idComentario is null and @idEntrada is null)
					begin
						set @error=10;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
								'. Debe ingresar @idComentario o @idEntrada.';
						RAISERROR ('Error interno',16,1); 
					end
				else
					begin
						if (@idComentario is not null)
							begin
								if (select count(*) from Comentario where idComentario=@idComentario)>0
									begin
										begin transaction
											select idComentario,idEntrada,MedioComunicacion.nombreMedio as medio,
												comentario,TipoComentario.nombreTipoComentario as tipoComentario,fechaHora from Comentario inner join
												MedioComunicacion on MedioComunicacion.idMedio=Comentario.idMedio inner join
												TipoComentario on TipoComentario.idTipoComentario=Comentario.idTipoComentario
												where idComentario=@idComentario;
										commit transaction
									end
								else
									begin
										set @error=11;
										set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
											'. No existe comentario con @idComentario ingresada.';
										RAISERROR ('Error interno',16,1); 
									end
							end
						if (@idEntrada is not null)
							begin
								if (select count(*) from Comentario where idEntrada=@idEntrada)>0
										begin
											begin transaction
												select idComentario,idEntrada,MedioComunicacion.nombreMedio as medio,
												comentario,TipoComentario.nombreTipoComentario as tipoComentario,fechaHora from Comentario inner join
												MedioComunicacion on MedioComunicacion.idMedio=Comentario.idMedio inner join
												TipoComentario on TipoComentario.idTipoComentario=Comentario.idTipoComentario
												where idEntrada=@idEntrada;
											commit transaction
										end
									else
										begin
											set @error=12;
											set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
												'. No existe comentario con @idComentario ingresada.';
											RAISERROR ('Error interno',16,1); 
										end
							end
					end
			end
			else if (@opcion=3)
				begin
				begin transaction
					select Comentario.idComentario,Comentario.comentario,Comentario.fechaHora,Comentario.idTipoComentario,
					Comentario.idMedio,Comentario.idEntrada from Comentario;
				commit transaction
				end
			else
				begin
					set @error=2;
					set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar una @opcion valida.';
					RAISERROR ('Error interno',16,1); end
		end
	end try
	begin catch--Atrapa cualquier error en la transaccion.
			print @errorMsg;
	end catch
	end

	/*
	--Insertar 
	exec spComentario null,null,null,null,null,null;--Error 1. opcion nula. FUNCIONA
	exec spComentario 165,null,null,null,null,null;--Error 2. opcion invalida. FUNCIONA
	exec spComentario 1,null,null,null,null,null;--Error 3. id entrada nula. FUNCIONA
	exec spComentario 1,null,1,null,null,null;--Error 4. id tipo comentario nula. FUNCIONA
	exec spComentario 1,null,1,1,null,null;--Error 5. id medio nulo. FUNCIONA
	exec spComentario 1,null,1,1,2,null;--Error 6. comentario nulo.FUNCIONA

	--Consultar
	exec spComentario 2,1,null,null,null,null;--Consultar por id comentario funciona
	exec spComentario 2,null,1,null,null,null;--Consultar por id entrada funciona
	exec spComentario 2,1,1,null,null,null;--Consultar por id comentario e id entrada funciona


	select * from Entrada;
	select * from TipoComentario;
	select * from MedioComunicacion;
	select * from Comentario;
	*/

END
GO
---------------------------------------------------------------------------------------
--CRUD Solucion
GO
CREATE PROCEDURE spSolucion @opcion int, @idSolucion int,@reembolso int,@reemplazo int,@estado int with encryption AS
BEGIN
	declare @error int, @errorMsg varchar(200);
	--Validar opcion
	begin
	begin try
	if (@opcion is null)begin
		set @error=1;
		set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar el parametro @opcion';
		RAISERROR ('Error interno',16,1); end
	else
		begin
			if (@opcion=1)begin--Insertar
				if (@reembolso is null)
					begin
						set @error=3;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
								'. Debe ingresar el parametro @reembolso';
						RAISERROR ('Error interno',16,1);
					end
				else if (@reemplazo is null)
					begin
						set @error=4;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
								'. Debe ingresar el parametro @reemplazo';
						RAISERROR ('Error interno',16,1);
					end
				else if (@estado is null)
					begin
						set @error=5;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
								'. Debe ingresar el parametro @estado';
						RAISERROR ('Error interno',16,1);
					end
				else
					begin--si ingresaron parametros
						if (@reembolso not in (0,1))
							begin
								set @error=6;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
										'. Debe ingresar 1 para reembolar o 0 para no reembolsar.';
								RAISERROR ('Error interno',16,1);
							end
						if (@reemplazo not in (0,1))
							begin
								set @error=7;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
										'Debe ingresar 1 para reemplazar o 0 para no reemplazar.';
								RAISERROR ('Error interno',16,1);
							end
						begin transaction

							insert into Solucion(reembolso,reemplazo,estado) values (@reembolso,@reemplazo,@estado);

						commit transaction
					end
			end
			else if (@opcion=2)begin--Consultar
				if (@idSolucion is null)
					begin
						set @error=8;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
								'. Debe ingresar el parametro @idEstado';
						RAISERROR ('Error interno',16,1);
					end
				else
					begin
						if (select count(*) from Solucion where idSolucion=@idSolucion)>0
							begin
							begin transaction
								select idSolucion,Estado.nombre,reembolso,reemplazo from Solucion inner join
								Estado on Estado.idEstado=Solucion.estado where idSolucion=@idSolucion;
							commit transaction		
							end
						else
							begin
								set @error=9;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
									'. No existe solucion con @idSolucion ingresada.';
								RAISERROR ('Error interno',16,1);
							end
					end
			end
			else if(@opcion=3)begin--Modificar
				--Codigo
				if (@idSolucion is null)
					begin
						set @error=10;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
								'. Debe ingresar el parametro @idEstado';
						RAISERROR ('Error interno',16,1);
					end
				else
					begin
						if (select count(*) from Solucion where idSolucion=@idSolucion)>0
							begin
								if (@estado is not null)
								begin
								if (select count(*) from Estado where idEstado=@estado)>0
									begin
									begin transaction
										update Solucion set estado=@estado where idSolucion=@idSolucion;
									commit transaction
									end
								else
									begin
									set @error=12;
									set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
										'. No existe estado con @estado ingresada.';
									RAISERROR ('Error interno',16,1);		
									end
								end
							end
						else
							begin
								set @error=11;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
									'. No existe solucion con @idSolucion ingresada.';
								RAISERROR ('Error interno',16,1);
							end
						end
			end
			else if (@opcion=4)	
				begin
					begin transaction
					select Solucion.idSolucion,Solucion.estado,Solucion.reembolso,Solucion.reemplazo from Solucion;
					commit transaction
				end
			else
				begin
					set @error=2;
					set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar una @opcion valida.';
					RAISERROR ('Error interno',16,1); end
		end
	end try
	begin catch--Atrapa cualquier error en la transaccion.
			print @errorMsg;
	end catch
	end
	/*
	--Insert 
	exec spSolucion null,null,null,null,null;--Erro 1. opcion nula. FUNCIONA
	exec spSolucion 78,null,null,null,null;--Erro 2. opcion invalida. FUNCIONA
	exec spSolucion 1,null,null,null,null;--Erro 3. reembolso nulo. FUNCIONA
	exec spSolucion 1,null,1,null,null;--Erro 4. reemplazo nulo. FUNCIONA
	exec spSolucion 1,null,1,0,null;--Erro 5. estado nulo. FUNCIONA


	--Consultar
	exec spSolucion 2,100,null,null,null;--Erro 9. no existe solucion. FUNCIONA
	exec spSolucion 2,1,null,null,null;--Consultar funciona
	--Modificar
	exec spSolucion 3,1,null,null,2;--Modificar funciona
	exec spSolucion 2,1,null,null,null;--Consultar funciona
	exec spSolucion 3,1,null,null,5;--Modificar funciona
	exec spSolucion 2,1,null,null,null;--Consultar funciona
	
	select * from Estado;
	select * from Solucion;

	*/
END
GO
---------------------------------------------------------------------------------------
--CRUD Departamento
GO
CREATE PROCEDURE spDepartamento @opcion int,@idDepartamento int,@nombre varchar(25),
								@descripcion varchar(200), @estado int with encryption AS
BEGIN
	declare @error int, @errorMsg varchar(200);
	--Validar opcion
	begin
	begin try
	if (@opcion is null)begin
		set @error=1;
		set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar el parametro @opcion';
		RAISERROR ('Error interno',16,1); end
	else
		begin
			if (@opcion=1)begin--Insertar
				if (@nombre is null)
					begin
						set @error=3;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
									'.Debe ingresar el parametro @nombre.';
						RAISERROR ('Error interno',16,1);
					end
				else if (@descripcion is null)
					begin
						set @error=4;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
									'.Debe ingresar el parametro @descripcion.';
						RAISERROR ('Error interno',16,1);
					end
				else
					begin
						if (select count(*) from Departamento where nombre=@nombre)>0
							begin
								set @error=5;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
											'. Ya existe un departamento con ese nombre.';
								RAISERROR ('Error interno',16,1);
							end
						else
							begin
								begin transaction

									insert into Departamento(nombre,descripcion,estado) values(@nombre,@descripcion,1);
									
								commit transaction
							end
					end
			end
			else if (@opcion=2)begin--Consultar
				if (@idDepartamento is null)
					begin
						set @error=6;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
							'. Debe ingresar parametro @idDepartamento.';
						RAISERROR ('Error interno',16,1);

					end
				else
					begin
						if (select count(*) from Departamento where idDepartamento=@idDepartamento)>0
							begin
								begin transaction
									
									select idDepartamento,Departamento.nombre,Departamento.descripcion,Estado.nombre from Departamento inner join Estado on Estado.idEstado=Departamento.estado 
									where idDepartamento=@idDepartamento;

								commit transaction
							end
						else
							begin
								set @error=7;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
									'. No existe departamento con el @idDepartamento ingresado..';
								RAISERROR ('Error interno',16,1);
							end
					end
			end
			else if(@opcion=3)begin--Modificar
				if (@idDepartamento is null)
					begin
						set @error=8;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
							'. Debe ingresar parametro @idDepartamento.';
						RAISERROR ('Error interno',16,1);

					end
				else
					begin
						if (select count(*) from Departamento where idDepartamento=@idDepartamento)>0
							begin
								if (@descripcion is not null)
									begin
										begin transaction
											update Departamento set descripcion=@descripcion where idDepartamento=@idDepartamento;
										commit transaction
									end
								if (@estado is not null)
									begin
										if (select count(*) from Estado where idEstado=@estado)>0
											begin
												begin transaction
													update Departamento set estado=@estado where idDepartamento=@idDepartamento;
												commit transaction
											end
										else
											begin
												set @error=10;
												set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
													'. No existe estado con el @estado ingresado.';
												RAISERROR ('Error interno',16,1);
											end
									end
							end
						else
							begin
								set @error=9;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
									'. No existe departamento con el @idDepartamento ingresado..';
								RAISERROR ('Error interno',16,1);
							end
					end
			end
			else if (@opcion=4)
				begin
					begin transaction
						select Departamento.idDepartamento,Departamento.nombre,Departamento.descripcion,Departamento.estado from Departamento;
					commit transaction
				end
			else
				begin
					set @error=2;
					set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar una @opcion valida.';
					RAISERROR ('Error interno',16,1); end
		end
	end try
	begin catch--Atrapa cualquier error en la transaccion.
			print @errorMsg;
	end catch
	end
	/*
	--Insertar
	exec spDepartamento null,null,null,null,null;--Error 1. opcion nula. FUNCIONA
	exec spDepartamento 78,null,null,null,null;--Erro 2. opcion invalida. FUNCIONA
	exec spDepartamento 1,null,null,null,null;--Erro 3. nombre nulo. FUNCIONA
	exec spDepartamento 1,null,'Informática',null,null;--Erro 4. descripcion nula. FUNCIONA
	--Consultar
	exec spDepartamento 2,null,null,null,null;--Erro 6. id departamento nulo. FUNCIONA
	exec spDepartamento 2,10,null,null,null;--Erro 7. no existe. FUNCIONA
	exec spDepartamento 2,1,null,null,null;--Consultar funciona
	--Modificar
	exec spDepartamento 3,null,null,null,null;--Error 8. id depa nulo. FUNCIONA
	exec spDepartamento 3,10,null,null,null;--Error 9. no existe. FUNCIONA
	exec spDepartamento 3,1,null,'Arreglan compus',null;--Modificar funciona
	exec spDepartamento 3,1,null,null,2;--Modificar funciona
	exec spDepartamento 2,1,null,null,null;--Consultar funciona
	exec spDepartamento 3,1,null,'Se encarga de toda la parte de informatica de la empresa.',1;--Modificar funciona
	exec spDepartamento 2,1,null,null,null;--Consultar funciona
	select * from Departamento;
	*/
END
GO
---------------------------------------------------------------------------------------
--CRUD Tipo Empleado
GO
CREATE PROCEDURE spTipoEmpleado @opcion int,@idTipoEmpleado int, @nombre varchar(25),@descripcion varchar(200) with encryption AS
BEGIN
	declare @error int, @errorMsg varchar(200);
	--Validar opcion
	begin
	begin try
	if (@opcion is null)begin
		set @error=1;
		set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar el parametro @opcion';
		RAISERROR ('Error interno',16,1); end
	else
		begin
			if (@opcion=1)begin--Insertar
				if (@nombre is null and @descripcion is null)
					begin
						set @error=3;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
								'.Debe ingresar @nombre y descripcion.';
						RAISERROR ('Error interno',16,1); 
					end
				else
					begin
						begin transaction 
							insert  into TipoEmpleado(nombreTipoEmpleado,descripcion) values(@nombre,@descripcion);
						commit transaction
					end
			end
			else if (@opcion=2)begin--Consultar
				--Codigo
				if (@idTipoEmpleado is null)
					begin
						set @error=4;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar un @idTipoEmpleado.';
						RAISERROR ('Error interno',16,1); 
					end
				else
					begin
						if (select count(*) from TipoEmpleado where idTipoEmpleado=@idTipoEmpleado)>0
							begin
								begin transaction
									select nombreTipoEmpleado,descripcion from TipoEmpleado where idTipoEmpleado=@idTipoEmpleado;
								commit transaction
							end
						else
							begin
								set @error=5;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
											'. No existe tipo de empleado con el @idTipoEmpleado ingresado.';
								RAISERROR ('Error interno',16,1); 
							end

					end
			end
			else if(@opcion=3)begin--Modificar
				if (@idTipoEmpleado is null and @descripcion is null)
					begin
						set @error=4;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar un @idTipoEmpleado y @descripcion.';
						RAISERROR ('Error interno',16,1); 
					end
				else
					begin
						if (select count(*) from TipoEmpleado where idTipoEmpleado=@idTipoEmpleado)>0
							begin
								begin transaction
									update TipoEmpleado set descripcion=@descripcion where idTipoEmpleado=@idTipoEmpleado;
								commit transaction
							end
						else
							begin
								set @error=5;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
											'. No existe tipo de empleado con el @idTipoEmpleado ingresado.';
								RAISERROR ('Error interno',16,1); 
							end

					end
			end
			else if (@opcion=4)
				begin
				begin transaction
					select TipoEmpleado.idTipoEmpleado,TipoEmpleado.nombreTipoEmpleado,TipoEmpleado.descripcion from TipoEmpleado;
				commit transaction
				end
			else
				begin
					set @error=2;
					set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar una @opcion valida.';
					RAISERROR ('Error interno',16,1); end
		end
	end try
	begin catch--Atrapa cualquier error en la transaccion.
			print @errorMsg;
	end catch
	end
END
GO
---------------------------------------------------------------------------------------
--CRUD Empleado
GO
CREATE PROCEDURE spEmpleado @opcion int,@idEmpleado int,@idDepartamento int,@idJefe int,
							@nombre varchar(25),@primerApellido varchar(25),@segundoApellido varchar(25),
							@fechaNacimiento varchar(10),@correo varchar(50),@telefono int,@salario float,
							@contrasenna varchar(16),@numeroCuenta varchar(34),@estado int,
							@contraVieja varchar(16),@idTipoEmpleado int with encryption AS
BEGIN
	declare @error int, @errorMsg varchar(200);
	declare @fechaDate date;
	--Validar opcion
	begin
	begin try
	if (@opcion is null)begin
		set @error=1;
		set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar el parametro @opcion';
		RAISERROR ('Error interno',16,1); end
	else
		begin
			if (@opcion=1)begin--Insertar
				if (@idEmpleado is null and @idDepartamento is null and @idJefe is null and @nombre is null
					and @primerApellido is null and @segundoApellido is null and @fechaNacimiento is null
					and @correo is null and @telefono is null and @salario is null and @contrasenna is null
					and @numeroCuenta is null and @idTipoEmpleado is null)
					begin
						set @error=3;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
							'. Debe ingresar los parametros idDepartamento,idJefe,nombre,primerApellio,segundoApellido,'+
							'fechaNacimiento,correo,telefono,salario,contrasenna,numeroCuenta,idTipoEmpleado.';
						RAISERROR ('Error interno',16,1); 
					end
				else
					begin
						if (select count(*) from Empleado where correo=@correo or telefono=@telefono or
						numeroCuenta=@numeroCuenta)>0
							begin
								set @error=4;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
										'. El correo o telefono o numero de cuenta pertenecen a otros empleado.';
								RAISERROR ('Error interno',16,1); 
							end
						else
							begin
								begin try
									 set @fechaDate=CONVERT(DATE, CAST(@fechaNacimiento AS datetime));

									 begin transaction

									insert into Empleado(idEmpleado,idDepartamento,idJefe,nombre,primerApellido,segundoApellido,
													fechaNacimiento,correo,telefono,salario,contrasenna,numeroCuenta,estado,idTipoEmpleado) values
														(@idEmpleado,@idDepartamento,@idJefe,@nombre,@primerApellido,@segundoApellido,
													@fechaDate,@correo,@telefono,@salario,@contrasenna,@numeroCuenta,1,@idTipoEmpleado);

									commit transaction
								end try
								begin catch
									rollback;
									print 'Ha ocurrido un error al intentar insertar al empleado.'
									RAISERROR ('Error interno',16,1); 
								end catch
							end
					end
			end
			else if (@opcion=2)begin--Consultar
				if (@idEmpleado is null)
					begin
						set @error=6;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
									'. Debe ingresar parametro @idEmpleado.';
						RAISERROR ('Error interno',16,1); 
					end
				else
					begin
						if (select count(*) from Empleado where idEmpleado=@idEmpleado)>0
							begin
								begin transaction
									select Empleado.idEmpleado,Empleado.nombre,Empleado.primerApellido,
									Empleado.segundoApellido,Empleado.correo, Empleado.telefono,Departamento.nombre as departamento,
									Estado.nombre as estadoEmpleado from Empleado
									inner join Estado on Estado.idEstado=Empleado.estado 
									inner join Departamento on Departamento.idDepartamento= Empleado.idDepartamento
									where idEmpleado=@idEmpleado;
								commit transaction
							end
						else
							begin
								set @error=7;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
										'. No existe empleado con el @idEmpleado ingresado.';
								RAISERROR ('Error interno',16,1); 

							end

					end
			end
			else if(@opcion=3)begin--Modificar
				if (@idEmpleado is null)
					begin
						set @error=8;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
									'. Debe ingresar parametro @idEmpleado.';
						RAISERROR ('Error interno',16,1); 
					end
				else
					begin
						if (select count(*) from Empleado where idEmpleado=@idEmpleado)>0
							begin
								if (@contraVieja is not null and @contrasenna is not null)
									begin
									if ((select contrasenna from Empleado where idEmpleado=@idEmpleado)=@contraVieja)
										begin --revisa uqe la contra vieja sea igual para verificar
										begin transaction
											update Empleado set contrasenna=@contrasenna where idEmpleado=@idEmpleado;			
										commit transaction
										end
									else
										begin
											set @error=9;
											set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
													'. La contrasenna vieja @contraVieja no coincide con la registrada.';
											RAISERROR ('Error interno',16,1); 
										end
									end
								if (@idDepartamento is not null)
									begin
										if (select count(*) from Departamento where idDepartamento=@idDepartamento)>0
											begin
												begin transaction
													update Empleado set idDepartamento=@idDepartamento where idEmpleado=@idEmpleado;
												commit transaction
											end
										else
											begin
												set @error=10;
												set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
														'. No existe departamento con @idDepartamento ingresado.';
												RAISERROR ('Error interno',16,1); 
											end
									end
								if (@idJefe is not null)
								begin
									if (select count(*) from Empleado where idJefe=@idJefe)>0
										begin
											begin transaction
												update Empleado set idJefe=@idJefe where idEmpleado=@idEmpleado;
											commit transaction
										end
									else
										begin
											set @error=12;
											set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
													'. No existe empleado con @idEmpleado ingresado.';
											RAISERROR ('Error interno',16,1); 
										end
								end
								if (@estado is not null and @estado!=-1)
									begin
										if (select count(*) from Estado where idEstado=@estado)>0
											begin
												update Empleado set estado=@estado where idEmpleado=@idEmpleado;
											end
										else
											begin
											set @error=13;
											set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
													'. No existe estado con @estado ingresado.';
											RAISERROR ('Error interno',16,1); 

											end
									end
							end
						else
							begin
								set @error=11;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
										'. No existe empleado con el @idEmpleado ingresado.';
								RAISERROR ('Error interno',16,1); 

							end
					end
			end
			else if (@opcion=4)
				begin
					begin transaction 
						select Empleado.idEmpleado,Empleado.idDepartamento,Empleado.nombre,Empleado.primerApellido,
						Empleado.segundoApellido,Empleado.fechaNacimiento,Empleado.correo,Empleado.telefono from Empleado;
					commit transaction
				end
			else
				begin
					set @error=2;
					set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar una @opcion valida.';
					RAISERROR ('Error interno',16,1); end
		end
	end try
	begin catch--Atrapa cualquier error en la transaccion.
			print @errorMsg;
	end catch
	end

	/*
	--Insertar
	exec spEmpleado 1,45400,1,45400,'Beatris','Pinzón','Solano','12-12-1988',
	'beatris@compania.com',7845,3500,'contraBeatris','cuenta beatris',null,null;--Error 4. empleado repetido.

	 --Consultar
	exec spEmpleado 2,45400,null,null,null,null,null,null,null,null,null,null,null,null,null;--Consultar funciona
	select * from Empleado;
	*/

END
GO
---------------------------------------------------------------------------------------
--CRUD Atencion Cliente
GO
CREATE PROCEDURE spAtencionCliente @opcion int,@idTicket int,@idEmpleado int,@idComentario int,@idSolucion int  with encryption AS
BEGIN
	declare @error int, @errorMsg varchar(200);
	--Validar opcion
	begin
	begin try
		if (@opcion is null)
			begin
				set @error=1;
				set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar el parametro @opcion';
				RAISERROR ('Error interno',16,1); 
			end
		else
			begin
				if (@opcion=1) --Insertar
					begin
						if (@idEmpleado is null and @idComentario is null and @idSolucion is null)
							begin
								set @error=3;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
									'. Debe ingresar id empleado, id comentario e id solucion.';
								RAISERROR ('Error interno',16,1); 
							end
						else
							begin
								if (select count(*) from Empleado where idEmpleado=@idEmpleado)>0
									begin 
										if (select count(*) from Comentario where idComentario=@idComentario)>0
											begin
												if (select count(*) from Solucion where idSolucion=@idSolucion)>0
													begin 
														begin transaction
															insert into AtencionCliente(idEmpleado,idComentario,idSolucion,fechaHora)
																values(@idEmpleado,@idComentario,@idSolucion,GETDATE());
														commit transaction
													end
												else
													begin
														set @error=6;
														set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
																'. No existe solucion con @idSolucion ingresada.';
														RAISERROR ('Error interno',16,1);
													end
											end
										else
											begin
												set @error=5;
												set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
													'. No existe comentario con @idComentario ingresado.';
												RAISERROR ('Error interno',16,1);
											end
									end
								else
									begin
										set @error=4;
										set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
											'. No existe empleado con @idEmpleado ingresado.';
										RAISERROR ('Error interno',16,1);
									end
							end
				end
				else if (@opcion=2)
					begin--Consultar
						if (@idTicket is null)
							begin
								set @error=7;
								set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
												'. Debe ingresar parametro @idTicket.';
								RAISERROR ('Error interno',16,1);
							end
						else
							begin
								if (select count(*) from AtencionCliente where idTicket=@idTicket)>0
									begin
										begin transaction
											select idTicket,idEmpleado,idComentario,idSolucion,fechaHora 
												from AtencionCliente where idTicket=@idTicket;

										commit transaction
									end
								else
									begin
										set @error=8;
										set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
													'. No existe atencion al cliente con @idTicket ingresado.';
										RAISERROR ('Error interno',16,1);

									end
							end
					end
				else if (@opcion=3)
					begin
						begin transaction
							select AtencionCliente.idTicket,AtencionCliente.idComentario,AtencionCliente.idEmpleado,AtencionCliente.idSolucion from AtencionCliente;
						commit transaction
					end
				else
					begin
						set @error=2;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar una @opcion valida.';
						RAISERROR ('Error interno',16,1);
					end
		end
	end try
	begin catch--Atrapa cualquier error en la transaccion.
			print @errorMsg;
	end catch
	end
	/*
	--Insertar 
	exec spAtencionCliente 1,null,45400,1,1;--Insertar funciona
	--Consultar
	exec spAtencionCliente 2,1,null,null,null;--Consultar funciona
	*/
END
GO

---------------------------------------------------------------------------------------
--CONSULTAR
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
--Consultar Evento por tipo de evento y fechas
GO
CREATE PROCEDURE spConsultarEventoXTipoEventoYFechas @idTipoEvento int,@fechaIncio varchar(10),@fechaFin varchar(10) with encryption AS
BEGIN

	/*
		Por tipo de evento filtra los eventos del tipo que le pasen por parametro y
		que la fecha del evento sea futura, no muestra las pasadas.
	
	*/
	declare @error int, @errorMsg varchar(200);
	declare @fechaInicioDate date;
	declare @fechaFinalDate date;
	--fecha mm-dd-yyyy
	begin
	begin try
			--Filtra solo por tipo de evento de la hora actual en adelante.
		if (@idTipoEvento is not null and @fechaIncio is null and @fechaFin is null)
			begin
				print 'Filtro por Tipo Evento'
				--Validar que exista
				if (select count(*) from TipoEvento where idTipoEvento=@idTipoEvento)>0
					begin--Si existe el tipo evento 
					begin transaction

						--Buscar todos los eventos que sean del tipo de evento seleccionado.
						--Se hace con fecha porque para que un evento exista desde la vista de un cliente
						--debe haberse creado una fecha que diga el evento,pais y fecha.
						

						select FechaEvento.idFecha as idFecha,Evento.nombre as nombreEvento,Evento.descripcion as descripcionEvento,
						TipoEvento.nombre as tipoEvento,
							Pais.nombre as pais, LugarEvento.detalleUbicacion,FechaEvento.fechaHora as fecha from FechaEvento inner join
							Evento on Evento.idEvento=FechaEvento.idEvento inner join
							TipoEvento on TipoEvento.idTipoEvento=@idTipoEvento inner join
							Pais on Pais.idPais=FechaEvento.idPais inner join EventoXPais on EventoXPais.idEvento = FechaEvento.idEvento 
							and EventoXPais.idPais=FechaEvento.idPais inner join LugarEvento on LugarEvento.idLugar = EventoXPais.idLugar
							where Evento.idTipoEvento=@idTipoEvento and FechaEvento.estado=1 and
							FechaEvento.fechaHora>GETDATE();
							
					commit transaction
					end
				else
					begin
						set @error=2;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
									'. No existe ningun tipo de evento con @idTipoEvento ingresado.';
						RAISERROR ('Error interno',16,1);
					end
			end
				--Tipo evento inicio y final
		else if (@idTipoEvento is not null and @fechaIncio is not null and @fechaFin is not null)
			begin
				print 'Filtro Tipo inicio y final'
				--valida tipo de evento
				if (select count(*) from TipoEvento where idTipoEvento=@idTipoEvento)>0
					begin
						--validar fecha incio
						begin try
							set @fechaInicioDate = CONVERT(varchar, CAST(@fechaIncio AS date));	
							set @fechaFinalDate = CONVERT(varchar, CAST(@fechaFin AS date));	
						end try
						begin catch
							print 'Ha ocurrido un error. Error 3. La fecha debe tener el formato "mm-dd-yyyy".'
						end catch
						
						begin transaction
							
							select FechaEvento.idFecha as idFecha,Evento.nombre as nombreEvento,
							Evento.descripcion as descripcionEvento,TipoEvento.nombre as tipoEvento,
								Pais.nombre as pais, LugarEvento.detalleUbicacion,FechaEvento.fechaHora as fecha from FechaEvento inner join
								Evento on Evento.idEvento=FechaEvento.idEvento inner join
								TipoEvento on TipoEvento.idTipoEvento=@idTipoEvento inner join
								Pais on Pais.idPais=FechaEvento.idPais inner join EventoXPais on EventoXPais.idEvento = FechaEvento.idEvento 
								and EventoXPais.idPais=FechaEvento.idPais inner join LugarEvento on LugarEvento.idLugar = EventoXPais.idLugar
								where Evento.idTipoEvento=@idTipoEvento and FechaEvento.estado=1 and
								FechaEvento.fechaHora>=@fechaInicioDate and FechaEvento.fechaHora<=DATEADD(DAY,1,@fechaFinalDate);

						commit transaction

					end
				else
					begin
						set @error=10;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
									'. No existe ningun tipo de evento con @idTipoEvento ingresado.';
						RAISERROR ('Error interno',16,1);
					end

			end
			--Filtra por tipo evento a partir de una fecha de inicio
		else if (@idTipoEvento is not null and @fechaIncio is not null and @fechaFin is null)
			begin
				print 'Filtro tipo evento y a partir de fecha de inicio.'
				--validar tipo evento
				if (select count(*) from TipoEvento where idTipoEvento=@idTipoEvento)>0
					begin
					--validar fecha incio
					begin try
						set @fechaInicioDate = CONVERT(varchar, CAST(@fechaIncio AS date));	
					end try
					begin catch
						print 'Ha ocurrido un error. Error 3. La fecha debe tener el formato "mm-dd-yyyy".'
					end catch

					begin transaction

					select FechaEvento.idFecha as idFecha,Evento.nombre as nombreEvento,Evento.descripcion as descripcionEvento,TipoEvento.nombre as tipoEvento,
							Pais.nombre as pais, LugarEvento.detalleUbicacion,FechaEvento.fechaHora as fecha from FechaEvento inner join
							Evento on Evento.idEvento=FechaEvento.idEvento inner join
							TipoEvento on TipoEvento.idTipoEvento=@idTipoEvento inner join
							Pais on Pais.idPais=FechaEvento.idPais inner join EventoXPais on EventoXPais.idEvento = FechaEvento.idEvento 
							and EventoXPais.idPais=FechaEvento.idPais inner join LugarEvento on LugarEvento.idLugar = EventoXPais.idLugar
							where Evento.idTipoEvento=@idTipoEvento and FechaEvento.estado=1 and
							FechaEvento.fechaHora>=@fechaInicioDate;
					commit transaction

					end
				else
					begin
						set @error=3;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
									'. No existe ningun tipo de evento con @idTipoEvento ingresado.';
						RAISERROR ('Error interno',16,1);
					end
			end
			--Filtra por tipo evento desde hoy hasta una fecha final
		else if (@idTipoEvento is not null and @fechaIncio is null and @fechaFin is not null)
			begin
				print 'Filtro tipo evento y  hasta fecha final'
			--validar tipo evento
				if (select count(*) from TipoEvento where idTipoEvento=@idTipoEvento)>0
					begin
					--validar fecha incio

					begin try
						set @fechaFinalDate = CONVERT(varchar, CAST(@fechaFin AS date));	
					end try
					begin catch
						print 'Ha ocurrido un error. Error 4. La fecha debe tener el formato "mm-dd-yyyy".'
					end catch

					begin transaction
					select FechaEvento.idFecha as idFecha,Evento.nombre as nombreEvento,Evento.descripcion as descripcionEvento,TipoEvento.nombre as tipoEvento,
							Pais.nombre as pais, LugarEvento.detalleUbicacion,FechaEvento.fechaHora as fecha from FechaEvento inner join
							Evento on Evento.idEvento=FechaEvento.idEvento inner join
							TipoEvento on TipoEvento.idTipoEvento=@idTipoEvento inner join
							Pais on Pais.idPais=FechaEvento.idPais inner join EventoXPais on EventoXPais.idEvento = FechaEvento.idEvento 
							and EventoXPais.idPais=FechaEvento.idPais inner join LugarEvento on LugarEvento.idLugar = EventoXPais.idLugar
							where Evento.idTipoEvento=@idTipoEvento and FechaEvento.estado=1 and
							FechaEvento.fechaHora>=GETDATE() and FechaEvento.fechaHora<=DATEADD(DAY,1,@fechaFinalDate);--se le suma para incluya el actual
					commit transaction
					end
				else
					begin
						set @error=5;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
									'. No existe ningun tipo de evento con @idTipoEvento ingresado.';
						RAISERROR ('Error interno',16,1);
					end
			end
				--Filtra por fecha inicio y fecha fin
		else if (@idTipoEvento is null and @fechaIncio is not null and @fechaFin is not null)
			begin
				print 'Filtro inicio hasta final.'
				--validar fecha incio y final
				begin try
					set @fechaInicioDate = CONVERT(varchar, CAST(@fechaIncio AS date));	
					set @fechaFinalDate = CONVERT(varchar, CAST(@fechaFin AS date));	
				end try
				begin catch
					print 'Ha ocurrido un error. Error 4. La fecha debe tener el formato "mm-dd-yyyy".'
				end catch
				begin transaction
					select FechaEvento.idFecha as idFecha,Evento.nombre as nombreEvento,Evento.descripcion as descripcionEvento,TipoEvento.nombre as tipoEvento,
							Pais.nombre as pais, LugarEvento.detalleUbicacion,FechaEvento.fechaHora as fecha from FechaEvento inner join
							Evento on Evento.idEvento=FechaEvento.idEvento inner join
							TipoEvento on TipoEvento.idTipoEvento=Evento.idEvento inner join
							Pais on Pais.idPais=FechaEvento.idPais inner join EventoXPais on EventoXPais.idEvento = FechaEvento.idEvento 
							and EventoXPais.idPais=FechaEvento.idPais inner join LugarEvento on LugarEvento.idLugar = EventoXPais.idLugar
							where FechaEvento.estado=1 and FechaEvento.fechaHora>=@fechaInicioDate and 
							FechaEvento.fechaHora<=DATEADD(DAY,1,@fechaFinalDate);
				commit transaction
			end
				--Filtra de una fecha de incio en adelante
		else if (@idTipoEvento is null and @fechaIncio is not null and @fechaFin is null)
			begin
				print 'Filtro de inicio en adelante'
				begin try
					set @fechaInicioDate = CONVERT(varchar, CAST(@fechaIncio AS date));	
				end try
				begin catch
					print 'Ha ocurrido un error. Error 4. La fecha debe tener el formato "mm-dd-yyyy".'
				end catch
				begin transaction

					select FechaEvento.idFecha as idFecha,Evento.nombre as nombreEvento,Evento.descripcion as descripcionEvento,TipoEvento.nombre as tipoEvento,
							Pais.nombre as pais, LugarEvento.detalleUbicacion,FechaEvento.fechaHora as fecha from FechaEvento inner join
							Evento on Evento.idEvento=FechaEvento.idEvento inner join
							TipoEvento on TipoEvento.idTipoEvento=Evento.idEvento inner join
							Pais on Pais.idPais=FechaEvento.idPais inner join EventoXPais on EventoXPais.idEvento = FechaEvento.idEvento 
							and EventoXPais.idPais=FechaEvento.idPais inner join LugarEvento on LugarEvento.idLugar = EventoXPais.idLugar
							where FechaEvento.estado=1 and FechaEvento.fechaHora>=@fechaInicioDate;

				commit transaction
			end
				--Filtra hasta una fecha final
		else if (@idTipoEvento is null and @fechaIncio is null and @fechaFin is not null)
			begin
				print 'filtro hasta final'
				begin try
					set @fechaFinalDate = CONVERT(varchar, CAST(@fechaFin AS date));	
				end try
				begin catch
					print 'Ha ocurrido un error. Error 4. La fecha debe tener el formato "mm-dd-yyyy".'
				end catch
				begin transaction

				select FechaEvento.idFecha as idFecha,Evento.nombre as nombreEvento,Evento.descripcion as descripcionEvento,TipoEvento.nombre as tipoEvento,
							Pais.nombre as pais, LugarEvento.detalleUbicacion,FechaEvento.fechaHora as fecha from FechaEvento inner join
							Evento on Evento.idEvento=FechaEvento.idEvento inner join
							TipoEvento on TipoEvento.idTipoEvento=Evento.idEvento inner join
							Pais on Pais.idPais=FechaEvento.idPais inner join EventoXPais on EventoXPais.idEvento = FechaEvento.idEvento 
							and EventoXPais.idPais=FechaEvento.idPais inner join LugarEvento on LugarEvento.idLugar = EventoXPais.idLugar
							where FechaEvento.estado=1 and FechaEvento.fechaHora<=DATEADD(DAY,1,@fechaFinalDate);

				commit transaction
			end--todo nulo
		else if (@idTipoEvento is null and @fechaIncio is null and @fechaFin is null)
			begin
				set @error=1;
				set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar al menos un parametro para filtrar.';
				RAISERROR ('Error interno',16,1);
			end
	end try
	begin catch--Atrapa cualquier error en la transaccion.
			print @errorMsg;
	end catch
	end
END
GO
-----------------------------------------------------------------------------------
--Consultar disponibilidad de entradas de un evento
GO
CREATE PROCEDURE spConsultarDisponibilidadTipoEntrada @idFecha int,@idTipoEntrada int with encryption AS
BEGIN
	--Cuando un usuario selecciona un evento, le apareceran los tipos de entrada disponible
	--y su precio.

	--para provechar el procedimniento se puede usar para sacar los tipos de entradas de un evento
	--y tambien para sacar cuantos campos hay de un tipo de entrada de un evento.

	--con la fecha se saca el evento, pais y fecha.

	declare @error int, @errorMsg varchar(200);
	
	begin
	begin try
		if (@idFecha is null)begin
			set @error=1;
			set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+'.Debe ingresar el parametro @idFecha';
			RAISERROR ('Error interno',16,1); 
			end
		else
			begin
				--validar que exista
				if (select count(*) from FechaEvento where idFecha=@idFecha and estado!=-1)>0	
					begin--si existe
						--filtrar por el tipo de entrada ingresado.
						if (@idTipoEntrada is not null)
							begin
								if (select count(*) from TipoEntrada where idTipoEntrada=@idTipoEntrada)>0
									begin
									begin transaction
									
									select TipoAsiento.nombre as tipoEntrada, TipoAsiento.cantidad as disponible,Moneda.nombre as moneda,
										TipoEntrada.precio as precio, TipoEntrada.recargoTipoServicio as recargoServicio from FechaEvento inner join
										TipoEntrada on TipoEntrada.idTipoEntrada=@idTipoEntrada inner join 
										Pais on Pais.idPais = FechaEvento.idPais inner join
										Moneda on Moneda.idMoneda=Pais.moneda inner join
										TipoAsiento on TipoAsiento.numeroAsiento=TipoEntrada.idTipoAsiento
										where FechaEvento.idFecha=@idFecha and FechaEvento.estado!=-1;
									
									commit transaction
									end
								else
									begin
										set @error=3;
										set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
											'. No existe tipo de entrada con el @idTipoEntrada ingresado..';
										RAISERROR ('Error interno',16,1); 
									end
								
							end
						else--mostrar todos los tipos de entrada disponble para el evento
							begin
								begin transaction
									
									select TipoAsiento.nombre as tipoEntrada,TipoAsiento.cantidad as disponible,
										Moneda.nombre as moneda,TipoEntrada.precio as precio, 
										TipoEntrada.recargoTipoServicio as recargoServicio
										from FechaEvento  inner join  EventoXPais on EventoXPais.idEvento=FechaEvento.idEvento
										and EventoXPais.idPais=FechaEvento.idPais inner join
										Pais on Pais.idPais=FechaEvento.idPais inner join
										Moneda on Moneda.idMoneda=Pais.moneda inner join
										LugarEvento on LugarEvento.idLugar=EventoXPais.idLugar inner join
										TipoAsiento on TipoAsiento.idLugar=LugarEvento.idLugar inner join
										TipoEntrada on TipoEntrada.idTipoAsiento=TipoAsiento.numeroAsiento
										where FechaEvento.idFecha=@idFecha and FechaEvento.estado!=-1;

								commit transaction
							end
					end
				else
					begin
						set @error=2;
						set @errorMsg='Ha ocurrido un error. Error '+ CAST(@error AS VARCHAR)+
									'. No existe fecha de evento con el @idFecha ingresado.';
						RAISERROR ('Error interno',16,1); 
					end


			end
	end try
	begin catch--Atrapa cualquier error en la transaccion.
			print @errorMsg;
	end catch
	end
	/*
	Pruebas
	exec spConsultarDisponibilidadTipoEntrada null,null;--Erro 1. id fecha nulo. FUNCIONA
	exec spConsultarDisponibilidadTipoEntrada 5,null;--Consultar por fecha de evento en general. FUNCIONA
	exec spConsultarDisponibilidadTipoEntrada 5,1;--Consultar por fecha de evento y un tipo de asiento.

	select * from FechaEvento;
	select * from TipoEntrada;
	
	*/
END
GO
-----------------------------------------------------------------------------------
--Consultar comentarios cliente (consultar los problemas/quejas reportados por los clientes)
GO
CREATE PROCEDURE spConsultarComentarios @fechaInicio varchar(10),@fechaFin varchar(10),
										@idCliente int,@idFechaEvento int with encryption AS
BEGIN
	/*
		--Fechas 
		--Cliente
		--Evento
		
		--Ver comentarios y soluciones
	*/

	declare @errorMsg varchar(200);
	declare @fechaDateInicio date;
	declare @fechaDateFin date;

	begin
	begin try
		if (@fechaInicio is null and @fechaFin is null and 
			@idCliente is null and @idFechaEvento is null)
			begin
				set @errorMsg='Ha ocurrido un error. Error '+ CAST(1 AS VARCHAR)+
							'. Debe ingresar al menos un parametro para filtrar.';
				RAISERROR ('Error interno',16,1);
			end
		else
			begin--Si ingreso parametro
				
				--Filtro por fechas
				if (@fechaInicio is not null and @fechaFin is not null)
					begin
						begin try
							set @fechaDateInicio = CONVERT(DATE, CAST(@fechaInicio AS datetime));
							set @fechaDateFin = CONVERT(DATE, CAST(@fechaFin AS datetime));
							set @fechaDateFin = DATEADD(DAY,1,@fechaDateFin);--para que incluya el ultimo dia
							end try
						begin catch
							print 'Error 2. El formato de las fechas debe ser "mm-dd-yyyy".'
							RAISERROR ('Error interno',16,1);
						end catch
							begin transaction
							select Comentario.comentario as comentario,TipoComentario.nombreTipoComentario as tipoComentario,
								case 
									when Solucion.reembolso=0 then 'No' 
									when Solucion.reembolso=1 then 'Si' 
								end as reembolso
								,case 
									when Solucion.reemplazo=0 then 'No'
									when Solucion.reemplazo=1 then 'Si'
								end as reemplazo, AtencionCliente.fechaHora
								from AtencionCliente inner join Comentario on Comentario.idComentario=AtencionCliente.idComentario
								inner join TipoComentario on TipoComentario.idTipoComentario=Comentario.idTipoComentario
								inner join Solucion on Solucion.idSolucion=AtencionCliente.idSolucion
								where AtencionCliente.fechaHora between @fechaDateInicio and @fechaDateFin;
							commit transaction
					end
			--Filtro Por Cliente
			else if (@idCliente is not null)
				begin
					if (select count(*) from Cliente where idCliente=@idCliente)>0
						begin
							begin transaction
								select Cliente.idCliente as idCliente,C.comentario as comentario,TC.nombreTipoComentario as tipoComentario,
								case 
									when S.reembolso=0 then 'No' 
									when S.reembolso=1 then 'Si' 
								end as reembolso
								,case 
									when S.reemplazo=0 then 'No'
									when S.reemplazo=1 then 'Si'
								end as reemplazo, AC.fechaHora
								
								
								from AtencionCliente as AC inner join Comentario as C on C.idComentario=AC.idComentario
								inner join Entrada as E on E.idEntrada=C.idEntrada inner join Detalle as D on D.idEntrada=E.idEntrada
								inner join Compra on Compra.idCompra=D.idCompra inner join Cliente on Cliente.idCliente=Compra.idCliente
								inner join TipoComentario as TC on TC.idTipoComentario= C.idTipoComentario
								inner join Solucion as S on S.idSolucion=AC.idSolucion
								where Cliente.idCliente=@idCliente;
							commit transaction
						end
					else
						begin
							set @errorMsg='Ha ocurrido un error. Error '+ CAST(3 AS VARCHAR)+
							'. No existe cliente con el @idCliente ingresado.';
							RAISERROR ('Error interno',16,1);
						end
				end
			--Filtro por Evento
			else if (@idFechaEvento is not null)
				begin
					if (select count(*) from FechaEvento where idFecha=@idFechaEvento)>0
						begin
							begin transaction

								select FE.idEvento,Ev.nombre as nombreEvento,P.nombre as pais,C.comentario as comentario,
								TC.nombreTipoComentario as tipoComentario ,
								case 
									when S.reembolso=0 then 'No' 
									when S.reembolso=1 then 'Si' 
								end as reembolso
								,case 
									when S.reemplazo=0 then 'No'
									when S.reemplazo=1 then 'Si'
								end as reemplazo, AC.fechaHora
								
								from AtencionCliente as AC inner join Comentario as C on C.idComentario=AC.idComentario
								inner join Entrada as En on En.idEntrada=C.idEntrada 
								inner join FechaEvento as FE on FE.idFecha=En.idFechaEvento 
								inner join EventoXPais as EP on EP.idEvento=FE.idEvento and EP.idPais=FE.idPais
								inner join Evento as Ev on Ev.idEvento=EP.idEvento
								inner join Pais as P on P.idPais=EP.idPais
								inner join TipoComentario as TC on TC.idTipoComentario=C.idTipoComentario
								inner join Solucion as S on S.idSolucion=AC.idSolucion
								
								where FE.idFecha=@idFechaEvento;
							commit transaction
						end
					else
						begin
							set @errorMsg='Ha ocurrido un error. Error '+ CAST(4 AS VARCHAR)+
							'. No existe evento con el @idFechaEvento ingresado.';
							RAISERROR ('Error interno',16,1);

						end
				end
			end
	end try
	begin catch--Atrapa cualquier error en la transaccion.
			print @errorMsg;
	end catch
	end
	/*
	--Fechas
	declare @fechaDateInicio date;
	declare @fechaDateFin date;
	set @fechaDateInicio=CONVERT(DATE, CAST('01-01-2022' AS datetime));
	set @fechaDateFin = CONVERT(DATE, CAST('06-10-2022' AS datetime));
	set @fechaDateFin = DATEADD(DAY,1,@fechaDateFin);

	select Comentario.comentario as comentario,TipoComentario.nombreTipoComentario as tipoComentario,
		case 
			when Solucion.reembolso=0 then 'No' 
			when Solucion.reembolso=1 then 'Si' 
		end as reembolso
		,case 
			when Solucion.reemplazo=0 then 'No'
			when Solucion.reemplazo=1 then 'Si'
		end as reemplazo, AtencionCliente.fechaHora
		from AtencionCliente inner join Comentario on Comentario.idComentario=AtencionCliente.idComentario
		inner join TipoComentario on TipoComentario.idTipoComentario=Comentario.idTipoComentario
		inner join Solucion on Solucion.idSolucion=AtencionCliente.idSolucion
		where AtencionCliente.fechaHora between @fechaDateInicio and @fechaDateFin;
	--Cliente
	declare @idCliente int =1;
	select Cliente.idCliente as idCliente,C.comentario as comentario,TC.nombreTipoComentario as tipoComentario,
			case 
				when S.reembolso=0 then 'No' 
				when S.reembolso=1 then 'Si' 
			end as reembolso
			,case 
				when S.reemplazo=0 then 'No'
				when S.reemplazo=1 then 'Si'
			end as reemplazo, AC.fechaHora
								
								
			from AtencionCliente as AC inner join Comentario as C on C.idComentario=AC.idComentario
			inner join Entrada as E on E.idEntrada=C.idEntrada inner join Detalle as D on D.idEntrada=E.idEntrada
			inner join Compra on Compra.idCompra=D.idCompra inner join Cliente on Cliente.idCliente=Compra.idCliente
			inner join TipoComentario as TC on TC.idTipoComentario= C.idTipoComentario
			inner join Solucion as S on S.idSolucion=AC.idSolucion
			where Cliente.idCliente=@idCliente;
	--Evento							
	declare @idFechaEvento int= 5;
	--select * from FechaEvento;
	--select * from AtencionCliente;
	select FE.idEvento,Ev.nombre as nombreEvento,P.nombre as pais,C.comentario as comentario,
		TC.nombreTipoComentario as tipoComentario ,
		case 
			when S.reembolso=0 then 'No' 
			when S.reembolso=1 then 'Si' 
		end as reembolso
		,case 
			when S.reemplazo=0 then 'No'
			when S.reemplazo=1 then 'Si'
		end as reemplazo, AC.fechaHora
								
		from AtencionCliente as AC inner join Comentario as C on C.idComentario=AC.idComentario
		inner join Entrada as En on En.idEntrada=C.idEntrada 
		inner join FechaEvento as FE on FE.idFecha=En.idFechaEvento 
		inner join EventoXPais as EP on EP.idEvento=FE.idEvento and EP.idPais=FE.idPais
		inner join Evento as Ev on Ev.idEvento=EP.idEvento
		inner join Pais as P on P.idPais=EP.idPais
		inner join TipoComentario as TC on TC.idTipoComentario=C.idTipoComentario
		inner join Solucion as S on S.idSolucion=AC.idSolucion	
		where FE.idFecha=@idFechaEvento;
	

	--Por fechas
	exec spConsultarComentarios '01-01-2022','06-10-2022',null,null;
	--Por cliente
	exec spConsultarComentarios null,null,1,null;
	--Por evento
	exec spConsultarComentarios null,null,null,5;
	*/
END
GO
-----------------------------------------------------------------------------------
--Consultar pais donde mas eventos se dan
GO
CREATE PROCEDURE spConsultarPaisMasEventos @fechaInicio varchar(10),@fechaFin varchar(10),@idTipoEvento int with encryption AS
BEGIN
	/*  Se debe poder ver cual es el país donde mas eventos se dan, el tipo de evento,
		y las fechas, todo esto de manera opcional.

	*/

	declare @errorMsg varchar(200);
	declare @fechaDateInicio date;
	declare @fechaDateFin date;
	--Validar opcion
	begin
	begin try
		--Sin parametros filtra siplemente el pais donde mas eventos se dan.
		if (@fechaInicio is null and @fechaFin is null and @idTipoEvento is null)
			begin
				begin transaction
				select TOP 1 count(FE.idPais) as cantidadEventos,FE.idPais,P.nombre as pais from FechaEvento as FE 
					inner join Pais as P on FE.idPais=P.idPais
					group by FE.idPais,P.nombre;
				commit transaction
				
			end
		--Filtra por fechas
		else if (@fechaInicio is not null and @fechaFin is not null and @idTipoEvento is null)
			begin
				begin try
						set @fechaDateInicio = CONVERT(DATE, CAST(@fechaInicio AS datetime));
						set @fechaDateFin = CONVERT(DATE, CAST(@fechaFin AS datetime));
						set @fechaDateFin = DATEADD(DAY,1,@fechaDateFin);--para que incluya el ultimo dia
					end try
				begin catch
					print 'Error 1. El formato de las fechas debe ser "mm-dd-yyyy".';
				end catch
				begin transaction
					select TOP 1 count(FE.idPais) as cantidadEventos,FE.idPais,P.nombre as pais from FechaEvento as FE 
					inner join Pais as P on FE.idPais=P.idPais
					where FE.fechaHora between @fechaDateInicio and @fechaDateFin group by FE.idPais,P.nombre;
				commit transaction
			end
		--Filtra por tipo evento
		else if (@fechaInicio is null and @fechaFin is null and @idTipoEvento is not null)
			begin
				begin transaction
					select TOP 1 count(FE.idPais) as cantidadEventos,TipoEvento.idTipoEvento,TipoEvento.nombre as tipoEvento,
						FE.idPais,P.nombre as pais from FechaEvento as FE 		
						inner join Pais as P on FE.idPais=P.idPais inner join Evento on Evento.idEvento=FE.idEvento
						inner join TipoEvento on TipoEvento.idTipoEvento=Evento.idTipoEvento
						where TipoEvento.idTipoEvento=@idTipoEvento group by TipoEvento.idTipoEvento,TipoEvento.nombre,FE.idPais,P.nombre;
				commit transaction
			end
		else if (@fechaInicio is not null and @fechaFin is not null and @idTipoEvento is not null)
			begin
				begin try
							set @fechaDateInicio = CONVERT(DATE, CAST(@fechaInicio AS datetime));
							set @fechaDateFin = CONVERT(DATE, CAST(@fechaFin AS datetime));
							set @fechaDateFin = DATEADD(DAY,1,@fechaDateFin);--para que incluya el ultimo dia
						end try
				begin catch
					print 'Error 1. El formato de las fechas debe ser "mm-dd-yyyy".';
				end catch
				select TOP 1 count(FE.idPais) as cantidadEventos,TipoEvento.idTipoEvento,TipoEvento.nombre as tipoEvento,
						FE.idPais,P.nombre as pais from FechaEvento as FE 		
						inner join Pais as P on FE.idPais=P.idPais inner join Evento on Evento.idEvento=FE.idEvento
						inner join TipoEvento on TipoEvento.idTipoEvento=Evento.idTipoEvento
						where TipoEvento.idTipoEvento=@idTipoEvento and FE.fechaHora between @fechaDateInicio and @fechaDateFin
						group by TipoEvento.idTipoEvento,TipoEvento.nombre,FE.idPais,P.nombre;
			end
	end try
	begin catch--Atrapa cualquier error en la transaccion.
			print @errorMsg;
	end catch
	end

	/*
	--Consulta pais con mas eventos
	exec spConsultarPaisMasEventos null,null,null;
	--Consulta pais con mas evento por fechas
	exec spConsultarPaisMasEventos '01-01-2022' ,'08-21-2022' ,null;
	--Consulta pais con mas eventos por tipo evento
	exec spConsultarPaisMasEventos null,null,1;
	--Consultar pais con mas eventos por fechas y tipo de evento
	exec spConsultarPaisMasEventos '01-01-2022' ,'08-21-2022' ,2;



	declare @fechaDateInicio date  = CONVERT(DATE, CAST('01-01-2022' AS datetime));
	declare @fechaDateFin date = CONVERT(DATE, CAST('08-21-2022' AS datetime));

	--General
	select TOP 1 count(FE.idPais) as cantidadEventos,FE.idPais,P.nombre as pais from FechaEvento as FE 
			inner join Pais as P on FE.idPais=P.idPais
			group by FE.idPais,P.nombre;
	--Por fechas
	select TOP 1 count(FE.idPais) as cantidadEventos,FE.idPais,P.nombre as pais from FechaEvento as FE 
			inner join Pais as P on FE.idPais=P.idPais
			where FE.fechaHora between @fechaDateInicio and @fechaDateFin group by FE.idPais,P.nombre;
	--Por tipo evento
	declare @idTipoEvento int = 1;
	select TOP 1 count(FE.idPais) as cantidadEventos,TipoEvento.idTipoEvento,TipoEvento.nombre as tipoEvento,
			FE.idPais,P.nombre as pais from FechaEvento as FE 		
			inner join Pais as P on FE.idPais=P.idPais inner join Evento on Evento.idEvento=FE.idEvento
			inner join TipoEvento on TipoEvento.idTipoEvento=Evento.idTipoEvento
			where TipoEvento.idTipoEvento=@idTipoEvento group by TipoEvento.idTipoEvento,TipoEvento.nombre,FE.idPais,P.nombre;


	select * from FechaEvento;
	*/

END
GO
-----------------------------------------------------------------------------------
--Consular pais donde artistas generan mas ventas
GO
CREATE PROCEDURE spConsultarPaisGeneraMasArtista @idArtista int with encryption AS
BEGIN
	/*
	Determinar en cuál país es donde un grupo/artista genera mas ventas, por lo que es necesario una consulta donde pueda
	consultarse por artista o por todos los artistas dónde es mas popular debido a las ventas.
	*/
	declare @error int, @errorMsg varchar(200);
	--Validar opcion
	begin
	begin try
	if (@idArtista is not null)--Consultar artitsta en espeficico
		begin	
			if (select count(*) from Artista where idArtista=@idArtista)>0
				begin
				begin transaction
					select  TOP 1 sum(D.subtotal) totalVentas,A.nombre,P.idPais as idPais,P.nombre as pais from Detalle as D 
						inner join Entrada as En on En.idEntrada = D.idEntrada
						inner join FechaEvento as FE on FE.idFecha = En.idFechaEvento
						inner join Pais as P on P.idPais = FE.idPais 
						inner join ArtistaXEvento as AE on AE.idFecha=FE.idFecha and AE.idArtista=@idArtista
						inner join Artista as A on A.idArtista=AE.idArtista
						where AE.idArtista=@idArtista
						group by P.idPais,P.nombre,A.nombre order by  totalVentas desc;
				commit transaction
				end
			else
				begin
					set @errorMsg='Ha ocurrido un error. Error '+ CAST(1 AS VARCHAR)+
								'. No existe artista con el @idArtista ingresado.';
					RAISERROR ('Error interno',16,1);
				end
		end
	else--Consultar todos los artistas
		begin			
			select sum(D.subtotal) totalVentas,A.nombre,P.idPais as idPais,P.nombre as pais from Detalle as D 
				inner join Entrada as En on En.idEntrada = D.idEntrada
				inner join FechaEvento as FE on FE.idFecha = En.idFechaEvento
				inner join Pais as P on P.idPais = FE.idPais 
				inner join ArtistaXEvento as AE on AE.idFecha=FE.idFecha
				inner join Artista as A on A.idArtista=AE.idArtista
				group by P.idPais,P.nombre,A.nombre order by  totalVentas desc;


		end
	end try
	begin catch--Atrapa cualquier error en la transaccion.
			print @errorMsg;
	end catch
	end
	/*
	select  TOP 1 sum(D.subtotal) totalVentas,A.nombre,P.idPais as idPais,P.nombre as pais from Detalle as D 
		inner join Entrada as En on En.idEntrada = D.idEntrada
		inner join FechaEvento as FE on FE.idFecha = En.idFechaEvento
		inner join Pais as P on P.idPais = FE.idPais 
		inner join ArtistaXEvento as AE on AE.idFecha=FE.idFecha and AE.idArtista=2
		inner join Artista as A on A.idArtista=AE.idArtista
		where AE.idArtista=2
		group by P.idPais,P.nombre,A.nombre order by  totalVentas desc;


	select sum(D.subtotal) totalVentas,A.nombre,P.idPais as idPais,P.nombre as pais from Detalle as D 
		inner join Entrada as En on En.idEntrada = D.idEntrada
		inner join FechaEvento as FE on FE.idFecha = En.idFechaEvento
		inner join Pais as P on P.idPais = FE.idPais 
		inner join ArtistaXEvento as AE on AE.idFecha=FE.idFecha
		inner join Artista as A on A.idArtista=AE.idArtista
		group by P.idPais,P.nombre,A.nombre order by  totalVentas desc;

	select * from Detalle;
	select * from Entrada;
	select * from Compra;
	select * from Estado;
	*/
END
GO
-----------------------------------------------------------------------------------
--Consular eventos x nombre de evento, tipo presentacion,pais,artista,fechas,tipos de entrada
GO
CREATE PROCEDURE spConsultarEventos @nombre varchar(100),@idTipoEvento int,@idPais int,
									@fechaInicio varchar(10),@fechaFin varchar(10) with encryption AS
BEGIN
	declare @error int, @errorMsg varchar(200),@fechaInicioDate date,@fechaFinDate date;
	begin
	begin try
		if (@nombre is not null)
			begin
				begin transaction
					--Vendidas
					select count(Entrada.idEntrada) as entradasVendidas,TipoAsiento.nombre, Pais.nombre as pais,
							FechaEvento.idFecha from Entrada inner join
							TipoEntrada on TipoEntrada.idTipoEntrada=Entrada.idTipoEntrada inner join
							TipoAsiento on TipoAsiento.numeroAsiento=TipoEntrada.idTipoAsiento inner join 
							FechaEvento on FechaEvento.idFecha = Entrada.idFechaEvento inner join 
							EventoXPais on EventoXPais.idEvento = FechaEvento.idEvento and
											EventoXPais.idPais=FechaEvento.idPais inner join
							LugarEvento on LugarEvento.idLugar=EventoXPais.idLugar inner join
							Evento on Evento.idEvento=FechaEvento.idEvento inner join 
							Pais on Pais.idPais=FechaEvento.idPais
							where Entrada.estado=4 and Evento.nombre=@nombre
							group by TipoAsiento.numeroAsiento,TipoAsiento.nombre,Pais.nombre,
									LugarEvento.nombre,FechaEvento.idFecha;
					--Sin vender
					select sum(TipoAsiento.cantidad) sinVender,TipoAsiento.nombre,FechaEvento.idFecha as fecha,
						Pais.nombre as pais
						from TipoAsiento inner join
						LugarEvento on LugarEvento.idLugar=TipoAsiento.idLugar inner join
						EventoXPais on EventoXPais.idLugar=LugarEvento.idLugar inner join
						Evento on Evento.idEvento=EventoXPais.idEvento inner join
						Pais on Pais.idPais=EventoXPais.idPais inner join
						FechaEvento on FechaEvento.idEvento=Evento.idEvento and FechaEvento.idPais=Pais.idPais
						where Evento.nombre=@nombre
						group by TipoAsiento.nombre,FechaEvento.idFecha,Pais.nombre;
					--Monto total recaudado con recargo, precio e impuesto.
					select sum(distinct Compra.total) montoTotalRecaudado,Moneda.nombre as moneda,Evento.nombre,Pais.nombre
						from Compra inner join 
						Detalle on Detalle.idCompra=Compra.idCompra inner join
						Entrada on Entrada.idEntrada=Detalle.idEntrada inner join
						FechaEvento on FechaEvento.idFecha=Entrada.idFechaEvento inner join
						Evento on Evento.idEvento=FechaEvento.idEvento inner join 
						Pais on Pais.idPais=FechaEvento.idPais inner join
						Moneda on Moneda.idMoneda=Pais.moneda
						where Evento.nombre=@nombre group by Evento.nombre,Pais.nombre,Moneda.nombre;
					--Monto recaudado por servicios
					select sum(TipoEntrada.recargoTipoServicio) as montoPorRecargoServicios,Moneda.nombre as moneda,
						Pais.nombre as pais,FechaEvento.idFecha as idFecha
						from TipoEntrada inner join
						Entrada on Entrada.idTipoEntrada=TipoEntrada.idTipoEntrada inner join
						TipoAsiento on TipoAsiento.numeroAsiento=TipoEntrada.idTipoAsiento inner join
						FechaEvento on FechaEvento.idFecha=Entrada.idFechaEvento  inner join
						Evento on Evento.idEvento=Evento.idEvento inner join
						Pais on Pais.idPais=FechaEvento.idPais inner join
						Moneda on Moneda.idMoneda=Pais.moneda
						where Evento.nombre=@nombre
						group by Pais.nombre,Moneda.nombre,FechaEvento.idFecha;
					--Monto recaudado de impuestos
					select sum(Detalle.subtotal-(Detalle.subtotal*Pais.porcentajeImpuestos)) as impuestos,
						Moneda.nombre,Pais.nombre,Evento.nombre
						from Detalle inner join
						Entrada on Entrada.idEntrada=Detalle.idEntrada inner join
						FechaEvento on FechaEvento.idFecha=Entrada.idFechaEvento inner join
						Pais on Pais.idPais=FechaEvento.idPais inner join
						Evento on Evento.idEvento=FechaEvento.idEvento inner join
						Moneda on Moneda.idMoneda=Pais.moneda
						where Evento.nombre=@nombre group by Moneda.nombre,Pais.nombre,Evento.nombre;
				commit transaction
			end
		else if (@idTipoEvento is not null)
			begin
					--Vendidas
					begin transaction
					select count(Entrada.idEntrada) as entradasVendidas,TipoAsiento.nombre,Pais.nombre as pais,
						FechaEvento.idFecha,TipoEvento.nombre as tipoEvento from Entrada inner join
						TipoEntrada on TipoEntrada.idTipoEntrada=Entrada.idTipoEntrada inner join
						TipoAsiento on TipoAsiento.numeroAsiento=TipoEntrada.idTipoAsiento inner join 
						FechaEvento on FechaEvento.idFecha = Entrada.idFechaEvento inner join 
						EventoXPais on EventoXPais.idEvento = FechaEvento.idEvento and
										EventoXPais.idPais=FechaEvento.idPais inner join
						LugarEvento on LugarEvento.idLugar=EventoXPais.idLugar inner join
						Evento on Evento.idEvento=FechaEvento.idEvento inner join 
						Pais on Pais.idPais=FechaEvento.idPais inner join 
						TipoEvento on TipoEvento.idTipoEvento=Evento.idTipoEvento
						where Entrada.estado=4 and TipoEvento.idTipoEvento=@idTipoEvento
						group by TipoAsiento.numeroAsiento,TipoAsiento.nombre,
							Pais.nombre,LugarEvento.nombre,FechaEvento.idFecha,TipoEvento.nombre;
					--Sin vender
					select sum(TipoAsiento.cantidad) sinVender,TipoAsiento.nombre,FechaEvento.idFecha as fecha,
						Pais.nombre,TipoEvento.nombre as tipoEvento
						from TipoAsiento inner join
						LugarEvento on LugarEvento.idLugar=TipoAsiento.idLugar inner join
						EventoXPais on EventoXPais.idLugar=LugarEvento.idLugar inner join
						Evento on Evento.idEvento=EventoXPais.idEvento inner join
						Pais on Pais.idPais=EventoXPais.idPais inner join
						FechaEvento on FechaEvento.idEvento=Evento.idEvento and 
										FechaEvento.idPais=Pais.idPais inner join
						TipoEvento on TipoEvento.idTipoEvento=Evento.idTipoEvento
						where TipoEvento.idTipoEvento = @idTipoEvento
						group by TipoAsiento.nombre,FechaEvento.idFecha,Pais.nombre,TipoEvento.nombre;
					--Monto total recaudado con recargo, precio e impuesto.
					select sum(distinct Compra.total) montoTotalRecaudado,Moneda.nombre as moneda,Evento.nombre,
						Pais.nombre,TipoEvento.nombre as tipoEvento
						from Compra inner join 
						Detalle on Detalle.idCompra=Compra.idCompra inner join
						Entrada on Entrada.idEntrada=Detalle.idEntrada inner join
						FechaEvento on FechaEvento.idFecha=Entrada.idFechaEvento inner join
						Evento on Evento.idEvento=FechaEvento.idEvento inner join 
						Pais on Pais.idPais=FechaEvento.idPais inner join
						Moneda on Moneda.idMoneda=Pais.moneda inner join
						TipoEvento on TipoEvento.idTipoEvento=Evento.idTipoEvento
						where TipoEvento.idTipoEvento=@idTipoEvento and Compra.estado=6
						group by Evento.nombre,Pais.nombre,Moneda.nombre,TipoEvento.nombre;
					--Monto recaudado por servicios
					select sum(TipoEntrada.recargoTipoServicio) as montoPorRecargoServicios,Moneda.nombre as moneda,
						Pais.nombre as pais,FechaEvento.idFecha as idFecha,TipoEvento.nombre as tipoEvento
						from TipoEntrada inner join
						Entrada on Entrada.idTipoEntrada=TipoEntrada.idTipoEntrada inner join
						TipoAsiento on TipoAsiento.numeroAsiento=TipoEntrada.idTipoAsiento inner join
						FechaEvento on FechaEvento.idFecha=Entrada.idFechaEvento  inner join
						Evento on Evento.idEvento=Evento.idEvento inner join
						Pais on Pais.idPais=FechaEvento.idPais inner join
						Moneda on Moneda.idMoneda=Pais.moneda inner join 
						TipoEvento on TipoEvento.idTipoEvento=@idTipoEvento
						where TipoEvento.idTipoEvento=@idTipoEvento and Entrada.estado=4
						group by Pais.nombre,Moneda.nombre,FechaEvento.idFecha,TipoEvento.nombre ;
					--Monto recaudado de impuestos
					select sum(Detalle.subtotal-(Detalle.subtotal*Pais.porcentajeImpuestos)) as impuestos,
						Moneda.nombre,Pais.nombre,Evento.nombre as evento,TipoEvento.nombre as tipoEvento
						from Detalle inner join
						Entrada on Entrada.idEntrada=Detalle.idEntrada inner join
						FechaEvento on FechaEvento.idFecha=Entrada.idFechaEvento inner join
						Pais on Pais.idPais=FechaEvento.idPais inner join
						Evento on Evento.idEvento=FechaEvento.idEvento inner join
						Moneda on Moneda.idMoneda=Pais.moneda inner join
						TipoEvento on TipoEvento.idTipoEvento=@idTipoEvento
						where TipoEvento.idTipoEvento=@idTipoEvento and Entrada.estado=4
						group by Moneda.nombre,Pais.nombre,Evento.nombre,TipoEvento.nombre;
				commit transaction
			end
		else if (@idPais is not null)
			begin
				begin transaction
					--Vendidas
					select count(Entrada.idEntrada) as entradasVendidas,TipoAsiento.nombre,Pais.nombre as pais,
						FechaEvento.idFecha from Entrada inner join
						TipoEntrada on TipoEntrada.idTipoEntrada=Entrada.idTipoEntrada inner join
						TipoAsiento on TipoAsiento.numeroAsiento=TipoEntrada.idTipoAsiento inner join 
						FechaEvento on FechaEvento.idFecha = Entrada.idFechaEvento inner join 
						EventoXPais on EventoXPais.idEvento = FechaEvento.idEvento and
										EventoXPais.idPais=FechaEvento.idPais inner join
						LugarEvento on LugarEvento.idLugar=EventoXPais.idLugar inner join
						Evento on Evento.idEvento=FechaEvento.idEvento inner join 
						Pais on Pais.idPais=FechaEvento.idPais 
						where Entrada.estado=4 and Pais.idPais=@idPais 
						group by TipoAsiento.numeroAsiento,TipoAsiento.nombre,
							Pais.nombre,LugarEvento.nombre,FechaEvento.idFecha;
					--Sin vender
					select sum(TipoAsiento.cantidad) sinVender,TipoAsiento.nombre,FechaEvento.idFecha as fecha,
						Pais.nombre from TipoAsiento inner join
						LugarEvento on LugarEvento.idLugar=TipoAsiento.idLugar inner join
						EventoXPais on EventoXPais.idLugar=LugarEvento.idLugar inner join
						Evento on Evento.idEvento=EventoXPais.idEvento inner join
						Pais on Pais.idPais=EventoXPais.idPais inner join
						FechaEvento on FechaEvento.idEvento=Evento.idEvento and 
										FechaEvento.idPais=Pais.idPais 
						where Pais.idPais=@idPais
						group by TipoAsiento.nombre,FechaEvento.idFecha,Pais.nombre;
					--Monto total recaudado con recargo, precio e impuesto.
					select sum(distinct Compra.total) montoTotalRecaudado,Pais.nombre as pais,Moneda.nombre as moneda
						 from Compra inner join 
						Detalle on Detalle.idCompra=Compra.idCompra inner join
						Entrada on Entrada.idEntrada=Detalle.idEntrada inner join
						FechaEvento on FechaEvento.idFecha=Entrada.idFechaEvento inner join
						Evento on Evento.idEvento=FechaEvento.idEvento inner join 
						Pais on Pais.idPais=@idPais inner join
						Moneda on Moneda.idMoneda=Pais.moneda 
						where Pais.idPais=@idPais and Compra.estado=6 and FechaEvento.idPais=@idPais
						group by Pais.nombre,Moneda.nombre;
					--Monto recaudado por servicios
					select sum(TipoEntrada.recargoTipoServicio) as montoPorRecargoServicios,Moneda.nombre as moneda,
						Pais.nombre as pais from TipoEntrada inner join
						Entrada on Entrada.idTipoEntrada=TipoEntrada.idTipoEntrada inner join
						TipoAsiento on TipoAsiento.numeroAsiento=TipoEntrada.idTipoAsiento inner join
						FechaEvento on FechaEvento.idFecha=Entrada.idFechaEvento  inner join
						Evento on Evento.idEvento=Evento.idEvento inner join
						Pais on Pais.idPais=FechaEvento.idPais inner join
						Moneda on Moneda.idMoneda=Pais.moneda 
						where Entrada.estado=4 and Pais.idPais=@idPais
						group by Pais.nombre,Moneda.nombre;
					--Monto recaudado de impuestos
					select sum(Detalle.subtotal-(Detalle.subtotal*Pais.porcentajeImpuestos)) as impuestos,
						Moneda.nombre,Pais.nombre,Evento.nombre as evento 
						from Detalle inner join
						Entrada on Entrada.idEntrada=Detalle.idEntrada inner join
						FechaEvento on FechaEvento.idFecha=Entrada.idFechaEvento inner join
						Pais on Pais.idPais=FechaEvento.idPais inner join
						Evento on Evento.idEvento=FechaEvento.idEvento inner join
						Moneda on Moneda.idMoneda=Pais.moneda 
						where Pais.idPais=@idPais and Entrada.estado=4
						group by Moneda.nombre,Pais.nombre,Evento.nombre;
				commit transaction

			end
		else if (@fechaInicio is not null and @fechaFin is not null)
			begin
				begin try
					set @fechaInicioDate=CONVERT(DATE, CAST(@fechaInicio AS datetime));
					set @fechaFinDate=CONVERT(DATE, CAST(@fechaFin AS datetime));
				end try
				begin catch
					print 'Ha ocurrido un error convirtiendo las fechas.'
					RAISERROR ('Error interno',16,1);
				end catch
				begin transaction
				--Vendidas
				select count(Entrada.idEntrada) as entradasVendidas,TipoAsiento.nombre,Pais.nombre as pais,
						FechaEvento.idFecha from Entrada inner join
						TipoEntrada on TipoEntrada.idTipoEntrada=Entrada.idTipoEntrada inner join
						TipoAsiento on TipoAsiento.numeroAsiento=TipoEntrada.idTipoAsiento inner join 
						FechaEvento on FechaEvento.idFecha = Entrada.idFechaEvento inner join 
						EventoXPais on EventoXPais.idEvento = FechaEvento.idEvento and
										EventoXPais.idPais=FechaEvento.idPais inner join
						LugarEvento on LugarEvento.idLugar=EventoXPais.idLugar inner join
						Evento on Evento.idEvento=FechaEvento.idEvento inner join 
						Pais on Pais.idPais=FechaEvento.idPais
						where Entrada.estado=4 and FechaEvento.fechaHora between @fechaInicioDate and @fechaFinDate
						group by TipoAsiento.numeroAsiento,TipoAsiento.nombre,
							Pais.nombre,LugarEvento.nombre,FechaEvento.idFecha;
				--Sin vender
				select sum(TipoAsiento.cantidad) sinVender,TipoAsiento.nombre,FechaEvento.idFecha as fecha,
						Pais.nombre
						from TipoAsiento inner join
						LugarEvento on LugarEvento.idLugar=TipoAsiento.idLugar inner join
						EventoXPais on EventoXPais.idLugar=LugarEvento.idLugar inner join
						Evento on Evento.idEvento=EventoXPais.idEvento inner join
						Pais on Pais.idPais=EventoXPais.idPais inner join
						FechaEvento on FechaEvento.idEvento=Evento.idEvento and FechaEvento.idPais=Pais.idPais
						where FechaEvento.fechaHora between @fechaInicioDate and @fechaFinDate
						group by TipoAsiento.nombre,FechaEvento.idFecha,Pais.nombre;
				--Monto total recaudado con recargo, precio e impuesto.
				select sum(distinct Compra.total) montoTotalRecaudado,Moneda.nombre as moneda,Evento.nombre,Pais.nombre
					from Compra inner join 
					Detalle on Detalle.idCompra=Compra.idCompra inner join
					Entrada on Entrada.idEntrada=Detalle.idEntrada inner join
					FechaEvento on FechaEvento.idFecha=Entrada.idFechaEvento inner join
					Evento on Evento.idEvento=FechaEvento.idEvento inner join 
					Pais on Pais.idPais=FechaEvento.idPais inner join
					Moneda on Moneda.idMoneda=Pais.moneda
					where FechaEvento.fechaHora between @fechaInicioDate and @fechaFinDate
					group by Evento.nombre,Pais.nombre,Moneda.nombre;
				--Monto recaudado por servicios
				select sum(TipoEntrada.recargoTipoServicio) as montoPorRecargoServicios,Moneda.nombre as moneda,
					Pais.nombre as pais,FechaEvento.idFecha as idFecha
					from TipoEntrada inner join
					Entrada on Entrada.idTipoEntrada=TipoEntrada.idTipoEntrada inner join
					TipoAsiento on TipoAsiento.numeroAsiento=TipoEntrada.idTipoAsiento inner join
					FechaEvento on FechaEvento.idFecha=Entrada.idFechaEvento  inner join
					Evento on Evento.idEvento=Evento.idEvento inner join
					Pais on Pais.idPais=FechaEvento.idPais inner join
					Moneda on Moneda.idMoneda=Pais.moneda
					where FechaEvento.fechaHora between @fechaInicioDate and @fechaFinDate
					group by Pais.nombre,Moneda.nombre,FechaEvento.idFecha;
				--Monto recaudado de impuestos
				select sum(Detalle.subtotal-(Detalle.subtotal*Pais.porcentajeImpuestos)) as impuestos,
					Moneda.nombre,Pais.nombre,Evento.nombre
					from Detalle inner join
					Entrada on Entrada.idEntrada=Detalle.idEntrada inner join
					FechaEvento on FechaEvento.idFecha=Entrada.idFechaEvento inner join
					Pais on Pais.idPais=FechaEvento.idPais inner join
					Evento on Evento.idEvento=FechaEvento.idEvento inner join
					Moneda on Moneda.idMoneda=Pais.moneda
					where FechaEvento.fechaHora between @fechaInicioDate and @fechaFinDate
					group by Moneda.nombre,Pais.nombre,Evento.nombre;

				commit transaction
			end
	end try
	begin catch--Atrapa cualquier error en la transaccion.
			print @errorMsg;
	end catch
	end
END
GO
-----------------------------------------------------------------------------------
--Consular eventos x nombre de evento, tipo presentacion,pais,artista,fechas,tipos de entrada
GO
CREATE PROCEDURE spDevolucionDinero @idFecha int with encryption AS
BEGIN
	begin try
	if(@idFecha is null)
		begin
			print 'Error, debe ingresar el id la fecha del evento.'
			RAISERROR ('Error interno',16,1);
		end
	else
		begin
		--buscar la fecha del evento para devolver dinero a los clientes
		--el estado de la fecha debe ser =3 porque 3 es cancelado.
		begin tran
			
			--Guardo lo que tengo que devolver en una tabla tmp
			declare @tablaTmp as table (idCliente int,total float,numeroTarjeta int );
			insert into @tablaTmp(idCliente,total,numeroTarjeta) select distinct Compra.idCliente as idCliente,Compra.total as total,
				MetodoPago.numeroTarjeta as numeroTarjeta from Compra inner join 
				Detalle on Detalle.idCompra=Compra.idCompra inner join	
				Entrada on Entrada.idEntrada=Detalle.idEntrada inner join 
				MetodoPago on MetodoPago.idMetodoPago=Compra.idMetodoPago inner join
				FechaEvento on FechaEvento.idFecha=Entrada.idFechaEvento 
				where Entrada.idFechaEvento=@idFecha and FechaEvento.estado=3;--estado 3 es cancelado
			--Acutalizo la compra
			update Compra set total=0 from Compra inner join Detalle on Detalle.idCompra=Compra.idCompra
				inner join Entrada on Entrada.idEntrada=Detalle.idEntrada inner join
				FechaEvento on FechaEvento.idFecha=Entrada.idFechaEvento where Entrada.idFechaEvento=@idFecha;
			--Actualizo los detalles
			update Detalle set subtotal=0 from Detalle inner join Entrada on Entrada.idEntrada=Detalle.idEntrada 
				inner join FechaEvento on FechaEvento.idFecha=@idFecha where Entrada.idFechaEvento=@idFecha;
			--Selecciona lo que tiene que devolver a cada cliente.
			select * from @tablaTmp;

		commit tran
		end
	end try
	begin catch--Atrapa cualquier error en la transaccion.
			rollback;
			print 'Ha ocurrido un error.';
	end catch
	--end
END
GO


------------------------------------------------------------------------------
--INSERTAR DATOS
------------------------------------------------------------------------------

--Insertar Estado
exec spEstado 1,-1,'Eliminado','Se ha borrado de los registros de la base de datos.';--Insertar funciona
exec spEstado 1,0,'Inactivo','No se encuentra disponible en este momento.';--Insertar funciona
exec spEstado 1,1,'Activo','Se encuentra disponible.';--Insertar funciona
exec spEstado 1,2,'Suspendido','No se encuentra disponible por el momento.';--Insertar funciona
exec spEstado 1,3,'Cancelado','Se cancela, se devolvera dinero a los clientes.';--Insertar funciona
exec spEstado 1,4, 'Vendida','Entrada vendida.';
exec spEstado 1,5,'Pendiente','Aun no se completa la compra en su totalidad, faltan los detalles.';
exec spEstado 1,6,'Finalizada','La compra se ha realizado con exito';

--Insertar Moneda
exec spMoneda 1,null,'Colón',null;--FUNCIONA
exec spMoneda 1,null,'Peso Mexicano',null; --FUNCIONA
exec spMoneda 1,null,'Sol',null;--FUNCIONA

--Insertar Pais
exec spPais 1,188,1,'Costa Rica',0.13,null;--Insertar funciona
exec spPais 1,484,2,'México',0.10,null;--Insertar funciona
exec spPais 1,604,3,'Perú',0.09,null;--Insertar funciona

--Insertar Tipo Evento
exec spTipoEvento 1,1,'Concierto','Presentación de un artista.',null;--Insertar funciona
exec spTipoEvento 1,1,'Festival','Presentaciones de muchos artistas.',null;--Insertar funciona

--Insertar Evento
exec spEvento 1,null,1,'Bad Bunny','LAS ZONAS LA PLAYA Y LA FIESTA SOLO PARA MAYORES DE 18 AÑOS ',null;--FUNCIONA
exec spEvento 1,null,2,'Picnic','Serie de conciertos de artistas nacionales e internacionales',null;--FUNCIONA
exec spEvento 1,null,1,'Zoé','Zoé celebra su 20 aniversario',null;--FUNCIONA
exec spEvento 1,null,2,'Lollapalooza','Uno de los festivales mas grandes del contimente',null;--FUNCIONA

--Insertar Artista
exec spArtista 1,null,'Gandhi','Rock',null,'numero cuenta de gandhi';
exec spArtista 1,null,'Bad Bunny','Reggaeton',null,'numero cuenta de Bad Bunny';
exec spArtista 1,null,'Zoé','Rock',null,'numero cuenta de Zoé';
exec spArtista 1,null,'Doja Cat','Rap',null,'numero cuenta Doja Cat';
exec spArtista 1,null,'The Strokes','Rock',null,'numero cuenta The Strokes';

--Insertar Integrantes
exec spIntegrante 1,1,1,'Luis','Montalbert-Smith','Desconocido',null;--Insertar funciona Gandhi
exec spIntegrante 1,1,1,'Massimo','Hernández','Desconocido',null;--Insertar funciona Gandhi
exec spIntegrante 1,1,1,'Federico','Miranda','Desconocido',null;--Insertar funciona Gandhi
exec spIntegrante 1,1,1,'Alber','Guier','Desconocido',null;--Insertar funciona Gandhi
exec spIntegrante 1,null,2,'Benito','Martínez','Ocasio',null;--Bad Bunny
exec spIntegrante 1,null,3,'León','Larregui','Desconocido',null;--Zoe
exec spIntegrante 1,null,3,'Sergio','Acosta','Desconocido',null;--Zoe
exec spIntegrante 1,null,3,'Jesús','Báez','Desconocido',null;--Zoe
exec spIntegrante 1,null,3,'Ángel','Mosqueda','Desconocido',null;--Zoe
exec spIntegrante 1,null,3,'Rodrigo','Guardiola','Desconocido',null;--Zoe
exec spIntegrante 1,null,4,'Amala','Zandile','Dlamini',null;--Doja Cat
exec spIntegrante 1,null,5,'Julian','Casablancas','Desconocido',null;--The Strokes
exec spIntegrante 1,null,5,'Nick','Valensi','Desconocido',null;--The Strokes
exec spIntegrante 1,null,5,'Albert','Hammond Jr.','Desconocido',null;--The Strokes
exec spIntegrante 1,null,5,'Fabrizio','Moretti','Desconocido',null;--The Strokes
exec spIntegrante 1,null,5,'Nikolai','Fraiture','Desconocido',null;--The Strokes

--Insertar Lugar Funciona
exec spLugarEvento 1,null,'Estadio Nacional de Costa Rica','San Jose, La Sabana',42000,null;--Insertar funciona
exec spLugarEvento 1,null,'Centro de Eventos Pedregal','Heredia, Belen, San Antonio',15000,null;--Insertar funciona
exec spLugarEvento 1,null,'Sala de Fiestas La Finca','Heredia, San Joaquin',300,null;--Insertar funciona
exec spLugarEvento 1,null,'Sala de Eventos La Cabuya','Cartago, Tres Rios, Concepcion',1000,null;
exec spLugarEvento 1,null,'Estadio Nacional de Perú','Lima',30000,null;
exec spLugarEvento 1,null,'Estadio Azteca','Ciudad de México',80000,null;

--Insertar Tipo Asiento 
exec spTipoAsiento 1,null,1,'Palco',1100,null;--Palco Estado Nacional Costa Rica
exec spTipoAsiento 1,null,1,'Graderias',30000,null;--Graderias Estadio Nacional Costa Rica
exec spTipoAsiento 1,null,1,'Preferencial',10900,null;--Preferencial Estadio Nacional Costa Rica
exec spTipoAsiento 1,null,2,'General',15000,null;--General Centro de Eventos Pedregal
exec spTipoAsiento 1,null,3,'Salon General',300,null;--Salon General Sala de Eventos La Finca
exec spTipoAsiento 1,null,4,'Salon General',1000,null;--Salon General Sala de Eventos La Cabuya
exec spTipoAsiento 1,null,5,'Graderia General',10000,null;--Graderia General Estadio Nacional Peru
exec spTipoAsiento 1,null,5,'Graderia Central',10000,null;--Graderia Central Estadio Nacional Peru
exec spTipoAsiento 1,null,5,'Graderia Sur',10000,null;--Graderia Sur Estadio Nacional Peru
exec spTipoAsiento 1,null,6,'Publico General',80000,null;--Graderai General Estado Azteca

--Insertar Evento X Pais
exec spEventoXPais 1,1,188,1;--Bad Bunny Cost Rica
exec spEventoXPais 1,1,484,6;--Bad Bunny Mexico
exec spEventoXPais 1,2,188,2;--Picnic Costa Rica
exec spEventoXPais 1,3,188,2;--Zoe Costa Rica
exec spEventoXPais 1,3,604,5;--Zoe Peru
exec spEventoXPais 1,4,604,5;--Lola en Peru

--Insertar Fecha Eventos
exec spFechaEvento 1,null,1,484,'09-23-2022',null;--Fecha Bad Bunny Mexico
exec spFechaEvento 1,null,1,188,'10-15-2022',null;--Fecha Bad Bunny Costa Rica
exec spFechaEvento 1,null,2,188,'08-20-2022 16:00:00',null;--Fecha 1 Picnic Costa Rica
exec spFechaEvento 1,null,2,188,'08-21-2022 16:00:00',null;--Fecha 2 Picnic Costa Rica
exec spFechaEvento 1,null,3,188,'12-10-2022',null--Fecha Zoe Costa Rica
exec spFechaEvento 1,null,3,604,'12-17-2022',null--Fecha Zoe Peru
exec spFechaEvento 1,null,4,604,'11-26-2022 10:00:00',null;--Insertar funciona Lola
exec spFechaEvento 1,null,4,604,'11-27-2022 10:00:00',null;--Insertar funciona Lola

--Insertar Artista X Evento
exec spArtistaXEvento 1,1,2,'2022-09-23 20:00:00','2022-09-23 22:00:00',null;--Bad bunny en Bad bunny Mexico
exec spArtistaXEvento 1,2,2,'2022-10-15 20:00:00','2022-10-15 22:00:00',null;--Bad bunny en Bad bunny Costa Rica
exec spArtistaXEvento 1,3,1,'2022-08-20 16:30:00','2022-08-20 18:00:00',null;--Gandhi en Picnic 1 Costa Rica
exec spArtistaXEvento 1,3,3,'2022-08-20 19:00:00','2022-08-20 21:00:00',null;--Zoe en Picnic 1 Costa Rica
exec spArtistaXEvento 1,4,1,'2022-08-20 16:30:00','2022-08-20 18:00:00',null;--Gandhi en Picnic 1 Costa Rica
exec spArtistaXEvento 1,4,3,'2022-08-20 19:00:00','2022-08-20 21:00:00',null;--Zoe en Picnic 1 Costa Rica
exec spArtistaXEvento 1,5,3,'2022-12-10 18:00:00','2022-12-10 21:00:00',null;--Zoe Costa Rica
exec spArtistaXEvento 1,6,3,'2022-12-17 18:00:00','2022-12-17 21:00:00',null;--Zoe Peru
exec spArtistaXEvento 1,7,4,'2022-11-26 10:30:00','2022-11-26 11:30:00',null;--Doja Lola 1 Peru
exec spArtistaXEvento 1,7,5,'2022-11-26 12:00:00','2022-11-26 13:30:00',null;--The Strokes Lola 1 Peru
exec spArtistaXEvento 1,8,4,'2022-11-27 10:30:00','2022-11-27 11:30:00',null;--Doja Lola 2 Peru
exec spArtistaXEvento 1,8,5,'2022-11-27 12:00:00','2022-11-27 13:30:00',null;--The Strokes 2 Lola Peru

--Insertar Tipo Entrada
exec spTipoEntrada 1,null,1,6500,60000,null;--Palco Estadio Nacional  Costa Rica
exec spTipoEntrada 1,null,2,5000,45000,null;--Graderias Estadio Nacional Costa Rica
exec spTipoEntrada 1,null,3,1000,20000,null;--Preferencial Estadio Nacional Costa Rica
exec spTipoEntrada 1,null,4,5000,50000,null;--General Pedregal
exec spTipoEntrada 1,null,5,1000,10000,null;--Salon General Sala de Fiestas La Finca
exec spTipoEntrada 1,null,6,13.76,165.12,null--Graderia General Estadio Nacional Peru
exec spTipoEntrada 1,null,7,23.76,265.12,null--Graderia Central Estadio Nacional Peru
exec spTipoEntrada 1,null,8,10.76,130.12,null--Graderia Sur Estadio Nacional Peru
exec spTipoEntrada 1,null,9,100,1733.25,null;--Publico General Estadio Azteca Mexico

--Insertar Cliente
exec spCliente 1,null,'Felipe','Obando','Arrieta','10-31-2001','felipeobando2001@gmail.com',70130686,'contra',null,null;--Insertar funciona
exec spCliente 1,null,'Carlos','Torres','Quesada','05-07-1975','carlostorresquesada@gmail.com',80808080,'contraCarlos',null,null;--Insertar funciona
exec spCliente 1,null,'María','Cabrera','Romero','02-23-1980','mariacabreraromero@gmail.com',40587843,'contraMaria',null,null;--Insertar funciona

--Insertar Metodo Pago
exec spMetodoPago 1,null,'Felipe Obando A.',1111111111,'05-01-2024',012;--Insertar funciona
exec spMetodoPago 1,null,'Carlos Torres Q.',1212121212,'08-07-2023',782;--Insertar funciona (cuando puse 2222222222 no porque se pasa delrango de int.)
exec spMetodoPago 1,null,'Maria Cabrera R.',4515338,'07-15-2025',457;--Insertar funciona

--Insertar Compra - Insertar Entrada - Insertar Detalle

--9166250 + (9166250*impuesto 10%)=10082875 
exec spCompra 1,null,2,2,10082875.0,null;--El cliente 2 compro 5000 (5000*(100+1733.25)=9166250 sin impuesto)
--de las entradas para el conejo en mexico
---Entradas y detalles para la compra de 5000 entradas para el concierto del conejo

declare @cantidadEntradas int =0;
declare @numeroEntrada int =1;
while (@cantidadEntradas<5000)
	begin
		exec spEntrada 1,null,9,1,null;--Entradas de los detalles compra conejo mexico
		exec spDetalle 1,null,1,@numeroEntrada;--Detalles de la compra 1
		set @numeroEntrada=@numeroEntrada+1;
		set @cantidadEntradas=@cantidadEntradas+1;
	end
--Compra Conejo costa rica 10000*(45000+5000)=500000000 + (500000000*13%)= 565000000
exec spCompra 1,null,1,1,565000000,null;
--Detalle compra conejo costa rica
set @cantidadEntradas=0;
while (@cantidadEntradas<10000)
	begin
		exec spEntrada 1,null,2,2,null;--Entradas detalles compra conejo costa rica
		exec spDetalle 1,null,2,@numeroEntrada;--Detalles de la compra 2
		set @numeroEntrada=@numeroEntrada+1;
		set @cantidadEntradas=@cantidadEntradas+1;
	end
--Compra Lola peru 
--447200+(447200*9%)
exec spCompra 1,null,3,3,487448,null;--Compra 2500 entradas graderia general peru lola 2500*(13.76+165.12)=447200.0
--Detalle lola
set @cantidadEntradas=0;
while (@cantidadEntradas<2500)
	begin
		exec spEntrada 1,null,6,7,null;
		exec spDetalle 1,null,3,@numeroEntrada;
		set @numeroEntrada=@numeroEntrada+1;
		set @cantidadEntradas=@cantidadEntradas+1;
	end

--Insertar Direccion Cliente
exec spDireccionCliente 1,null,1,188,'Cartago,La Union',30303,null;--Insertar funciona
exec spDireccionCliente 1,null,2,484,'Ciudad de Mexico',00810,null;--Insertar funciona
exec spDireccionCliente 1,null,3,604,'Lima',02002,null;--Insertar funciona

--Insertar envio
exec spEnvio 1,null,1,0,0,null;--Insertar funciona

--Insertar Tipo Comentario
exec spTipoComentario 1,null,'Queja',null;--Insertar funciona
exec spTipoComentario 1,null,'Problema',null;--Insertar funciona
exec spTipoComentario 1,null,'Felicitación',null;--Insertar funciona

--Insertar Medio Comunicacion
exec spMedioComunicacion 1,null,'Llamada',null;--Insertar funciona
exec spMedioComunicacion 1,null,'Correo',null;--Insertar funciona
exec spMedioComunicacion 1,null,'Pagina Web',null;--Insertar funciona

--Insertar Comentario
exec spComentario 1,null,1,1,2,'Pesima Organizacion del evento.';--Insertar funciona

--Insertar Solucion
exec spSolucion 1,null,0,0,5;--Insertar funciona

--Insertar Deptartamento
exec spDepartamento 1,null,'Atencion Al Cliente','Se encarga de toda de atender a los clientes.',null;--Insertar funciona

--Insertar Tipo Empleado
exec spTipoEmpleado 1,null,'Tipo Empleado 1','El tipo de Empleado 1 hace tal y tal tareas.';

--Insertar Empleado
exec spEmpleado 1,45400,1,45400,'Beatris','Pinzón','Solano','12-12-1988',
'beatris@compania.com',7845,3500,'contraBeatris','cuenta beatris',null,null,1;--Insertar funciona
 exec spEmpleado 1,104541,1,45400,'Nicolás','Mora','Pinzón','07-25-1985',
'nicolas@compania.com',4512,5000,'contraNico','cuenta nicolas',null,null,1;--Insertar funciona

--Insertar Atencion al Cliente
exec spAtencionCliente 1,null,45400,1,1;--Insertar funciona


--------------------------------------------------------------------------------------------------------
--CONSULTAS
--------------------------------------------------------------------------------------------------------
--Consultas eventos
exec spConsultarEventoXTipoEventoYFechas 1,null,null;--Consulta todos los conciertos
exec spConsultarEventoXTipoEventoYFechas 2,null,null;--Consulta todos los festivales
exec spConsultarEventoXTipoEventoYFechas 2,'2022-08-21 16:00:00','2022-11-26 10:00:00';--Consulta todos los festivales en las fechas dadas con tipo de evento
exec spConsultarEventoXTipoEventoYFechas null,'2021-08-21 16:00:00','2022-11-26 10:00:00';--Consulta por fechas sin tipo de evento

exec spConsultarDisponibilidadTipoEntrada 1,null;--Consulta cuantas entradas quedan para el conejo en mexico
exec spConsultarDisponibilidadTipoEntrada 2,2;--Consulta cuantas Graderias quedan para el concierto del conejo en costa rica
exec spConsultarDisponibilidadTipoEntrada 7,null;--Consulta todo de Lola
exec spConsultarDisponibilidadTipoEntrada 7,7;--Consulta las Graderia central de Lola peru

--Consulta pais mas eventos
exec spConsultarPaisMasEventos '01-01-2022','12-20-2022',null;
exec spConsultarPaisMasEventos '01-01-2022','12-20-2022',1;
exec spConsultarPaisMasEventos null,null,2;

--Consultar problemas
exec spConsultarComentarios '01-01-2022','12-10-2022',null,null;

--Consultar ventas de artistas por pais
exec spConsultarPaisGeneraMasArtista 2;
exec spConsultarPaisGeneraMasArtista null;

--Consultar eventos
exec spConsultarEventos 'Bad Bunny',null,null,null,null;

--Dura 3 minutos ejecutandose


------------------------------------------------------------------------------
--CREACION DE USUARIOS
------------------------------------------------------------------------------
--ADMINISTRADOR
--Ingresar con el sa para crear el usuario administrador
--crear login del usuario administrador y darle en server role el permiso para sysadmin
--conectarse al servidor con ese nuevo usuario administrador
--crear base de datos y todos los procedimientos con el usuario administrador

--una vez todo este creado, crear el usuario normal con estas lineas de abajo


--USUARIO NORMAL
--Login en servidor para el usuario normal
create login logUsuario with password = '1234';
--User en base de datos para el usuario normal
create user userUsuario for login logUsuario;
--Role en base de datos para el usuario normal
create role roleUsuario;
--asignar permisos al role en base de datos para el usuario normal
grant execute to roleUsuario;
--asignar role al usuario normal
ALTER ROLE roleUsuario ADD MEMBER userUsuario;
--conectarse al servidor con este nuevo usuario para que solo pueda usar 
--los procedimientos. si se permanece en este mismo query no va a funcionar 
--porque estamos conectados con el admin.
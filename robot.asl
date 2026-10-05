habitacion(cocina).
habitacion(salon).
habitacion(bano).
bateria(80).
autoridad(coordinador).
en(base).
//ocupada(cocina).
//desea(coordinador, limpia(bano)).

// 1. El robot cree que la cocina está sucia.
sucia(cocina).

// 3. El robot no sabe si el salón está libre.
// (no existe ni libre(salon) ni ~libre(salon))
+!comprobar(H) : not libre(H) & not ~libre(H)
   <- .send(coordinador, askOne, libre(H)).

// 4. El robot cree que el coordinador cree que el baño está sucio.
cree(coordinador, sucia(bano)).

// Batería suficiente (>= 30 %), auxiliar del enunciado 5.
bateria_suficiente :- bateria(B) & B >= 30.

// 10. Objetivo inicial: volver a la base.
!volver.

// 2. Si el robot cree que una habitación está sucia, desea que esté limpia.
+sucia(H) : habitacion(H) <- !limpia(H).

// 6. Mantiene la intención de limpiar hasta que crea que está limpia...
+!limpia(H) : limpia(H)
   <- .print(H, " limpia");
      !!volver.

// 6. ...o que es imposible.
+!limpia(H) : imposible(limpiar(H))
   <- .print("Imposible limpiar ", H);
      !!volver.

// 8. Está prohibido limpiar una habitación ocupada.
+!limpia(H) : ocupada(H)
   <- .print("PROHIBIDO limpiar ", H, ": esta ocupada");
      !!volver.

// 5. El robot solo se compromete a limpiar si cree que tiene batería suficiente.
+!limpia(H) : not bateria_suficiente
   <- !cargar;
      !limpia(H).

// 6. Mientras no se cumpla ninguna parada, mantiene la intención de limpiar.
+!limpia(H)
   <- !hacer_limpieza(H);
      !limpia(H).

+!hacer_limpieza(H)
   <- !ir(H);
      .print("Limpiando ", H);
      .wait(500);
      if (sucia(H)) { -sucia(H) };
      +limpia(H).

// 7. Siempre que la batería baje del 20 %, el robot acabará cargado.
+bateria(B) : B < 20 & not cargando
   <- !cargar.

+!cargar : cargando
   <- .wait(1500).

+!cargar
   <- +cargando;
      !ir(base);
      .print("Cargando...");
      .wait(1000);
      -+bateria(100);
      -cargando.

// 9. Si el robot cree que el coordinador desea que limpie una habitación,
//    y reconoce su autoridad, adopta esa intención.
+desea(Q, limpia(H)) : autoridad(Q)
   <- .print("Orden de ", Q, " aceptada: limpiar ", H);
      !limpia(H).

// 10. Si el robot no tiene intención de limpiar ninguna habitación,
//     desea volver a la base.
+!volver
   <- .wait(200);
      if (not .intend(limpia(_))) { !ir(base) }.

+!ir(L) : en(L) <- true.
+!ir(L)
   <- .print("Yendo a ", L);
      .wait(300);
      -+en(L).

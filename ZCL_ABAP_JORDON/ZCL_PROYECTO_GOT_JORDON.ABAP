CLASS zcl_proyecto_got_jordon DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
   INTERFACES: if_oo_Adt_classrun.
   METHODS: CREATE_WORK_ORDER     IMPORTING ir_out TYPE REF TO IF_OO_ADT_CLASSRUN_OUT.
   METHODS: READ_WORK_ORDER       IMPORTING ir_out TYPE REF TO IF_OO_ADT_CLASSRUN_OUT.
   METHODS: UPDATE_WORK_ORDER     IMPORTING ir_out TYPE REF TO IF_OO_ADT_CLASSRUN_OUT.
   METHODS: DELETE_WORK_ORDER     IMPORTING ir_out TYPE REF TO IF_OO_ADT_CLASSRUN_OUT.
   METHODS: VALIDATE_CREATE_ORDER IMPORTING iv_customer_id    TYPE zde_customer_id
                                            iv_technician_id  TYPE zde_technician_id
                                            iv_priority       TYPE C
                                  RETURNING VALUE(rv_valid)   TYPE ABAP_BOOL.
  METHODS: VALIDATE_UPDATE_ORDER  IMPORTING iv_order_id       TYPE zde_work_order_id
                                  RETURNING VALUE(rv_valid)   TYPE ABAP_BOOL.
  METHODS: VALIDATE_DELETE_ORDER  IMPORTING iv_order_id       TYPE zde_work_order_id
                                  RETURNING VALUE(rv_valid)   TYPE ABAP_BOOL.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS. 

CLASS zcl_proyecto_got_jordon IMPLEMENTATION. 
  METHOD if_oo_adt_classrun~main.
        me->read_work_order( out ).
        "me->create_work_order( out ).
  ENDMETHOD.

METHOD CREATE_WORK_ORDER.

    DATA ls_work TYPE ZTWORKORDERJORDO.

    ls_work-work_order_id = 000000006.
    ls_work-customer_id   = '00012345'.
    ls_work-technician_id = '00012346'.
    ls_work-creation_date = sy-datum.
    ls_work-status        = 'PE'.
    ls_work-priority      = 'A'.
    ls_work-description   = 'Test para delete 2'.

* --> VALIDAR SI EL CODIGO DE CLIENTE EXISTE
* --> vALIDAR SI EL CODIGO DE TECNICO EXISTE
* --> VALIDAR QUE EL PRIORITY

    DATA(lv_valid) = me->validate_create_order(
                                               iv_customer_id   = ls_work-customer_id
                                               iv_technician_id = ls_work-technician_id
                                               iv_priority      = ls_work-priority ).


    IF lv_valid EQ ABAP_FALSE.
       ir_out->write( 'Datos invalidos, no se puede crear la orden.' ).
       RETURN.
    ENDIF.

    INSERT ZTWORKORDERJORDO FROM @LS_WORK.

    IF sy-subrc EQ 0.
        ir_out->write( 'Orden de trabajo creada correctamente!' ).
    ELSE.
        ir_out->write( 'Error al crear la orden de trabajo' ).
    ENDIF.


ENDMETHOD.

METHOD READ_WORK_ORDER.

    SELECT FROM ZTWORKORDERJORDO
    FIELDS *
    INTO TABLE @DATA(lt_work_orders).

    ir_out->write( lt_work_orders ).

ENDMETHOD.

METHOD UPDATE_WORK_ORDER.

    DATA: LS_WORK TYPE ZTWORKORDERJORDO,
          LS_HIST TYPE ZTWORKORDERHISTJ.


    ls_work-work_order_id = 000000003.  
    ls_work-customer_id   = '00012345'.
    ls_work-technician_id = '00012346'.
    ls_work-creation_date = sy-datum.
    ls_work-status        = 'CO'.
    ls_work-priority      = 'A'.
    ls_work-description   = 'Cambio de aceite'.

    DATA(lv_valid) = me->validate_update_order( iv_order_id   = ls_work-work_order_id ).

    IF lv_valid EQ ABAP_FALSE.
        IR_OUT->write( 'OT no cumple para ser actualizada!' ).
        RETURN.
    ENDIF.

    UPDATE ZTWORKORDERJORDO FROM @LS_WORK.

    IF sy-subrc EQ 0.
        ir_out->write( 'Orden de trabajo actualizada correctamente!' ).

        ls_hist-work_order_id      = ls_work-work_order_id.
        ls_hist-modification_date  = sy-datum.
        ls_hist-change_description = ls_work-description.

        INSERT ZTWORKORDERHISTJ FROM @ls_hist.

        IF sy-subrc EQ 0.
          ir_out->write( 'Bitacora creada correctamente!' ).
        ELSE.
          ir_out->write( 'Error en bitacora' ).
        ENDIF.

    ELSE.
        ir_out->write( 'Error al actualizar la orden de trabajo' ).
    ENDIF.


ENDMETHOD.

METHOD DELETE_WORK_ORDER.

    DATA LV_WORK_ORDER_ID TYPE zde_work_order_id VALUE 0000000005.

    IF LV_WORK_ORDER_ID IS INITIAL.
        ir_out->write( 'ID no puede ir vacio' ).
    ELSE.
       DATA(lv_valid) = me->validate_delete_order( iv_order_id = LV_WORK_ORDER_ID ).

       IF lv_valid EQ abap_false.
        ir_out->write( 'La OT no cumple las condiciones para ser eliminada' ).
        RETURN.
      ENDIF.

     DELETE FROM ztworkorderjordo
     WHERE work_order_id = @LV_WORK_ORDER_ID.

      IF sy-subrc = 0.
        ir_out->write( 'Orden de trabajo eliminada correctamente' ).
      ELSE.
        ir_out->write( 'Error al eliminar la orden de trabajo' ).
      ENDIF.
    ENDIF.

ENDMETHOD.

METHOD validate_create_order.

  rv_valid = abap_true. " Asumimos que todo es válido al inicio

  " 1. Validar cliente
  SELECT SINGLE customer_id
    FROM ztcustomerjo
    WHERE customer_id = @iv_customer_id
    INTO @DATA(lv_customer).

  IF sy-subrc <> 0.
    rv_valid = abap_false.
    RETURN.
  ENDIF.


ENDMETHOD.

METHOD validate_update_order.
* --> Primero inicializo la boolean
   rv_valid = abap_true.

   SELECT SINGLE work_order_id
   FROM ZTWORKORDERJORDO
   WHERE WORK_ORDER_ID EQ @iv_order_id
     AND STATUS        EQ 'PE'
   INTO @DATA(LV_WORK_ORDER).

   IF sy-subrc <> 0.
     rv_valid = abap_false.
     RETURN.
   ENDIF.
ENDMETHOD.

METHOD VALIDATE_DELETE_ORDER.
   rv_valid = abap_true.

* --> Valido el estado

   SELECT SINGLE work_order_id
   FROM ZTWORKORDERJORDO
   WHERE WORK_ORDER_ID EQ @iv_order_id
     AND STATUS        EQ 'PE'
   INTO @DATA(LV_WORK_ORDER).

   IF sy-subrc <> 0.
     rv_valid = abap_false.
     RETURN.
   ENDIF.

* --> Valido que no tenga historial

   SELECT SINGLE WORK_ORDER_ID
   FROM ZTWORKORDERHISTJ
   WHERE WORK_ORDER_ID EQ @IV_ORDER_ID
   INTO @DATA(LV_WORK_ORDER_HIST).

   IF sy-subrc <> 4.
     rv_valid = abap_false.
     RETURN.
   ENDIF.

ENDMETHOD.

ENDCLASS.
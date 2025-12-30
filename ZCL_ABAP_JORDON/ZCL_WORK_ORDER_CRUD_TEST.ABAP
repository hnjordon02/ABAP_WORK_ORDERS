CLASS zcl_work_order_crud_test_jordo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES: IF_OO_ADT_CLASSRUN.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_work_order_crud_test_jordo IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    DATA(go_class) = new ZCL_PROYECTO_GOT_JORDON( ).

    "go_class->read_work_order( out ).
    " go_class->create_work_order( out ).
    "go_class->update_work_order( out ).
    go_class->delete_work_order( out ).

  ENDMETHOD.

ENDCLASS.
*&---------------------------------------------------------------------*
*&  Include           ZABAPGIT_PASSWORD_DIALOG
*&---------------------------------------------------------------------*
TABLES sscrfields.

SELECTION-SCREEN BEGIN OF SCREEN 1002 TITLE s_title.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 1(10) s_url FOR FIELD p_url.
    PARAMETER: p_url  TYPE string LOWER CASE VISIBLE LENGTH 40.
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 1(10) s_user FOR FIELD p_user.
    PARAMETER: p_user TYPE string LOWER CASE VISIBLE LENGTH 40.
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 1(10) s_pass FOR FIELD p_pass.
    PARAMETER: p_pass TYPE string LOWER CASE VISIBLE LENGTH 40.
  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF SCREEN 1002.

*-----------------------------------------------------------------------
* LCL_PASSWORD_DIALOG
*-----------------------------------------------------------------------
CLASS lcl_password_dialog DEFINITION.

  PUBLIC SECTION.
    CONSTANTS DYNNR TYPE char4 VALUE '1002'.

    CLASS-METHODS popup
      IMPORTING
        iv_repo_url TYPE string
      CHANGING
        cv_user     TYPE string
        cv_pass     TYPE string.

    CLASS-METHODS on_screen_init.
    CLASS-METHODS on_screen_output.
    CLASS-METHODS on_screen_event
      IMPORTING
        iv_ucomm    TYPE syucomm.

  PRIVATE SECTION.
    CLASS-DATA mv_confirm TYPE abap_bool.

ENDCLASS. "lcl_password_dialog DEFINITION

CLASS lcl_password_dialog IMPLEMENTATION.

  METHOD popup.

    clear p_pass.
    p_url      = iv_repo_url.
    p_user     = cv_user.
    mv_confirm = abap_false.

    CALL SELECTION-SCREEN DYNNR STARTING AT 5 5 ENDING AT 60 8.

    IF mv_confirm = abap_true.
      cv_user = p_user.
      cv_pass = p_pass.
    ELSE.
      CLEAR: cv_user, cv_pass.
    ENDIF.

  ENDMETHOD.  "popup

  METHOD on_screen_init.
    s_title = 'Login'     ##NO_TEXT.
    s_url   = 'Repo URL'  ##NO_TEXT.
    s_user  = 'User'      ##NO_TEXT.
    s_pass  = 'Password'  ##NO_TEXT.
  ENDMETHOD.  "on_screen_init

  METHOD on_screen_output.
    DATA lt_ucomm TYPE TABLE OF sy-ucomm.

    ASSERT sy-dynnr = DYNNR.

    LOOP AT SCREEN.
      IF screen-name = 'P_URL'.
        screen-input      = '0'.
        screen-display_3d = '0'.
        MODIFY SCREEN.
      ENDIF.
      IF screen-name = 'P_PASS'.
        screen-invisible = '1'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.

    " Program RSSYSTDB, GUI Status %_CSP
    PERFORM set_pf_status IN PROGRAM rsdbrunt IF FOUND.
    APPEND 'NONE' TO lt_ucomm.  "Button Check
    APPEND 'SPOS' TO lt_ucomm.  "Save as Variant

    CALL FUNCTION 'RS_SET_SELSCREEN_STATUS'
      EXPORTING p_status  = sy-pfkey
      TABLES    p_exclude = lt_ucomm.

  ENDMETHOD.  "on_screen_output

  METHOD on_screen_event.
    ASSERT sy-dynnr = DYNNR.

    " CRET   - F8
    " OTHERS - simulate Enter press
    CASE iv_ucomm.
      WHEN 'CRET'.
        mv_confirm = abap_true.
      WHEN OTHERS. "TODO REFACTOR !!! A CLUTCH !
      " This will work unless any new specific logic appear
      " for other commands. The problem is that the password dialog
      " does not have Enter event (or I don't know how to activate it ;)
      " so Enter issues previous command from previous screen
      " But for now this works :) Fortunately Esc produces another flow
        mv_confirm = abap_true.
        LEAVE TO SCREEN 0.
    ENDCASE.

  ENDMETHOD.  "on_screen_event

ENDCLASS. " lcl_password_dialog IMPLEMENTATION
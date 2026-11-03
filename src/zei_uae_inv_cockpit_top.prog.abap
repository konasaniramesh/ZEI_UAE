*&---------------------------------------------------------------------*
*& Include          ZEI_UAE_INV_COCKPIT_TOP
*&---------------------------------------------------------------------*
TYPE-POOLS: icon, slis.

"PINT AE / SBDH constants
CONSTANTS:
  gc_ns_sbdh    TYPE string VALUE 'http://www.unece.org/cefact/namespaces/StandardBusinessDocumentHeader',
  gc_ns_xsi     TYPE string VALUE 'http://www.w3.org/2001/XMLSchema-instance',
  gc_ns_cbc     TYPE string VALUE 'urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2',
  gc_ns_cac     TYPE string VALUE 'urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2',
  gc_ns_inv     TYPE string VALUE 'urn:oasis:names:specification:ubl:schema:xsd:Invoice-2',
  gc_ns_cn      TYPE string VALUE 'urn:oasis:names:specification:ubl:schema:xsd:CreditNote-2',
  gc_sbdh_xsd   TYPE string VALUE 'https://docs.peppol.eu/poacc/billing/3.0/files/xsd/openpeppol-sbdh-1.3.xsd',
  gc_inv_xsd    TYPE string VALUE 'http://docs.oasis-open.org/ubl/os-UBL-2.1/xsd/maindoc/UBL-Invoice-2.1.xsd',
  gc_custid     TYPE string VALUE 'urn:peppol:pint:billing-1@ae-1',
  gc_profile    TYPE string VALUE 'urn:peppol:bis:billing',
  gc_authority  TYPE string VALUE 'iso6523-actorid-upis',
  gc_mls_to     TYPE string VALUE '0242:000539',
  gc_scheme_tin TYPE string VALUE '0235',
  gc_format     TYPE zde_ei_format VALUE 'XML',
  gc_msgid      TYPE msgid VALUE 'ZEINV',
  gc_msgno      TYPE msgno VALUE '000',
  gc_map_ns     TYPE /aif/t_mvmapval5-ns VALUE 'AEINV',
  "Fallback bank details (same as ZEI_PROCESS_COCKPIT) - maintain the
  "value mappings AE_PAYEE_BANK / AE_PAYEE_BIC (key = company code)
  gc_def_iban   TYPE string VALUE 'AE070331234567890123456',
  gc_def_accnm  TYPE string VALUE 'Bank Account Name',
  gc_def_bic    TYPE string VALUE 'BIC324098'.

"5-corner processing status (stored in ZEINVOICE_DETAIL-PSTATUS)
CONSTANTS:
  BEGIN OF gc_st,
    pending TYPE zde_ei_pstatus VALUE 'PENDING',
    c1      TYPE zde_ei_pstatus VALUE 'C1_XML_GENERATED',
    c2      TYPE zde_ei_pstatus VALUE 'C2_ACCEPTED_BY_ASP',
    c3      TYPE zde_ei_pstatus VALUE 'C3_ACCEPTED_BY_CUSTOMER_ASP',
    c4      TYPE zde_ei_pstatus VALUE 'C4_DELIVERED_TO_CUSTOMER',
    c5      TYPE zde_ei_pstatus VALUE 'C5_REPORTED_TO_FTA',
  END OF gc_st.

"----------------------------------------------------------------------
" 5-Corner model - one status field per corner (ZEINVOICE_DETAIL-ZZ*)
"----------------------------------------------------------------------
CONSTANTS:
  "Value of each corner status field
  BEGIN OF gc_cs,
    generated  TYPE c LENGTH 1 VALUE 'G',   "C1 Generated in SAP
    accepted   TYPE c LENGTH 1 VALUE 'A',   "C2 Accepted by Supplier's ASP
    rejected   TYPE c LENGTH 1 VALUE 'R',   "C2 Rejected by Supplier's ASP
    successful TYPE c LENGTH 1 VALUE 'S',
    failed     TYPE c LENGTH 1 VALUE 'F',
  END OF gc_cs,
  "Overall Invoice / Credit Note document status
  BEGIN OF gc_ov,
    success     TYPE c LENGTH 12 VALUE 'SUCCESS',
    failed      TYPE c LENGTH 12 VALUE 'FAILED',
    in_progress TYPE c LENGTH 12 VALUE 'IN PROGRESS',
  END OF gc_ov,
  "transmissionType values of the status (GET) API
  BEGIN OF gc_tt,
    outbound           TYPE c LENGTH 30 VALUE 'outbound',
    mls_inbound        TYPE c LENGTH 30 VALUE 'mls_inbound',
    c2_tdd_outbound    TYPE c LENGTH 30 VALUE 'c2_tdd_outbound',
    c2_tdd_mls_inbound TYPE c LENGTH 30 VALUE 'c2_tdd_mls_inbound',
  END OF gc_tt,
  "Corner status texts - exactly as specified
  BEGIN OF gc_txt,
    c1      TYPE c LENGTH 60 VALUE 'Generated in SAP (Corner 1)',
    c2_acc  TYPE c LENGTH 60 VALUE 'Accepted by Supplier''s ASP (Corner 2)',
    c2_rej  TYPE c LENGTH 60 VALUE 'Rejected by Supplier''s ASP (Corner 2)',
    c2_pend TYPE c LENGTH 60 VALUE 'Pending at Corner 2',
    c3_sent TYPE c LENGTH 60 VALUE 'Sent to Buyer''s ASP (Corner 3)',
    c3_ack  TYPE c LENGTH 60 VALUE 'Accepted by Buyer''s ASP (Corner 3)',
    c4      TYPE c LENGTH 60 VALUE 'Delivered to Buyer (Corner 4)',
    c5_rep  TYPE c LENGTH 60 VALUE 'Reported to FTA (Corner 5)',
    c5_ack  TYPE c LENGTH 60 VALUE 'Accepted by FTA (Corner 5)',
  END OF gc_txt,
  gc_status_success TYPE c LENGTH 20 VALUE 'SUCCESS',
  gc_status_valerr  TYPE c LENGTH 20 VALUE 'VALIDATION_ERROR',
  gc_ack_ap         TYPE c LENGTH 2  VALUE 'AP',
  gc_api_get_ack    TYPE c LENGTH 10 VALUE 'GET_ACK',
  gc_http_timeout   TYPE i VALUE 60.     "seconds

TYPES: BEGIN OF ty_output.
         INCLUDE TYPE zi_einvoice_header.
TYPES:   check            TYPE char1,
         c1               TYPE icon_d,
         c2               TYPE icon_d,
         c3               TYPE icon_d,
         c4               TYPE icon_d,
         c5               TYPE icon_d,
         c3a              TYPE icon_d,      "C3 Accepted (LED)
         c5a              TYPE icon_d,      "C5 Accepted (LED)
         zzc1_status      TYPE zeinvoice_detail-zzc1_status,
         zzc2_status      TYPE zeinvoice_detail-zzc2_status,
         zzc3_sent_status TYPE zeinvoice_detail-zzc3_sent_status,
         zzc3_ack_status  TYPE zeinvoice_detail-zzc3_ack_status,
         zzc4_status      TYPE zeinvoice_detail-zzc4_status,
         zzc5_rep_status  TYPE zeinvoice_detail-zzc5_rep_status,
         zzc5_ack_status  TYPE zeinvoice_detail-zzc5_ack_status,
         zzoverall_status TYPE zeinvoice_detail-zzoverall_status,
         corner           TYPE char60,
         cornerlog        TYPE char80,
         stattext         TYPE char60,
         request          TYPE icon_d,
         response         TYPE icon_d,
         html             TYPE icon_d,
         styl             TYPE lvc_t_styl,
       END OF ty_output,
       tt_output TYPE STANDARD TABLE OF ty_output WITH DEFAULT KEY.

TYPES tt_nodes TYPE STANDARD TABLE OF REF TO if_ixml_node WITH EMPTY KEY.

"ASP (outbound) response
TYPES: BEGIN OF ty_asp_resp,
         id                 TYPE string,
         messageid          TYPE string,
         instanceidentifier TYPE string,
         transmissiontype   TYPE string,
         status             TYPE string,
         errordetails       TYPE string,
         createddate        TYPE string,
       END OF ty_asp_resp,
       BEGIN OF ty_asp_result,
         response TYPE ty_asp_resp,
         message  TYPE string,
       END OF ty_asp_result.

"POST outbound response - status is read from response-status
TYPES: BEGIN OF ty_post_resp,
         id                 TYPE string,
         messageid          TYPE string,
         instanceidentifier TYPE string,
         status             TYPE string,
         errordetails       TYPE REF TO data,  "string, object or array
       END OF ty_post_resp,
       BEGIN OF ty_post_result,
         response TYPE ty_post_resp,
         message  TYPE string,
       END OF ty_post_result.

"Status (GET) API - one entry per transmission leg
TYPES: BEGIN OF ty_tx_entry,
         transmissiontype      TYPE string,
         status                TYPE string,
         transactionid         TYPE string,
         createddate           TYPE string,
         receiverparticipantid TYPE string,
         errordetails          TYPE REF TO data,
       END OF ty_tx_entry,
       tt_tx_entry TYPE STANDARD TABLE OF ty_tx_entry WITH EMPTY KEY.

TYPES: BEGIN OF ty_token_resp,
         access_token TYPE string,
         expires_in   TYPE string,
         token_type   TYPE string,
       END OF ty_token_resp,
       BEGIN OF ty_token,
         bukrs TYPE bukrs,
         token TYPE string,
       END OF ty_token.

TYPES: BEGIN OF ty_taxsum,
         taxcode   TYPE zi_einvoice_conditions-taxcode,
         taxrate   TYPE zi_einvoice_conditions-taxrate,
         eitaxtype TYPE zi_einvoice_conditions-einvoicetaxtype,
         base      TYPE vfprc_element_value,
         amount    TYPE vfprc_element_value,
       END OF ty_taxsum,
       tt_taxsum TYPE STANDARD TABLE OF ty_taxsum WITH DEFAULT KEY.

DATA: gt_output  TYPE tt_output,
      "Performance: sorted keys -> binary search for every LOOP ... WHERE / READ on the key
      gt_items   TYPE SORTED TABLE OF zi_einvoice_items WITH NON-UNIQUE KEY sapdocument sapdocitem,
      gt_prcd    TYPE SORTED TABLE OF zi_einvoice_conditions WITH NON-UNIQUE KEY conditionno item conditiontype,
      gt_mapping TYPE SORTED TABLE OF /aif/t_mvmapval5 WITH NON-UNIQUE KEY vmapname vmapvalnr,
      gt_apiurl  TYPE TABLE OF zeinvoice_apiurl,
      gt_errors  TYPE STANDARD TABLE OF zeinvoice_error WITH DEFAULT KEY
                 WITH NON-UNIQUE SORTED KEY doc COMPONENTS bukrs vbeln gjahr type,
      gt_tokens  TYPE TABLE OF ty_token.

DATA: gt_fcat TYPE lvc_t_fcat,
      gs_layo TYPE lvc_s_layo,
      go_alv  TYPE REF TO cl_gui_alv_grid.

"HTML viewer: force IE standards mode + scroll inside the page (#scr)
"so the scrollbar can be dragged in SAP GUI for Windows and WebGUI
CONSTANTS: gc_html_head  TYPE string VALUE
             `<!DOCTYPE html><html><head><meta http-equiv="X-UA-Compatible" content="IE=edge"><meta charset="utf-8"><style>` ##NO_TEXT,
           gc_scroll_css TYPE string VALUE
             `html,body{height:100%;margin:0;padding:0;overflow:hidden}#scr{position:absolute;top:0;right:0;bottom:0;left:0;overflow:auto}` ##NO_TEXT.

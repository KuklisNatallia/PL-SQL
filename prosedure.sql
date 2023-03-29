
PROCEDURE CHK_QC_DEAL_88 (IN_DATASET    IN SYS_REFCURSOR,
                         ID_PROTOCOL    IN NUMBER,
                         START_DATE     IN DATE,
                         P_EXPERIMENTID IN NUMBER,
                         P_EXECDATE     IN DATE,
                         OUT_STATUS     OUT NUMBER,
                         OUT_ERR_QTY    OUT NUMBER,
                         OUT_CRITICAL   OUT NUMBER,
                         OUT_MESSAGES   OUT TQCD_DETAIL_PROTOCOL_LIST) IS
  TYPE TROW IS RECORD(
    ID_DEAL         VARCHAR2(30), 
    ExecDate        DATE,
    ID_RSH          VARCHAR2(30), 
    NAME_GR         VARCHAR2(250),
    DT_PAY          VARCHAR2(250), 
    SYS_NAME        VARCHAR2(30), 
    DD_DEPARTMENT   VARCHAR2(250),
    D_DEPARTMENT    VARCHAR2(30),
    DOCNUM          VARCHAR2(250),
    BEGINDATE       DATE,
    ENTITYID1       VARCHAR2(30),
    NAME_F_P        VARCHAR2(250),
    id_sp_ca        VARCHAR2(30)
    );
  
  L_PRERESULT TQCD_DETAIL_PROTOCOL_LIST := TQCD_DETAIL_PROTOCOL_LIST();
  TYPE TROWLIST IS TABLE OF TROW;
  L_RESULT_TYPE TROWLIST;
  L_SHORT_MSG   VARCHAR2(250);
  L_LONG_MSG    VARCHAR2(4000);

BEGIN
  OUT_STATUS := 0;
  LOOP
    FETCH IN_DATASET BULK COLLECT
      INTO L_RESULT_TYPE;
  
    EXIT WHEN IN_DATASET%NOTFOUND;
  END LOOP;

  
  
  FOR I IN 1 .. L_RESULT_TYPE.COUNT LOOP
    L_SHORT_MSG := ' Для договора ' || L_RESULT_TYPE(I).DOCNUM ||
                   ' от ' || L_RESULT_TYPE(I).BEGINDATE ||
                   ' клиент ' || L_RESULT_TYPE(I).NAME_F_P ;
    L_LONG_MSG  := SUBSTR(
                   (' Вид графика ' || L_RESULT_TYPE(I).NAME_GR || 
                   ' Для договора ' || L_RESULT_TYPE(I).DOCNUM ||
                   ' от ' || L_RESULT_TYPE(I).BEGINDATE ||
                   ' клиент ' || L_RESULT_TYPE(I).NAME_F_P || ' (ENTITYID : ' || 
                   L_RESULT_TYPE(I).ENTITYID1 || ')' ||
                   ' загружены дубли строк графика ' || ' Дата(ы) платежа(ей) ' || L_RESULT_TYPE(I).DT_PAY),1,4000);
    L_PRERESULT.EXTEND;
    L_PRERESULT(L_PRERESULT.LAST) := TQCD_DETAIL_PROTOCOL_MSG(ID_PROTOCOL,
                                                              L_LONG_MSG,
                                                              L_SHORT_MSG, 
                                                              L_RESULT_TYPE(I).id_sp_ca, 
                                                              system_name => L_RESULT_TYPE(I).SYS_NAME,
                                                              department_name => (L_RESULT_TYPE(I).DD_DEPARTMENT || ' / ' || L_RESULT_TYPE(I).D_DEPARTMENT),
                                                              IBAN => null,
                                                              currency_code => null, 
                                                              employee_name => null);
  
    OUT_STATUS := 1;
  END LOOP;
  OUT_ERR_QTY  := L_RESULT_TYPE.COUNT;
  OUT_CRITICAL := 1;

  --Возвращаем строки в протокол
  OUT_MESSAGES := L_PRERESULT;
END;
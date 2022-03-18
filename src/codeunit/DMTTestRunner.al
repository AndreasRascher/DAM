codeunit 91006 "DMTTestRunner"
{
    Subtype = TestRunner;
    TestIsolation = Disabled;
    trigger OnRun()
    var
        DMTTest: Codeunit DMTTest;
    begin
        CurrDMTTable.Calcfields("No.of Fields in Trgt. Table");
        if CurrDMTTable."No.of Fields in Trgt. Table" > 100 then Error('More Testfunctions needed');
        Clear(DMTTest);
        DMTErrorLog.DeleteExistingLogForBufferRec(CurrBufferRef);
        DMTTest.SetUpTestParams(CurrDMTTable, CurrBufferRef);
        DMTTest.Run();
    end;

    trigger OnAfterTestRun(CodeunitId: Integer; CodeunitName: Text; FunctionName: Text; Permissions: TestPermissions; Success: Boolean)
    var
        DMTField: record "DMTField";
        DMTVariableStorage: Codeunit DMTVariableStorage;
        BufferRef, TmpTargetRef : recordref;
    begin
        IF not Success then begin
            DMTVariableStorage.GetRecRef(BufferRef, TmpTargetRef);
            DMTVariableStorage.GetDMTField(DMTField);
            DMTErrorLog.AddEntryForLastError(BufferRef, TmpTargetRef, DMTField);
        end;
        ClearLastError();
    end;

    procedure InitializeValidationTests(BufferRef_NEW: RecordRef; DMTTable_NEW: Record DMTTable)
    begin
        CurrBufferRef := BufferRef_NEW;
        CurrDMTTable := DMTTable_NEW;
    end;

    procedure GetResultRef(var TmpTargetRef: RecordRef)
    var
        DMTVariableStorage: Codeunit DMTVariableStorage;
        BufferRef: recordref;
    begin
        DMTVariableStorage.GetRecRef(BufferRef, TmpTargetRef);
    end;

    var
        DMTErrorLog: Record DMTErrorLog;
        CurrDMTTable: Record DMTTable;
        CurrBufferRef: RecordRef;

}
codeunit 91007 DMTTest
{
    Subtype = Test;

    [Test]
    procedure FillTargetRef()
    var
        DMTImport: Codeunit "DMTImport";
    begin
        DMTImport.AssignKeyFieldsAndInsertTmpRec(BufferRef, TmpTargetRef, TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField001()
    begin
        TempDMTField.Reset();
        TempDMTField.SetFilter("To Field No.", NonKeyFieldsFilter);
        TempDMTField.findset();
        ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    #region ValidateNonKeyField
    [Test]
    procedure ValidateNonKeyField002()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField003()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField004()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField005()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField006()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField007()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField008()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField009()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField010()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField011()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField012()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField013()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField014()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField015()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField016()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField017()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField018()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField019()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField020()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField021()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField022()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField023()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField024()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField025()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField026()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField027()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField028()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField029()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField030()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField031()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField032()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField033()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField034()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField035()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField036()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField037()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField038()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField039()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField040()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField041()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField042()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField043()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField044()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField045()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField046()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField047()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField048()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField049()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField050()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField051()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField052()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField053()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField054()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField055()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField056()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField057()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField058()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField059()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField060()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField061()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField062()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField063()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField064()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField065()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField066()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField067()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField068()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField069()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField070()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField071()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField072()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField073()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField074()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField075()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField076()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField077()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField078()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField079()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField080()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField081()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField082()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField083()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField084()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField085()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField086()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField087()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField088()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField089()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField090()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField091()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField092()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField093()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField094()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField095()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField096()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField097()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField098()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField099()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;

    [Test]
    procedure ValidateNonKeyField100()
    begin
        if (TempDMTField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDMTField);
    end;
    #endregion ValidateNonKeyField

    [Test]
    procedure StoreResult()
    var
        DMTVariableStorage: Codeunit DMTVariableStorage;
    begin
        DMTVariableStorage.SetRecRef(BufferRef, TmpTargetRef);
    end;

    procedure ValidateNonKeyFieldsAndModify(var CurrTempDMTField: Record "DMTField" temporary)
    var
        DMTMgt: Codeunit DMTMgt;
        DMTVariableStorage: Codeunit DMTVariableStorage;
        ToFieldRef: FieldRef;
    begin
        DMTVariableStorage.SetDMTField(CurrTempDMTField);
        DMTVariableStorage.SetRecRef(BufferRef, TmpTargetRef);
        case true of
            (CurrTempDMTField."Processing Action" = CurrTempDMTField."Processing Action"::Transfer):
                begin
                    if CurrTempDMTField."Validate Value" then
                        DMTMgt.ValidateFieldImplementation(BufferRef,
                        CurrTempDMTField."From Field No.",
                        CurrTempDMTField."To Field No.",
                        TmpTargetRef)
                    else
                        DMTMgt.AssignFieldWithoutValidate(TmpTargetRef, CurrTempDMTField."From Field No.", BufferRef, CurrTempDMTField."To Field No.", true);
                end;
            (CurrTempDMTField."Processing Action" = CurrTempDMTField."Processing Action"::FixedValue):
                begin
                    ToFieldRef := TmpTargetRef.Field(CurrTempDMTField."To Field No.");
                    if not DMTMgt.EvaluateFieldRef(ToFieldRef, CurrTempDMTField."Fixed Value", false) then
                        Error('Invalid Fixed Value %1', CurrTempDMTField."Fixed Value");
                    DMTMgt.ValidateFieldWithValue(TmpTargetRef, CurrTempDMTField."To Field No.",
                      ToFieldRef.Value,
                      CurrTempDMTField."Ignore Validation Error");
                end;
        end;
        TmpTargetRef.Modify();
    end;

    procedure SetUpTestParams(DMTTable_NEW: Record DMTTable; CurrBufferRef: RecordRef)
    var
        DMTImport: Codeunit "DMTImport";
        DMTMgt: Codeunit DMTMgt;
    begin
        DMTTable.Copy(DMTTable_NEW);
        BufferRef := CurrBufferRef;
        DMTImport.LoadFieldMapping(DMTTable, TempDMTField);
        TmpTargetRef.Open(DMTTable."To Table ID", true);
        KeyFieldsFilter := DMTMgt.GetIncludeExcludeKeyFieldFilter(bufferRef.NUMBER, true /*include*/);
        NonKeyFieldsFilter := DMTMgt.GetIncludeExcludeKeyFieldFilter(bufferRef.NUMBER, false /*exclude*/);
    end;

    var
        TempDMTField: Record "DMTField" temporary;
        DMTTable: Record DMTTable;
        BufferRef, TmpTargetRef : RecordRef;
        KeyFieldsFilter: Text;
        NonKeyFieldsFilter: Text;
}
codeunit 91008 DMTVariableStorage
{
    SingleInstance = true;

    procedure SetRecRef(var _FromRecRef: Recordref; var _ToRecRef: RecordRef);
    begin
        FromRecRef := _FromRecRef.Duplicate();
        ToRecRef := _ToRecRef.Duplicate();
    end;

    procedure GetRecRef(var _FromRecRef: Recordref; var _ToRecRef: RecordRef);
    begin
        _FromRecRef := FromRecRef.Duplicate();
        _ToRecRef := ToRecRef.Duplicate();
    end;

    procedure SetDMTField(var DMTField_NEW: Record "DMTField")
    begin
        TempDMTField.Copy(DMTField_NEW);
    end;

    procedure GetDMTField(var DMTField_FOUND: Record "DMTField")
    begin
        DMTField_FOUND.Copy(TempDMTField);
    end;

    var
        TempDMTField: Record "DMTField" temporary;
        FromRecRef: RecordRef;
        ToRecRef: RecordRef;
}
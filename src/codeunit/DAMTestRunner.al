codeunit 91006 DAMTestRunner
{
    Subtype = TestRunner;
    TestIsolation = Disabled;
    trigger OnRun()
    var
        DAMTest: Codeunit DAMTest;
    begin
        CurrDAMTable.Calcfields("No.of Fields in Trgt. Table");
        if CurrDAMTable."No.of Fields in Trgt. Table" > 100 then Error('More Testfunctions needed');
        Clear(DAMTest);
        DAMErrorLog.DeleteExistingLogForBufferRec(CurrBufferRef);
        DAMTest.SetUpTestParams(CurrDAMTable, CurrBufferRef);
        DAMTest.Run();
    end;

    trigger OnAfterTestRun(CodeunitId: Integer; CodeunitName: Text; FunctionName: Text; Permissions: TestPermissions; Success: Boolean)
    var
        DAMField: record DAMField;
        DAMVariableStorage: Codeunit DAMVariableStorage;
        BufferRef, TmpTargetRef : recordref;
    begin
        IF not Success then begin
            DAMVariableStorage.GetRecRef(BufferRef, TmpTargetRef);
            DAMVariableStorage.GetDAMField(DAMField);
            DAMErrorLog.AddEntryForLastError(BufferRef, TmpTargetRef, DAMField);
        end;
        ClearLastError();
    end;

    procedure InitializeValidationTests(BufferRef_NEW: RecordRef; DAMTable_NEW: Record DAMTable)
    begin
        CurrBufferRef := BufferRef_NEW;
        CurrDAMTable := DAMTable_NEW;
    end;

    procedure GetResultRef(var TmpTargetRef: RecordRef)
    var
        DAMVariableStorage: Codeunit DAMVariableStorage;
        BufferRef: recordref;
    begin
        DAMVariableStorage.GetRecRef(BufferRef, TmpTargetRef);
    end;

    var
        DAMErrorLog: Record DAMErrorLog;
        CurrDAMTable: Record DAMTable;
        CurrBufferRef: RecordRef;

}
codeunit 91007 DAMTest
{
    Subtype = Test;

    [Test]
    procedure FillTargetRef()
    var
        DAMImport: Codeunit DAMImport;
    begin
        DAMImport.AssignKeyFieldsAndInsertTmpRec(BufferRef, TmpTargetRef, KeyFieldsFilter, TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField001()
    begin
        TempDAMField.Reset();
        TempDAMField.SetFilter("To Field No.", NonKeyFieldsFilter);
        TempDAMField.findset();
        ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    #region ValidateNonKeyField
    [Test]
    procedure ValidateNonKeyField002()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField003()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField004()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField005()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField006()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField007()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField008()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField009()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField010()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField011()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField012()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField013()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField014()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField015()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField016()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField017()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField018()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField019()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField020()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField021()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField022()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField023()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField024()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField025()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField026()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField027()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField028()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField029()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField030()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField031()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField032()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField033()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField034()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField035()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField036()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField037()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField038()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField039()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField040()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField041()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField042()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField043()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField044()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField045()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField046()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField047()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField048()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField049()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField050()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField051()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField052()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField053()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField054()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField055()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField056()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField057()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField058()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField059()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField060()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField061()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField062()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField063()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField064()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField065()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField066()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField067()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField068()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField069()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField070()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField071()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField072()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField073()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField074()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField075()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField076()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField077()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField078()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField079()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField080()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField081()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField082()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField083()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField084()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField085()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField086()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField087()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField088()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField089()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField090()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField091()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField092()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField093()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField094()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField095()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField096()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField097()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField098()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField099()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField100()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(TempDAMField);
    end;
    #endregion ValidateNonKeyField

    [Test]
    procedure StoreResult()
    var
        DAMVariableStorage: Codeunit DAMVariableStorage;
    begin
        DAMVariableStorage.SetRecRef(BufferRef, TmpTargetRef);
    end;

    procedure ValidateNonKeyFieldsAndModify(var CurrTempDAMField: Record DAMField temporary)
    var
        DAMMgt: Codeunit DAMMgt;
        DAMVariableStorage: Codeunit DAMVariableStorage;
        ToFieldRef: FieldRef;
    begin
        DAMVariableStorage.SetDAMField(CurrTempDAMField);
        DAMVariableStorage.SetRecRef(BufferRef, TmpTargetRef);
        case true of
            (CurrTempDAMField."Processing Action" = CurrTempDAMField."Processing Action"::Transfer):
                begin
                    if CurrTempDAMField."Validate Value" then
                        DAMMgt.ValidateFieldImplementation(BufferRef,
                        CurrTempDAMField."From Field No.",
                        CurrTempDAMField."To Field No.",
                        TmpTargetRef)
                    else
                        DAMMgt.AssignFieldWithoutValidate(TmpTargetRef, CurrTempDAMField."From Field No.", BufferRef, CurrTempDAMField."To Field No.", true);
                end;
            (CurrTempDAMField."Processing Action" = CurrTempDAMField."Processing Action"::FixedValue):
                begin
                    ToFieldRef := TmpTargetRef.Field(CurrTempDAMField."To Field No.");
                    if not DAMMgt.EvaluateFieldRef(ToFieldRef, CurrTempDAMField."Fixed Value", false) then
                        Error('Invalid Fixed Value %1', CurrTempDAMField."Fixed Value");
                    DAMMgt.ValidateFieldWithValue(TmpTargetRef, CurrTempDAMField."To Field No.",
                      ToFieldRef.Value,
                      CurrTempDAMField."Ignore Validation Error");
                end;
        end;
        TmpTargetRef.Modify();
    end;

    procedure SetUpTestParams(dAMTable_NEW: Record DAMTable; CurrBufferRef: RecordRef)
    var
        DAMImport: Codeunit DAMImport;
        DAMMgt: Codeunit DAMMgt;
    begin
        DAMTable.Copy(dAMTable_NEW);
        BufferRef := CurrBufferRef;
        DAMImport.LoadFieldMapping(DAMTable, TempDAMField);
        TmpTargetRef.Open(DAMTable."To Table ID", true);
        KeyFieldsFilter := DAMMgt.GetIncludeExcludeKeyFieldFilter(bufferRef.NUMBER, true /*include*/);
        NonKeyFieldsFilter := DAMMgt.GetIncludeExcludeKeyFieldFilter(bufferRef.NUMBER, false /*exclude*/);
    end;

    var
        TempDAMField: Record DAMField temporary;
        DAMTable: Record DAMTable;
        BufferRef, TmpTargetRef : RecordRef;
        KeyFieldsFilter: Text;
        NonKeyFieldsFilter: Text;
}
codeunit 91008 DAMVariableStorage
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

    procedure SetDAMField(var DAMField_NEW: Record DAMField)
    begin
        TempDAMField.Copy(DAMField_NEW);
    end;

    procedure GetDAMField(var DAMField_FOUND: Record DAMField)
    begin
        DAMField_FOUND.Copy(TempDAMField);
    end;

    var
        TempDAMField: Record DAMField temporary;
        FromRecRef: RecordRef;
        ToRecRef: RecordRef;
}
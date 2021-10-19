codeunit 91006 DAMTestRunner
{
    Subtype = TestRunner;
    TestIsolation = Disabled;
    trigger OnRun()
    var
        DAMTable: Record DAMTable;
        DAMTest: Codeunit DAMTest;
        BufferRef: RecordRef;
    begin
        Clear(DAMTest);
        DAMTable.Get(Database::Contact);
        BufferRef.Open(DAMTable."Buffer Table ID");
        BufferRef.FindFirst();
        DAMTest.SetUpTestParams(DAMTable, BufferRef);
        DAMTest.Run();
    end;

    trigger OnAfterTestRun(CodeunitId: Integer; CodeunitName: Text; FunctionName: Text; Permissions: TestPermissions; Success: Boolean)
    var
        // DAMVariableStorage: Codeunit DAMVariableStorage;
        LastError: Text;
    begin
        IF not Success then
            LastError := GetLastErrorText();
        ClearLastError();
    end;
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
    procedure ValidateNonKeyField1()
    begin
        TempDAMField.Reset();
        TempDAMField.SetFilter("To Field No.", NonKeyFieldsFilter);
        TempDAMField.findset();
        ValidateNonKeyFieldsAndModify(TempDAMField);
    end;

    [Test]
    procedure ValidateNonKeyField2()
    begin
        if (TempDAMField.next() = 1) then ValidateNonKeyFieldsAndModify(CurrDAMField);
    end;

    procedure ValidateNonKeyFieldsAndModify(var CurrTempDAMField: Record DAMField temporary)
    var
        DAMMgt: Codeunit DAMMgt;
        ToFieldRef: FieldRef;
    begin
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
        CurrDAMField: Record DAMField;
        TempDAMField: Record DAMField temporary;
        DAMTable: Record DAMTable;
        BufferRef, TmpTargetRef : RecordRef;
        KeyFieldsFilter: Text;
        NonKeyFieldsFilter: Text;
}
// codeunit 91008 DAMVariableStorage
// {
//     SingleInstance = true;

//     procedure SetRecRef(var _FromRecRef: Recordref; var _ToRecRef: RecordRef);
//     begin
//         FromRecRef := _FromRecRef.Duplicate();
//         ToRecRef := _ToRecRef.Duplicate();
//     end;

//     procedure GetRecRef(var _FromRecRef: Recordref; var _ToRecRef: RecordRef);
//     begin
//         _FromRecRef := FromRecRef.Duplicate();
//         _ToRecRef := ToRecRef.Duplicate();
//     end;

//     procedure SetDAMFields(var DAMField_NEW: Record DAMField temporary)
//     begin
//         TempDAMField.Copy(DAMField_NEW, true);
//     end;

//     procedure GetDAMFields(var DAMField_FOUND: Record DAMField temporary)
//     begin
//         DAMField_FOUND.Copy(TempDAMField, true);
//     end;

//     procedure GetNextField(var DAMField: Record DAMField) OK: Boolean
//     begin
//         Clear(DAMField);
//         OK := TempDAMField.next() <> 0;
//         if OK then
//             DAMField := TempDAMField;
//     end;

//     procedure AddEntryForLastError()
//     var
//         DAMErrorLog: Record DAMErrorLog;
//     begin
//         DAMErrorLog.AddEntryForLastError(FromRecRef, ToRecRef, TempDAMField);
//     end;

//     var
//         TempDAMField: Record DAMField temporary;
//         FromRecRef: RecordRef;
//         ToRecRef: RecordRef;
// }
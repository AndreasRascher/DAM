// codeunit 91006 DAMTestRunner
// {
//     Subtype = TestRunner;
//     TestIsolation = Disabled;
//     trigger OnRun()
//     var
//         DAMTable: Record DAMTable;
//         DAMTest: Codeunit DAMTest;
//     begin
//         Clear(DAMTest);
//         DAMTable.Get(Database::Contact);
//         DAMTest.SetUpTestParams(DAMTable);
//         Codeunit.Run(Codeunit::DAMTest);
//     end;

//     trigger OnAfterTestRun(CodeunitId: Integer; CodeunitName: Text; FunctionName: Text; Permissions: TestPermissions; Success: Boolean)
//     var
//         DAMVariableStorage: Codeunit DAMVariableStorage;
//     begin
//         IF not Success then DAMVariableStorage.AddEntryForLastError();
//     end;
// }
// codeunit 91007 DAMTest
// {
//     Subtype = Test;

//     [Test]
//     procedure FillTargetRef()
//     var
//         DAMImport: Codeunit DAMImport;
//         BufferRef, TmpTargetRef : RecordRef;
//     begin
//         DAMImport.AssignKeyFieldsAndInsertTmpRec(BufferRef, TmpTargetRef);
//     end;
//     #region Field1To10
//     [Test]
//     procedure ValidateNonKeyField1()
//     var
//         TempDAMField: Record DAMField temporary;
//     begin
//         DAMVariableStorage.GetDAMFields(TempDAMField);
//         TempDAMField.Reset();
//         TempDAMField.SetFilter("To Field No.", NonKeyFieldsFilter);
//         TempDAMField.findset();
//         DAMVariableStorage.SetDAMFields(TempDAMField);
//         ValidateNonKeyFieldsAndModify(TempDAMField);
//     end;

//     [Test]
//     procedure ValidateNonKeyField2()
//     begin
//         if DAMVariableStorage.GetNextField(CurrDAMField) then ValidateNonKeyFieldsAndModify(CurrDAMField);
//     end;

//     [Test]
//     procedure ValidateNonKeyField3()
//     begin
//         if DAMVariableStorage.GetNextField(CurrDAMField) then ValidateNonKeyFieldsAndModify(CurrDAMField);
//     end;

//     [Test]
//     procedure ValidateNonKeyField4()
//     begin
//         if DAMVariableStorage.GetNextField(CurrDAMField) then ValidateNonKeyFieldsAndModify(CurrDAMField);
//     end;

//     [Test]
//     procedure ValidateNonKeyField5()
//     begin
//         if DAMVariableStorage.GetNextField(CurrDAMField) then ValidateNonKeyFieldsAndModify(CurrDAMField);
//     end;

//     [Test]
//     procedure ValidateNonKeyField6()
//     begin
//         if DAMVariableStorage.GetNextField(CurrDAMField) then ValidateNonKeyFieldsAndModify(CurrDAMField);
//     end;

//     [Test]
//     procedure ValidateNonKeyField7()
//     begin
//         if DAMVariableStorage.GetNextField(CurrDAMField) then ValidateNonKeyFieldsAndModify(CurrDAMField);
//     end;

//     [Test]
//     procedure ValidateNonKeyField8()
//     begin
//         if DAMVariableStorage.GetNextField(CurrDAMField) then ValidateNonKeyFieldsAndModify(CurrDAMField);
//     end;

//     [Test]
//     procedure ValidateNonKeyField9()
//     begin
//         if DAMVariableStorage.GetNextField(CurrDAMField) then ValidateNonKeyFieldsAndModify(CurrDAMField);
//     end;

//     [Test]
//     procedure ValidateNonKeyField10()
//     begin
//         if DAMVariableStorage.GetNextField(CurrDAMField) then ValidateNonKeyFieldsAndModify(CurrDAMField);
//     end;
//     #endregion Field1To10
//     #region Field11to20
//     [Test]
//     procedure ValidateNonKeyField11()
//     begin
//         if DAMVariableStorage.GetNextField(CurrDAMField) then ValidateNonKeyFieldsAndModify(CurrDAMField);
//     end;

//     [Test]
//     procedure ValidateNonKeyField12()
//     begin
//         if DAMVariableStorage.GetNextField(CurrDAMField) then ValidateNonKeyFieldsAndModify(CurrDAMField);
//     end;

//     [Test]
//     procedure ValidateNonKeyField13()
//     begin
//         if DAMVariableStorage.GetNextField(CurrDAMField) then ValidateNonKeyFieldsAndModify(CurrDAMField);
//     end;

//     [Test]
//     procedure ValidateNonKeyField14()
//     begin
//         if DAMVariableStorage.GetNextField(CurrDAMField) then ValidateNonKeyFieldsAndModify(CurrDAMField);
//     end;

//     [Test]
//     procedure ValidateNonKeyField15()
//     begin
//         if DAMVariableStorage.GetNextField(CurrDAMField) then ValidateNonKeyFieldsAndModify(CurrDAMField);
//     end;

//     [Test]
//     procedure ValidateNonKeyField16()
//     begin
//         if DAMVariableStorage.GetNextField(CurrDAMField) then ValidateNonKeyFieldsAndModify(CurrDAMField);
//     end;

//     [Test]
//     procedure ValidateNonKeyField17()
//     begin
//         if DAMVariableStorage.GetNextField(CurrDAMField) then ValidateNonKeyFieldsAndModify(CurrDAMField);
//     end;

//     [Test]
//     procedure ValidateNonKeyField18()
//     begin
//         if DAMVariableStorage.GetNextField(CurrDAMField) then ValidateNonKeyFieldsAndModify(CurrDAMField);
//     end;

//     [Test]
//     procedure ValidateNonKeyField19()
//     begin
//         if DAMVariableStorage.GetNextField(CurrDAMField) then ValidateNonKeyFieldsAndModify(CurrDAMField);
//     end;

//     [Test]
//     procedure ValidateNonKeyField20()
//     begin
//         if DAMVariableStorage.GetNextField(CurrDAMField) then ValidateNonKeyFieldsAndModify(CurrDAMField);
//     end;
//     #endregion Field11to20
//     procedure ValidateNonKeyFieldsAndModify(var CurrTempDAMField: Record DAMField temporary)
//     var
//         DAMMgt: Codeunit DAMMgt;
//         BufferRef, TmpTargetRef : RecordRef;
//         ToFieldRef: FieldRef;
//     begin
//         DAMVariableStorage.GetRecRef(BufferRef, TmpTargetRef);
//         case true of
//             (CurrTempDAMField."Processing Action" = CurrTempDAMField."Processing Action"::Transfer):
//                 begin
//                     if CurrTempDAMField."Validate Value" then
//                         DAMMgt.ValidateFieldImplementation(BufferRef,
//                         CurrTempDAMField."From Field No.",
//                         CurrTempDAMField."To Field No.",
//                         TmpTargetRef)
//                     else
//                         DAMMgt.AssignFieldWithoutValidate(TmpTargetRef, CurrTempDAMField."From Field No.", BufferRef, CurrTempDAMField."To Field No.", true);
//                 end;
//             (CurrTempDAMField."Processing Action" = CurrTempDAMField."Processing Action"::FixedValue):
//                 begin
//                     ToFieldRef := TmpTargetRef.Field(CurrTempDAMField."To Field No.");
//                     if not DAMMgt.EvaluateFieldRef(ToFieldRef, CurrTempDAMField."Fixed Value", false) then
//                         Error('Invalid Fixed Value %1', CurrTempDAMField."Fixed Value");
//                     DAMMgt.ValidateFieldWithValue(TmpTargetRef, CurrTempDAMField."To Field No.",
//                       ToFieldRef.Value,
//                       CurrTempDAMField."Ignore Validation Error");
//                 end;
//         end;
//         TmpTargetRef.Modify();
//         DAMVariableStorage.SetRecRef(BufferRef, TmpTargetRef);
//     end;

//     procedure SetUpTestParams(DAMTable_NEW: Record DAMTable)
//     var
//         TempDAMFields: Record DAMField temporary;
//         DAMImport: Codeunit DAMImport;
//         DAMMgt: Codeunit DAMMgt;
//         BufferRef: RecordRef;
//         TmpTargetRef: RecordRef;
//     begin
//         DAMTable.Copy(DAMTable_NEW);
//         DAMImport.LoadFieldMapping(DAMTable, TempDAMFields);
//         DAMVariableStorage.SetDAMFields(TempDAMFields);
//         BufferRef.OPEN(DAMTable."Buffer Table ID");
//         TmpTargetRef.Open(DAMTable."To Table ID", true);
//         DAMVariableStorage.SetRecRef(BufferRef, TmpTargetRef);
//         KeyFieldsFilter := DAMMgt.GetIncludeExcludeKeyFieldFilter(BufferRef.NUMBER, true /*include*/);
//         NonKeyFieldsFilter := DAMMgt.GetIncludeExcludeKeyFieldFilter(BufferRef.NUMBER, false /*exclude*/);
//     end;

//     var
//         CurrDAMField: Record DAMField;
//         DAMTable: Record DAMTable;
//         DAMVariableStorage: Codeunit DAMVariableStorage;
//         KeyFieldsFilter: Text;
//         NonKeyFieldsFilter: Text;
// }
// codeunit 91008 DAMVariableStorage
// {
//     SingleInstance = true;

//     procedure SetRecRef(var _FromRecRef: Recordref; var _ToRecRef: RecordRef);
//     begin
//         FromRecRef := _FromRecRef;
//         ToRecRef := _ToRecRef;
//     end;

//     procedure GetRecRef(var _FromRecRef: Recordref; var _ToRecRef: RecordRef);
//     begin
//         _FromRecRef := FromRecRef;
//         _ToRecRef := ToRecRef;
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
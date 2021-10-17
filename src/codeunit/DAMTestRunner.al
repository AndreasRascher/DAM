// codeunit 91006 DAMTestRunner
// {
//     Subtype = TestRunner;
//     TestIsolation = Disabled;
//     trigger OnRun()
//     begin
//         Commit();
//         Codeunit.Run(Codeunit::DAMTest);
//     end;

//     trigger OnAfterTestRun(CodeunitId: Integer; CodeunitName: Text; FunctionName: Text; Permissions: TestPermissions; Success: Boolean)
//     begin

//     end;
// }
// codeunit 91007 DAMTest
// {
//     Subtype = Test;

//     [Test]
//     procedure ValidateField()
//     var
//         myInt: Integer;
//     begin

//     end;

//     var
//         DAMTable: Record DAMTable;
//         DAMMgt: Codeunit DAMMgt;
// }
// codeunit 50009 DMTPageBackgroundTasks
// {
//     trigger OnRun()
//     begin
//         // if not Evaluate(WaitTime, Page.GetBackgroundParameters().Get('Wait')) then
//         //     Error('Could not parse parameter WaitParam');
//         ReadTableRelations();
//         Page.SetBackgroundTaskResult(Result);
//     end;

//     local procedure ReadTableRelations()
//     var
//         DMTTable: Record DMTTable;
//         RelationsCheck: Codeunit DMTRelationsCheck;
//     begin
//         if DMTTable.FindSet(false, false) then begin
//             repeat
//                 Result.Add(format(DMTTable.RecordId), Format(RelationsCheck.FindUnhandledRelatedTableIDs(DMTTable).Count));
//             until DMTTable.Next() = 0;
//         end;
//         Error('test');
//     end;

//     var
//         Result: Dictionary of [Text, Text];
// }

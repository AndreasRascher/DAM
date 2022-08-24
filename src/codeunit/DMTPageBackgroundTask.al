codeunit 110006 DMTPageBackgroundTasks
{
    trigger OnRun()
    begin
        // myInt := 1;
        MyDictionary := Page.GetBackgroundParameters();
        // MyResult.Add('xxx', 'ttt');
        // Page.SetBackgroundTaskResult(MyResult);

        // if not Evaluate(WaitTime, Page.GetBackgroundParameters().Get('Wait')) then
        //     Error('Could not parse parameter WaitParam');
        ReadTableRelations();
        Page.SetBackgroundTaskResult(MyResult);
    end;

    local procedure ReadTableRelations()
    var
        DMTTable: Record DMTTable;
        RelationsCheck: Codeunit DMTRelationsCheck;
    begin
        if DMTTable.FindSet(false, false) then begin
            repeat
                MyResult.Add(format(DMTTable.RecordId), Format(RelationsCheck.FindUnhandledRelatedTableIDs(DMTTable).Count));
            until DMTTable.Next() = 0;
        end;
        Message('test');
    end;

    var
        MyResult, MyDictionary : Dictionary of [Text, Text];
        myInt: Integer;
}

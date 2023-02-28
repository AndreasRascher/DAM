codeunit 110018 DMTDeleteRecordsWithErrorLog
{
    trigger OnRun()
    begin
        case Runmode of
            Runmode::"Delete Record":
                DeleteRecord();
        end;
    end;

    procedure InitRecordToDelete(_RecIDToDelete: RecordId; _UseOnDeleteTriggers: Boolean)
    begin
        RecIDToDelete := _RecIDToDelete;
        UseOnDeleteTriggers := _UseOnDeleteTriggers;
        Runmode := Runmode::"Delete Record";
    end;

    local procedure DeleteRecord()
    var
        RecRef: RecordRef;
    begin
        RecRef.Get(RecIDToDelete);
        RecRef.Delete(UseOnDeleteTriggers);
    end;

    procedure DialogOpen(Dialogtext: Text)
    begin
        if not GuiAllowed then exit;
        if DialogIsOpen then exit;
        DialogIsOpen := true;
        DialogWindow.Open(Dialogtext);
        LastUpdate := CurrentDateTime - 501;
        Start := CurrentDateTime;
    end;

    [TryFunction]
    procedure DialogUpdate(UpdateControl1: Integer; Value1: Variant; UpdateControl2: Integer; Value2: Variant; UpdateControl3: Integer; Value3: Variant)
    begin
        if not DialogIsOpen then exit;
        if Abs(CurrentDateTime - LastUpdate) > 500 then begin
            if UpdateControl1 <> 0 then
                DialogWindow.Update(UpdateControl1, Value1);
            if UpdateControl2 <> 0 then
                DialogWindow.Update(UpdateControl2, Value2);
            if UpdateControl3 <> 0 then
                DialogWindow.Update(UpdateControl3, Value3);
            LastUpdate := CurrentDateTime;
        end;
    end;

    procedure DialogClose()
    begin
        if not DialogIsOpen then exit;
        DialogWindow.Close();
        DialogIsOpen := false;
        Finish := CurrentDateTime;
    end;



    procedure GetDuratiation(): Duration
    begin
        exit(Finish - Start);
    end;


    var
        RecIDToDelete: RecordId;
        UseOnDeleteTriggers: Boolean;
        Runmode: Option " ","Delete Record";
        DialogWindow: Dialog;
        LastUpdate: DateTime;
        DialogIsOpen: Boolean;
        Start, Finish : DateTime;
}
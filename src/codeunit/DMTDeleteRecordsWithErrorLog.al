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

    procedure LogLastError()
    var
        ErrorItem: Dictionary of [Text, Text];
    begin
        ErrorItem.Add('GetLastErrorCallStack', GetLastErrorCallStack);
        ErrorItem.Add('GetLastErrorCode', GetLastErrorCode);
        ErrorItem.Add('GetLastErrorText', GetLastErrorText);
        case Runmode of
            Runmode::"Delete Record":
                ErrorLogDict.Add(RecIDToDelete, ErrorItem);
        end;
        ClearLastError();
    end;

    procedure showErrors()
    var
        TempErrorMessage: Record "Error Message" temporary;
        RecID: RecordId;
        ErrorItem: Dictionary of [Text, Text];
        ID: Integer;
    begin
        if ErrorLogDict.Count = 0 then exit;
        foreach RecID in ErrorLogDict.Keys do begin
            ErrorItem := ErrorLogDict.Get(RecID);
            Clear(TempErrorMessage);
            ID += 1;
            TempErrorMessage.ID := ID;
            TempErrorMessage."Record ID" := RecID;
            TempErrorMessage."Field Name" := CopyStr(Format(RecID), 1, MaxStrLen(TempErrorMessage."Field Name"));
            TempErrorMessage.Description := CopyStr(ErrorItem.Get('GetLastErrorText'), 1, MaxStrLen(TempErrorMessage.Description));
            TempErrorMessage.SetErrorCallStack(ErrorItem.Get('GetLastErrorCallStack'));
            TempErrorMessage.Insert();
        end;
        Page.Run(Page::"Error Messages", TempErrorMessage);
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
        ErrorLogDict: Dictionary of [RecordId, Dictionary of [Text, Text]];
        UseOnDeleteTriggers: Boolean;
        Runmode: Option " ","Delete Record";
        DialogWindow: Dialog;
        LastUpdate: DateTime;
        DialogIsOpen: Boolean;
        Start, Finish : DateTime;
}
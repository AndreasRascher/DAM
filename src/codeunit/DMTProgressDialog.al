codeunit 110010 "DMTProgressDialog"
{
    procedure AppendTextLine(TextLineNew: Text)
    begin
        ProgressMsg.AppendLine(TextLineNew);
    end;

    procedure AppendText(TextLineNew: Text)
    begin
        ProgressMsg.Append(TextLineNew);
    end;

    procedure AddBar(IndicatorLenght: Integer; ProgressIndicatorNo: Integer)
    var
        FieldText: Text;
    begin
        FieldText := PadStr('', IndicatorLenght, '#') + format(ProgressIndicatorNo) + '#';
        ProgressMsg.Append(FieldText);
    end;

    procedure AddField(IndicatorLenght: Integer; ProgressIndicatorNo: Integer)
    var
        FieldText: Text;
    begin
        FieldText := PadStr('', IndicatorLenght, '#') + format(ProgressIndicatorNo) + '@';
        ProgressMsg.Append(FieldText);
    end;

    procedure Open()
    begin
        UpdateThresholdInMS := 1000; // 1 Second
        if ProgressMsg.ToText().TrimEnd() = '' then
            Error('es wurde kein Text für Dialog definiert');
        Progress.Open(ProgressMsg.ToText().TrimEnd());
        Start := CurrentDateTime;
        IsProgressOpen := true;
    end;

    procedure UpdateControl(Number: Integer; Value: Variant)
    begin
        if not IsProgressOpen then
            exit;
        if Number <> 0 then
            Progress.update(Number, Value);
    end;

    procedure Close()
    begin
        if IsProgressOpen then
            Progress.close();
    end;

    procedure SaveCustomStartTime(Index: Integer)
    begin
        if CustomStart.ContainsKey(Index) then
            CustomStart.Set(Index, CurrentDateTime)
        else
            CustomStart.Add(Index, CurrentDateTime);
    end;

    procedure GetCustomDuration(Index: Integer) TimeElapsed: Duration
    begin
        if CustomStart.ContainsKey(Index) then
            exit(CurrentDateTime - CustomStart.Get(Index))
        else
            exit(0);
    end;

    procedure UpdateControlWithCustomDuration(ControlIndex: Integer; CustomDuration: Integer)
    begin
        ControlValuesDict.Add(ControlIndex, format(GetCustomDuration(CustomDuration)));
        DoUpdate();
    end;

    local procedure DoUpdate()
    var
        ControlID: Integer;
    begin

        if LastUpdate = 0DT then
            LastUpdate := CurrentDateTime - UpdateThresholdInMS;
        if (CurrentDateTime - LastUpdate) <= UpdateThresholdInMS then
            exit;
        foreach ControlID in ControlValuesDict.Keys do begin
            Progress.Update(ControlID, ControlValuesDict.Get(ControlID));
        end;
    end;

    procedure NextStep(ControlIndex: Integer)
    var
        CurrStep: Integer;
    begin
        if not CurrStepValuesDict.Get(ControlIndex, CurrStep) then
            CurrStepValuesDict.Add(ControlIndex, 1)
        else
            CurrStepValuesDict.Set(ControlIndex, CurrStep + 1);
    end;

    var
        ProgressMsg: TextBuilder;
        IsProgressOpen: Boolean;
        Progress: Dialog;
        UpdateThresholdInMS: Integer;
        Start: DateTime;
        CustomStart: Dictionary of [Integer, DateTime];
        LastUpdate: DateTime;
        TotalStepValuesDict, CurrStepValuesDict : Dictionary of [Integer, Integer];
        ControlValuesDict: Dictionary of [Integer, Text];
}
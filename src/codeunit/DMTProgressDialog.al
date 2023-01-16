codeunit 110010 DMTProgressDialog
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
        FieldText := PadStr('', IndicatorLenght, '@') + Format(ProgressIndicatorNo) + '@';
        ProgressMsg.Append(FieldText);
    end;

    procedure AddField(IndicatorLenght: Integer; ProgressIndicatorNo: Integer)
    var
        FieldText: Text;
    begin
        FieldText := PadStr('', IndicatorLenght, '#') + Format(ProgressIndicatorNo) + '#';
        ProgressMsg.Append(FieldText);
    end;

    procedure Open()
    begin
        UpdateThresholdInMS := 1000; // 1 Seconds
        if ProgressMsg.ToText().TrimEnd() = '' then
            Error('es wurde kein Text für Dialog definiert');
        Progress.Open(ProgressMsg.ToText().TrimEnd());
        Start := CurrentDateTime;
        IsProgressOpen := true;
    end;

    procedure UpdateFieldControl(ControlIndex: Integer; Value: Variant)
    begin
        if not FieldControlValuesDict.ContainsKey(ControlIndex) then
            FieldControlValuesDict.Add(ControlIndex, Value)
        else
            FieldControlValuesDict.Set(ControlIndex, Value);
        DoUpdate();
    end;

    local procedure UpdateBarControl(ControlIndex: Integer; Value: Variant)
    begin
        if not BarControlValuesDict.ContainsKey(ControlIndex) then
            BarControlValuesDict.Add(ControlIndex, Value)
        else
            BarControlValuesDict.Set(ControlIndex, Value);
        DoUpdate();
    end;

    procedure Close()
    begin
        if IsProgressOpen then
            Progress.Close();
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
        UpdateFieldControl(ControlIndex, Format(GetCustomDuration(CustomDuration)));
        DoUpdate();
    end;

    procedure UpdateProgressBar(ControlIndex: Integer; StepIndex: Integer)
    var
        ProgressStep: Integer;
    begin
        ProgressStep := (10000 * (GetStep(StepIndex) / GetTotalStep(StepIndex))) div 1;
        UpdateBarControl(ControlIndex, ProgressStep);
    end;

    procedure GetRemainingTime(StartTimeIndex: Integer; StepIndex: Integer) TimeLeft: Text
    var
        RemainingMins: Decimal;
        RemainingSeconds: Decimal;
        ElapsedTime: Duration;
        RoundedRemainingMins: Integer;
    begin
        ElapsedTime := Round(((GetCustomDuration(StartTimeIndex)) / 1000), 1);
        RemainingMins := Round((((ElapsedTime / ((GetStep(StepIndex) / GetTotalStep(StepIndex)) * 100) * 100) - ElapsedTime) / 60), 0.1);
        RoundedRemainingMins := Round(RemainingMins, 1, '<');
        RemainingSeconds := Round(((RemainingMins - RoundedRemainingMins) * 0.6) * 100, 1);
        TimeLeft := StrSubstNo('%1:', RoundedRemainingMins);
        if StrLen(Format(RemainingSeconds)) = 1 then
            TimeLeft += StrSubstNo('0%1', RemainingSeconds)
        else
            TimeLeft += StrSubstNo('%1', RemainingSeconds);
    end;

    local procedure DoUpdate()
    var
        ControlID: Integer;
    begin
        if not IsProgressOpen then
            exit;
        if LastUpdate = 0DT then
            LastUpdate := CurrentDateTime - UpdateThresholdInMS;
        if (CurrentDateTime - LastUpdate) <= UpdateThresholdInMS then
            exit;
        foreach ControlID in FieldControlValuesDict.Keys do begin
            Progress.Update(ControlID, FieldControlValuesDict.Get(ControlID));
        end;
        foreach ControlID in BarControlValuesDict.Keys do begin
            Progress.Update(ControlID, BarControlValuesDict.Get(ControlID));
        end;
        LastUpdate := CurrentDateTime;
    end;

    procedure NextStep(StepIndex: Integer)
    var
        CurrStep: Integer;
    begin
        if not CurrStepValuesDict.Get(StepIndex, CurrStep) then
            CurrStepValuesDict.Add(StepIndex, 1)
        else
            CurrStepValuesDict.Set(StepIndex, CurrStep + 1);
    end;

    procedure GetStep(StepIndex: Integer) CurrStep: Integer
    begin
        if not CurrStepValuesDict.Get(StepIndex, CurrStep) then;
        exit(CurrStep);
    end;

    procedure SetTotalSteps(Index: Integer; TotalStepsNew: Integer)
    begin
        if TotalStepValuesDict.ContainsKey(Index) then
            TotalStepValuesDict.Set(Index, TotalStepsNew)
        else
            TotalStepValuesDict.Add(Index, TotalStepsNew);
    end;

    procedure GetTotalStep(Index: Integer) TotalSteps: Integer
    begin
        if TotalStepValuesDict.Get(Index, TotalSteps) then;
        exit(TotalSteps);
    end;

    var
        IsProgressOpen: Boolean;
        LastUpdate: DateTime;
        Start: DateTime;
        Progress: Dialog;
        CustomStart: Dictionary of [Integer, DateTime];
        CurrStepValuesDict, TotalStepValuesDict : Dictionary of [Integer, Integer];
        FieldControlValuesDict: Dictionary of [Integer, Text];
        BarControlValuesDict: Dictionary of [Integer, Integer];
        UpdateThresholdInMS: Integer;
        ProgressMsg: TextBuilder;
}
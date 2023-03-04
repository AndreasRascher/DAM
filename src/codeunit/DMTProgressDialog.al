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

    procedure AddBar(IndicatorLenght: Integer; NewProgressBarName: Text)
    var
        FieldText: Text;
    begin
        if ProgressBarNames.Contains(NewProgressBarName) then
            Error('Bar with indicator name %1 exists already', NewProgressBarName);
        ProgressBarNames.Add(NewProgressBarName);
        FieldText := PadStr('', IndicatorLenght, '@') + Format(ProgressBarNames.IndexOf(NewProgressBarName)) + '@';
        ProgressMsg.Append(FieldText);
    end;

    procedure AddField(IndicatorLenght: Integer; NewProgressFieldName: Text)
    var
        FieldText: Text;
    begin
        if ProgressFieldNames.Contains(NewProgressFieldName) then
            Error('Field with indicator name %1 exists already', NewProgressFieldName);
        ProgressFieldNames.Add(NewProgressFieldName);

        FieldText := PadStr('', IndicatorLenght, '#') + Format(ProgressFieldNames.IndexOf(NewProgressFieldName)) + '#';
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

    procedure UpdateFieldControl(ControlName: Text; Value: Variant)
    var
        ControlIndex: Integer;
    begin
        ControlIndex := ProgressFieldNames.IndexOf(ControlName);
        if not FieldControlValuesDict.ContainsKey(ControlIndex) then
            FieldControlValuesDict.Add(ControlIndex, Value)
        else
            FieldControlValuesDict.Set(ControlIndex, Value);
        DoUpdate();
    end;

    local procedure UpdateBarControl(ControlName: Text; Value: Variant)
    var
        ControlIndex: Integer;
    begin
        ControlIndex := ProgressBarNames.IndexOf(ControlName);
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

    procedure SaveCustomStartTime(IndexName: Text)
    begin
        if CustomStart.ContainsKey(IndexName) then
            CustomStart.Set(IndexName, CurrentDateTime)
        else
            CustomStart.Add(IndexName, CurrentDateTime);
    end;

    procedure GetCustomDuration(CustomDurationName: Text) TimeElapsed: Duration
    begin
        if CustomStart.ContainsKey(CustomDurationName) then
            exit(CurrentDateTime - CustomStart.Get(CustomDurationName))
        else
            exit(0);
    end;

    procedure UpdateControlWithCustomDuration(ProgressFieldName: Text; CustomDurationName: Text)
    begin
        UpdateFieldControl(ProgressFieldName, Format(GetCustomDuration(CustomDurationName)));
        DoUpdate();
    end;

    procedure UpdateProgressBar(ControlName: Text; StepIndexName: Text)
    var
        ProgressStep: Integer;
    begin
        ProgressStep := (10000 * (GetStep(StepIndexName) / GetTotalStep(StepIndexName))) div 1;
        UpdateBarControl(ControlName, ProgressStep);
    end;

    procedure GetRemainingTime(StartTimeName: Text; StepIndexName: Text) TimeLeft: Text
    var
        RemainingMins: Decimal;
        RemainingSeconds: Decimal;
        ElapsedTime: Duration;
        RoundedRemainingMins: Integer;
    begin
        ElapsedTime := Round(((GetCustomDuration(StartTimeName)) / 1000), 1);
        RemainingMins := Round((((ElapsedTime / ((GetStep(StepIndexName) / GetTotalStep(StepIndexName)) * 100) * 100) - ElapsedTime) / 60), 0.1);
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

    procedure NextStep(StepIndexName: Text)
    var
        CurrStep: Integer;
    begin
        if not CurrStepValuesDict.Get(StepIndexName, CurrStep) then
            CurrStepValuesDict.Add(StepIndexName, 1)
        else
            CurrStepValuesDict.Set(StepIndexName, CurrStep + 1);
    end;

    procedure GetStep(StepIndexName: Text) CurrStep: Integer
    begin
        if not CurrStepValuesDict.Get(StepIndexName, CurrStep) then;
        exit(CurrStep);
    end;

    procedure SetTotalSteps(TotalIndexName: Text; TotalStepsNew: Integer)
    begin
        if TotalStepValuesDict.ContainsKey(TotalIndexName) then
            TotalStepValuesDict.Set(TotalIndexName, TotalStepsNew)
        else
            TotalStepValuesDict.Add(TotalIndexName, TotalStepsNew);
    end;

    procedure GetTotalStep(IndexName: Text) TotalSteps: Integer
    begin
        if TotalStepValuesDict.Get(IndexName, TotalSteps) then;
        exit(TotalSteps);
    end;

    var
        IsProgressOpen: Boolean;
        LastUpdate: DateTime;
        Start: DateTime;
        Progress: Dialog;
        CustomStart: Dictionary of [Text, DateTime];
        ProgressBarNames, ProgressFieldNames : List of [Text];
        CurrStepValuesDict, TotalStepValuesDict : Dictionary of [Text, Integer];
        FieldControlValuesDict: Dictionary of [Integer, Text];
        BarControlValuesDict: Dictionary of [Integer, Integer];
        UpdateThresholdInMS: Integer;
        ProgressMsg: TextBuilder;
}
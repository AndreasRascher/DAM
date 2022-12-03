page 110015 DMTProcessingPlan
{
    Caption = 'DMT Processing Plan', Comment = 'de-DE=DMT Verarbeitungsplan';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = DMTProcessingPlan;
    AutoSplitKey = true;
    layout
    {
        area(Content)
        {
            repeater("Repeater")
            {
                IndentationColumn = Rec.Indentation;
                IndentationControls = Description;
                field("Line Type"; Rec.Type) { ApplicationArea = All; StyleExpr = LineStyle; }
                field(DataFileID; Rec.ID) { ApplicationArea = All; StyleExpr = LineStyle; BlankZero = true; }
                field(Description; Rec.Description) { ApplicationArea = All; StyleExpr = LineStyle; }
                field(ProcessingTime; Rec."Processing Duration") { ApplicationArea = All; StyleExpr = LineStyle; }
                field(StartTime; Rec.StartTime) { ApplicationArea = All; StyleExpr = LineStyle; }
                field(Status; Rec.Status) { ApplicationArea = All; StyleExpr = LineStyle; }
                field("Line No."; Rec."Line No.") { ApplicationArea = All; Visible = false; StyleExpr = LineStyle; }
            }
        }
        area(FactBoxes)
        {
            part(SourceTableFilter; "DMTProcessInstructionFactBox")
            {
                Caption = 'Source Table Filter', Comment = 'de-DE=Quelldaten Filter';
                SubPageLink = "Data File ID" = field(ID);
                UpdatePropagation = Both;
            }
            part(FixedValues; "DMTProcessInstructionFactBox")
            {
                Caption = 'Default Values', Comment = 'de-DE=Vorgabewerte';
                SubPageLink = "Data File ID" = field(ID);
                UpdatePropagation = Both;
            }
            part(UpdadeSelectedFields; "DMTProcessInstructionFactBox")
            {
                Caption = 'Update Selected Fields', Comment = 'de-DE=Felder für Update';
                SubPageLink = "Data File ID" = field(ID);
                UpdatePropagation = Both;
            }
        }
    }


    actions
    {
        area(Processing)
        {
            action(Start)
            {
                Caption = 'Start', comment = 'de-DE=Ausführen';
                ApplicationArea = All;
                Image = Start;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction();
                begin
                    GetSelection(ProcessingPlan_SELECTED);
                    RunSelected(ProcessingPlan_SELECTED);
                    CurrPage.Update(false);
                end;
            }
            action(IndentLeft)
            {
                Caption = 'Indent Left', comment = 'de-DE=Links einrücken';
                ApplicationArea = All;
                Image = PreviousRecord;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    GetSelection(ProcessingPlan_SELECTED);
                    IndentLines(ProcessingPlan_SELECTED, -1);
                    CurrPage.Update(false);
                end;
            }
            action(IndentRight)
            {
                Caption = 'Indent Right', comment = 'de-DE=Rechts einrücken';
                ApplicationArea = All;
                Image = NextRecord;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    GetSelection(ProcessingPlan_SELECTED);
                    IndentLines(ProcessingPlan_SELECTED, +1);
                    CurrPage.Update(false);
                end;
            }
            action(ResetLinesAction)
            {
                Caption = 'Reset Lines', comment = 'de-DE=Zeilen zurücksetzen';
                ApplicationArea = All;
                Image = NextRecord;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    GetSelection(ProcessingPlan_SELECTED);
                    ResetLines(ProcessingPlan_SELECTED);
                    CurrPage.Update(false);
                end;
            }
            action(RenumberLinesAction)
            {
                Caption = 'Renumber Lines', comment = 'de-DE=Zeilen neu nummerieren';
                ApplicationArea = All;
                Image = NumberGroup;
                trigger OnAction()
                begin
                    RenumberLines()
                end;
            }
        }
    }
    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        LineStyle := '';
    end;

    trigger OnAfterGetRecord()
    begin
        LineStyle := '';
        case true of
            (Rec.Type = Rec.Type::Group):
                LineStyle := format(Enum::DMTFieldStyle::Bold);
            (Rec.Status = Rec.Status::"In Progress"):
                LineStyle := format(Enum::DMTFieldStyle::Yellow);
            (Rec.Status = Rec.Status::Finished):
                LineStyle := format(Enum::DMTFieldStyle::"Bold + Green");
        end;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.SourceTableFilter.Page.InitFactBoxAsSourceTableFilter(Rec);
        CurrPage.FixedValues.Page.InitFactBoxAsFixedValueView(Rec);
        CurrPage.UpdadeSelectedFields.Page.InitFactBoxAsUpdateSelectedFields(Rec);
    end;

    local procedure RunSelected(var ProcessingPlan_SELECTED: Record DMTProcessingPlan temporary)
    var
        DMTDataFile: Record DMTDataFile;
        ProcessingPlan: record DMTProcessingPlan;
        ProcessStorage: Codeunit DMTProcessStorage;
        PageAction: Codeunit DMTDataFilePageAction;
        Success: Boolean;
    begin
        if not ProcessingPlan_SELECTED.FindSet then exit;
        ProcessStorage.Bind();
        repeat
            ProcessingPlan.Get(ProcessingPlan_SELECTED.RecordId);
            ProcessingPlan.TestField(ID);
            case ProcessingPlan.Type of
                DMTProcessingPlanType::" ", DMTProcessingPlanType::"Group":
                    ;
                DMTProcessingPlanType::"Import To Buffer":
                    begin
                        SetStatusToStartAndCommit(ProcessingPlan);
                        DMTDataFile.Get(ProcessingPlan.ID);
                        DMTDataFile.SetRecFilter();
                        PageAction.ImportToBufferTable(DMTDataFile, false);
                    end;
                DMTProcessingPlanType::"Import To Target":
                    begin
                        SetStatusToStartAndCommit(ProcessingPlan);
                        PageAction.RunWithProcessingPlanParams(ProcessingPlan);
                    end;
                DMTProcessingPlanType::"Run Codeunit":
                    begin
                        SetStatusToStartAndCommit(ProcessingPlan);
                        ClearLastError();
                        ProcessStorage.Set(ProcessingPlan);
                        Success := Codeunit.Run(ProcessingPlan.ID);
                        if GetLastErrorText() <> '' then
                            Message(GetLastErrorText());
                    end;
                DMTProcessingPlanType::"Update Field":
                    begin
                        SetStatusToStartAndCommit(ProcessingPlan);
                        PageAction.RunWithProcessingPlanParams(ProcessingPlan);
                    end;
            end;
            ProcessingPlan."Processing Duration" := CurrentDateTime - ProcessingPlan.StartTime;
            ProcessingPlan.Status := ProcessingPlan.Status::Finished;
            ProcessingPlan.Modify();
            Commit();
            ProcessStorage.Unbind();
        until ProcessingPlan_SELECTED.Next() = 0;
    end;

    local procedure ResetLines(var ProcessingPlan_SELECTED: Record DMTProcessingPlan temporary)
    var
        ProcessingPlan: record DMTProcessingPlan;
    begin
        if not ProcessingPlan_SELECTED.FindSet then exit;
        repeat
            ProcessingPlan.Get(ProcessingPlan_SELECTED.RecordId);
            Clear(ProcessingPlan.Status);
            Clear(ProcessingPlan.StartTime);
            Clear(ProcessingPlan."Processing Duration");
            ProcessingPlan.Modify();
            Commit();
        until ProcessingPlan_SELECTED.Next() = 0;
    end;

    local procedure SetStatusToStartAndCommit(var ProcessingPlan: record DMTProcessingPlan)
    begin
        ProcessingPlan.StartTime := CurrentDateTime;
        ProcessingPlan.Status := ProcessingPlan.Status::"In Progress";
        ProcessingPlan.Modify();
        Commit();
    end;

    local procedure RenumberLines()
    var
        ProcessingPlan: Record DMTProcessingPlan;
        LineNoMapping: Dictionary of [Integer, Integer];
        OldLineNo, NewLineNo : Integer;
    begin
        if not ProcessingPlan.FindSet() then exit;
        //Create Mapping
        repeat
            NewLineNo += 10000;
            LineNoMapping.Add(ProcessingPlan."Line No.", NewLineNo);
        until ProcessingPlan.Next() = 0;
        //Rename Lines
        while LineNoMapping.Count > 0 do begin
            foreach OldLineNo in LineNoMapping.Keys do begin
                // Remove from mapping if same line no
                NewLineNo := LineNoMapping.Get(OldLineNo);
                if OldLineNo = NewLineNo then
                    LineNoMapping.Remove(OldLineNo);
                // Rename Line to free line no, Remove From Mapping
                if not LineNoMapping.Keys.Contains(NewLineNo) then begin
                    ProcessingPlan.Get(OldLineNo);
                    ProcessingPlan.Rename(NewLineNo);
                    LineNoMapping.Remove(OldLineNo);
                end;
            end;
        end;
    end;

    procedure GetSelection(var TempProcessingPlan_Selected: Record DMTProcessingPlan temporary) HasLines: Boolean
    var
        ProcessingPlan: Record DMTProcessingPlan;
        Debug: Integer;
    begin
        Clear(TempProcessingPlan_Selected);
        if TempProcessingPlan_Selected.IsTemporary then
            TempProcessingPlan_Selected.DeleteAll();

        ProcessingPlan.Copy(rec); // if all fields are selected, no filter is applied but the view is also not applied
        CurrPage.SetSelectionFilter(ProcessingPlan);
        Debug := ProcessingPlan.Count;
        ProcessingPlan.CopyToTemp(TempProcessingPlan_Selected);
        HasLines := TempProcessingPlan_Selected.FindFirst();
    end;

    internal procedure IndentLines(var TempProcessingPLan: Record DMTProcessingPlan temporary; Direction: Integer)
    var
        ProcessingPlan: record DMTProcessingPlan;
    begin
        if not TempProcessingPLan.FindSet() then exit;
        repeat
            ProcessingPlan.Get(ProcessingPlan_SELECTED.RecordId);
            ProcessingPlan.Indentation += Direction;
            if ProcessingPlan.Indentation < 0 then
                ProcessingPlan.Indentation := 0;
            ProcessingPlan.Modify()
        until TempProcessingPLan.Next() = 0;
    end;

    // local procedure UpdateVisibility()
    // begin
    //     ShowSourceTableFilterPart := Rec.Type in [Rec.Type::"Import To Target", Rec.Type::"Update Field"];
    //     ShowFixedValuesPart := Rec.Type in [Rec.Type::"Import To Target", Rec.Type::"Update Field"];
    //     ShowUpdateSelectedFieldsPart := Rec.Type in [Rec.Type::"Import To Target", Rec.Type::"Update Field"];
    // end;

    var
        ProcessingPlan_SELECTED: record DMTProcessingPlan temporary;
        LineStyle: Text;
}